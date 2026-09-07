import type { OutboxEventType } from '../../../platform/outbox/outbox.events';

export type Channel = 'IN_APP' | 'PUSH' | 'EMAIL';

export type RecipientRef =
  | { type: 'user'; userId: string }
  | { type: 'vendorProfiles'; profileIds: string[] }
  | { type: 'offerVendors'; offerIds: string[] }
  | { type: 'pendingOfferVendors'; requestId: string }
  | { type: 'requestOfferVendors'; requestId: string }
  | { type: 'admins' }
  | { type: 'announcement'; announcementId: string };

export type DispatchIntent = {
  copyKey: string;
  notificationType: string;
  category: string;
  recipient: RecipientRef;
  channels: Channel[];
  isCritical: boolean;
  deepLink: string;
  vars?: Record<string, string>;
};

/** 17 events that produce in-app/push rows (Async-Contract §5 / §7.2). */
export const NOTIFICATION_DISPATCH_EVENTS: OutboxEventType[] = [
  'request.matched',
  'request.edited',
  'request.cancelled',
  'request.expired',
  'request.expiry.warning',
  'request.draft.purge_warning',
  'offer.submitted',
  'offer.revised',
  'offer.withdrawn',
  'offer.expiry.warning',
  'offer.expired',
  'offer.accepted',
  'connection.closed',
  'review.published',
  'vendor.verification.decided',
  'announcement.scheduled',
  'vendor.document.expiring',
];

/** Full 21-event catalogue the dispatcher consumes (Architecture §11.2 + AD-ASYNC-08). */
export const NOTIFICATION_CONSUMER_EVENTS: OutboxEventType[] = [
  ...NOTIFICATION_DISPATCH_EVENTS,
  'request.published',
  'review.moderated',
  'vendor.eligibility.changed',
  'media.uploaded',
];

const DISPATCH_SET = new Set<string>(NOTIFICATION_DISPATCH_EVENTS);
const CONSUMER_SET = new Set<string>(NOTIFICATION_CONSUMER_EVENTS);

export function isNotificationConsumerEvent(eventType: string): boolean {
  return CONSUMER_SET.has(eventType);
}

export function isNotificationDispatchEvent(eventType: string): boolean {
  return DISPATCH_SET.has(eventType);
}

function asRecord(payload: unknown): Record<string, unknown> {
  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) return {};
  const obj = payload as Record<string, unknown>;
  if (obj.data && typeof obj.data === 'object' && !Array.isArray(obj.data)) {
    return obj.data as Record<string, unknown>;
  }
  return obj;
}

function str(value: unknown): string | undefined {
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

function strArr(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === 'string')
    : [];
}

function money(value: unknown): string | undefined {
  if (typeof value === 'string' && value.length > 0) return value;
  if (value && typeof value === 'object' && 'amount' in value) {
    return String((value as { amount: unknown }).amount);
  }
  return undefined;
}

function intent(partial: DispatchIntent): DispatchIntent {
  return partial;
}

/**
 * Pure routing: event type + payload → dispatch intents.
 * Recipients that are not in the payload stay as lookup refs (resolved at dispatch).
 */
export function intentsFor(eventType: string, payload: unknown): DispatchIntent[] {
  const data = asRecord(payload);
  const requestId = str(data.requestId);
  const offerId = str(data.offerId);
  const connectionId = str(data.connectionId);
  const customerUserId = str(data.customerUserId);
  const vendorUserId = str(data.vendorUserId);

  switch (eventType) {
    case 'request.matched': {
      const vendor = vendorUserId ?? str(data.vendorUserId);
      if (!vendor || !requestId) return [];
      return [
        intent({
          copyKey: 'request.matched',
          notificationType: 'request.matched',
          category: 'request.matched',
          recipient: { type: 'user', userId: vendor },
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: `/requests/${requestId}`,
        }),
      ];
    }
    case 'request.edited': {
      if (!requestId) return [];
      const profileIds = strArr(data.notifyVendorProfileIds);
      const recipient: RecipientRef =
        profileIds.length > 0
          ? { type: 'vendorProfiles', profileIds }
          : { type: 'pendingOfferVendors', requestId };
      return [
        intent({
          copyKey: 'request.edited',
          notificationType: 'request.edited',
          category: 'request.edited',
          recipient,
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: `/requests/${requestId}`,
        }),
      ];
    }
    case 'request.cancelled': {
      if (!requestId) return [];
      const offerIds = strArr(data.affectedOfferIds);
      const recipient: RecipientRef =
        offerIds.length > 0
          ? { type: 'offerVendors', offerIds }
          : { type: 'requestOfferVendors', requestId };
      return [
        intent({
          copyKey: 'request.cancelled',
          notificationType: 'request.cancelled',
          category: 'request.cancelled',
          recipient,
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: `/requests/${requestId}`,
        }),
      ];
    }
    case 'request.expired': {
      if (!requestId) return [];
      const pendingOfferIds = strArr(data.pendingOfferIds);
      const vendorRecipient: RecipientRef =
        pendingOfferIds.length > 0
          ? { type: 'offerVendors', offerIds: pendingOfferIds }
          : { type: 'requestOfferVendors', requestId };
      const out: DispatchIntent[] = [];
      if (customerUserId) {
        out.push(
          intent({
            copyKey: 'request.expired.customer',
            notificationType: 'request.expired',
            category: 'request.expired',
            recipient: { type: 'user', userId: customerUserId },
            channels: ['IN_APP', 'PUSH'],
            isCritical: false,
            deepLink: `/requests/${requestId}`,
          }),
        );
      }
      out.push(
        intent({
          copyKey: 'request.expired.vendor',
          notificationType: 'request.expired',
          category: 'request.expired',
          recipient: vendorRecipient,
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: `/requests/${requestId}`,
        }),
      );
      return out;
    }
    case 'request.expiry.warning': {
      if (!customerUserId || !requestId) return [];
      return [
        intent({
          copyKey: 'request.expiry.warning',
          notificationType: 'request.expiry.warning',
          category: 'request.expiry.warning',
          recipient: { type: 'user', userId: customerUserId },
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: `/requests/${requestId}`,
        }),
      ];
    }
    case 'request.draft.purge_warning': {
      if (!customerUserId || !requestId) return [];
      return [
        intent({
          copyKey: 'request.draft.purge_warning',
          notificationType: 'request.draft.purge_warning',
          category: 'request.draft.purge_warning',
          recipient: { type: 'user', userId: customerUserId },
          channels: ['IN_APP'],
          isCritical: false,
          deepLink: `/requests/${requestId}`,
        }),
      ];
    }
    case 'offer.submitted': {
      if (!customerUserId || !requestId) return [];
      const first = data.isFirstOfferOnRequest === true;
      return [
        intent({
          copyKey: first ? 'offer.submitted.first' : 'offer.submitted.subsequent',
          notificationType: 'offer.submitted',
          category: 'offer.submitted',
          recipient: { type: 'user', userId: customerUserId },
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: `/requests/${requestId}/offers`,
        }),
      ];
    }
    case 'offer.revised': {
      if (!customerUserId || !requestId) return [];
      return [
        intent({
          copyKey: 'offer.revised',
          notificationType: 'offer.revised',
          category: 'offer.revised',
          recipient: { type: 'user', userId: customerUserId },
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: `/requests/${requestId}/offers`,
          vars: {
            previousPrice: money(data.previousPrice) ?? '',
            newPrice: money(data.newPrice) ?? '',
          },
        }),
      ];
    }
    case 'offer.withdrawn': {
      if (!customerUserId || !requestId) return [];
      return [
        intent({
          copyKey: 'offer.withdrawn',
          notificationType: 'offer.withdrawn',
          category: 'offer.withdrawn',
          recipient: { type: 'user', userId: customerUserId },
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: `/requests/${requestId}/offers`,
        }),
      ];
    }
    case 'offer.expiry.warning': {
      if (!vendorUserId || !offerId) return [];
      return [
        intent({
          copyKey: 'offer.expiry.warning',
          notificationType: 'offer.expiry.warning',
          category: 'offer.expiry.warning',
          recipient: { type: 'user', userId: vendorUserId },
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: `/offers/${offerId}`,
        }),
      ];
    }
    case 'offer.expired': {
      const out: DispatchIntent[] = [];
      if (vendorUserId && offerId) {
        out.push(
          intent({
            copyKey: 'offer.expired.vendor',
            notificationType: 'offer.expired',
            category: 'offer.expired',
            recipient: { type: 'user', userId: vendorUserId },
            channels: ['IN_APP', 'PUSH'],
            isCritical: false,
            deepLink: `/offers/${offerId}`,
          }),
        );
      }
      if (customerUserId && requestId) {
        out.push(
          intent({
            copyKey: 'offer.expired.customer',
            notificationType: 'offer.expired',
            category: 'offer.expired',
            recipient: { type: 'user', userId: customerUserId },
            channels: ['IN_APP', 'PUSH'],
            isCritical: false,
            deepLink: `/requests/${requestId}/offers`,
          }),
        );
      }
      return out;
    }
    case 'offer.accepted': {
      const winnerVendorUserId = str(data.winnerVendorUserId);
      const rejectedOfferIds = strArr(data.rejectedOfferIds);
      const out: DispatchIntent[] = [];
      if (winnerVendorUserId && connectionId) {
        out.push(
          intent({
            copyKey: 'offer.accepted.winner',
            notificationType: 'offer.accepted',
            category: 'offer.accepted',
            recipient: { type: 'user', userId: winnerVendorUserId },
            channels: ['IN_APP', 'PUSH'],
            isCritical: false,
            deepLink: `/connections/${connectionId}`,
          }),
        );
      }
      if (rejectedOfferIds.length > 0 && requestId) {
        out.push(
          intent({
            copyKey: 'offer.accepted.loser',
            notificationType: 'offer.rejected',
            category: 'offer.accepted',
            recipient: { type: 'offerVendors', offerIds: rejectedOfferIds },
            channels: ['IN_APP', 'PUSH'],
            isCritical: false,
            deepLink: `/requests/${requestId}`,
          }),
        );
      }
      if (customerUserId && connectionId) {
        out.push(
          intent({
            copyKey: 'offer.accepted.customer',
            notificationType: 'connection.established',
            category: 'offer.accepted',
            recipient: { type: 'user', userId: customerUserId },
            channels: ['IN_APP', 'PUSH'],
            isCritical: false,
            deepLink: `/connections/${connectionId}`,
          }),
        );
      }
      return out;
    }
    case 'connection.closed': {
      if (!connectionId) return [];
      const parties: string[] = [];
      if (customerUserId) parties.push(customerUserId);
      if (vendorUserId) parties.push(vendorUserId);
      const out: DispatchIntent[] = [];
      for (const userId of parties) {
        out.push(
          intent({
            copyKey: 'connection.closed',
            notificationType: 'connection.closed',
            category: 'connection.closed',
            recipient: { type: 'user', userId },
            channels: ['IN_APP'],
            isCritical: false,
            deepLink: `/connections/${connectionId}`,
          }),
        );
        out.push(
          intent({
            copyKey: 'connection.closed.review',
            notificationType: 'review.reminder',
            category: 'connection.closed',
            recipient: { type: 'user', userId },
            channels: ['IN_APP', 'PUSH'],
            isCritical: false,
            deepLink: `/connections/${connectionId}/review`,
          }),
        );
      }
      return out;
    }
    case 'review.published': {
      const subjectUserId = str(data.subjectUserId) ?? str(data.subjectCustomerUserId);
      const subjectVendorProfileId = str(data.subjectVendorProfileId);
      let recipient: RecipientRef | null = null;
      if (subjectUserId) recipient = { type: 'user', userId: subjectUserId };
      else if (subjectVendorProfileId) {
        recipient = { type: 'vendorProfiles', profileIds: [subjectVendorProfileId] };
      }
      if (!recipient) return [];
      return [
        intent({
          copyKey: 'review.published',
          notificationType: 'review.published',
          category: 'review.published',
          recipient,
          channels: ['IN_APP', 'PUSH'],
          isCritical: false,
          deepLink: '/me/reviews',
        }),
      ];
    }
    case 'vendor.verification.decided': {
      const vendor = vendorUserId;
      if (!vendor) return [];
      return [
        intent({
          copyKey: 'vendor.verification.decided',
          notificationType: 'vendor.verification.decided',
          category: 'vendor.verification.decided',
          recipient: { type: 'user', userId: vendor },
          channels: ['IN_APP', 'PUSH', 'EMAIL'],
          isCritical: false,
          deepLink: '/me/vendor',
          vars: { decision: str(data.decision) ?? '' },
        }),
      ];
    }
    case 'announcement.scheduled': {
      const announcementId = str(data.announcementId);
      if (!announcementId) return [];
      return [
        intent({
          copyKey: 'announcement.scheduled',
          notificationType: 'announcement.scheduled',
          category: 'announcement.scheduled',
          recipient: { type: 'announcement', announcementId },
          channels: ['IN_APP', 'PUSH'],
          isCritical: data.critical === true,
          deepLink: `/announcements/${announcementId}`,
        }),
      ];
    }
    case 'vendor.document.expiring': {
      const vendor = vendorUserId;
      const vendorProfileId = str(data.vendorProfileId);
      const out: DispatchIntent[] = [];
      if (vendor) {
        out.push(
          intent({
            copyKey: 'vendor.document.expiring',
            notificationType: 'vendor.document.expiring',
            category: 'vendor.document.expiring',
            recipient: { type: 'user', userId: vendor },
            channels: ['IN_APP', 'PUSH', 'EMAIL'],
            isCritical: false,
            deepLink: '/me/vendor/documents',
          }),
        );
      }
      out.push(
        intent({
          copyKey: 'vendor.document.expiring',
          notificationType: 'vendor.document.expiring',
          category: 'vendor.document.expiring',
          recipient: { type: 'admins' },
          channels: ['IN_APP', 'PUSH', 'EMAIL'],
          isCritical: false,
          deepLink: vendorProfileId ? `/admin/vendors/${vendorProfileId}` : '/me/vendor/documents',
        }),
      );
      return out;
    }
    default:
      return [];
  }
}
