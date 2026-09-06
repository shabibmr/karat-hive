import type { RequestType, VendorTypeSubscription } from '@prisma/client';
import {
  computeSubscriptionState,
  type SubscriptionEntitlementState,
} from '../domain/subscription.types';

export type SubscriptionView = {
  requestType: RequestType;
  state: SubscriptionEntitlementState;
  periodStart: string | null;
  periodEnd: string | null;
  priceAed: string | null;
  graceEndsAt: string | null;
  renewalDate: string | null;
  paymentReference: string | null;
};

export function presentSubscription(
  requestType: RequestType,
  sub: VendorTypeSubscription | null,
  now: Date,
): SubscriptionView {
  const state = computeSubscriptionState(sub, now);

  if (!sub) {
    return {
      requestType,
      state: 'NONE',
      periodStart: null,
      periodEnd: null,
      priceAed: null,
      graceEndsAt: null,
      renewalDate: null,
      paymentReference: null,
    };
  }

  const periodEndIso = sub.periodEnd.toISOString();
  return {
    requestType: sub.requestType,
    state,
    periodStart: sub.periodStart.toISOString(),
    periodEnd: periodEndIso,
    priceAed: sub.priceAed.toFixed(2),
    graceEndsAt: sub.graceEndsAt ? sub.graceEndsAt.toISOString() : null,
    renewalDate: periodEndIso,
    paymentReference: sub.paymentReference ?? null,
  };
}
