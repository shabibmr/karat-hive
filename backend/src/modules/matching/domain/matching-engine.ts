import type { Karat, RequestType } from '@prisma/client';

export type MatchingCriteria = {
  requestId: string;
  requestType: RequestType;
  categoryId: string;
  regionId: string;
};

export type VendorEligibilitySnapshot = {
  vendorProfileId: string;
  isVerified: boolean;
  isActive: boolean;
  categoryIds: string[];
  regionIds: string[];
  activeSubscriptionTypes: RequestType[];
};

/**
 * Pure domain check for vendor eligibility against a request (FR-SYS-002).
 */
export function isVendorEligibleForRequest(
  vendor: VendorEligibilitySnapshot,
  request: MatchingCriteria,
): boolean {
  if (!vendor.isVerified || !vendor.isActive) {
    return false;
  }
  if (!vendor.categoryIds.includes(request.categoryId)) {
    return false;
  }
  if (!vendor.regionIds.includes(request.regionId)) {
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
  categoryId?: string;
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
