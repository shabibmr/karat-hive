import { describe, expect, it } from 'vitest';
import type { Media, VendorProfile } from '@prisma/client';
import type { VendorLifecycleInput } from '../domain/vendor-lifecycle';
import { presentVendorMe } from './vendor-me.presenter';

describe('presentVendorMe logoUrl (Phase 0 fix)', () => {
  const profile = {
    id: 'vp-1',
    legalBusinessName: 'Gold House LLC',
    tradingName: 'Gold House',
    tradeLicenceNumber: 'TL-1',
    licenceExpiryDate: new Date('2027-01-01T00:00:00Z'),
    businessAddress: 'Dubai',
    contactPersonName: 'Ali',
    businessEmail: 'shop@example.com',
    contactWhatsApp: null,
    description: null,
    businessHours: null,
    verificationMessage: null,
    verifiedAt: null,
    awayMode: false,
  } as unknown as VendorProfile;

  const lifecycleInput: VendorLifecycleInput = {
    accountState: 'ACTIVE',
    verificationState: 'VERIFIED',
    activatedAt: new Date('2026-09-01T00:00:00Z'),
    hasMandatoryDocuments: true,
  };

  const counts = { regionCount: 1, regionIds: ['reg-1'] };

  it('is null when the vendor has no logo', () => {
    const result = presentVendorMe({ ...profile, logoMedia: null }, lifecycleInput, counts);
    expect(result.logoUrl).toBeNull();
  });

  it('is omitted-relation-safe when logoMedia was never fetched', () => {
    const result = presentVendorMe(profile, lifecycleInput, counts);
    expect(result.logoUrl).toBeNull();
  });

  it('proxies through /v1/media/{key} when a logo is attached', () => {
    const logoMedia = { key: 'media-key-123' } as unknown as Media;
    const result = presentVendorMe({ ...profile, logoMedia }, lifecycleInput, counts);
    expect(result.logoUrl).toBe('/v1/media/media-key-123');
  });
});
