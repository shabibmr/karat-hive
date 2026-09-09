import type { VendorDocument, VendorProfile } from '@prisma/client';
import {
  awaitingApprovalReason,
  composeVendorLifecycle,
  type VendorLifecycleInput,
} from '../domain/vendor-lifecycle';

export type VendorMe = {
  vendorProfileId: string;
  lifecycle: ReturnType<typeof composeVendorLifecycle>;
  awaitingApproval: boolean;
  awaitingApprovalReason?: string;
  verificationMessage?: string;
  legalBusinessName: string;
  tradingName: string;
  tradeLicenceNumber: string;
  licenceExpiryDate: string;
  businessAddress: string;
  contactPersonName: string;
  businessEmail: string;
  description: string | null;
  businessHours: unknown | null;
  verifiedAt: string | null;
  categoryCount: number;
  regionCount: number;
  categoryIds: string[];
  regionIds: string[];
  awayMode: boolean;
};

export type VendorDocumentView = {
  id: string;
  documentType: VendorDocument['documentType'];
  verified: boolean;
  expiryDate: string | null;
  uploadedAt: string;
};

export function presentVendorMe(
  profile: VendorProfile,
  lifecycleInput: VendorLifecycleInput,
  counts: {
    categoryCount: number;
    regionCount: number;
    categoryIds?: string[];
    regionIds?: string[];
  },
): VendorMe {
  const lifecycle = composeVendorLifecycle(lifecycleInput);
  const reason = awaitingApprovalReason(lifecycleInput);
  return {
    vendorProfileId: profile.id,
    lifecycle,
    awaitingApproval: lifecycle !== 'ACTIVE',
    awaitingApprovalReason: reason,
    verificationMessage: profile.verificationMessage ?? undefined,
    legalBusinessName: profile.legalBusinessName,
    tradingName: profile.tradingName,
    tradeLicenceNumber: profile.tradeLicenceNumber,
    licenceExpiryDate: profile.licenceExpiryDate.toISOString().slice(0, 10),
    businessAddress: profile.businessAddress,
    contactPersonName: profile.contactPersonName,
    businessEmail: profile.businessEmail,
    description: profile.description ?? null,
    businessHours: profile.businessHours ?? null,
    verifiedAt: profile.verifiedAt ? profile.verifiedAt.toISOString() : null,
    categoryCount: counts.categoryCount,
    regionCount: counts.regionCount,
    categoryIds: counts.categoryIds ?? [],
    regionIds: counts.regionIds ?? [],
    awayMode: profile.awayMode,
  };
}

export function presentVendorDocument(doc: VendorDocument): VendorDocumentView {
  return {
    id: doc.id,
    documentType: doc.documentType,
    verified: doc.verified,
    expiryDate: doc.expiryDate ? doc.expiryDate.toISOString().slice(0, 10) : null,
    uploadedAt: doc.uploadedAt.toISOString(),
  };
}
