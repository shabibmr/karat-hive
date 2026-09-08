import type {
  Category,
  Direction,
  ItemCondition,
  Karat,
  Media,
  Offer,
  OrnamentType,
  Region,
  Request,
  RequestMedia,
  RequestState,
  RequestType,
} from '@prisma/client';

export type CategorySummary = {
  id: string;
  nameEn: string;
  nameAr: string;
  parentId?: string | null;
  isActive: boolean;
  displayOrder: number;
  icon?: string | null;
};

export type RegionSummary = {
  id: string;
  nameEn: string;
  nameAr: string;
  parentId?: string | null;
  isActive: boolean;
  displayOrder: number;
};

export type RequestMediaRef = {
  id: string;
  key: string;
  state: Media['state'];
  purpose: Media['purpose'];
  contentType: string;
  byteSize: number;
  displayOrder: number;
};

export type MaskedCustomer = {
  label: string;
  region: RegionSummary;
  connectionCount: number;
  rating?: {
    average: string;
    count: number;
    distribution: Record<string, number>;
    limitedHistory: boolean;
  };
};

export type RequestBaseDto = {
  id: string;
  reference?: string;
  requestType: RequestType;
  direction: Direction;
  state: RequestState;
  category: CategorySummary;
  region: RegionSummary;
  notes?: string;
  weightGrams?: string;
  weightIsApproximate: boolean;
  purityKarat?: Karat;
  ornamentType?: OrnamentType;
  condition?: ItemCondition;
  denominationGrams?: string;
  quantity?: number;
  mintOrRefiner?: string;
  budgetMin?: string;
  budgetMax?: string;
  budgetIsFlexible: boolean;
  indicativeValue?: string;
  publishedAt?: string;
  expiresAt?: string;
  offerCount: number;
  media: RequestMediaRef[];
  createdAt: string;
  updatedAt: string;
};

export type RequestForCustomer = RequestBaseDto & {
  /**
   * SAM-GAP-1 / CBG-01: presenter-time aggregate — offers on this Request that are
   * still PENDING and have not been marked viewed (`POST /v1/offers/{id}/viewed`).
   * Drives the CUS-S02 per-Request badge and the CUS-S11 list-level count.
   */
  unreadOfferCount: number;
  gemstones?: Record<string, unknown>;
  cancellationReason?: string;
  acceptedOfferId?: string;
  connectionId?: string;
  offers?: Array<{
    id: string;
    requestId: string;
    state: string;
    submittedAt: string;
    expiresAt: string;
    decidedAt?: string;
    revisionCount: number;
    terms: {
      offeredPrice: string;
      makingCharges?: string;
      ratePerGram?: string;
      deliveryTimeframe?: string;
      warrantyTerms?: string;
      vendorNote?: string;
      validityHours: number;
    };
    vendor: {
      label: string;
      region: RegionSummary;
      connectionCount: number;
      rating: {
        average: string;
        count: number;
        distribution: Record<string, number>;
        limitedHistory: boolean;
      };
    };
  }>;
};

export type RequestForVendor = RequestBaseDto & {
  gemstones?: Record<string, unknown>;
  customer: MaskedCustomer;
  viewedAt?: string;
  myOffer?: {
    id: string;
    state: string;
    offeredPrice: string;
    submittedAt: string;
    expiresAt: string;
  };
};

/** Join row for SAM-GAP-3: Connection is unique on offer_id, not a Request column. */
export type AcceptedOfferConnectionJoin = {
  id: string;
  connection?: { id: string } | null;
};

export type FullPrismaRequest = Request & {
  category: Category;
  region: Region;
  media: Array<RequestMedia & { media: Media }>;
  offers?: Offer[];
  acceptedOffer?: AcceptedOfferConnectionJoin | null;
  /** Filtered relation count for SAM-GAP-1: PENDING & unviewed offers. */
  _count?: { offers: number } | null;
};

/**
 * Customer deep-link id for CUS-S10. Only when ACCEPTED; sourced from the
 * unique Connection.offer_id join (G2-C05 / SAM-GAP-3).
 */
export function connectionIdForAcceptedRequest(
  request: Pick<FullPrismaRequest, 'state' | 'acceptedOffer'>,
  fallback?: string,
): string | undefined {
  if (request.state !== 'ACCEPTED') {
    return undefined;
  }
  return request.acceptedOffer?.connection?.id ?? fallback;
}

export function presentCategory(c: Category): CategorySummary {
  return {
    id: c.id,
    nameEn: c.nameEn,
    nameAr: c.nameAr,
    parentId: c.parentId ?? undefined,
    isActive: c.isActive,
    displayOrder: c.displayOrder,
    icon: c.icon ?? undefined,
  };
}

export function presentRegion(r: Region): RegionSummary {
  return {
    id: r.id,
    nameEn: r.nameEn,
    nameAr: r.nameAr,
    parentId: r.parentId ?? undefined,
    isActive: r.isActive,
    displayOrder: r.displayOrder,
  };
}

export function presentRequestMedia(rm: RequestMedia & { media: Media }): RequestMediaRef {
  return {
    id: rm.media.id,
    key: rm.media.key,
    state: rm.media.state,
    purpose: rm.media.purpose,
    contentType: rm.media.contentType,
    byteSize: rm.media.byteSize,
    displayOrder: rm.displayOrder,
  };
}

export function presentRequestForCustomer(
  request: FullPrismaRequest,
  options?: { includeOffers?: boolean; connectionId?: string },
): RequestForCustomer {
  const mediaList = (request.media ?? [])
    .slice()
    .sort((a, b) => a.displayOrder - b.displayOrder)
    .map(presentRequestMedia);

  const res: RequestForCustomer = {
    id: request.id,
    reference: request.reference ?? undefined,
    requestType: request.requestType,
    direction: request.direction,
    state: request.state,
    category: presentCategory(request.category),
    region: presentRegion(request.region),
    notes: request.notes ?? undefined,
    weightGrams: request.weightGrams ? request.weightGrams.toString() : undefined,
    weightIsApproximate: request.weightIsApproximate,
    purityKarat: request.purityKarat ?? undefined,
    ornamentType: request.ornamentType ?? undefined,
    condition: request.condition ?? undefined,
    denominationGrams: request.denominationGrams
      ? request.denominationGrams.toString()
      : undefined,
    quantity: request.quantity ?? undefined,
    mintOrRefiner: request.mintOrRefiner ?? undefined,
    budgetMin: request.budgetMin ? request.budgetMin.toString() : undefined,
    budgetMax: request.budgetMax ? request.budgetMax.toString() : undefined,
    budgetIsFlexible: request.budgetIsFlexible,
    indicativeValue: request.indicativeValue ? request.indicativeValue.toString() : undefined,
    publishedAt: request.publishedAt?.toISOString(),
    expiresAt: request.expiresAt?.toISOString(),
    offerCount: request.offerCount,
    unreadOfferCount: request._count?.offers ?? 0,
    media: mediaList,
    createdAt: request.createdAt.toISOString(),
    updatedAt: request.updatedAt.toISOString(),
    cancellationReason: request.cancellationReason ?? undefined,
    acceptedOfferId: request.acceptedOfferId ?? undefined,
    connectionId: connectionIdForAcceptedRequest(request, options?.connectionId),
    gemstones: (request.gemstones as Record<string, unknown>) ?? undefined,
  };

  if (options?.includeOffers && request.offers) {
    // Nested offers on GET /v1/requests/:id for owner
    res.offers = [];
  }

  return res;
}

export function presentRequestForVendor(
  request: FullPrismaRequest,
  options?: {
    customerConnectionCount?: number;
    customerRating?: { average: string; count: number; distribution: Record<string, number>; limitedHistory: boolean };
    viewedAt?: Date | null;
    myOffer?: { id: string; state: string; offeredPrice: string; submittedAt: string; expiresAt: string };
  },
): RequestForVendor {
  const mediaList = (request.media ?? [])
    .filter((rm) => rm.media.state === 'READY')
    .sort((a, b) => a.displayOrder - b.displayOrder)
    .map(presentRequestMedia);

  const region = presentRegion(request.region);

  return {
    id: request.id,
    reference: request.reference ?? undefined,
    requestType: request.requestType,
    direction: request.direction,
    state: request.state,
    category: presentCategory(request.category),
    region,
    notes: request.notes ?? undefined,
    weightGrams: request.weightGrams ? request.weightGrams.toString() : undefined,
    weightIsApproximate: request.weightIsApproximate,
    purityKarat: request.purityKarat ?? undefined,
    ornamentType: request.ornamentType ?? undefined,
    condition: request.condition ?? undefined,
    denominationGrams: request.denominationGrams
      ? request.denominationGrams.toString()
      : undefined,
    quantity: request.quantity ?? undefined,
    mintOrRefiner: request.mintOrRefiner ?? undefined,
    budgetMin: request.budgetMin ? request.budgetMin.toString() : undefined,
    budgetMax: request.budgetMax ? request.budgetMax.toString() : undefined,
    budgetIsFlexible: request.budgetIsFlexible,
    indicativeValue: request.indicativeValue ? request.indicativeValue.toString() : undefined,
    publishedAt: request.publishedAt?.toISOString(),
    expiresAt: request.expiresAt?.toISOString(),
    offerCount: request.offerCount,
    media: mediaList,
    createdAt: request.createdAt.toISOString(),
    updatedAt: request.updatedAt.toISOString(),
    gemstones: (request.gemstones as Record<string, unknown>) ?? undefined,
    customer: {
      label: `Customer · ${region.nameEn}`,
      region,
      connectionCount: options?.customerConnectionCount ?? 0,
      rating: options?.customerRating,
    },
    viewedAt: options?.viewedAt?.toISOString(),
    myOffer: options?.myOffer,
  };
}
