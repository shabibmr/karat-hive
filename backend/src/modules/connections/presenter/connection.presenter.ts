import type {
  Category,
  ClosedBy,
  Connection,
  ConnectionState,
  CustomerProfile,
  Offer,
  Region,
  Request,
  User,
  VendorProfile,
  VendorRegion,
} from '@prisma/client';
import {
  presentCategory,
  presentRegion,
  type CategorySummary,
  type RegionSummary,
} from '../../requests/presenter/request.presenter';

export type TalkDto = {
  available: boolean;
  waUrl: string;
  phone: string;
  callUrl: string;
};

export type ConnectionForCustomer = {
  id: string;
  offerId: string;
  requestId: string;
  state: ConnectionState;
  identityRevealedAt: string;
  closedAt?: string;
  closedBy?: ClosedBy;
  vendor: {
    id: string;
    legalBusinessName: string;
    tradingName: string;
    tradeLicenceNumber: string;
    phone: string;
    connectionCount: number;
    region?: RegionSummary;
    rating?: {
      average: string;
      count: number;
    };
  };
  offer: {
    id: string;
    offeredPrice: string;
    makingCharges?: string;
    ratePerGram?: string;
    validityHours: number;
    deliveryTimeframe?: string;
    warrantyTerms?: string;
    vendorNote?: string;
  };
  request: {
    id: string;
    reference?: string;
    requestType: string;
    direction: string;
    category: CategorySummary;
    region: RegionSummary;
  };
  talk: TalkDto;
};

export type ConnectionForVendor = {
  id: string;
  offerId: string;
  requestId: string;
  state: ConnectionState;
  identityRevealedAt: string;
  closedAt?: string;
  closedBy?: ClosedBy;
  customer: {
    id: string;
    displayName: string;
    phone: string;
    connectionCount: number;
    rating?: {
      average: string;
      count: number;
    };
  };
  offer: {
    id: string;
    offeredPrice: string;
    makingCharges?: string;
    ratePerGram?: string;
    validityHours: number;
    deliveryTimeframe?: string;
    warrantyTerms?: string;
    vendorNote?: string;
  };
  request: {
    id: string;
    reference?: string;
    requestType: string;
    direction: string;
    category: CategorySummary;
    region: RegionSummary;
  };
  talk: TalkDto;
};

export type PrismaConnectionWithDetails = Connection & {
  offer: Offer;
  request: Request & {
    category: Category;
    region: Region;
  };
  customerProfile: CustomerProfile & {
    user: User;
  };
  vendorProfile: VendorProfile & {
    user: User;
    regions?: Array<VendorRegion & { region: Region }>;
  };
};

export function buildWhatsAppUrl(
  mobileNumber: string,
  reference?: string | null,
  priceAed?: string | number,
  language: 'en' | 'ar' = 'en',
): string {
  const digits = mobileNumber.replace(/\D/g, '');
  const ref = reference ?? 'N/A';
  const price = priceAed ?? '';

  const text =
    language === 'ar'
      ? `مرحباً، بخصوص طلب كارات هايف ${ref}: العرض بقيمة ${price} درهم`
      : `Hello, regarding KaratHive request ${ref}: Offer of AED ${price}`;

  return `https://wa.me/${digits}?text=${encodeURIComponent(text)}`;
}

export function buildTalkDto(
  connectionState: ConnectionState,
  targetMobile: string,
  reference?: string | null,
  priceAed?: string | number,
  language: 'en' | 'ar' = 'en',
): TalkDto {
  return {
    available: connectionState === 'ACTIVE',
    waUrl: buildWhatsAppUrl(targetMobile, reference, priceAed, language),
    phone: targetMobile,
    callUrl: `tel:${targetMobile}`,
  };
}

/**
 * Present Connection to Customer (reveals Vendor identity per BR-007 / FR-CUS-024).
 */
export function presentConnectionForCustomer(
  conn: PrismaConnectionWithDetails,
  language: 'en' | 'ar' = 'en',
): ConnectionForCustomer {
  const vp = conn.vendorProfile;
  const primaryRegion = vp.regions && vp.regions.length > 0 ? vp.regions[0]?.region : undefined;
  const regionDto = primaryRegion ? presentRegion(primaryRegion) : undefined;

  const vendorRating = vp.aggregateRating
    ? {
        average: vp.aggregateRating.toString(),
        count: vp.reviewCount,
      }
    : undefined;

  const priceStr = conn.offer.offeredPrice.toString();

  return {
    id: conn.id,
    offerId: conn.offerId,
    requestId: conn.requestId,
    state: conn.state,
    identityRevealedAt: conn.identityRevealedAt.toISOString(),
    closedAt: conn.closedAt?.toISOString(),
    closedBy: conn.closedBy ?? undefined,
    vendor: {
      id: vp.id,
      legalBusinessName: vp.legalBusinessName,
      tradingName: vp.tradingName,
      tradeLicenceNumber: vp.tradeLicenceNumber,
      phone: vp.user.mobileNumber,
      connectionCount: vp.offersAcceptedCount,
      region: regionDto,
      rating: vendorRating,
    },
    offer: {
      id: conn.offer.id,
      offeredPrice: priceStr,
      makingCharges: conn.offer.makingCharges ? conn.offer.makingCharges.toString() : undefined,
      ratePerGram: conn.offer.ratePerGram ? conn.offer.ratePerGram.toString() : undefined,
      validityHours: conn.offer.validityHours,
      deliveryTimeframe: conn.offer.deliveryTimeframe ?? undefined,
      warrantyTerms: conn.offer.warrantyTerms ?? undefined,
      vendorNote: conn.offer.vendorNote ?? undefined,
    },
    request: {
      id: conn.request.id,
      reference: conn.request.reference ?? undefined,
      requestType: conn.request.requestType,
      direction: conn.request.direction,
      category: presentCategory(conn.request.category),
      region: presentRegion(conn.request.region),
    },
    talk: buildTalkDto(conn.state, vp.user.mobileNumber, conn.request.reference, priceStr, language),
  };
}

/**
 * Present Connection to Vendor (reveals Customer identity per BR-007 / FR-VEN-021).
 */
export function presentConnectionForVendor(
  conn: PrismaConnectionWithDetails,
  language: 'en' | 'ar' = 'en',
): ConnectionForVendor {
  const cp = conn.customerProfile;
  const customerRating = cp.aggregateRating
    ? {
        average: cp.aggregateRating.toString(),
        count: cp.reviewCount,
      }
    : undefined;

  const priceStr = conn.offer.offeredPrice.toString();

  return {
    id: conn.id,
    offerId: conn.offerId,
    requestId: conn.requestId,
    state: conn.state,
    identityRevealedAt: conn.identityRevealedAt.toISOString(),
    closedAt: conn.closedAt?.toISOString(),
    closedBy: conn.closedBy ?? undefined,
    customer: {
      id: cp.id,
      displayName: cp.displayName,
      phone: cp.user.mobileNumber,
      connectionCount: cp.connectionCount,
      rating: customerRating,
    },
    offer: {
      id: conn.offer.id,
      offeredPrice: priceStr,
      makingCharges: conn.offer.makingCharges ? conn.offer.makingCharges.toString() : undefined,
      ratePerGram: conn.offer.ratePerGram ? conn.offer.ratePerGram.toString() : undefined,
      validityHours: conn.offer.validityHours,
      deliveryTimeframe: conn.offer.deliveryTimeframe ?? undefined,
      warrantyTerms: conn.offer.warrantyTerms ?? undefined,
      vendorNote: conn.offer.vendorNote ?? undefined,
    },
    request: {
      id: conn.request.id,
      reference: conn.request.reference ?? undefined,
      requestType: conn.request.requestType,
      direction: conn.request.direction,
      category: presentCategory(conn.request.category),
      region: presentRegion(conn.request.region),
    },
    talk: buildTalkDto(conn.state, cp.user.mobileNumber, conn.request.reference, priceStr, language),
  };
}
