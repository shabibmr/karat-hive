import type { VendorTypeSubscription } from '@prisma/client';

export interface SubscriptionView {
  id: string;
  requestType: string;
  state: string;
  periodStart: string;
  periodEnd: string;
  priceAed: string;
  graceEndsAt?: string;
  paymentReference?: string;
}

export function presentSubscription(sub: VendorTypeSubscription): SubscriptionView {
  return {
    id: sub.id,
    requestType: sub.requestType,
    state: sub.state,
    periodStart: sub.periodStart.toISOString(),
    periodEnd: sub.periodEnd.toISOString(),
    priceAed: Number(sub.priceAed).toFixed(2),
    ...(sub.graceEndsAt ? { graceEndsAt: sub.graceEndsAt.toISOString() } : {}),
    ...(sub.paymentReference ? { paymentReference: sub.paymentReference } : {}),
  };
}
