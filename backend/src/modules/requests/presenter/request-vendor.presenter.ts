import type { Request } from '@prisma/client';

export type MaskedCustomerSummary = {
  label: string; // e.g. "Customer in Deira"
  region: string;
  ratingScore?: number | null;
  dealCount?: number;
};

export type CategorySummary = {
  id?: string;
  nameEn?: string;
  nameAr?: string;
  slug?: string;
  isActive?: boolean;
  displayOrder?: number;
};

export type RegionSummary = {
  id?: string;
  nameEn?: string;
  nameAr?: string;
  slug?: string;
  isActive?: boolean;
  displayOrder?: number;
};

export type MediaView = {
  id: string;
  key: string;
  contentType: string;
  displayOrder: number;
  thumbnailUrl?: string | null;
  displayUrl?: string | null;
};

export type VendorRequestView = {
  id: string;
  reference: string | null;
  requestType: string;
  direction: string;
  state: string;
  categoryId: string;
  category?: CategorySummary;
  regionId: string;
  region?: RegionSummary;
  notes: string | null;
  weightGrams: string | null;
  weightIsApproximate: boolean;
  purityKarat: string | null;
  ornamentType: string | null;
  condition: string | null;
  denominationGrams: string | null;
  quantity: number | null;
  mintOrRefiner: string | null;
  budgetMin: string | null;
  budgetMax: string | null;
  budgetIsFlexible: boolean;
  indicativeValue: string | null;
  gemstones: unknown;
  publishedAt: string | null;
  expiresAt: string | null;
  offerCount: number; // Aggregate count only (BR-008)
  media?: MediaView[];
  viewedAt?: string | null;
  customer: MaskedCustomerSummary;
  createdAt: string;
  updatedAt: string;
};

export function presentVendorRequest(
  request: Request & {
    category?: CategorySummary;
    region?: RegionSummary;
    media?: Array<{ displayOrder: number; media: { id: string; key: string; contentType: string } }>;
  },
  customerSummary?: Partial<MaskedCustomerSummary>,
  viewedAt?: Date | null,
): VendorRequestView {
  const mediaViews: MediaView[] | undefined = request.media?.map((m) => ({
    id: m.media.id,
    key: m.media.key,
    contentType: m.media.contentType,
    displayOrder: m.displayOrder,
  }));

  return {
    id: request.id,
    reference: request.reference,
    requestType: request.requestType,
    direction: request.direction,
    state: request.state,
    categoryId: request.categoryId,
    ...(request.category && {
      category: {
        id: request.category.id,
        nameEn: request.category.nameEn,
        nameAr: request.category.nameAr,
        slug: request.category.slug,
        isActive: request.category.isActive,
        displayOrder: request.category.displayOrder,
      },
    }),
    regionId: request.regionId,
    ...(request.region && {
      region: {
        id: request.region.id,
        nameEn: request.region.nameEn,
        nameAr: request.region.nameAr,
        slug: request.region.slug,
        isActive: request.region.isActive,
        displayOrder: request.region.displayOrder,
      },
    }),
    notes: request.notes,
    weightGrams: request.weightGrams ? request.weightGrams.toFixed(2) : null,
    weightIsApproximate: request.weightIsApproximate,
    purityKarat: request.purityKarat,
    ornamentType: request.ornamentType,
    condition: request.condition,
    denominationGrams: request.denominationGrams ? request.denominationGrams.toFixed(2) : null,
    quantity: request.quantity,
    mintOrRefiner: request.mintOrRefiner,
    budgetMin: request.budgetMin ? request.budgetMin.toFixed(2) : null,
    budgetMax: request.budgetMax ? request.budgetMax.toFixed(2) : null,
    budgetIsFlexible: request.budgetIsFlexible,
    indicativeValue: request.indicativeValue ? request.indicativeValue.toFixed(2) : null,
    gemstones: request.gemstones,
    publishedAt: request.publishedAt ? request.publishedAt.toISOString() : null,
    expiresAt: request.expiresAt ? request.expiresAt.toISOString() : null,
    offerCount: request.offerCount,
    ...(mediaViews && mediaViews.length > 0 && { media: mediaViews }),
    viewedAt: viewedAt ? viewedAt.toISOString() : null,
    customer: {
      label: customerSummary?.label ?? 'Customer',
      region: customerSummary?.region ?? (request.region?.nameEn ?? 'UAE'),
      ratingScore: customerSummary?.ratingScore ?? null,
      dealCount: customerSummary?.dealCount ?? 0,
    },
    createdAt: request.createdAt.toISOString(),
    updatedAt: request.updatedAt.toISOString(),
  };
}
