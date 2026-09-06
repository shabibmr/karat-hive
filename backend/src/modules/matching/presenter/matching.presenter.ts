import type { Request, RequestMatch } from '@prisma/client';
import {
  presentVendorRequest,
  type VendorRequestView,
} from '../../requests/presenter/request-vendor.presenter';

export type MatchesListView = {
  data: VendorRequestView[];
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
): VendorRequestView {
  const regionName = match.request.region?.nameEn ?? 'UAE';
  return presentVendorRequest(
    match.request as Parameters<typeof presentVendorRequest>[0],
    {
      label: `Customer in ${regionName}`,
      region: regionName,
      ratingScore: 5.0,
      dealCount: 1,
    },
    match.viewedAt,
  );
}
