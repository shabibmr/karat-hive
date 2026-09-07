import type { Notification } from '@prisma/client';

export interface NotificationView {
  id: string;
  type: string;
  title: string;
  body: string;
  deepLink: string;
  isCritical: boolean;
  readAt?: string;
  createdAt: string;
}

export function presentNotification(
  notification: Notification,
  language: 'en' | 'ar' = 'en',
): NotificationView {
  const isAr = language === 'ar';
  return {
    id: notification.id,
    type: notification.type,
    title: isAr ? notification.titleAr : notification.titleEn,
    body: isAr ? notification.bodyAr : notification.bodyEn,
    deepLink: notification.deepLink,
    isCritical: notification.isCritical,
    ...(notification.readAt ? { readAt: notification.readAt.toISOString() } : {}),
    createdAt: notification.createdAt.toISOString(),
  };
}
