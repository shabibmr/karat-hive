import type { MediaPurpose, StorageBucket } from '@prisma/client';

export type MediaConstraint = {
  bucket: StorageBucket;
  allowedContentTypes: readonly string[];
  maxBytes: number;
};

const MIB = 1024 * 1024;

/** Per-purpose upload rules (FR-VEN-002, FR-CUS-007, NFR-005). */
export const MEDIA_CONSTRAINTS: Record<MediaPurpose, MediaConstraint> = {
  KYC_DOCUMENT: {
    bucket: 'KYC',
    allowedContentTypes: ['application/pdf', 'image/jpeg', 'image/png'],
    maxBytes: 10 * MIB,
  },
  REQUEST_IMAGE: {
    bucket: 'REQUEST_MEDIA',
    allowedContentTypes: ['image/jpeg', 'image/png', 'image/webp'],
    maxBytes: 5 * MIB,
  },
  OFFER_IMAGE: {
    bucket: 'REQUEST_MEDIA',
    allowedContentTypes: ['image/jpeg', 'image/png', 'image/webp'],
    maxBytes: 5 * MIB,
  },
  PROFILE_PHOTO: {
    bucket: 'REQUEST_MEDIA',
    allowedContentTypes: ['image/jpeg', 'image/png', 'image/webp'],
    maxBytes: 5 * MIB,
  },
  VENDOR_LOGO: {
    bucket: 'REQUEST_MEDIA',
    allowedContentTypes: ['image/jpeg', 'image/png', 'image/webp'],
    maxBytes: 5 * MIB,
  },
  VENDOR_SHOP_PHOTO: {
    bucket: 'REQUEST_MEDIA',
    allowedContentTypes: ['image/jpeg', 'image/png', 'image/webp'],
    maxBytes: 5 * MIB,
  },
  EXPORT_ARTEFACT: {
    bucket: 'EXPORT',
    allowedContentTypes: [
      'text/csv',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'image/png',
    ],
    maxBytes: 25 * MIB,
  },
};

export function isContentTypeAllowed(purpose: MediaPurpose, contentType: string): boolean {
  return MEDIA_CONSTRAINTS[purpose].allowedContentTypes.includes(contentType);
}

export function isByteSizeAllowed(purpose: MediaPurpose, byteSize: number): boolean {
  return (
    Number.isInteger(byteSize) && byteSize > 0 && byteSize <= MEDIA_CONSTRAINTS[purpose].maxBytes
  );
}

/** Storage object path. KYC is scoped by vendor profile; other media by owning entity or user. */
export function storagePath(input: {
  purpose: MediaPurpose;
  key: string;
  vendorProfileId?: string | null;
  ownerUserId: string;
}): string {
  if (input.purpose === 'KYC_DOCUMENT') {
    return `vendor/${input.vendorProfileId ?? input.ownerUserId}/KYC_DOCUMENT/${input.key}`;
  }
  return `user/${input.ownerUserId}/${input.purpose}/${input.key}`;
}

/** Real object-store bucket name for a StorageBucket enum value. */
export function physicalBucketName(bucket: StorageBucket, kycBucket: string): string {
  switch (bucket) {
    case 'KYC':
      return kycBucket;
    case 'REQUEST_MEDIA':
      return 'request-media';
    case 'EXPORT':
      return 'export';
  }
}

/**
 * Derivative object key stored on `media.thumbnail_key` (varchar 64).
 * Random UUID prefix keeps it non-guessable (NFR-014).
 */
export function thumbnailStorageKey(mediaKey: string): string {
  return `${mediaKey}.thumb`;
}
