import { describe, expect, it } from 'vitest';
import { isVendorEligibleForRequest, type MatchingCriteria, type VendorEligibilitySnapshot } from './matching-engine';

describe('MatchingEngine (FR-SYS-002)', () => {
  const sampleRequest: MatchingCriteria = {
    requestId: 'req-1',
    requestType: 'FIND_ORNAMENT',
  };

  const fullyEligibleVendor: VendorEligibilitySnapshot = {
    vendorProfileId: 'vp-1',
    isVerified: true,
    isActive: true,
    activeSubscriptionTypes: ['FIND_ORNAMENT', 'SELL_OLD_GOLD'],
  };

  it('matches when vendor is VERIFIED + ACTIVE with live Type Subscription', () => {
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

  it('rejects vendor without active subscription for request type (BR-002)', () => {
    const vendor = { ...fullyEligibleVendor, activeSubscriptionTypes: ['SELL_OLD_GOLD' as const] };
    expect(isVendorEligibleForRequest(vendor, sampleRequest)).toBe(false);
  });
});
