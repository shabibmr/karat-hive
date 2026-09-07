import { Injectable } from '@nestjs/common';
import type {
  DevicePlatform,
  Notification,
  NotificationChannel,
  NotificationDelivery,
  NotificationDeliveryStatus,
  Prisma,
  UserAccountState,
  UserType,
} from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';

export type DispatchContext = {
  id: string;
  preferredLanguage: 'en' | 'ar' | string;
  quietHoursStart: string | null;
  quietHoursEnd: string | null;
  notificationPreferences: Array<{
    category: string;
    inApp: boolean;
    push: boolean;
    email: boolean;
  }>;
  devices: Array<{
    id: string;
    platform: DevicePlatform;
    pushToken: string;
  }>;
};

export type AnnouncementAudience = {
  userTypes?: UserType[];
  accountStates?: UserAccountState[];
  regionIds?: string[];
  categoryIds?: string[];
};

@Injectable()
export class NotificationRepository {
  constructor(private readonly prisma: PrismaService) {}

  async listNotifications(
    userId: string,
    options: { unread?: boolean; limit?: number; cursor?: string },
  ) {
    const limit = Math.min(options.limit ?? 20, 50);
    const where: Prisma.NotificationWhereInput = {
      recipientUserId: userId,
      ...(options.unread ? { readAt: null } : {}),
    };

    const items = await this.prisma.notification.findMany({
      where,
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const nextItem = items.pop();
      nextCursor = nextItem?.id;
    }

    return { items, nextCursor };
  }

  async countUnread(userId: string): Promise<number> {
    return this.prisma.notification.count({
      where: {
        recipientUserId: userId,
        readAt: null,
      },
    });
  }

  async markAsRead(userId: string, notificationId: string): Promise<Notification | null> {
    const notif = await this.prisma.notification.findFirst({
      where: { id: notificationId, recipientUserId: userId },
    });
    if (!notif) return null;

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { readAt: new Date() },
    });
  }

  async markAllAsRead(userId: string): Promise<number> {
    const res = await this.prisma.notification.updateMany({
      where: {
        recipientUserId: userId,
        readAt: null,
      },
      data: { readAt: new Date() },
    });
    return res.count;
  }

  async createNotification(
    tx: Prisma.TransactionClient,
    data: {
      recipientUserId: string;
      type: string;
      titleEn: string;
      titleAr: string;
      bodyEn: string;
      bodyAr: string;
      deepLink: string;
      isCritical?: boolean;
      channelsSent?: Prisma.InputJsonValue;
    },
  ): Promise<Notification> {
    return tx.notification.create({
      data: {
        recipientUserId: data.recipientUserId,
        type: data.type,
        titleEn: data.titleEn,
        titleAr: data.titleAr,
        bodyEn: data.bodyEn,
        bodyAr: data.bodyAr,
        deepLink: data.deepLink,
        isCritical: data.isCritical ?? false,
        channelsSent: data.channelsSent,
      },
    });
  }

  async createDelivery(
    tx: Prisma.TransactionClient | PrismaService,
    data: {
      notificationId: string;
      channel: NotificationChannel;
      attempt: number;
      status: NotificationDeliveryStatus;
      providerRef?: string | null;
      lastError?: string | null;
      attemptedAt: Date;
    },
  ): Promise<NotificationDelivery> {
    return tx.notificationDelivery.create({
      data: {
        notificationId: data.notificationId,
        channel: data.channel,
        attempt: data.attempt,
        status: data.status,
        providerRef: data.providerRef,
        lastError: data.lastError,
        attemptedAt: data.attemptedAt,
      },
    });
  }

  async getFailedDeliveriesForRetry(): Promise<
    (NotificationDelivery & { notification: Notification })[]
  > {
    return this.prisma.notificationDelivery.findMany({
      where: {
        status: 'FAILED',
        attempt: { lt: 3 },
      },
      include: {
        notification: true,
      },
      take: 50,
    });
  }

  async updateDelivery(
    id: string,
    data: {
      attempt: number;
      status: NotificationDeliveryStatus;
      lastError?: string | null;
      attemptedAt: Date;
    },
  ) {
    return this.prisma.notificationDelivery.update({
      where: { id },
      data,
    });
  }

  async upsertDevice(userId: string, platform: DevicePlatform, pushToken: string, label?: string) {
    return this.prisma.device.upsert({
      where: { pushToken },
      update: {
        userId,
        platform,
        label,
      },
      create: {
        userId,
        platform,
        pushToken,
        label,
      },
    });
  }

  async deleteDevice(userId: string, deviceId: string): Promise<boolean> {
    const dev = await this.prisma.device.findFirst({
      where: { id: deviceId, userId },
    });
    if (!dev) return false;
    await this.prisma.device.delete({ where: { id: deviceId } });
    return true;
  }

  async listDevicesForUser(userId: string) {
    return this.prisma.device.findMany({
      where: { userId },
    });
  }

  async findDispatchContext(userId: string): Promise<DispatchContext | null> {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        preferredLanguage: true,
        quietHoursStart: true,
        quietHoursEnd: true,
        notificationPreferences: {
          select: { category: true, inApp: true, push: true, email: true },
        },
        devices: { select: { id: true, platform: true, pushToken: true } },
      },
    });
  }

  async findVendorUserIdsByProfileIds(profileIds: string[]): Promise<string[]> {
    if (profileIds.length === 0) return [];
    const rows = await this.prisma.vendorProfile.findMany({
      where: { id: { in: profileIds } },
      select: { userId: true },
    });
    return unique(rows.map((row) => row.userId));
  }

  async findVendorUserIdsByOfferIds(offerIds: string[]): Promise<string[]> {
    if (offerIds.length === 0) return [];
    const rows = await this.prisma.offer.findMany({
      where: { id: { in: offerIds } },
      select: { vendorProfile: { select: { userId: true } } },
    });
    return unique(rows.map((row) => row.vendorProfile.userId));
  }

  async findPendingOfferVendorUserIds(requestId: string): Promise<string[]> {
    const rows = await this.prisma.offer.findMany({
      where: { requestId, state: 'PENDING' },
      select: { vendorProfile: { select: { userId: true } } },
    });
    return unique(rows.map((row) => row.vendorProfile.userId));
  }

  async findOfferVendorUserIdsForRequest(requestId: string): Promise<string[]> {
    const rows = await this.prisma.offer.findMany({
      where: { requestId },
      select: { vendorProfile: { select: { userId: true } } },
    });
    return unique(rows.map((row) => row.vendorProfile.userId));
  }

  async findAdminUserIds(): Promise<string[]> {
    const rows = await this.prisma.user.findMany({
      where: { userType: 'ADMIN', accountState: 'ACTIVE', deletedAt: null },
      select: { id: true },
    });
    return rows.map((row) => row.id);
  }

  async findAnnouncement(id: string) {
    return this.prisma.announcement.findUnique({ where: { id } });
  }

  async updateAnnouncementDispatchStats(
    id: string,
    stats: { sent: number; delivered: number; opened: number },
  ): Promise<void> {
    await this.prisma.announcement.update({
      where: { id },
      data: { dispatchStats: stats },
    });
  }

  async findAudienceUserIds(audience: AnnouncementAudience): Promise<string[]> {
    const accountStates = audience.accountStates ?? ['ACTIVE'];
    const where: Prisma.UserWhereInput = {
      accountState: { in: accountStates },
      deletedAt: null,
      ...(audience.userTypes?.length ? { userType: { in: audience.userTypes } } : {}),
    };

    const regionIds = audience.regionIds ?? [];
    const categoryIds = audience.categoryIds ?? [];
    if (regionIds.length > 0 || categoryIds.length > 0) {
      const or: Prisma.UserWhereInput[] = [];
      if (regionIds.length > 0) {
        or.push({ customerProfile: { defaultRegionId: { in: regionIds } } });
        or.push({
          vendorProfile: { regions: { some: { regionId: { in: regionIds } } } },
        });
      }
      if (categoryIds.length > 0) {
        or.push({
          vendorProfile: { categories: { some: { categoryId: { in: categoryIds } } } },
        });
      }
      where.OR = or;
    }

    const rows = await this.prisma.user.findMany({
      where,
      select: { id: true },
    });
    return rows.map((row) => row.id);
  }

  async purgeNotificationsOlderThan(date: Date): Promise<number> {
    const res = await this.prisma.notification.deleteMany({
      where: {
        createdAt: { lt: date },
      },
    });
    return res.count;
  }

  /** Media with no remaining attachments, older than threshold (FR-SYS-009.6). */
  async findOrphanMediaOlderThan(date: Date) {
    return this.prisma.media.findMany({
      where: {
        createdAt: { lt: date },
        requestMedia: { none: {} },
        offerMedia: { none: {} },
        vendorDocuments: { none: {} },
        customerPhotos: { none: {} },
        vendorLogos: { none: {} },
        exportJobs: { none: {} },
        dataSubjectCerts: { none: {} },
      },
      select: {
        id: true,
        key: true,
        purpose: true,
        bucket: true,
        uploadedByUserId: true,
        thumbnailKey: true,
      },
    });
  }

  async deleteMediaById(id: string): Promise<void> {
    await this.prisma.media.delete({ where: { id } });
  }

  async findVendorProfileIdByUserId(userId: string): Promise<string | null> {
    const profile = await this.prisma.vendorProfile.findUnique({
      where: { userId },
      select: { id: true },
    });
    return profile?.id ?? null;
  }

  async purgeIdempotencyKeysOlderThan(date: Date): Promise<number> {
    const res = await this.prisma.idempotencyKey.deleteMany({
      where: {
        createdAt: { lt: date },
      },
    });
    return res.count;
  }
}

function unique(values: string[]): string[] {
  return [...new Set(values)];
}
