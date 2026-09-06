import { RequestType, SubscriptionState, type VendorTypeSubscription } from '@prisma/client';

export const ALL_REQUEST_TYPES: readonly RequestType[] = [
  RequestType.FIND_ORNAMENT,
  RequestType.SELL_OLD_GOLD,
  RequestType.GOLD_COIN,
  RequestType.GOLD_BULLION,
] as const;

export type SubscriptionEntitlementState =
  | 'ACTIVE'
  | 'GRACE'
  | 'EXPIRED'
  | 'CANCELLED'
  | 'NONE';

/**
 * Evaluates the effective state of a subscription based on current timestamp (BR-002, AD-API-04).
 */
export function computeSubscriptionState(
  sub: VendorTypeSubscription | null,
  now: Date,
): SubscriptionEntitlementState {
  if (!sub) return 'NONE';

  if (sub.state === SubscriptionState.CANCELLED) {
    return 'CANCELLED';
  }

  const periodEnd = new Date(sub.periodEnd);
  const graceEnd = sub.graceEndsAt ? new Date(sub.graceEndsAt) : null;

  if (now <= periodEnd) {
    return sub.state === SubscriptionState.ACTIVE ? 'ACTIVE' : (sub.state as SubscriptionEntitlementState);
  }

  if (graceEnd && now <= graceEnd) {
    return 'GRACE';
  }

  return 'EXPIRED';
}
