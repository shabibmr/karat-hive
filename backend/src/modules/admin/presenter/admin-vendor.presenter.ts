import type {
  AdminNote,
  AdminProfile,
  Category,
  Media,
  Offer,
  Region,
  User,
  UserAccountState,
  VendorCategory,
  VendorDocument,
  VendorProfile,
  VendorRegion,
  VendorTypeSubscription,
  VendorVerificationState,
} from '@prisma/client';
import {
  composeVendorLifecycle,
  type VendorAccountState,
} from '../../vendor-onboarding/domain/vendor-lifecycle';

const MS_PER_HOUR = 60 * 60 * 1000;

export type VerificationQueueItem = {
  id: string;
  legalBusinessName: string;
  tradeLicenceNumber: string;
  oldestWaitingHours: number;
  tradingName?: string;
  submittedAt?: string;
};

export type VendorListItem = {
  id: string;
  legalBusinessName: string;
  tradingName: string;
  tradeLicenceNumber?: string;
  verificationState: VendorVerificationState;
  accountState: UserAccountState;
  waitingHours?: number;
  registeredAt?: string;
};

export type VendorDocumentDetail = {
  id: string;
  documentType: VendorDocument['documentType'];
  uploadedAt: string;
  fileName?: string;
  mimeType?: string;
  sizeBytes?: number;
  expiryDate?: string;
  verified: boolean;
};

export type AdminNoteView = {
  id: string;
  text: string;
  authorAdminId: string;
  authorDisplayName?: string;
  createdAt: string;
};

export type VendorPerformanceView = {
  aggregateRating: number | null;
  reviewCount: number;
  offersSubmittedCount: number;
  offersAcceptedCount: number;
  acceptanceRate: number;
};

export type VendorSubscriptionView = {
  id: string;
  requestType: string;
  state: string;
  periodStart: string;
  periodEnd: string;
};

export type VendorVerificationDetail = {
  id: string;
  legalBusinessName: string;
  tradeLicenceNumber: string;
  licenceExpiryDate: string;
  businessAddress: string;
  contactPersonName: string;
  businessEmail: string;
  description?: string | null;
  awayMode?: boolean;
  verificationState: VendorVerificationState;
  accountState: UserAccountState;
  lifecycle: VendorAccountState;
  activatedAt?: string | null;
  verifiedAt?: string | null;
  verifiedByAdmin?: { id: string; displayName: string } | null;
  verificationNotes?: string | null;
  verificationMessage?: string | null;
  documents: VendorDocumentDetail[];
  categories: string[];
  categoryDetails?: Array<{ id: string; nameEn: string; nameAr: string }>;
  regions: string[];
  regionDetails?: Array<{ id: string; nameEn: string; nameAr: string }>;
  tradingName?: string;
  mobileNumber?: string;
  user?: {
    id: string;
    mobileNumber: string;
    email: string | null;
    accountState: UserAccountState;
    createdAt: string;
    lastLoginAt?: string | null;
  };
  notes?: AdminNoteView[];
  performance?: VendorPerformanceView;
  subscriptions?: VendorSubscriptionView[];
  oldestWaitingHours?: number;
  submittedAt?: string;
  createdAt: string;
  updatedAt: string;
};

export type DocumentUrlView = {
  url: string;
  expiresAt: string;
};

export type VendorListPage = {
  data: VendorListItem[];
  meta: {
    total?: number;
    nextCursor: string | null;
    hasMore: boolean;
  };
};

export type VendorWithUser = VendorProfile & { user: User };

export type VendorDocumentRow = VendorDocument & { media: Media };

export type VendorDetailRow = VendorProfile & {
  user: User;
  documents?: VendorDocumentRow[];
  categories?: Array<VendorCategory & { category: Category }>;
  regions?: Array<VendorRegion & { region: Region }>;
  verifiedByAdmin?: (AdminProfile & { user?: User }) | null;
  notes?: Array<AdminNote & { author?: AdminProfile & { user?: User } }>;
  subscriptions?: VendorTypeSubscription[];
  offers?: Offer[];
};

export function pendingSubmittedAt(profile: { createdAt: Date; updatedAt?: Date }): Date {
  return profile.createdAt;
}

export function waitingHoursSince(submittedAt: Date, now: Date): number {
  const elapsed = now.getTime() - submittedAt.getTime();
  return Math.max(0, Number((elapsed / MS_PER_HOUR).toFixed(2)));
}

export function presentVerificationQueueItem(
  profile: VendorWithUser & { oldestWaitingHours?: number },
  now: Date,
): VerificationQueueItem {
  const submittedAt = pendingSubmittedAt(profile);
  const waitingHours =
    profile.oldestWaitingHours !== undefined
      ? profile.oldestWaitingHours
      : waitingHoursSince(submittedAt, now);
  return {
    id: profile.id,
    legalBusinessName: profile.legalBusinessName,
    tradeLicenceNumber: profile.tradeLicenceNumber,
    oldestWaitingHours: waitingHours,
    tradingName: profile.tradingName,
    submittedAt: submittedAt.toISOString(),
  };
}

export function presentVendorListItem(profile: VendorWithUser, now: Date): VendorListItem {
  const submittedAt =
    profile.verificationState === 'PENDING_VERIFICATION' ? pendingSubmittedAt(profile) : null;
  return {
    id: profile.id,
    legalBusinessName: profile.legalBusinessName,
    tradingName: profile.tradingName,
    tradeLicenceNumber: profile.tradeLicenceNumber,
    verificationState: profile.verificationState,
    accountState: profile.user.accountState,
    ...(submittedAt
      ? { waitingHours: Math.floor(waitingHoursSince(submittedAt, now)) }
      : {}),
    registeredAt: profile.createdAt.toISOString(),
  };
}

function documentFileName(documentType: VendorDocument['documentType'], media: Media): string {
  const ext = media.contentType?.split('/')[1] ?? 'bin';
  return `${documentType.toLowerCase()}.${ext}`;
}

export function presentVendorDocumentDetail(row: VendorDocumentRow): VendorDocumentDetail {
  return {
    id: row.id,
    documentType: row.documentType,
    uploadedAt: row.uploadedAt.toISOString(),
    fileName: documentFileName(row.documentType, row.media),
    mimeType: row.media.contentType,
    sizeBytes: row.media.byteSize,
    expiryDate: row.expiryDate ? row.expiryDate.toISOString().slice(0, 10) : undefined,
    verified: row.verified,
  };
}

export function presentVendorVerificationDetail(
  profile: VendorWithUser,
  documents: VendorDocumentRow[],
  categories: Category[],
  regions: Region[],
  now: Date,
): VendorVerificationDetail {
  const submittedAt =
    profile.verificationState === 'PENDING_VERIFICATION' ? pendingSubmittedAt(profile) : null;
  const lifecycle = composeVendorLifecycle({
    accountState: profile.user.accountState,
    verificationState: profile.verificationState,
    activatedAt: profile.activatedAt,
    hasMandatoryDocuments: documents.length > 0,
    hasCategories: categories.length > 0,
    hasRegions: regions.length > 0,
  });

  const aggregateRatingNum = profile.aggregateRating !== null ? Number(profile.aggregateRating) : null;
  const acceptanceRate =
    profile.offersSubmittedCount > 0
      ? Number(((profile.offersAcceptedCount / profile.offersSubmittedCount) * 100).toFixed(1))
      : 0;

  return {
    id: profile.id,
    legalBusinessName: profile.legalBusinessName,
    tradeLicenceNumber: profile.tradeLicenceNumber,
    licenceExpiryDate: profile.licenceExpiryDate.toISOString().slice(0, 10),
    businessAddress: profile.businessAddress,
    contactPersonName: profile.contactPersonName,
    businessEmail: profile.businessEmail,
    description: profile.description,
    awayMode: profile.awayMode,
    verificationState: profile.verificationState,
    accountState: profile.user.accountState,
    lifecycle,
    activatedAt: profile.activatedAt ? profile.activatedAt.toISOString() : null,
    verifiedAt: profile.verifiedAt ? profile.verifiedAt.toISOString() : null,
    verificationNotes: profile.verificationNotes,
    verificationMessage: profile.verificationMessage,
    documents: documents.map(presentVendorDocumentDetail),
    categories: categories.map((c) => c.nameEn),
    categoryDetails: categories.map((c) => ({ id: c.id, nameEn: c.nameEn, nameAr: c.nameAr })),
    regions: regions.map((r) => r.nameEn),
    regionDetails: regions.map((r) => ({ id: r.id, nameEn: r.nameEn, nameAr: r.nameAr })),
    tradingName: profile.tradingName,
    mobileNumber: profile.user.mobileNumber,
    user: {
      id: profile.user.id,
      mobileNumber: profile.user.mobileNumber,
      email: profile.user.email,
      accountState: profile.user.accountState,
      createdAt: profile.user.createdAt.toISOString(),
      lastLoginAt: profile.user.lastLoginAt ? profile.user.lastLoginAt.toISOString() : null,
    },
    performance: {
      aggregateRating: aggregateRatingNum,
      reviewCount: profile.reviewCount,
      offersSubmittedCount: profile.offersSubmittedCount,
      offersAcceptedCount: profile.offersAcceptedCount,
      acceptanceRate,
    },
    ...(submittedAt
      ? {
          submittedAt: submittedAt.toISOString(),
          oldestWaitingHours: waitingHoursSince(submittedAt, now),
        }
      : {}),
    createdAt: profile.createdAt.toISOString(),
    updatedAt: profile.updatedAt.toISOString(),
  };
}

export function presentVendorDetail(row: VendorDetailRow, now: Date): VendorVerificationDetail {
  const documents = row.documents ?? [];
  const categories = (row.categories ?? []).map((vc) => vc.category);
  const regions = (row.regions ?? []).map((vr) => vr.region);
  const base = presentVendorVerificationDetail(row, documents, categories, regions, now);

  if (row.verifiedByAdmin) {
    base.verifiedByAdmin = {
      id: row.verifiedByAdmin.id,
      displayName: row.verifiedByAdmin.displayName,
    };
  }

  if (row.notes) {
    base.notes = row.notes.map((n) => ({
      id: n.id,
      text: n.text,
      authorAdminId: n.authorAdminId,
      authorDisplayName: n.author?.displayName,
      createdAt: n.createdAt.toISOString(),
    }));
  }

  if (row.subscriptions) {
    base.subscriptions = row.subscriptions.map((s) => ({
      id: s.id,
      requestType: s.requestType,
      state: s.state,
      periodStart: s.periodStart.toISOString(),
      periodEnd: s.periodEnd.toISOString(),
    }));
  }

  return base;
}