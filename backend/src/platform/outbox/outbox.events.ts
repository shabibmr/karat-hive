/** Architecture §11.2 + Async-Contract §4. Compile-time catalogue. */
export const OUTBOX_EVENT_TYPES = [
  'request.published',
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
  'review.moderated',
  'vendor.registered',
  'vendor.documents.submitted',
  'vendor.verification.decided',
  'vendor.eligibility.changed',
  'media.uploaded',
  'announcement.scheduled',
  'vendor.document.expiring',
] as const;

export type OutboxEventType = (typeof OUTBOX_EVENT_TYPES)[number];
