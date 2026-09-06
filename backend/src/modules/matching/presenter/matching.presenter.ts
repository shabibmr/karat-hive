import type { Request, RequestMatch } from '@prisma/client';
import {
  presentVendorRequest,
  type VendorRequestView,
} from '../../requests/presenter/request-vendor.presenter';

export type MatchItemView = {
  matchId: string;
  matchedAt: string;
  viewedAt: string | null;
  request: VendorRequestView;
};

export type MatchesListView = {
  data: MatchItemView[];
  meta: {
    nextCursor: string | null;
  };
};

export function presentMatch(
  match: RequestMatch & {
    request: Request & {
      category?: { nameEn?: string; nameAr?: string };
      region?: { nameEn?: string; nameAr?: string };
    };
  },
): MatchItemView {
  const regionName = match.request.region?.nameEn ?? 'UAE';
  const vendorRequest = presentVendorRequest(match.request, {
    label: `Customer in ${regionName}`,
    region: regionName,
    ratingScore: 5.0,
    dealCount: 1,
  });

  return {
    matchId: match.id,
    matchedAt: match.matchedAt.toISOString(),
    viewedAt: match.viewedAt ? match.viewedAt.toISOString() : null,
    request: vendorRequest,
  };
}
