import { describe, expect, it } from 'vitest';
import { isVendorEligibleForRequest, type MatchingCriteria, type VendorEligibilitySnapshot } from './matching-engine';

describe('MatchingEngine (FR-SYS-002)', () => {
  const sampleRequest: MatchingCriteria = {
    requestId: 'req-1',
    requestType: 'FIND_ORNAMENT',
    categoryId: 'cat-gold-ring',
    regionId: 'reg-dubai',
  };

  const fullyEligibleVendor: VendorEligibilitySnapshot = {
    vendorProfileId: 'vp-1',
    isVerified: true,
    isActive: true,
    categoryIds: ['cat-gold-ring', 'cat-gold-chain'],
    regionIds: ['reg-dubai', 'reg-sharjah'],
    activeSubscriptionTypes: ['FIND_ORNAMENT', 'SELL_OLD_GOLD'],
  };

  it('matches when vendor meets all 5 eligibility criteria', () => {
    expect(isVendorEligibleForRequest(fullyEligibleVendor, sampleRequest)).toBe(true);
  });

  it('rejects unverified vendor', () => {
    const vendor = { ...fullyEligibleVendor, isVerified: false };
    expect(isVendorEligibleForRequest(vendor, sampleRequest)).toBe(false);
  });

  it('rejects inactive vendor', () => {
    const vendor = { ...fullyEligibleVendor, isActive: false };
    expect(isVendorEligibleForRequest(vendor, sampleRequest)).toBe(false);
  });

  it('rejects vendor lacking the category', () => {
    const vendor = { ...fullyEligibleVendor, categoryIds: ['cat-gold-necklace'] };
    expect(isVendorEligibleForRequest(vendor, sampleRequest)).toBe(false);
  });

  it('rejects vendor lacking the region', () => {
    const vendor = { ...fullyEligibleVendor, regionIds: ['reg-abu-dhabi'] };
    expect(isVendorEligibleForRequest(vendor, sampleRequest)).toBe(false);
  });

  it('rejects vendor without active subscription for request type (BR-002)', () => {
    const vendor = { ...fullyEligibleVendor, activeSubscriptionTypes: ['SELL_OLD_GOLD' as const] };
    expect(isVendorEligibleForRequest(vendor, sampleRequest)).toBe(false);
  });
});
