import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { Clock } from '../../../shared/clock';
import { MatchingService } from './matching.service';
import type { MatchingRepository } from '../repository/matching.repository';

describe('MatchingService', () => {
  let service: MatchingService;
  let repo: MatchingRepository;
  const mockNow = new Date('2026-09-07T00:00:00Z');
  const mockClock: Clock = { now: () => mockNow } as Clock;

  const activeVendorViewer: ViewerContext = {
    userId: 'usr-v-1',
    role: 'VENDOR',
    tokenVersion: 1,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    vendorProfileId: 'vp-1',
    vendorVerificationState: 'VERIFIED',
    vendorActivatedAt: new Date('2026-09-01T00:00:00Z'),
    customerProfileId: null,
    adminProfileId: null,
  };

  beforeEach(() => {
    repo = {
      fanOutMatches: vi.fn().mockResolvedValue(5),
      recomputeForVendor: vi.fn().mockResolvedValue(3),
      listMatchesForVendor: vi.fn().mockResolvedValue({ items: [], nextCursor: undefined }),
      markMatchViewed: vi.fn().mockResolvedValue(undefined),
      findFilterPreset: vi.fn(),
      listFilterPresets: vi.fn().mockResolvedValue([]),
      createFilterPreset: vi.fn(),
      updateFilterPreset: vi.fn(),
      deleteFilterPreset: vi.fn(),
    } as unknown as MatchingRepository;

    service = new MatchingService(repo, mockClock);
  });

  it('fans out matches on request publish (G2-M01)', async () => {
    const count = await service.fanOutForRequest(
      'req-1',
      'FIND_ORNAMENT',
      'cat-1',
      'reg-1',
    );

    expect(count).toBe(5);
    expect(repo.fanOutMatches).toHaveBeenCalledWith(
      'req-1',
      'FIND_ORNAMENT',
      'cat-1',
      'reg-1',
      mockNow,
    );
  });

  it('recomputes matches for vendor on eligibility change (G2-M05)', async () => {
    const count = await service.recomputeForVendor('vp-1');

    expect(count).toBe(3);
    expect(repo.recomputeForVendor).toHaveBeenCalledWith('vp-1', mockNow);
  });

  it('rejects non-vendor or unverified viewer on listMatches', async () => {
    const customerViewer: ViewerContext = {
      ...activeVendorViewer,
      role: 'CUSTOMER',
      vendorProfileId: null,
    };

    await expect(service.listMatches(customerViewer, {})).rejects.toMatchObject({
      status: HttpStatus.FORBIDDEN,
      errorCode: ErrorCode.VENDOR_NOT_ACTIVE,
    });
  });

  it('lists matches with customer identity masked (G2-M02, FR-VEN-011)', async () => {
    const mockFullRequest = {
      id: 'req-1',
      reference: 'KH-REQ-2026-00001',
      requestType: 'FIND_ORNAMENT' as const,
      direction: 'BUY' as const,
      state: 'PUBLISHED' as const,
      category: {
        id: 'cat-1',
        nameEn: 'Gold Ring',
        nameAr: 'خاتم ذهب',
        parentId: null,
        isActive: true,
        displayOrder: 1,
        icon: null,
      },
      region: {
        id: 'reg-1',
        nameEn: 'Dubai',
        nameAr: 'دبي',
        parentId: null,
        isActive: true,
        displayOrder: 1,
      },
      notes: 'Looking for a simple ring',
      weightGrams: '10.5',
      weightIsApproximate: false,
      purityKarat: 'K22' as const,
      ornamentType: 'RING' as const,
      condition: 'NEW' as const,
      budgetMin: '2000',
      budgetMax: '3000',
      budgetIsFlexible: false,
      indicativeValue: '2500',
      publishedAt: new Date('2026-09-06T12:00:00Z'),
      expiresAt: new Date('2026-09-08T12:00:00Z'),
      offerCount: 2,
      media: [],
      offers: [],
      createdAt: new Date('2026-09-06T12:00:00Z'),
      updatedAt: new Date('2026-09-06T12:00:00Z'),
      customerProfile: {
        connectionCount: 4,
        aggregateRating: '4.9',
        reviewCount: 7,
      },
    };

    vi.mocked(repo.listMatchesForVendor).mockResolvedValue({
      items: [
        {
          id: 'rm-1',
          requestId: 'req-1',
          vendorProfileId: 'vp-1',
          matchedAt: mockNow,
          viewedAt: null,
          isEligible: true,
          request: mockFullRequest as never,
        },
      ],
      nextCursor: undefined,
    });

    const result = await service.listMatches(activeVendorViewer, { sort: 'NEWEST' });

    expect(result.data).toHaveLength(1);
    const item = result.data[0];
    expect(item.id).toBe('req-1');
    expect(item.reference).toBe('KH-REQ-2026-00001');
    // Customer identity masking checks (FR-VEN-011)
    expect(item.customer.label).toBe('Customer · Dubai');
    expect(item.customer.connectionCount).toBe(4);
    expect(item.customer.rating?.average).toBe('4.9');
    expect((item as Record<string, unknown>).customerName).toBeUndefined();
    expect((item as Record<string, unknown>).customerPhone).toBeUndefined();
    expect((item as Record<string, unknown>).mobileNumber).toBeUndefined();
  });

  it('marks match as viewed (G2-M03)', async () => {
    await service.markViewed(activeVendorViewer, 'req-1');
    expect(repo.markMatchViewed).toHaveBeenCalledWith('vp-1', 'req-1', mockNow);
  });
});
