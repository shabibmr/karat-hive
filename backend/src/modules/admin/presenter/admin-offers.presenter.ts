import type {
  AdminNote,
  AdminProfile,
  Category,
  Connection,
  CustomerProfile,
  DeclineReason,
  Direction,
  Media,
  Offer,
  OfferMedia,
  OfferRevision,
  OfferState,
  Region,
  Request,
  RequestState,
  RequestType,
  User,
  VendorProfile,
} from '@prisma/client';
import type { AdminNoteView } from './admin-vendor.presenter';
import type {
  StateTransitionView,
  UnmaskedCustomerView,
  UnmaskedVendorSummary,
} from './admin-requests.presenter';

export type AdminOfferListItem = {
  id: string;
  requestId: string;
  vendorProfileId: string;
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
  declineReason: DeclineReason | null;
  createdAt: string;
  updatedAt: string;
  vendor: UnmaskedVendorSummary;
  request: {
    id: string;
    reference: string | null;
    requestType: RequestType;
    direction: Direction;
    state: RequestState;
    indicativeValue?: number | null;
    customer?: UnmaskedCustomerView;
    category?: { id: string; nameEn: string; nameAr: string };
    region?: { id: string; nameEn: string; nameAr: string };
  };
};

export type AdminOfferListPage = {
  data: AdminOfferListItem[];
  meta: {
    total?: number;
    nextCursor: string | null;
    hasMore: boolean;
  };
};

export type OfferRevisionView = {
  id: string;
  revisionNumber: number;
  previousTerms: unknown;
  revisedAt: string;
};

export type AdminOfferDetail = AdminOfferListItem & {
  revisions: OfferRevisionView[];
  transitions: StateTransitionView[];
  winningOfferId: string | null;
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
  connection: {
    id: string;
    state: string;
    identityRevealedAt: string;
    closedAt?: string | null;
    closedBy?: string | null;
  } | null;
  internalNotes: AdminNoteView[];
};

export type OfferListRow = Offer & {
  vendorProfile: VendorProfile & { user?: User };
  request: Request & {
    customerProfile?: CustomerProfile & { user?: User };
    category?: Category;
    region?: Region;
  };
};

export type OfferDetailRow = Offer & {
  vendorProfile: VendorProfile & { user?: User };
  request: Request & {
    customerProfile?: CustomerProfile & { user?: User };
    category?: Category;
    region?: Region;
    acceptedOffer?: Offer | null;
  };
  revisions?: OfferRevision[];
  media?: Array<OfferMedia & { media?: Media }>;
  connection?: Connection | null;
  notes?: Array<AdminNote & { author?: AdminProfile & { user?: User } }>;
  transitions?: StateTransitionView[];
};

export function presentAdminOfferListItem(row: OfferListRow): AdminOfferListItem {
  return {
    id: row.id,
    requestId: row.requestId,
    vendorProfileId: row.vendorProfileId,
    state: row.state,
    offeredPrice: Number(row.offeredPrice),
    makingCharges: row.makingCharges ? Number(row.makingCharges) : null,
    ratePerGram: row.ratePerGram ? Number(row.ratePerGram) : null,
    deliveryTimeframe: row.deliveryTimeframe,
    warrantyTerms: row.warrantyTerms,
    vendorNote: row.vendorNote,
    validityHours: row.validityHours,
    expiresAt: row.expiresAt.toISOString(),
    revisionCount: row.revisionCount,
    submittedAt: row.submittedAt.toISOString(),
    decidedAt: row.decidedAt ? row.decidedAt.toISOString() : null,
    declineReason: row.declineReason,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
    vendor: {
      id: row.vendorProfile.id,
      legalBusinessName: row.vendorProfile.legalBusinessName,
      tradingName: row.vendorProfile.tradingName,
      tradeLicenceNumber: row.vendorProfile.tradeLicenceNumber,
      mobileNumber: row.vendorProfile.user?.mobileNumber,
      email: row.vendorProfile.user?.email,
      user: row.vendorProfile.user
        ? {
            id: row.vendorProfile.user.id,
            mobileNumber: row.vendorProfile.user.mobileNumber,
            email: row.vendorProfile.user.email,
          }
        : undefined,
    },
    request: {
      id: row.request.id,
      reference: row.request.reference,
      requestType: row.request.requestType,
      direction: row.request.direction,
      state: row.request.state,
      indicativeValue: row.request.indicativeValue ? Number(row.request.indicativeValue) : null,
      customer: row.request.customerProfile
        ? {
            id: row.request.customerProfile.id,
            userId: row.request.customerProfile.userId,
            displayName: row.request.customerProfile.displayName,
            mobileNumber: row.request.customerProfile.user?.mobileNumber,
            email: row.request.customerProfile.user?.email,
            accountState: row.request.customerProfile.user?.accountState,
          }
        : undefined,
      category: row.request.category
        ? {
            id: row.request.category.id,
            nameEn: row.request.category.nameEn,
            nameAr: row.request.category.nameAr,
          }
        : undefined,
      region: row.request.region
        ? {
            id: row.request.region.id,
            nameEn: row.request.region.nameEn,
            nameAr: row.request.region.nameAr,
          }
        : undefined,
    },
  };
}

export function buildOfferStateTransitions(row: {
  submittedAt: Date;
  expiresAt: Date;
  decidedAt?: Date | null;
  updatedAt: Date;
  state: OfferState;
  declineReason?: DeclineReason | null;
  revisions?: OfferRevision[];
}): StateTransitionView[] {
  const transitions: StateTransitionView[] = [
    {
      fromState: null,
      toState: 'PENDING',
      transition: 'OFFER_SUBMITTED',
      timestamp: row.submittedAt.toISOString(),
    },
  ];

  if (row.revisions && row.revisions.length > 0) {
    const sortedRevs = [...row.revisions].sort(
      (a, b) => a.revisedAt.getTime() - b.revisedAt.getTime(),
    );
    for (const rev of sortedRevs) {
      transitions.push({
        fromState: 'PENDING',
        toState: 'PENDING',
        transition: `OFFER_REVISED_V${rev.revisionNumber}`,
        timestamp: rev.revisedAt.toISOString(),
      });
    }
  }

  if (row.state === 'ACCEPTED') {
    transitions.push({
      fromState: 'PENDING',
      toState: 'ACCEPTED',
      transition: 'OFFER_ACCEPTED',
      timestamp: (row.decidedAt ?? row.updatedAt).toISOString(),
    });
  } else if (row.state === 'REJECTED') {
    transitions.push({
      fromState: 'PENDING',
      toState: 'REJECTED',
      transition: 'OFFER_REJECTED',
      timestamp: (row.decidedAt ?? row.updatedAt).toISOString(),
      reason: row.declineReason ?? null,
    });
  } else if (row.state === 'EXPIRED') {
    transitions.push({
      fromState: 'PENDING',
      toState: 'EXPIRED',
      transition: 'OFFER_EXPIRED',
      timestamp: row.expiresAt.toISOString(),
    });
  } else if (row.state === 'WITHDRAWN') {
    transitions.push({
      fromState: 'PENDING',
      toState: 'WITHDRAWN',
      transition: 'VENDOR_WITHDRAWN',
      timestamp: row.updatedAt.toISOString(),
    });
  } else if (row.state === 'WITHDRAWN_BY_SYSTEM') {
    transitions.push({
      fromState: 'PENDING',
      toState: 'WITHDRAWN_BY_SYSTEM',
      transition: 'SYSTEM_WITHDRAWN',
      timestamp: row.updatedAt.toISOString(),
      reason: 'Parent request removed by admin',
    });
  }

  return transitions.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
}

export function presentAdminOfferDetail(row: OfferDetailRow): AdminOfferDetail {
  const base = presentAdminOfferListItem(row);

  const revisions: OfferRevisionView[] = (row.revisions ?? []).map((rev) => ({
    id: rev.id,
    revisionNumber: rev.revisionNumber,
    previousTerms: rev.previousTerms,
    revisedAt: rev.revisedAt.toISOString(),
  }));

  // FR-ADM-021 AC2: Where the Offer was rejected because a competitor's Offer was accepted,
  // the winning Offer is linked — Admin-only visibility.
  const parentAcceptedOfferId = row.request?.acceptedOfferId ?? null;
  const winningOfferId =
    parentAcceptedOfferId && parentAcceptedOfferId !== row.id
      ? parentAcceptedOfferId
      : null;

  const connection = row.connection
    ? {
        id: row.connection.id,
        state: row.connection.state,
        identityRevealedAt: row.connection.identityRevealedAt.toISOString(),
        closedAt: row.connection.closedAt ? row.connection.closedAt.toISOString() : null,
        closedBy: row.connection.closedBy,
      }
    : null;

  const internalNotes: AdminNoteView[] = (row.notes ?? []).map((n) => ({
    id: n.id,
    text: n.text,
    authorAdminId: n.authorAdminId,
    authorDisplayName: n.author?.displayName,
    createdAt: n.createdAt.toISOString(),
  }));

  const synthesized = buildOfferStateTransitions(row);
  const extraTransitions = row.transitions ?? [];
  const mergedTransitions = [...synthesized, ...extraTransitions].sort(
    (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime(),
  );

  return {
    ...base,
    revisions,
    transitions: mergedTransitions,
    winningOfferId,
    media: (row.media ?? []).map((m) => ({
      id: `${m.offerId}-${m.mediaId}`,
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
    connection,
    internalNotes,
  };
}
