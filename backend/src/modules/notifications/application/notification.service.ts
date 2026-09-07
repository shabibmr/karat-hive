import { HttpStatus, Inject, Injectable, Logger } from '@nestjs/common';
import type { DevicePlatform, MediaPurpose, Prisma, StorageBucket } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { ENV, type Env } from '../../../config/env';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { OBJECT_STORAGE, type ObjectStorage } from '../../../platform/ports/storage.port';
import { PUSH_GATEWAY, type PushGateway } from '../../../platform/ports/push.port';
import { isWithinQuietHours } from '../domain/quiet-hours';
import type { Channel } from '../domain/notification.plans';
import { presentNotification, type NotificationView } from '../presenter/notification.presenter';
import { NotificationRepository } from '../repository/notification.repository';

export type DeliverNotificationInput = {
  recipientUserId: string;
  type: string;
  category: string;
  titleEn: string;
  titleAr: string;
  bodyEn: string;
  bodyAr: string;
  deepLink: string;
  isCritical: boolean;
  channels: Channel[];
};

export interface RegisterDeviceDto {
  platform: 'IOS' | 'ANDROID';
  pushToken: string;
  label?: string;
}

export type RetentionPurgeResult = {
  notificationsPurged: number;
  orphanMediaPurged: number;
  idempotencyKeysPurged: number;
};

const MS_PER_DAY = 24 * 60 * 60 * 1000;

function storageBucketId(bucket: StorageBucket, env: Env): string {
  switch (bucket) {
    case 'KYC':
      return env.SUPABASE_STORAGE_BUCKET_KYC;
    case 'REQUEST_MEDIA':
      return 'request-media';
    case 'EXPORT':
      return 'export';
  }
}

/** Mirrors media storagePath — kept local to avoid a notifications→media module edge. */
function objectKeyFor(
  purpose: MediaPurpose,
  key: string,
  ownerUserId: string,
  vendorProfileId: string | null,
): string {
  if (purpose === 'KYC_DOCUMENT') {
    return `vendor/${vendorProfileId ?? ownerUserId}/KYC_DOCUMENT/${key}`;
  }
  return `user/${ownerUserId}/${purpose}/${key}`;
}

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(
    private readonly repo: NotificationRepository,
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
    @Inject(ENV) private readonly env: Env,
    @Inject(OBJECT_STORAGE) private readonly storage: ObjectStorage,
    @Inject(PUSH_GATEWAY) private readonly push: PushGateway,
  ) {}

  async listNotifications(
    viewer: ViewerContext,
    options: { unread?: boolean; limit?: number; cursor?: string },
  ): Promise<{ data: NotificationView[]; pagination: { nextCursor?: string } }> {
    const user = await this.prisma.user.findUnique({
      where: { id: viewer.userId },
      select: { preferredLanguage: true },
    });
    const lang = (user?.preferredLanguage ?? 'en') as 'en' | 'ar';

    const { items, nextCursor } = await this.repo.listNotifications(viewer.userId, options);

    const data = items.map((item) => presentNotification(item, lang));
    return {
      data,
      pagination: {
        nextCursor,
      },
    };
  }

  async getUnreadCount(viewer: ViewerContext): Promise<{ unreadCount: number }> {
    const unreadCount = await this.repo.countUnread(viewer.userId);
    return { unreadCount };
  }

  async markAsRead(
    viewer: ViewerContext,
    notificationId: string,
  ): Promise<{ id: string; readAt: string }> {
    const notif = await this.repo.markAsRead(viewer.userId, notificationId);
    if (!notif) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return {
      id: notif.id,
      readAt: (notif.readAt ?? this.clock.now()).toISOString(),
    };
  }

  async markAllAsRead(viewer: ViewerContext): Promise<{ markedReadCount: number }> {
    const markedReadCount = await this.repo.markAllAsRead(viewer.userId);
    return { markedReadCount };
  }

  async registerDevice(viewer: ViewerContext, dto: RegisterDeviceDto) {
    const device = await this.repo.upsertDevice(
      viewer.userId,
      dto.platform as DevicePlatform,
      dto.pushToken,
      dto.label,
    );
    return {
      id: device.id,
      platform: device.platform,
      pushToken: device.pushToken,
      label: device.label,
      createdAt: device.createdAt.toISOString(),
    };
  }

  async deleteDevice(viewer: ViewerContext, deviceId: string): Promise<void> {
    const deleted = await this.repo.deleteDevice(viewer.userId, deviceId);
    if (!deleted) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
  }

  async createInAppNotification(
    recipientUserId: string,
    data: {
      type: string;
      titleEn: string;
      titleAr: string;
      bodyEn: string;
      bodyAr: string;
      deepLink: string;
      isCritical?: boolean;
    },
  ) {
    return this.deliver({
      recipientUserId,
      type: data.type,
      category: data.type,
      titleEn: data.titleEn,
      titleAr: data.titleAr,
      bodyEn: data.bodyEn,
      bodyAr: data.bodyAr,
      deepLink: data.deepLink,
      isCritical: data.isCritical ?? false,
      channels: ['IN_APP'],
    });
  }

  /**
   * Persist the in-app row regardless of push outcome (FR-SYS-008.6).
   * Quiet hours and preferences are evaluated here, at dispatch time (FR-SYS-008.2).
   */
  async deliver(input: DeliverNotificationInput) {
    const ctx = await this.repo.findDispatchContext(input.recipientUserId);
    if (!ctx) {
      this.logger.warn(`Dispatch skipped; user ${input.recipientUserId} missing`);
      return null;
    }

    const pref = ctx.notificationPreferences.find((row) => row.category === input.category);
    const quietStart = ctx.quietHoursStart;
    const quietEnd = ctx.quietHoursEnd;
    const quiet =
      !input.isCritical &&
      quietStart !== null &&
      quietEnd !== null &&
      isWithinQuietHours(this.clock.now(), quietStart, quietEnd);

    const allowPush =
      input.channels.includes('PUSH') && (input.isCritical || ((pref?.push ?? true) && !quiet));

    const lang = ctx.preferredLanguage === 'ar' ? 'ar' : 'en';
    const now = this.clock.now();
    const channelsSent: string[] = ['IN_APP'];
    if (allowPush) channelsSent.push('PUSH');

    const notif = await this.prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      const created = await this.repo.createNotification(tx, {
        recipientUserId: input.recipientUserId,
        type: input.type,
        titleEn: input.titleEn,
        titleAr: input.titleAr,
        bodyEn: input.bodyEn,
        bodyAr: input.bodyAr,
        deepLink: input.deepLink,
        isCritical: input.isCritical,
        channelsSent,
      });

      await this.repo.createDelivery(tx, {
        notificationId: created.id,
        channel: 'IN_APP',
        attempt: 1,
        status: 'DELIVERED',
        attemptedAt: now,
      });

      return created;
    });

    if (allowPush) {
      const title = lang === 'ar' ? input.titleAr : input.titleEn;
      const body = lang === 'ar' ? input.bodyAr : input.bodyEn;
      for (const device of ctx.devices) {
        const result = await this.push.send(
          { token: device.pushToken, platform: device.platform },
          { title, body, deepLink: input.deepLink, data: { type: input.type } },
        );
        await this.repo.createDelivery(this.prisma, {
          notificationId: notif.id,
          channel: 'PUSH',
          attempt: 1,
          status:
            result.status === 'SENT' ? 'SENT' : result.status === 'BOUNCED' ? 'BOUNCED' : 'FAILED',
          providerRef: result.providerRef ?? null,
          lastError: result.error ?? null,
          attemptedAt: this.clock.now(),
        });
      }
    }

    return notif;
  }

  async retryFailedDeliveries(): Promise<number> {
    const failed = await this.repo.getFailedDeliveriesForRetry();
    let retried = 0;
    const now = this.clock.now();

    for (const item of failed) {
      try {
        if (item.channel === 'PUSH') {
          const devices = await this.repo.listDevicesForUser(item.notification.recipientUserId);
          const title = item.notification.titleEn;
          const body = item.notification.bodyEn;
          let anySent = false;
          let lastError: string | null = null;
          for (const device of devices) {
            const result = await this.push.send(
              { token: device.pushToken, platform: device.platform },
              {
                title,
                body,
                deepLink: item.notification.deepLink,
                data: { type: item.notification.type },
              },
            );
            if (result.status === 'SENT') anySent = true;
            else lastError = result.error ?? lastError;
          }
          await this.repo.updateDelivery(item.id, {
            attempt: item.attempt + 1,
            status: anySent || devices.length === 0 ? 'SENT' : 'FAILED',
            lastError: anySent ? null : lastError,
            attemptedAt: now,
          });
        } else {
          await this.repo.updateDelivery(item.id, {
            attempt: item.attempt + 1,
            status: 'FAILED',
            lastError: `no adapter for channel ${item.channel}`,
            attemptedAt: now,
          });
        }
        retried++;
      } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : String(err);
        await this.repo.updateDelivery(item.id, {
          attempt: item.attempt + 1,
          status: 'FAILED',
          lastError: msg,
          attemptedAt: now,
        });
      }
    }

    return retried;
  }

  async purgeOldNotifications(retentionDays = 90): Promise<number> {
    const threshold = new Date(this.clock.now().getTime() - retentionDays * MS_PER_DAY);
    return this.repo.purgeNotificationsOlderThan(threshold);
  }

  /**
   * G2-N06 / `retention-purge` (daily): notifications >90 d, orphan media >30 d,
   * idempotency_key >24 h. Audit is never purged (NFR-021). Idempotent.
   */
  async runRetentionPurge(): Promise<RetentionPurgeResult> {
    const now = this.clock.now();
    const notificationsThreshold = new Date(now.getTime() - 90 * MS_PER_DAY);
    const orphanMediaThreshold = new Date(now.getTime() - 30 * MS_PER_DAY);
    const idempotencyThreshold = new Date(now.getTime() - MS_PER_DAY);

    const notificationsPurged = await this.repo.purgeNotificationsOlderThan(notificationsThreshold);
    const orphanMediaPurged = await this.purgeOrphanMedia(orphanMediaThreshold);
    const idempotencyKeysPurged =
      await this.repo.purgeIdempotencyKeysOlderThan(idempotencyThreshold);

    // Audit log is intentionally never touched (NFR-021 / AD-BE-13).
    return {
      notificationsPurged,
      orphanMediaPurged,
      idempotencyKeysPurged,
    };
  }

  private async purgeOrphanMedia(olderThan: Date): Promise<number> {
    const orphans = await this.repo.findOrphanMediaOlderThan(olderThan);
    let purged = 0;

    for (const media of orphans) {
      try {
        if (media.uploadedByUserId) {
          const vendorProfileId =
            media.purpose === 'KYC_DOCUMENT'
              ? await this.repo.findVendorProfileIdByUserId(media.uploadedByUserId)
              : null;
          const objectKey = objectKeyFor(
            media.purpose,
            media.key,
            media.uploadedByUserId,
            vendorProfileId,
          );
          await this.storage.deleteObject(storageBucketId(media.bucket, this.env), objectKey);
          if (media.thumbnailKey) {
            await this.storage
              .deleteObject(storageBucketId(media.bucket, this.env), media.thumbnailKey)
              .catch(() => undefined);
          }
        }
        await this.repo.deleteMediaById(media.id);
        purged++;
      } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : String(err);
        this.logger.warn(`Orphan media purge failed id=${media.id}: ${msg}`);
      }
    }

    return purged;
  }
}
