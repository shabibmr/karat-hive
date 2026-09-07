import { describe, expect, it, vi } from 'vitest';
import type { Device, Notification } from '@prisma/client';
import type { Env } from '../../../config/env';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { ObjectStorage } from '../../../platform/ports/storage.port';
import type { PushGateway } from '../../../platform/ports/push.port';
import { Clock } from '../../../shared/clock';
import { NotificationService } from './notification.service';
import { NotificationRepository } from '../repository/notification.repository';

describe('NotificationService', () => {
  const mockRepo = {
    listNotifications: vi.fn(),
    countUnread: vi.fn(),
    markAsRead: vi.fn(),
    markAllAsRead: vi.fn(),
    upsertDevice: vi.fn(),
    deleteDevice: vi.fn(),
    createNotification: vi.fn(),
    createDelivery: vi.fn(),
    findDispatchContext: vi.fn(),
    getFailedDeliveriesForRetry: vi.fn(),
    updateDelivery: vi.fn(),
    listDevicesForUser: vi.fn(),
    purgeNotificationsOlderThan: vi.fn(),
    findOrphanMediaOlderThan: vi.fn(),
    deleteMediaById: vi.fn(),
    findVendorProfileIdByUserId: vi.fn(),
    purgeIdempotencyKeysOlderThan: vi.fn(),
  } as unknown as NotificationRepository;

  const mockPrisma = {
    $transaction: vi.fn().mockImplementation((cb) => cb(mockPrisma)),
    user: {
      findUnique: vi.fn().mockResolvedValue({ preferredLanguage: 'en' }),
    },
  } as unknown as PrismaService;

  const mockClock = {
    now: () => new Date('2026-04-01T12:00:00Z'),
  } as Clock;

  const mockEnv = {
    SUPABASE_STORAGE_BUCKET_KYC: 'kyc',
  } as Env;

  const mockStorage = {
    deleteObject: vi.fn().mockResolvedValue(undefined),
  } as unknown as ObjectStorage;

  const mockPush = {
    send: vi.fn().mockResolvedValue({ status: 'SENT', providerRef: 'stub:fcm' }),
  } as unknown as PushGateway;

  const service = new NotificationService(
    mockRepo,
    mockPrisma,
    mockClock,
    mockEnv,
    mockStorage,
    mockPush,
  );

  it('lists notifications and returns localized title/body', async () => {
    vi.mocked(mockRepo.listNotifications).mockResolvedValueOnce({
      items: [
        {
          id: 'n-1',
          recipientUserId: 'user-1',
          type: 'offer.received',
          titleEn: 'New offer received',
          titleAr: 'تم استلام عرض جديد',
          bodyEn: 'A jeweller submitted an offer.',
          bodyAr: 'قام تاجر مجوهرات بتقديم عرض.',
          deepLink: '/requests/req-1',
          isCritical: false,
          readAt: null,
          createdAt: new Date('2026-04-01T10:00:00Z'),
        } as unknown as Notification,
      ],
      nextCursor: undefined,
    });

    const result = await service.listNotifications(
      { userId: 'user-1', role: 'CUSTOMER', accountState: 'ACTIVE' },
      {},
    );

    expect(result.data).toHaveLength(1);
    expect(result.data[0].title).toBe('New offer received');
    expect(result.data[0].readAt).toBeUndefined();
  });

  it('returns unread count', async () => {
    vi.mocked(mockRepo.countUnread).mockResolvedValueOnce(3);

    const result = await service.getUnreadCount({
      userId: 'user-1',
      role: 'CUSTOMER',
      accountState: 'ACTIVE',
    });

    expect(result.unreadCount).toBe(3);
  });

  it('marks single notification as read', async () => {
    vi.mocked(mockRepo.markAsRead).mockResolvedValueOnce({
      id: 'n-1',
      readAt: new Date('2026-04-01T12:00:00Z'),
    } as unknown as Notification);

    const result = await service.markAsRead(
      { userId: 'user-1', role: 'CUSTOMER', accountState: 'ACTIVE' },
      'n-1',
    );

    expect(result.id).toBe('n-1');
    expect(result.readAt).toBe('2026-04-01T12:00:00.000Z');
  });

  it('marks all notifications as read', async () => {
    vi.mocked(mockRepo.markAllAsRead).mockResolvedValueOnce(5);

    const result = await service.markAllAsRead({
      userId: 'user-1',
      role: 'CUSTOMER',
      accountState: 'ACTIVE',
    });

    expect(result.markedReadCount).toBe(5);
  });

  it('registers device push token (G2-I11)', async () => {
    vi.mocked(mockRepo.upsertDevice).mockResolvedValueOnce({
      id: 'dev-1',
      userId: 'user-1',
      platform: 'IOS',
      pushToken: 'token-xyz',
      label: 'iPhone 15',
      createdAt: new Date('2026-04-01T12:00:00Z'),
      updatedAt: new Date('2026-04-01T12:00:00Z'),
    } as unknown as Device);

    const result = await service.registerDevice(
      { userId: 'user-1', role: 'CUSTOMER', accountState: 'ACTIVE' },
      {
        platform: 'IOS',
        pushToken: 'token-xyz',
        label: 'iPhone 15',
      },
    );

    expect(result.id).toBe('dev-1');
    expect(result.platform).toBe('IOS');
    expect(result.pushToken).toBe('token-xyz');
  });

  it('deletes device push token', async () => {
    vi.mocked(mockRepo.deleteDevice).mockResolvedValueOnce(true);

    await expect(
      service.deleteDevice({ userId: 'user-1', role: 'CUSTOMER', accountState: 'ACTIVE' }, 'dev-1'),
    ).resolves.toBeUndefined();
  });

  it('runRetentionPurge clears notifications, orphan media, and idempotency keys (G2-N06)', async () => {
    vi.mocked(mockRepo.purgeNotificationsOlderThan).mockResolvedValueOnce(4);
    vi.mocked(mockRepo.findOrphanMediaOlderThan).mockResolvedValueOnce([
      {
        id: 'media-1',
        key: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        purpose: 'REQUEST_IMAGE',
        bucket: 'REQUEST_MEDIA',
        uploadedByUserId: 'user-1',
        thumbnailKey: null,
      },
    ]);
    vi.mocked(mockRepo.deleteMediaById).mockResolvedValueOnce(undefined);
    vi.mocked(mockRepo.purgeIdempotencyKeysOlderThan).mockResolvedValueOnce(7);

    const result = await service.runRetentionPurge();

    expect(result).toEqual({
      notificationsPurged: 4,
      orphanMediaPurged: 1,
      idempotencyKeysPurged: 7,
    });

    const now = new Date('2026-04-01T12:00:00Z');
    expect(mockRepo.purgeNotificationsOlderThan).toHaveBeenCalledWith(
      new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000),
    );
    expect(mockRepo.findOrphanMediaOlderThan).toHaveBeenCalledWith(
      new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000),
    );
    expect(mockRepo.purgeIdempotencyKeysOlderThan).toHaveBeenCalledWith(
      new Date(now.getTime() - 24 * 60 * 60 * 1000),
    );
    expect(mockStorage.deleteObject).toHaveBeenCalledWith(
      'request-media',
      'user/user-1/REQUEST_IMAGE/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    );
    expect(mockRepo.deleteMediaById).toHaveBeenCalledWith('media-1');
  });

  it('persists in-app even when push fails (FR-SYS-008.6)', async () => {
    vi.mocked(mockRepo.findDispatchContext).mockResolvedValueOnce({
      id: 'user-1',
      preferredLanguage: 'en',
      quietHoursStart: null,
      quietHoursEnd: null,
      notificationPreferences: [],
      devices: [{ id: 'dev-1', platform: 'ANDROID', pushToken: 'tok' }],
    });
    vi.mocked(mockRepo.createNotification).mockResolvedValueOnce({
      id: 'n-1',
    } as unknown as Notification);
    vi.mocked(mockRepo.createDelivery).mockResolvedValue({} as never);
    vi.mocked(mockPush.send).mockResolvedValueOnce({
      status: 'FAILED',
      error: 'upstream down',
    });

    const created = await service.deliver({
      recipientUserId: 'user-1',
      type: 'offer.submitted',
      category: 'offer.submitted',
      titleEn: 'You have a new Offer',
      titleAr: 'لديك عرض جديد',
      bodyEn: 'A Vendor submitted an Offer on your Request.',
      bodyAr: 'قدّم تاجر عرضاً على طلبك.',
      deepLink: '/requests/req-1/offers',
      isCritical: false,
      channels: ['IN_APP', 'PUSH'],
    });

    expect(created?.id).toBe('n-1');
    expect(mockRepo.createNotification).toHaveBeenCalled();
    expect(mockPush.send).toHaveBeenCalled();
    expect(mockRepo.createDelivery).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ channel: 'PUSH', status: 'FAILED' }),
    );
  });

  it('skips push during quiet hours but still writes in-app', async () => {
    // 18:00 UTC = 22:00 GST, inside 22:00–07:00
    const evening = new NotificationService(
      mockRepo,
      mockPrisma,
      { now: () => new Date('2026-04-01T18:00:00Z') } as Clock,
      mockEnv,
      mockStorage,
      mockPush,
    );
    vi.mocked(mockRepo.findDispatchContext).mockResolvedValueOnce({
      id: 'user-1',
      preferredLanguage: 'en',
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      notificationPreferences: [],
      devices: [{ id: 'dev-1', platform: 'IOS', pushToken: 'tok' }],
    });
    vi.mocked(mockRepo.createNotification).mockResolvedValueOnce({
      id: 'n-2',
    } as unknown as Notification);
    vi.mocked(mockRepo.createDelivery).mockResolvedValue({} as never);
    vi.mocked(mockPush.send).mockClear();

    await evening.deliver({
      recipientUserId: 'user-1',
      type: 'offer.submitted',
      category: 'offer.submitted',
      titleEn: 'You have a new Offer',
      titleAr: 'لديك عرض جديد',
      bodyEn: 'body',
      bodyAr: 'body-ar',
      deepLink: '/requests/req-1/offers',
      isCritical: false,
      channels: ['IN_APP', 'PUSH'],
    });

    expect(mockPush.send).not.toHaveBeenCalled();
    expect(mockRepo.createNotification).toHaveBeenCalled();
  });

  it('critical notifications bypass quiet hours and push preference', async () => {
    const evening = new NotificationService(
      mockRepo,
      mockPrisma,
      { now: () => new Date('2026-04-01T18:00:00Z') } as Clock,
      mockEnv,
      mockStorage,
      mockPush,
    );
    vi.mocked(mockRepo.findDispatchContext).mockResolvedValueOnce({
      id: 'user-1',
      preferredLanguage: 'en',
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      notificationPreferences: [{ category: 'security', inApp: false, push: false, email: false }],
      devices: [{ id: 'dev-1', platform: 'ANDROID', pushToken: 'tok' }],
    });
    vi.mocked(mockRepo.createNotification).mockResolvedValueOnce({
      id: 'n-3',
    } as unknown as Notification);
    vi.mocked(mockRepo.createDelivery).mockResolvedValue({} as never);
    vi.mocked(mockPush.send).mockClear();
    vi.mocked(mockPush.send).mockResolvedValueOnce({ status: 'SENT', providerRef: 'stub:fcm' });

    await evening.deliver({
      recipientUserId: 'user-1',
      type: 'security',
      category: 'security',
      titleEn: 'Security alert',
      titleAr: 'تنبيه أمني',
      bodyEn: 'body',
      bodyAr: 'body-ar',
      deepLink: '/settings/security',
      isCritical: true,
      channels: ['IN_APP', 'PUSH'],
    });

    expect(mockPush.send).toHaveBeenCalledOnce();
  });
});
