import type {
  Category,
  DeclineReason,
  Media,
  Offer,
  OfferMedia,
  OfferState,
  Region,
  Request,
  VendorProfile,
  VendorRegion,
} from '@prisma/client';
import {
  presentCategory,
  presentRegion,
  type CategorySummary,
  type RegionSummary,
} from '../../requests/presenter/request.presenter';

export type OfferMediaDto = {
  id: string;
  key: string;
  displayOrder: number;
};

export type MaskedVendorDto = {
  label: string;
  region?: RegionSummary;
  connectionCount: number;
  rating?: {
    average: string;
    count: number;
    distribution: Record<string, number>;
    limitedHistory: boolean;
  };
};

export type OfferTermsDto = {
  offeredPrice: string;
  makingCharges?: string;
  ratePerGram?: string;
  deliveryTimeframe?: string;
  warrantyTerms?: string;
  vendorNote?: string;
  validityHours: number;
};

export type OfferForCustomer = {
  id: string;
  requestId: string;
  state: OfferState;
  submittedAt: string;
  expiresAt: string;
  decidedAt?: string;
  revisionCount: number;
  viewedByCustomerAt?: string;
  terms: OfferTermsDto;
  media: OfferMediaDto[];
  vendor: MaskedVendorDto;
};

export type OfferForVendor = {
  id: string;
  requestId: string;
  state: OfferState;
  submittedAt: string;
  expiresAt: string;
  decidedAt?: string;
  revisionCount: number;
  connectionId?: string;
  terms: OfferTermsDto;
  media: OfferMediaDto[];
  requestSummary?: {
    id: string;
    reference?: string;
    requestType: string;
    direction: string;
    category: CategorySummary;
    region: RegionSummary;
    customerLabel: string;
    purityKarat?: string;
    weightGrams?: string;
    budgetMax?: string;
    expiresAt?: string;
  };
  declineReason?: DeclineReason;
  awardedElsewhere?: boolean;
};

export type VendorRatingSummary = {
  vendor: {
    label: string;
    region?: RegionSummary;
    connectionCount: number;
    rating: {
      average: string;
      count: number;
      distribution: Record<string, number>;
      limitedHistory: boolean;
    };
  };
  reviews: Array<{
    id: string;
    rating: number;
    comment?: string;
    publishedAt?: string;
    reviewerLabel: string;
  }>;
};

export type PrismaOfferWithDetails = Offer & {
  media?: Array<OfferMedia & { media: Media }>;
  vendorProfile?: VendorProfile & {
    regions?: Array<VendorRegion & { region: Region }>;
  };
  request?: Request & {
    category?: Category;
    region?: Region;
  };
  connection?: { id: string } | null;
};

export function presentOfferTerms(offer: Offer): OfferTermsDto {
  return {
    offeredPrice: offer.offeredPrice.toString(),
    makingCharges: offer.makingCharges ? offer.makingCharges.toString() : undefined,
    ratePerGram: offer.ratePerGram ? offer.ratePerGram.toString() : undefined,
    deliveryTimeframe: offer.deliveryTimeframe ?? undefined,
    warrantyTerms: offer.warrantyTerms ?? undefined,
    vendorNote: offer.vendorNote ?? undefined,
    validityHours: offer.validityHours,
  };
}

export function presentOfferMedia(
  mediaList?: Array<OfferMedia & { media: Media }>,
): OfferMediaDto[] {
  if (!mediaList) return [];
  return mediaList
    .filter((m) => m.media.state === 'READY')
    .sort((a, b) => a.displayOrder - b.displayOrder)
    .map((m) => ({
      id: m.media.id,
      key: m.media.key,
      displayOrder: m.displayOrder,
    }));
}

/**
 * Present offer to Customer. Vendor identity is strictly masked (BR-006 / NFR-013).
 */
export function presentOfferForCustomer(offer: PrismaOfferWithDetails): OfferForCustomer {
  const vp = offer.vendorProfile;
  const primaryVendorRegion = vp?.regions && vp.regions.length > 0 ? vp.regions[0]?.region : undefined;
  const regionDto = primaryVendorRegion ? presentRegion(primaryVendorRegion) : undefined;
  const label = `Vendor · ${regionDto?.nameEn ?? 'UAE'}`;

  const reviewCount = vp?.reviewCount ?? 0;
  const ratingAvg = vp?.aggregateRating ? vp.aggregateRating.toString() : '0.0';

  return {
    id: offer.id,
    requestId: offer.requestId,
    state: offer.state,
    submittedAt: offer.submittedAt.toISOString(),
    expiresAt: offer.expiresAt.toISOString(),
    decidedAt: offer.decidedAt?.toISOString(),
    revisionCount: offer.revisionCount,
    viewedByCustomerAt: offer.viewedByCustomerAt?.toISOString(),
    terms: presentOfferTerms(offer),
    media: presentOfferMedia(offer.media),
    vendor: {
      label,
      region: regionDto,
      connectionCount: vp?.offersAcceptedCount ?? 0,
      rating: {
        average: ratingAvg,
        count: reviewCount,
        distribution: {},
        limitedHistory: reviewCount < 3,
      },
    },
  };
}

/**
 * Present offer to the submitting Vendor.
 * Competing prices, terms, and winning vendor identity are strictly omitted (BR-008).
 */
export function presentOfferForVendor(
  offer: PrismaOfferWithDetails,
  options?: {
    request?: Request & { category: Category; region: Region };
    awardedElsewhere?: boolean;
  },
): OfferForVendor {
  const req = options?.request ?? offer.request;
  let requestSummary: OfferForVendor['requestSummary'] = undefined;

  if (req && req.category && req.region) {
    const regionDto = presentRegion(req.region);
    requestSummary = {
      id: req.id,
      reference: req.reference ?? undefined,
      requestType: req.requestType,
      direction: req.direction,
      category: presentCategory(req.category),
      region: regionDto,
      customerLabel: `Customer · ${regionDto.nameEn}`,
      purityKarat: req.purityKarat ?? undefined,
      weightGrams: req.weightGrams ? req.weightGrams.toString() : undefined,
      budgetMax: req.budgetMax ? req.budgetMax.toString() : undefined,
      expiresAt: req.expiresAt?.toISOString(),
    };
  }

  return {
    id: offer.id,
    requestId: offer.requestId,
    state: offer.state,
    submittedAt: offer.submittedAt.toISOString(),
    expiresAt: offer.expiresAt.toISOString(),
    decidedAt: offer.decidedAt?.toISOString(),
    revisionCount: offer.revisionCount,
    connectionId: offer.connection?.id,
    terms: presentOfferTerms(offer),
    media: presentOfferMedia(offer.media),
    requestSummary,
    declineReason: offer.declineReason ?? undefined,
    awardedElsewhere: options?.awardedElsewhere,
  };
}
