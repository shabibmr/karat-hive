import type { Direction, Karat, RequestType } from '@prisma/client';

export type MatchSortOrder = 'NEWEST' | 'EXPIRING' | 'HIGHEST_VALUE' | 'FEWEST_OFFERS';

export type MatchFilters = {
  requestType?: RequestType;
  direction?: Direction;
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
  sort?: MatchSortOrder;
  presetId?: string;
  limit?: number;
  cursor?: string;
};
