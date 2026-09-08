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
