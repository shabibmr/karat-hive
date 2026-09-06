import { describe, expect, it, vi } from 'vitest';
import { Prisma, RequestType, SubscriptionState, type VendorTypeSubscription } from '@prisma/client';
import { Clock } from '../../../shared/clock';
import { SubscriptionService } from './subscription.service';
import type { SubscriptionRepository } from '../repository/subscription.repository';

describe('SubscriptionService', () => {
  const fakeRepo = {
    listByVendor: vi.fn(),
    findActiveByVendorAndType: vi.fn(),
    upsert: vi.fn(),
  } as unknown as SubscriptionRepository;

  const clock = new Clock();
  const service = new SubscriptionService(fakeRepo, clock);

  it('returns four type entitlements with default NONE state when vendor has no rows', async () => {
    vi.mocked(fakeRepo.listByVendor).mockResolvedValue([]);

    const result = await service.getSubscriptions('vendor-1');

    expect(result).toHaveLength(4);
    const types = result.map((r) => r.requestType);
    expect(types).toContain(RequestType.FIND_ORNAMENT);
    expect(types).toContain(RequestType.SELL_OLD_GOLD);
    expect(types).toContain(RequestType.GOLD_COIN);
    expect(types).toContain(RequestType.GOLD_BULLION);

    for (const sub of result) {
      expect(sub.state).toBe('NONE');
      expect(sub.periodStart).toBeNull();
      expect(sub.periodEnd).toBeNull();
      expect(sub.priceAed).toBeNull();
    }
  });

  it('correctly maps ACTIVE subscription when within period', async () => {
    const now = new Date();
    const periodStart = new Date(now.getTime() - 24 * 3600 * 1000);
    const periodEnd = new Date(now.getTime() + 30 * 24 * 3600 * 1000);

    const activeRow: VendorTypeSubscription = {
      id: 'sub-1',
      vendorProfileId: 'vendor-1',
      requestType: RequestType.FIND_ORNAMENT,
      state: SubscriptionState.ACTIVE,
      periodStart,
      periodEnd,
      priceAed: new Prisma.Decimal('150.00'),
      graceEndsAt: null,
      paymentReference: 'PAY-123',
      createdAt: now,
      updatedAt: now,
    };

    vi.mocked(fakeRepo.listByVendor).mockResolvedValue([activeRow]);

    const result = await service.getSubscriptions('vendor-1');
    const ornament = result.find((r) => r.requestType === RequestType.FIND_ORNAMENT);

    expect(ornament).toBeDefined();
    expect(ornament?.state).toBe('ACTIVE');
    expect(ornament?.priceAed).toBe('150.00');
    expect(ornament?.paymentReference).toBe('PAY-123');
  });

  it('evaluates GRACE state when past periodEnd but within grace period', async () => {
    const now = new Date();
    const periodStart = new Date(now.getTime() - 40 * 24 * 3600 * 1000);
    const periodEnd = new Date(now.getTime() - 2 * 24 * 3600 * 1000);
    const graceEndsAt = new Date(now.getTime() + 5 * 24 * 3600 * 1000);

    const graceRow: VendorTypeSubscription = {
      id: 'sub-2',
      vendorProfileId: 'vendor-1',
      requestType: RequestType.GOLD_COIN,
      state: SubscriptionState.ACTIVE,
      periodStart,
      periodEnd,
      priceAed: new Prisma.Decimal('200.00'),
      graceEndsAt,
      paymentReference: 'PAY-GRACE',
      createdAt: now,
      updatedAt: now,
    };

    vi.mocked(fakeRepo.listByVendor).mockResolvedValue([graceRow]);

    const result = await service.getSubscriptions('vendor-1');
    const coin = result.find((r) => r.requestType === RequestType.GOLD_COIN);

    expect(coin?.state).toBe('GRACE');
  });
});
