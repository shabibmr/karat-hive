import type {
  AdminNote,
  AdminProfile,
  Category,
  Connection,
  CustomerProfile,
  Direction,
  ItemCondition,
  Karat,
  Media,
  Offer,
  OfferMedia,
  OfferRevision,
  OfferState,
  OrnamentType,
  Region,
  Request,
  RequestMatch,
  RequestMedia,
  RequestState,
  RequestType,
  User,
  VendorProfile,
} from '@prisma/client';
import type { AdminNoteView } from './admin-vendor.presenter';

export type StateTransitionView = {
  fromState?: string | null;
  toState: string;
  transition: string;
  timestamp: string;
  actorUserId?: string | null;
  actorName?: string | null;
  reason?: string | null;
};

export type UnmaskedCustomerView = {
  id: string;
  userId: string;
  displayName: string;
  mobileNumber?: string;
  email?: string | null;
  accountState?: string;
};

export type UnmaskedVendorSummary = {
  id: string;
  legalBusinessName: string;
  tradingName: string;
  tradeLicenceNumber?: string;
  mobileNumber?: string;
  email?: string | null;
  user?: {
    id: string;
    mobileNumber: string;
    email?: string | null;
  };
};

export type AdminRequestListItem = {
  id: string;
  reference: string | null;
  requestType: RequestType;
  direction: Direction;
  state: RequestState;
  customer: UnmaskedCustomerView;
  category: {
    id: string;
    nameEn: string;
    nameAr: string;
  };
  region: {
    id: string;
    nameEn: string;
    nameAr: string;
  };
  indicativeValue: number | null;
  budgetMin: number | null;
  budgetMax: number | null;
  budgetIsFlexible: boolean;
  offerCount: number;
  publishedAt: string | null;
  expiresAt: string | null;
  createdAt: string;
  updatedAt: string;
};

export type AdminRequestListPage = {
  data: AdminRequestListItem[];
  meta: {
    total?: number;
    nextCursor: string | null;
    hasMore: boolean;
  };
};

export type MatchedVendorForAdmin = {
  vendorProfileId: string;
  isEligible: boolean;
  matchedAt: string;
  viewedAt?: string | null;
  vendor: UnmaskedVendorSummary;
};

export type OfferOnRequestForAdmin = {
  id: string;
  state: OfferState;
  offeredPrice: number;
  makingCharges: number | null;
  ratePerGram: number | null;
  deliveryTimeframe: string | null;
  warrantyTerms: string | null;
  vendorNote: string | null;
  validityHours: number;
  expiresAt: string;
  revisionCount: number;
  submittedAt: string;
  decidedAt: string | null;
  declineReason: string | null;
  createdAt: string;
  updatedAt: string;
  vendor: UnmaskedVendorSummary;
};

export type AdminRequestDetail = {
  id: string;
  reference: string | null;
  requestType: RequestType;
  direction: Direction;
  state: RequestState;
  customer: UnmaskedCustomerView;
  category: {
    id: string;
    nameEn: string;
    nameAr: string;
  };
  region: {
    id: string;
    nameEn: string;
    nameAr: string;
  };
  indicativeValue: number | null;
  budgetMin: number | null;
  budgetMax: number | null;
  budgetIsFlexible: boolean;
  notes: string | null;
  weightGrams: number | null;
  weightIsApproximate: boolean;
  purityKarat: Karat | null;
  ornamentType: OrnamentType | null;
  condition: ItemCondition | null;
  denominationGrams: number | null;
  quantity: number | null;
  mintOrRefiner: string | null;
  gemstones: unknown;
  cancellationReason: string | null;
  offerCount: number;
  publishedAt: string | null;
  expiresAt: string | null;
  createdAt: string;
  updatedAt: string;
  media: Array<{
    id: string;
    mediaId: string;
    displayOrder: number;
    media?: {
      id: string;
      bucket: string;
      storageKey: string;
      mimeType: string;
      byteSize: number;
      scanState?: string;
    };
  }>;
  matchedVendors: MatchedVendorForAdmin[];
  offers: OfferOnRequestForAdmin[];
  transitions: StateTransitionView[];
  connection: {
    id: string;
    state: string;
    identityRevealedAt: string;
    closedAt?: string | null;
    closedBy?: string | null;
    vendor?: {
      id: string;
      legalBusinessName: string;
      tradingName: string;
    };
  } | null;
  internalNotes: AdminNoteView[];
};

export type RequestListRow = Request & {
  customerProfile: CustomerProfile & { user?: User };
  category: Category;
  region: Region;
};

export type RequestDetailRow = Request & {
  customerProfile: CustomerProfile & { user?: User };
  category: Category;
  region: Region;
  media?: Array<RequestMedia & { media?: Media }>;
  matches?: Array<RequestMatch & { vendorProfile?: VendorProfile & { user?: User } }>;
  offers?: Array<Offer & { vendorProfile?: VendorProfile & { user?: User }; revisions?: OfferRevision[] }>;
  connections?: Array<Connection & { vendorProfile?: VendorProfile & { user?: User }; customerProfile?: CustomerProfile & { user?: User } }>;
  acceptedOffer?: (Offer & { vendorProfile?: VendorProfile & { user?: User } }) | null;
  notes?: Array<AdminNote & { author?: AdminProfile & { user?: User } }>;
  transitions?: StateTransitionView[];
};

export function presentAdminRequestListItem(row: RequestListRow): AdminRequestListItem {
  return {
    id: row.id,
    reference: row.reference,
    requestType: row.requestType,
    direction: row.direction,
    state: row.state,
    customer: {
      id: row.customerProfile.id,
      userId: row.customerProfile.userId,
      displayName: row.customerProfile.displayName,
      mobileNumber: row.customerProfile.user?.mobileNumber,
      email: row.customerProfile.user?.email,
      accountState: row.customerProfile.user?.accountState,
    },
    category: {
      id: row.category.id,
      nameEn: row.category.nameEn,
      nameAr: row.category.nameAr,
    },
    region: {
      id: row.region.id,
      nameEn: row.region.nameEn,
      nameAr: row.region.nameAr,
    },
    indicativeValue: row.indicativeValue ? Number(row.indicativeValue) : null,
    budgetMin: row.budgetMin ? Number(row.budgetMin) : null,
    budgetMax: row.budgetMax ? Number(row.budgetMax) : null,
    budgetIsFlexible: row.budgetIsFlexible,
    offerCount: row.offerCount,
    publishedAt: row.publishedAt ? row.publishedAt.toISOString() : null,
    expiresAt: row.expiresAt ? row.expiresAt.toISOString() : null,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

export function buildRequestStateTransitions(row: {
  createdAt: Date;
  publishedAt?: Date | null;
  expiresAt?: Date | null;
  updatedAt: Date;
  state: RequestState;
  offerCount: number;
  cancellationReason?: string | null;
  offers?: Array<{ submittedAt: Date; decidedAt?: Date | null; state: OfferState }>;
  connections?: Array<{ identityRevealedAt: Date }>;
  acceptedOffer?: { decidedAt?: Date | null } | null;
}): StateTransitionView[] {
  const transitions: StateTransitionView[] = [
    {
      fromState: null,
      toState: 'DRAFT',
      transition: 'CREATE_DRAFT',
      timestamp: row.createdAt.toISOString(),
    },
  ];

  if (row.publishedAt) {
    transitions.push({
      fromState: 'DRAFT',
      toState: 'PUBLISHED',
      transition: 'PUBLISH_REQUEST',
      timestamp: row.publishedAt.toISOString(),
    });
  }

  if (row.offers && row.offers.length > 0) {
    const earliestOffer = [...row.offers].sort(
      (a, b) => a.submittedAt.getTime() - b.submittedAt.getTime(),
    )[0]!;
    transitions.push({
      fromState: 'PUBLISHED',
      toState: 'OFFERS_RECEIVED',
      transition: 'FIRST_OFFER_RECEIVED',
      timestamp: earliestOffer.submittedAt.toISOString(),
    });
  }

  if (row.state === 'ACCEPTED') {
    const acceptedAt =
      row.acceptedOffer?.decidedAt ??
      row.connections?.[0]?.identityRevealedAt ??
      row.updatedAt;
    transitions.push({
      fromState: 'OFFERS_RECEIVED',
      toState: 'ACCEPTED',
      transition: 'OFFER_ACCEPTED',
      timestamp: acceptedAt.toISOString(),
    });
  } else if (row.state === 'CLOSED') {
    transitions.push({
      fromState: 'ACCEPTED',
      toState: 'CLOSED',
      transition: 'CONNECTION_CLOSED',
      timestamp: row.updatedAt.toISOString(),
    });
  } else if (row.state === 'EXPIRED') {
    transitions.push({
      fromState: row.offerCount > 0 ? 'OFFERS_RECEIVED' : 'PUBLISHED',
      toState: 'EXPIRED',
      transition: 'REQUEST_EXPIRED',
      timestamp: (row.expiresAt ?? row.updatedAt).toISOString(),
    });
  } else if (row.state === 'CANCELLED') {
    transitions.push({
      fromState: row.offerCount > 0 ? 'OFFERS_RECEIVED' : 'PUBLISHED',
      toState: 'CANCELLED',
      transition: 'CUSTOMER_CANCELLED',
      timestamp: row.updatedAt.toISOString(),
      reason: row.cancellationReason ?? null,
    });
  } else if (row.state === 'REMOVED') {
    transitions.push({
      fromState: row.offerCount > 0 ? 'OFFERS_RECEIVED' : 'PUBLISHED',
      toState: 'REMOVED',
      transition: 'ADMIN_REMOVED',
      timestamp: row.updatedAt.toISOString(),
      reason: row.cancellationReason ?? null,
    });
  }

  return transitions.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
}

export function presentAdminRequestDetail(row: RequestDetailRow): AdminRequestDetail {
  const base = presentAdminRequestListItem(row);

  const matchedVendors: MatchedVendorForAdmin[] = (row.matches ?? []).map((m) => ({
    vendorProfileId: m.vendorProfileId,
    isEligible: m.isEligible,
    matchedAt: m.matchedAt.toISOString(),
    viewedAt: m.viewedAt ? m.viewedAt.toISOString() : null,
    vendor: {
      id: m.vendorProfile?.id ?? m.vendorProfileId,
      legalBusinessName: m.vendorProfile?.legalBusinessName ?? '',
      tradingName: m.vendorProfile?.tradingName ?? '',
      tradeLicenceNumber: m.vendorProfile?.tradeLicenceNumber,
      mobileNumber: m.vendorProfile?.user?.mobileNumber,
      email: m.vendorProfile?.user?.email,
      user: m.vendorProfile?.user
        ? {
            id: m.vendorProfile.user.id,
            mobileNumber: m.vendorProfile.user.mobileNumber,
            email: m.vendorProfile.user.email,
          }
        : undefined,
    },
  }));

  const offers: OfferOnRequestForAdmin[] = (row.offers ?? []).map((o) => ({
    id: o.id,
    state: o.state,
    offeredPrice: Number(o.offeredPrice),
    makingCharges: o.makingCharges ? Number(o.makingCharges) : null,
    ratePerGram: o.ratePerGram ? Number(o.ratePerGram) : null,
    deliveryTimeframe: o.deliveryTimeframe,
    warrantyTerms: o.warrantyTerms,
    vendorNote: o.vendorNote,
    validityHours: o.validityHours,
    expiresAt: o.expiresAt.toISOString(),
    revisionCount: o.revisionCount,
    submittedAt: o.submittedAt.toISOString(),
    decidedAt: o.decidedAt ? o.decidedAt.toISOString() : null,
    declineReason: o.declineReason,
    createdAt: o.createdAt.toISOString(),
    updatedAt: o.updatedAt.toISOString(),
    vendor: {
      id: o.vendorProfile?.id ?? o.vendorProfileId,
      legalBusinessName: o.vendorProfile?.legalBusinessName ?? '',
      tradingName: o.vendorProfile?.tradingName ?? '',
      tradeLicenceNumber: o.vendorProfile?.tradeLicenceNumber,
      mobileNumber: o.vendorProfile?.user?.mobileNumber,
      email: o.vendorProfile?.user?.email,
      user: o.vendorProfile?.user
        ? {
            id: o.vendorProfile.user.id,
            mobileNumber: o.vendorProfile.user.mobileNumber,
            email: o.vendorProfile.user.email,
          }
        : undefined,
    },
  }));

  const activeConnection = (row.connections ?? [])[0] ?? null;
  const connection = activeConnection
    ? {
        id: activeConnection.id,
        state: activeConnection.state,
        identityRevealedAt: activeConnection.identityRevealedAt.toISOString(),
        closedAt: activeConnection.closedAt ? activeConnection.closedAt.toISOString() : null,
        closedBy: activeConnection.closedBy,
        vendor: activeConnection.vendorProfile
          ? {
              id: activeConnection.vendorProfile.id,
              legalBusinessName: activeConnection.vendorProfile.legalBusinessName,
              tradingName: activeConnection.vendorProfile.tradingName,
            }
          : undefined,
      }
    : null;

  const internalNotes: AdminNoteView[] = (row.notes ?? []).map((n) => ({
    id: n.id,
    text: n.text,
    authorAdminId: n.authorAdminId,
    authorDisplayName: n.author?.displayName,
    createdAt: n.createdAt.toISOString(),
  }));

  // Merge synthesized transitions with any persisted audit log transitions if passed
  const synthesized = buildRequestStateTransitions(row);
  const extraTransitions = row.transitions ?? [];
  const mergedTransitions = [...synthesized, ...extraTransitions].sort(
    (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime(),
  );

  return {
    ...base,
    notes: row.notes,
    weightGrams: row.weightGrams ? Number(row.weightGrams) : null,
    weightIsApproximate: row.weightIsApproximate,
    purityKarat: row.purityKarat,
    ornamentType: row.ornamentType,
    condition: row.condition,
    denominationGrams: row.denominationGrams ? Number(row.denominationGrams) : null,
    quantity: row.quantity,
    mintOrRefiner: row.mintOrRefiner,
    gemstones: row.gemstones,
    cancellationReason: row.cancellationReason,
    media: (row.media ?? []).map((m) => ({
      id: `${m.requestId}-${m.mediaId}`,
      mediaId: m.mediaId,
      displayOrder: m.displayOrder,
      media: m.media
        ? {
            id: m.media.id,
            bucket: m.media.bucket,
            storageKey: m.media.key,
            mimeType: m.media.contentType,
            byteSize: m.media.byteSize,
            scanState: m.media.malwareScanState,
          }
        : undefined,
    })),
    matchedVendors,
    offers,
    transitions: mergedTransitions,
    connection,
    internalNotes,
  };
}
