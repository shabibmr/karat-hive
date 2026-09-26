import { describe, expect, it } from 'vitest';
import { presentVendorDetail } from './admin-vendor.presenter';
import type { VendorDetailRow } from './admin-vendor.presenter';

const now = new Date('2026-09-26T12:00:00Z');

function baseRow(overrides: Partial<VendorDetailRow> = {}): VendorDetailRow {
  return {
    id: 'vendor-1',
    legalBusinessName: 'Al Karat Gold LLC',
    tradingName: 'Al Karat',
    tradeLicenceNumber: 'CN-1234567',
    licenceExpiryDate: new Date('2027-01-01T00:00:00.000Z'),
    businessAddress: 'Gold Souk, Deira, Dubai',
    contactPersonName: 'Rashid Khan',
    businessEmail: 'info@alkarat.ae',
    description: null,
    awayMode: false,
    verificationState: 'VERIFIED',
    activatedAt: null,
    verifiedAt: null,
    verificationNotes: null,
    verificationMessage: null,
    aggregateRating: null,
    reviewCount: 0,
    offersSubmittedCount: 0,
    offersAcceptedCount: 0,
    createdAt: now,
    updatedAt: now,
    user: {
      id: 'user-vendor-1',
      mobileNumber: '+971501234567',
      email: 'gold@example.com',
      accountState: 'ACTIVE',
      createdAt: now,
      lastLoginAt: null,
    },
    documents: [],
    categories: [],
    regions: [],
    ...overrides,
  } as unknown as VendorDetailRow;
}

describe('presentVendorDetail logoUrl (Phase 4 fix)', () => {
  it('resolves logoUrl from the logoMedia relation when a logo is set', () => {
    const row = baseRow({ logoMedia: { key: 'media-key-abc' } } as never);

    const result = presentVendorDetail(row, now);

    expect(result.logoUrl).toBe('/v1/media/media-key-abc');
  });

  it('is null when the vendor has no logoMedia', () => {
    const row = baseRow({ logoMedia: null } as never);

    const result = presentVendorDetail(row, now);

    expect(result.logoUrl).toBeNull();
  });
});
