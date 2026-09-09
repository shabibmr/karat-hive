import { describe, expect, it, vi } from 'vitest';
import type { PrismaService } from '../../../platform/db/prisma.service';
import { SubscriptionRepository } from './subscription.repository';

function decimal(value: number) {
  return { toNumber: () => value } as unknown as { toNumber(): number };
}

describe('SubscriptionRepository.getVendorPerformance (CP5-A05 / CP6-A03)', () => {
  it('passes through vendor_profile.rating_trend verbatim', async () => {
    const trend = [
      { period: '2026-04', average: 4.5, count: 3 },
      { period: '2026-05', average: 4.2, count: 2 },
      { period: '2026-06', average: 0, count: 0 },
      { period: '2026-07', average: 5, count: 1 },
      { period: '2026-08', average: 4.8, count: 4 },
      { period: '2026-09', average: 4.1, count: 2 },
    ];
    const offerFindMany = vi.fn().mockResolvedValueOnce([]);
    const vendorProfileFindUnique = vi.fn().mockResolvedValueOnce({ ratingTrend: trend });
    const prisma = {
      offer: { findMany: offerFindMany },
      vendorProfile: { findUnique: vendorProfileFindUnique },
    } as unknown as PrismaService;
    const repo = new SubscriptionRepository(prisma);

    const result = await repo.getVendorPerformance('vendor-prof-1', {});

    expect(result.ratingTrend).toEqual(
      trend.map((t) => ({ period: t.period, average: Number(t.average.toFixed(1)), count: t.count })),
    );
  });

  it('never exposes an averageOfferedVsAccepted field (BR-008: no competitor price leakage)', async () => {
    const offerFindMany = vi.fn().mockResolvedValueOnce([
      {
        id: 'offer-2',
        state: 'REJECTED',
        offeredPrice: decimal(4800),
        createdAt: new Date('2026-09-02T10:00:00Z'),
        request: { publishedAt: new Date('2026-09-02T09:00:00Z'), acceptedOfferId: 'offer-3' },
      },
    ]);
    const vendorProfileFindUnique = vi.fn().mockResolvedValueOnce({ ratingTrend: null });
    const prisma = {
      offer: { findMany: offerFindMany },
      vendorProfile: { findUnique: vendorProfileFindUnique },
    } as unknown as PrismaService;
    const repo = new SubscriptionRepository(prisma);

    const result = await repo.getVendorPerformance('vendor-prof-1', {});

    expect(result).not.toHaveProperty('averageOfferedVsAccepted');
    // a single-loss period must not trigger any secondary lookup of the winning Offer's price
    expect(offerFindMany).toHaveBeenCalledTimes(1);
  });
});
