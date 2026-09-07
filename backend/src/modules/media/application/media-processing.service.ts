import { Inject, Injectable, Logger } from '@nestjs/common';
import type { Media, Prisma } from '@prisma/client';
import { ENV, type Env } from '../../../config/env';
import { OBJECT_STORAGE, type ObjectStorage } from '../../../platform/ports/storage.port';
import { processMediaBytes } from '../domain/media-pipeline';
import { physicalBucketName, storagePath, thumbnailStorageKey } from '../domain/media-rules';
import { MediaRepository } from '../repository/media.repository';

export type MediaUploadedEvent = {
  id: string;
  aggregateId: string;
  payload: Prisma.JsonValue;
};

/**
 * `media:process` worker (Async-Contract §4.19 / FR-SYS-009).
 * Idempotent on media.id — already READY or QUARANTINED is a no-op.
 */
@Injectable()
export class MediaProcessingService {
  private readonly logger = new Logger(MediaProcessingService.name);

  constructor(
    @Inject(ENV) private readonly env: Env,
    @Inject(OBJECT_STORAGE) private readonly storage: ObjectStorage,
    private readonly repo: MediaRepository,
  ) {}

  async processUploaded(event: MediaUploadedEvent): Promise<void> {
    const payload = asRecord(event.payload);
    const media = await this.loadMedia(event.aggregateId, payload);
    if (!media) {
      this.logger.warn(
        `media.uploaded with no row: eventId=${event.id} aggregate=${event.aggregateId}`,
      );
      return;
    }
    if (media.state === 'READY' || media.state === 'QUARANTINED') {
      return;
    }
    if (media.state !== 'PENDING_PROCESSING') {
      this.logger.warn(`Skipping media ${media.id} in state ${media.state}`);
      return;
    }

    const objectKey = this.objectKeyOf(media, payload);
    const bucket = physicalBucketName(media.bucket, this.env.SUPABASE_STORAGE_BUCKET_KYC);
    const bytes = await this.storage.getObject(bucket, objectKey);
    if (!bytes) {
      throw new Error(`media object missing bucket=${bucket} key=${objectKey}`);
    }

    const result = processMediaBytes(bytes, media.contentType);
    if (result.action === 'quarantine') {
      await this.repo.updateByKey(media.key, {
        state: 'QUARANTINED',
        malwareScanState: 'QUARANTINED',
      });
      this.logger.warn(`Quarantined media ${media.id} reason=${result.reason}`);
      return;
    }

    await this.storage.putObject(bucket, objectKey, result.cleaned, media.contentType);

    let thumbnailKey: string | null = null;
    if (result.makeThumbnail) {
      thumbnailKey = thumbnailStorageKey(media.key);
      await this.storage.putObject(bucket, thumbnailKey, result.cleaned, media.contentType);
    }

    await this.repo.updateByKey(media.key, {
      state: 'READY',
      malwareScanState: 'CLEAN',
      exifStripped: true,
      thumbnailKey,
      byteSize: result.cleaned.length,
    });
  }

  private async loadMedia(
    aggregateId: string,
    payload: Record<string, unknown>,
  ): Promise<Media | null> {
    const byId = await this.repo.findById(aggregateId);
    if (byId) return byId;
    const key = typeof payload.key === 'string' ? payload.key : null;
    if (!key) return null;
    return this.repo.findByKey(key);
  }

  private objectKeyOf(media: Media, payload: Record<string, unknown>): string {
    if (typeof payload.objectKey === 'string' && payload.objectKey.length > 0) {
      return payload.objectKey;
    }
    return storagePath({
      purpose: media.purpose,
      key: media.key,
      ownerUserId: media.uploadedByUserId ?? 'unknown',
    });
  }
}

function asRecord(value: Prisma.JsonValue): Record<string, unknown> {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return {};
}
