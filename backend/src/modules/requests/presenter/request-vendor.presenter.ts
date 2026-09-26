import type { Request } from '@prisma/client';

export type MaskedCustomerSummary = {
  label: string; // e.g. "Customer in Deira"
  region: string;
  ratingScore?: number | null;
  dealCount?: number;
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
  /** True when this Vendor already has a non-terminal Offer on the Request. */
  hasResponded?: boolean;
  customer: MaskedCustomerSummary;
  createdAt: string;
  updatedAt: string;
};

export function presentVendorRequest(
  request: Request & {
    region?: RegionSummary;
    media?: Array<{
      displayOrder: number;
      media: { id: string; key: string; contentType: string; thumbnailKey?: string | null };
    }>;
  },
  customerSummary?: Partial<MaskedCustomerSummary>,
  viewedAt?: Date | null,
  hasResponded = false,
): VendorRequestView {
  // Served by GET /v1/media/:key (public, redirects to the object store) — the
  // client resolves this path against its own API base URL.
  const mediaViews: MediaView[] | undefined = request.media?.map((m) => ({
    id: m.media.id,
    key: m.media.key,
    contentType: m.media.contentType,
    displayOrder: m.displayOrder,
    displayUrl: `/v1/media/${m.media.key}`,
    thumbnailUrl: m.media.thumbnailKey
      ? `/v1/media/${m.media.thumbnailKey}`
      : `/v1/media/${m.media.key}`,
  }));

  return {
    id: request.id,
    reference: request.reference,
    requestType: request.requestType,
    direction: request.direction,
    state: request.state,
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
    hasResponded,
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
