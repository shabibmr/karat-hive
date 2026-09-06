import type { Request } from '@prisma/client';

export type CustomerRequestView = {
  id: string;
  reference: string | null;
  requestType: string;
  direction: string;
  state: string;
  categoryId: string;
  regionId: string;
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
  offerCount: number;
  createdAt: string;
  updatedAt: string;
};

export function presentCustomerRequest(request: Request): CustomerRequestView {
  return {
    id: request.id,
    reference: request.reference,
    requestType: request.requestType,
    direction: request.direction,
    state: request.state,
    categoryId: request.categoryId,
    regionId: request.regionId,
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
    createdAt: request.createdAt.toISOString(),
    updatedAt: request.updatedAt.toISOString(),
  };
}
