import { describe, expect, it, vi } from 'vitest';
import { Clock } from '../../../shared/clock';
import { MatchingService } from './matching.service';
import type { MatchingRepository } from '../repository/matching.repository';
import type { PrismaService } from '../../../platform/db/prisma.service';

describe('MatchingService', () => {
  const fakeRepo = {
    findEligibleVendorProfileIds: vi.fn(),
    createMatch: vi.fn(),
    listMatches: vi.fn(),
    markViewed: vi.fn(),
  } as unknown as MatchingRepository;

  const fakePrisma = {
    $transaction: vi.fn((cb) => cb({ outboxEvent: { create: vi.fn() } })),
  } as unknown as PrismaService;

  const clock = new Clock();
  const service = new MatchingService(fakeRepo, fakePrisma, clock);

  it('fans out request.published and creates request_match rows per vendor (T21, AD-ASYNC-02)', async () => {
    vi.mocked(fakeRepo.findEligibleVendorProfileIds).mockResolvedValue(['v-1', 'v-2']);
    vi.mocked(fakeRepo.createMatch).mockImplementation(async (reqId, vendorId, now) => ({
      id: `match-${vendorId}`,
      requestId: reqId,
      vendorProfileId: vendorId,
      matchedAt: now,
      viewedAt: null,
      isEligible: true,
    }));

    const count = await service.fanOutRequest('req-100');

    expect(count).toBe(2);
    expect(fakeRepo.createMatch).toHaveBeenCalledTimes(2);
  });

  it('marks match as viewed (CP2-A09)', async () => {
    vi.mocked(fakeRepo.markViewed).mockResolvedValue(true);

    const ok = await service.markViewed('v-1', 'req-100');
    expect(ok).toBe(true);
    expect(fakeRepo.markViewed).toHaveBeenCalledWith('v-1', 'req-100', expect.any(Date));
  });

  it('recomputes vendor eligibility with additions and removals (T37, CP2-A12)', async () => {
    fakeRepo.recomputeVendorEligibility = vi.fn().mockResolvedValue({
      addedRequestIds: ['req-new-1', 'req-new-2'],
      removedCount: 1,
    });

    const result = await service.recomputeVendorEligibility('v-1');
    expect(result.addedRequestIds).toHaveLength(2);
    expect(result.removedCount).toBe(1);
    expect(fakeRepo.recomputeVendorEligibility).toHaveBeenCalledWith('v-1', expect.any(Date), expect.anything());
  });
});
