import { randomUUID } from 'node:crypto';
import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import type { Media, MediaPurpose, StorageBucket } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { ENV, type Env } from '../../../config/env';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { OBJECT_STORAGE, type ObjectStorage } from '../../../platform/ports/storage.port';
import { AuditWriter } from '../../audit';
import {
  MEDIA_CONSTRAINTS,
  isByteSizeAllowed,
  isContentTypeAllowed,
  storagePath,
} from '../domain/media-rules';
import { MediaRepository } from '../repository/media.repository';
import { presentMediaRef, type MediaRef, type UploadIntent } from '../presenter/media.presenter';

/** Which real storage bucket each StorageBucket enum value maps to. */
function bucketId(bucket: StorageBucket, env: Env): string {
  switch (bucket) {
    case 'KYC':
      return env.SUPABASE_STORAGE_BUCKET_KYC;
    case 'REQUEST_MEDIA':
      return 'request-media';
    case 'EXPORT':
      return 'export';
  }
}

@Injectable()
export class MediaService {
  constructor(
    @Inject(ENV) private readonly env: Env,
    @Inject(OBJECT_STORAGE) private readonly storage: ObjectStorage,
    private readonly prisma: PrismaService,
    private readonly repo: MediaRepository,
    private readonly audit: AuditWriter,
  ) {}

  /** API `key` stays a UUID (`media.key` varchar 64). Object storage uses the scoped path. */
  objectKeyFor(purpose: MediaPurpose, apiKey: string, viewer: ViewerContext): string {
    return storagePath({
      purpose,
      key: apiKey,
      vendorProfileId: viewer.vendorProfileId,
      ownerUserId: viewer.userId,
    });
  }

  async createIntent(
    viewer: ViewerContext,
    dto: { purpose: MediaPurpose; contentType: string; byteSize: number },
  ): Promise<UploadIntent> {
    if (dto.purpose === 'KYC_DOCUMENT' && viewer.role !== 'VENDOR') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
    if (!isContentTypeAllowed(dto.purpose, dto.contentType)) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.MEDIA_TYPE_REJECTED, [
        { path: 'contentType', code: 'NOT_ALLOWED', message: 'This file type is not accepted.' },
      ]);
    }
    if (!isByteSizeAllowed(dto.purpose, dto.byteSize)) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.MEDIA_TYPE_REJECTED, [
        { path: 'byteSize', code: 'TOO_LARGE', message: 'This file is too large.' },
      ]);
    }

    const constraint = MEDIA_CONSTRAINTS[dto.purpose];
    const key = randomUUID();
    const objectKey = this.objectKeyFor(dto.purpose, key, viewer);
    const signed = await this.storage.createSignedUploadUrl({
      bucket: bucketId(constraint.bucket, this.env),
      key: objectKey,
      contentType: dto.contentType,
      maxBytes: constraint.maxBytes,
      ttlSeconds: this.env.SIGNED_UPLOAD_TTL_SECONDS,
    });

    const row = await withTx(this.prisma, async (tx) => {
      const created = await this.repo.create(
        {
          key,
          purpose: dto.purpose,
          bucket: constraint.bucket,
          contentType: dto.contentType,
          byteSize: dto.byteSize,
          uploadedByUserId: viewer.userId,
        },
        tx,
      );
      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'KYC_UPLOAD_INTENT',
        entityType: 'media',
        entityId: created.id,
        afterValue: { key, purpose: dto.purpose, objectKey },
      });
      return created;
    });

    return {
      key: row.key,
      uploadUrl: signed.uploadUrl,
      requiredHeaders: signed.requiredHeaders,
      maxBytes: constraint.maxBytes,
      expiresAt: signed.expiresAt.toISOString(),
    };
  }

  async complete(viewer: ViewerContext, key: string): Promise<MediaRef> {
    const media = await this.repo.findByKey(key);
    if (!media || media.uploadedByUserId !== viewer.userId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    if (media.state === 'READY' || media.state === 'PENDING_PROCESSING') {
      return presentMediaRef(media);
    }
    if (media.state !== 'PENDING_UPLOAD') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.UPLOAD_NOT_COMPLETED);
    }

    const objectKey = this.objectKeyFor(media.purpose, key, viewer);
    const head = await this.storage.headObject(bucketId(media.bucket, this.env), objectKey);
    if (!head || !head.exists) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.UPLOAD_NOT_COMPLETED);
    }
    if (head.contentType && head.contentType.split(';')[0] !== media.contentType) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.UPLOAD_NOT_COMPLETED, [
        { path: 'contentType', code: 'MISMATCH', message: 'Uploaded file type does not match.' },
      ]);
    }
    if (typeof head.size === 'number' && head.size !== media.byteSize) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.UPLOAD_NOT_COMPLETED, [
        { path: 'byteSize', code: 'MISMATCH', message: 'Uploaded file size does not match.' },
      ]);
    }

    // Dev shortcut (P4/T17 pending): no async EXIF/malware worker yet — KYC documents
    // move straight to READY on a verified upload.
    const devReady = this.env.NODE_ENV !== 'production';
    const updated = await withTx(this.prisma, async (tx) => {
      const row = await this.repo.markState(tx, key, devReady ? 'READY' : 'PENDING_PROCESSING', {
        malwareScanState: devReady ? 'CLEAN' : 'PENDING',
        exifStripped: devReady,
      });
      await enqueueOutbox(tx, {
        eventType: 'media.uploaded',
        aggregateType: 'media',
        aggregateId: row.id,
        payload: { key: row.key, purpose: row.purpose, bucket: row.bucket },
      });
      return row;
    });
    return presentMediaRef(updated);
  }

  async remove(viewer: ViewerContext, key: string): Promise<void> {
    const media = await this.repo.findByKey(key);
    if (!media || media.uploadedByUserId !== viewer.userId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    const attached = await this.repo.countAttachments(media.id);
    if (attached > 0) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT, [
        { path: 'key', code: 'ATTACHED', message: 'Media is attached and cannot be deleted.' },
      ]);
    }
    const objectKey = this.objectKeyFor(media.purpose, key, viewer);
    await this.storage.deleteObject(bucketId(media.bucket, this.env), objectKey);
    await this.repo.deleteByKey(key);
  }

  /** module-public: fetch a caller-owned media row usable as an attachment. */
  async getAttachable(key: string, ownerUserId: string): Promise<Media> {
    const media = await this.repo.findByKey(key);
    if (!media || media.uploadedByUserId !== ownerUserId) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.UPLOAD_NOT_COMPLETED, [
        { path: 'mediaKey', code: 'UNKNOWN', message: 'Unknown upload.' },
      ]);
    }
    if (media.state === 'QUARANTINED') {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.MEDIA_QUARANTINED);
    }
    if (media.state === 'PENDING_UPLOAD' || media.state === 'FAILED') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.UPLOAD_NOT_COMPLETED);
    }
    return media;
  }
}
