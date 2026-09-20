import { describe, expect, it, vi } from 'vitest';
import type { PrismaService } from '../../../platform/db/prisma.service';
import { OfferRepository } from './offer.repository';

describe('OfferRepository.markOfferViewedByCustomer (CBG-03)', () => {
  it('guards on state PENDING and viewedByCustomerAt null (first-write-wins, terminal no-op)', async () => {
    const updateMany = vi.fn().mockResolvedValue({ count: 1 });
    const prisma = { offer: { updateMany } } as unknown as PrismaService;
    const repo = new OfferRepository(prisma);
    const now = new Date('2026-09-08T10:00:00Z');

    await repo.markOfferViewedByCustomer('offer-1', now);

    expect(updateMany).toHaveBeenCalledWith({
      where: {
        id: 'offer-1',
        state: 'PENDING',
        viewedByCustomerAt: null,
      },
      data: {
        viewedByCustomerAt: now,
      },
    });
  });
});

describe('OfferRepository.checkVendorEligibility (VO-04 / VO-07)', () => {
  const now = new Date('2026-09-20T12:00:00Z');

  function makeVendor(overrides: {
    activatedAt?: Date | null;
    subscriptions?: Array<{
      state: 'ACTIVE' | 'GRACE' | 'EXPIRED' | 'CANCELLED';
      periodEnd: Date;
      graceEndsAt: Date | null;
    }>;
  }) {
    return {
      id: 'vp-1',
      verificationState: 'VERIFIED',
      activatedAt: overrides.activatedAt === undefined ? new Date('2026-09-01T00:00:00Z') : overrides.activatedAt,
      user: { accountState: 'ACTIVE', deletedAt: null },
      subscriptions: (overrides.subscriptions ?? []).map((s, i) => ({
        id: `sub-${i}`,
        vendorProfileId: 'vp-1',
        requestType: 'FIND_ORNAMENT',
        state: s.state,
        periodStart: new Date('2026-08-01T00:00:00Z'),
        periodEnd: s.periodEnd,
        graceEndsAt: s.graceEndsAt,
        priceAed: 100,
        paymentReference: null,
        createdAt: now,
        updatedAt: now,
      })),
    };
  }

  it('treats periodEnd-past ACTIVE without grace as no live subscription', async () => {
    const findUnique = vi.fn().mockResolvedValue(
      makeVendor({
        subscriptions: [
          {
            state: 'ACTIVE',
            periodEnd: new Date('2026-09-01T00:00:00Z'),
            graceEndsAt: null,
          },
        ],
      }),
    );
    const repo = new OfferRepository({
      vendorProfile: { findUnique },
    } as unknown as PrismaService);

    const result = await repo.checkVendorEligibility('vp-1', 'FIND_ORNAMENT', undefined, now);

    expect(result.isActive).toBe(true);
    expect(result.hasSubscription).toBe(false);
  });

  it('keeps subscription live during grace after periodEnd', async () => {
    const findUnique = vi.fn().mockResolvedValue(
      makeVendor({
        subscriptions: [
          {
            state: 'ACTIVE',
            periodEnd: new Date('2026-09-01T00:00:00Z'),
            graceEndsAt: new Date('2026-09-25T00:00:00Z'),
          },
        ],
      }),
    );
    const repo = new OfferRepository({
      vendorProfile: { findUnique },
    } as unknown as PrismaService);

    const result = await repo.checkVendorEligibility('vp-1', 'FIND_ORNAMENT', undefined, now);

    expect(result.hasSubscription).toBe(true);
  });

  it('requires activatedAt for isActive (VO-07)', async () => {
    const findUnique = vi.fn().mockResolvedValue(
      makeVendor({
        activatedAt: null,
        subscriptions: [
          {
            state: 'ACTIVE',
            periodEnd: new Date('2026-10-01T00:00:00Z'),
            graceEndsAt: null,
          },
        ],
      }),
    );
    const repo = new OfferRepository({
      vendorProfile: { findUnique },
    } as unknown as PrismaService);

    const result = await repo.checkVendorEligibility('vp-1', 'FIND_ORNAMENT', undefined, now);

    expect(result.isActive).toBe(false);
    expect(result.hasSubscription).toBe(true);
  });
});
