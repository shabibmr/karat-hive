import { describe, expect, it } from 'vitest';
import type { VendorTypeSubscription } from '@prisma/client';
import { computeSubscriptionState } from './subscription.types';

function sub(
  overrides: Partial<VendorTypeSubscription> & Pick<VendorTypeSubscription, 'state' | 'periodEnd'>,
): VendorTypeSubscription {
  return {
    id: 'sub-1',
    vendorProfileId: 'vp-1',
    requestType: 'FIND_ORNAMENT',
    periodStart: new Date('2026-08-01T00:00:00Z'),
    graceEndsAt: null,
    priceAed: 100 as never,
    paymentReference: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

describe('computeSubscriptionState (VO-04)', () => {
  const now = new Date('2026-09-20T12:00:00Z');

  it('returns NONE for null', () => {
    expect(computeSubscriptionState(null, now)).toBe('NONE');
  });

  it('returns CANCELLED regardless of dates', () => {
    expect(
      computeSubscriptionState(
        sub({ state: 'CANCELLED', periodEnd: new Date('2026-10-01T00:00:00Z') }),
        now,
      ),
    ).toBe('CANCELLED');
  });

  it('returns ACTIVE when within periodEnd', () => {
    expect(
      computeSubscriptionState(
        sub({ state: 'ACTIVE', periodEnd: new Date('2026-10-01T00:00:00Z') }),
        now,
      ),
    ).toBe('ACTIVE');
  });

  it('returns GRACE when past periodEnd but within graceEndsAt', () => {
    expect(
      computeSubscriptionState(
        sub({
          state: 'ACTIVE',
          periodEnd: new Date('2026-09-01T00:00:00Z'),
          graceEndsAt: new Date('2026-09-25T00:00:00Z'),
        }),
        now,
      ),
    ).toBe('GRACE');
  });

  it('returns EXPIRED when past periodEnd and grace', () => {
    expect(
      computeSubscriptionState(
        sub({
          state: 'ACTIVE',
          periodEnd: new Date('2026-09-01T00:00:00Z'),
          graceEndsAt: new Date('2026-09-10T00:00:00Z'),
        }),
        now,
      ),
    ).toBe('EXPIRED');
  });
});
