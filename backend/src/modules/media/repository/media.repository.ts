import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { Media, MediaPurpose, MediaState, StorageBucket } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';

@Injectable()
export class MediaRepository {
  constructor(private readonly prisma: PrismaService) {}

  create(
    input: {
      key: string;
      purpose: MediaPurpose;
      bucket: StorageBucket;
      contentType: string;
      byteSize: number;
      uploadedByUserId: string;
    },
    tx?: DbTx,
  ): Promise<Media> {
    const client = tx ?? this.prisma;
    return client.media.create({
      data: {
        key: input.key,
        purpose: input.purpose,
        bucket: input.bucket,
        contentType: input.contentType,
        byteSize: input.byteSize,
        state: 'PENDING_UPLOAD',
        uploadedByUserId: input.uploadedByUserId,
      },
    });
  }

  countAttachments(mediaId: string): Promise<number> {
    return this.prisma.vendorDocument.count({ where: { mediaId } });
  }

  findByKey(key: string): Promise<Media | null> {
    return this.prisma.media.findUnique({ where: { key } });
  }

  markState(
    tx: DbTx,
    key: string,
    state: MediaState,
    extra?: Prisma.MediaUncheckedUpdateInput,
  ): Promise<Media> {
    return tx.media.update({
      where: { key },
      data: { state, ...extra },
    });
  }

  async deleteByKey(key: string): Promise<void> {
    await this.prisma.media.delete({ where: { key } });
  }
}
