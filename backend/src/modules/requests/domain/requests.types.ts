import { Direction, ItemCondition, Karat, OrnamentType, RequestState, RequestType } from '@prisma/client';

export type CreateRequestDraftInput = {
  customerProfileId: string;
  requestType: RequestType;
  direction?: Direction;
  categoryId: string;
  regionId: string;
  notes?: string | null;
  weightGrams?: number | string | null;
  weightIsApproximate?: boolean;
  purityKarat?: Karat | null;
  ornamentType?: OrnamentType | null;
  condition?: ItemCondition | null;
  denominationGrams?: number | string | null;
  quantity?: number | null;
  mintOrRefiner?: string | null;
  budgetMin?: number | string | null;
  budgetMax?: number | string | null;
  budgetIsFlexible?: boolean;
  gemstones?: unknown;
};

export const REQUEST_EXPIRY_HOURS = 48; // C-07
