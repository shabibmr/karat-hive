import type { Karat, RequestType } from '@prisma/client';

export type MatchingCriteria = {
  requestId: string;
  requestType: RequestType;
};

export type VendorEligibilitySnapshot = {
  vendorProfileId: string;
  isVerified: boolean;
  isActive: boolean;
  activeSubscriptionTypes: RequestType[];
};

/**
 * Pure domain check for vendor eligibility against a request (FR-SYS-002).
 * Eligibility gates on verification, ACTIVE state, and an active Type
 * Subscription for the Request's type only (BR-002) — not Region.
 */
export function isVendorEligibleForRequest(
  vendor: VendorEligibilitySnapshot,
  request: MatchingCriteria,
): boolean {
  if (!vendor.isVerified || !vendor.isActive) {
    return false;
  }
  if (!vendor.activeSubscriptionTypes.includes(request.requestType)) {
    return false;
  }
  return true;
}

export type MatchesSortOption = 'NEWEST' | 'EXPIRING' | 'HIGHEST_VALUE' | 'FEWEST_OFFERS';

export type MatchesFilterDto = {
  requestType?: RequestType;
  direction?: 'BUY' | 'SELL';
  regionId?: string;
  purityKarat?: Karat;
  weightMin?: number;
  weightMax?: number;
  budgetMin?: number;
  budgetMax?: number;
  publishedWithinHours?: number;
  includeResponded?: boolean;
  q?: string;
  sort?: MatchesSortOption;
  presetId?: string;
  limit?: number;
  cursor?: string;
};
