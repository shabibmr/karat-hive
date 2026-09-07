import { describe, expect, it, vi, beforeEach } from 'vitest';
import { Decimal } from '@prisma/client/runtime/library';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { Clock } from '../../../shared/clock';
import { OfferService } from './offer.service';
import type { OfferRepository } from '../repository/offer.repository';
import type { PrismaService } from '../../../platform/db/prisma.service';

describe('OfferService', () => {
  let service: OfferService;
  let repo: OfferRepository;
  let prisma: PrismaService;
  const mockNow = new Date('2026-09-07T12:00:00Z');
  const mockClock: Clock = { now: () => mockNow } as Clock;

  const vendorViewer: ViewerContext = {
    userId: 'user-v1',
    role: 'VENDOR',
    tokenVersion: 1,
    vendorProfileId: 'vendor-1',
  };

  const customerViewer: ViewerContext = {
    userId: 'user-c1',
    role: 'CUSTOMER',
    tokenVersion: 1,
    customerProfileId: 'cust-1',
  };

  const mockRequest = {
    id: 'req-1',
    state: 'PUBLISHED',
    requestType: 'FIND_ORNAMENT',
    direction: 'BUY',
    expiresAt: new Date('2026-09-09T12:00:00Z'),
    customerProfileId: 'cust-1',
    customerProfile: {
      userId: 'user-c1',
    },
    category: {
      id: 'cat-1',
      nameEn: 'Rings',
      nameAr: 'خواتم',
      isActive: true,
      displayOrder: 1,
    },
    region: {
      id: 'reg-1',
      nameEn: 'Dubai',
      nameAr: 'دبي',
      isActive: true,
      displayOrder: 1,
    },
  };

  beforeEach(() => {
    repo = {
      findRequestForOffer: vi.fn().mockResolvedValue(mockRequest),
      checkVendorEligibility: vi.fn().mockResolvedValue({
        isFound: true,
        isActive: true,
        hasSubscription: true,
      }),
      isInMatchSet: vi.fn().mockResolvedValue(true),
      findPendingOfferByVendor: vi.fn().mockResolvedValue(null),
      createOffer: vi.fn().mockImplementation(async ({ terms, expiresAt }) => ({
        id: 'offer-1',
        requestId: 'req-1',
        vendorProfileId: 'vendor-1',
        state: 'PENDING',
        offeredPrice: new Decimal(terms.offeredPrice),
        makingCharges: null,
        ratePerGram: null,
        deliveryTimeframe: null,
        warrantyTerms: null,
        vendorNote: terms.vendorNote ?? null,
        validityHours: terms.validityHours,
        expiresAt,
        submittedAt: mockNow,
        revisionCount: 0,
        viewedByCustomerAt: null,
        decidedAt: null,
        declineReason: null,
        media: [],
        vendorProfile: {
          regions: [],
        },
      })),
      findOfferById: vi.fn(),
      createRevision: vi.fn(),
      updateOfferState: vi.fn(),
      countPendingOffersOnRequest: vi.fn().mockResolvedValue(0),
      listOffersForRequest: vi.fn(),
      listOffersForVendor: vi.fn(),
      markOfferViewedByCustomer: vi.fn(),
      findExpiredPendingOffers: vi.fn(),
      findExpiringPendingOffersWarning: vi.fn(),
    } as unknown as OfferRepository;

    prisma = {
      $transaction: vi.fn(async (cb) =>
        cb({
          outboxEvent: { create: vi.fn().mockResolvedValue({}) },
          request: { update: vi.fn().mockResolvedValue({}) },
          offer: { update: vi.fn().mockResolvedValue({}) },
        }),
      ),
      review: {
        findMany: vi.fn().mockResolvedValue([]),
      },
    } as unknown as PrismaService;

    service = new OfferService(repo, prisma, mockClock);
  });

  describe('submitOffer', () => {
    it('successfully creates an offer when all preconditions are met', async () => {
      const res = await service.submitOffer(vendorViewer, 'req-1', {
        offeredPrice: 3000,
        validityHours: 24,
      });

      expect(res.id).toBe('offer-1');
      expect(res.terms.offeredPrice).toBe('3000');
      expect(repo.createOffer).toHaveBeenCalled();
    });

    it('rejects if request not open (e.g. EXPIRED)', async () => {
      vi.mocked(repo.findRequestForOffer).mockResolvedValueOnce({
        ...mockRequest,
        state: 'EXPIRED',
      } as unknown as Awaited<ReturnType<typeof repo.findRequestForOffer>>);

      await expect(
        service.submitOffer(vendorViewer, 'req-1', {
          offeredPrice: 3000,
          validityHours: 24,
        }),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: 'OFFER_NOT_OPEN',
        }),
      );
    });

    it('rejects if vendor lacks active type subscription', async () => {
      vi.mocked(repo.checkVendorEligibility).mockResolvedValueOnce({
        isFound: true,
        isActive: true,
        hasSubscription: false,
      });

      await expect(
        service.submitOffer(vendorViewer, 'req-1', {
          offeredPrice: 3000,
          validityHours: 24,
        }),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: 'SUBSCRIPTION_REQUIRED',
        }),
      );
    });

    it('rejects if vendor is not in match set', async () => {
      vi.mocked(repo.isInMatchSet).mockResolvedValueOnce(false);

      await expect(
        service.submitOffer(vendorViewer, 'req-1', {
          offeredPrice: 3000,
          validityHours: 24,
        }),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: 'NOT_IN_MATCH_SET',
        }),
      );
    });

    it('rejects if vendor already holds a pending offer (BR-009)', async () => {
      vi.mocked(repo.findPendingOfferByVendor).mockResolvedValueOnce({
        id: 'existing-pending',
      } as unknown as Awaited<ReturnType<typeof repo.findPendingOfferByVendor>>);

      await expect(
        service.submitOffer(vendorViewer, 'req-1', {
          offeredPrice: 3000,
          validityHours: 24,
        }),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: 'OFFER_ALREADY_PENDING',
        }),
      );
    });
  });

  describe('reviseOffer', () => {
    it('rejects if revision limit reached', async () => {
      vi.mocked(repo.findOfferById).mockResolvedValueOnce({
        id: 'offer-1',
        vendorProfileId: 'vendor-1',
        state: 'PENDING',
        revisionCount: 3,
        expiresAt: new Date('2026-09-08T12:00:00Z'),
        offeredPrice: new Decimal(2000),
      } as unknown as Awaited<ReturnType<typeof repo.findOfferById>>);

      await expect(
        service.reviseOffer(vendorViewer, 'offer-1', {
          offeredPrice: 1900,
          validityHours: 24,
        }),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: 'OFFER_REVISION_LIMIT',
        }),
      );
    });
  });

  describe('withdrawOffer', () => {
    it('successfully withdraws a pending offer', async () => {
      vi.mocked(repo.findOfferById).mockResolvedValueOnce({
        id: 'offer-1',
        requestId: 'req-1',
        vendorProfileId: 'vendor-1',
        state: 'PENDING',
        offeredPrice: new Decimal(2000),
        validityHours: 24,
        submittedAt: mockNow,
        expiresAt: new Date('2026-09-08T12:00:00Z'),
        revisionCount: 0,
      } as unknown as Awaited<ReturnType<typeof repo.findOfferById>>);

      vi.mocked(repo.updateOfferState).mockResolvedValueOnce({
        id: 'offer-1',
        requestId: 'req-1',
        state: 'WITHDRAWN',
        offeredPrice: new Decimal(2000),
        validityHours: 24,
        submittedAt: mockNow,
        expiresAt: new Date('2026-09-08T12:00:00Z'),
        revisionCount: 0,
      } as unknown as Awaited<ReturnType<typeof repo.updateOfferState>>);

      const res = await service.withdrawOffer(vendorViewer, 'offer-1');
      expect(res.state).toBe('WITHDRAWN');
      expect(repo.updateOfferState).toHaveBeenCalledWith('offer-1', 'WITHDRAWN', expect.any(Object), expect.anything());
    });
  });

  describe('declineOffer', () => {
    it('customer declines an offer', async () => {
      vi.mocked(repo.findOfferById).mockResolvedValueOnce({
        id: 'offer-1',
        requestId: 'req-1',
        state: 'PENDING',
        offeredPrice: new Decimal(2000),
        validityHours: 24,
        submittedAt: mockNow,
        expiresAt: new Date('2026-09-08T12:00:00Z'),
        revisionCount: 0,
      } as unknown as Awaited<ReturnType<typeof repo.findOfferById>>);

      vi.mocked(repo.updateOfferState).mockResolvedValueOnce({
        id: 'offer-1',
        requestId: 'req-1',
        state: 'REJECTED',
        offeredPrice: new Decimal(2000),
        validityHours: 24,
        submittedAt: mockNow,
        expiresAt: new Date('2026-09-08T12:00:00Z'),
        revisionCount: 0,
        declineReason: 'PRICE_TOO_HIGH',
      } as unknown as Awaited<ReturnType<typeof repo.updateOfferState>>);

      const res = await service.declineOffer(customerViewer, 'offer-1', {
        reason: 'PRICE_TOO_HIGH',
      });
      expect(res.state).toBe('REJECTED');
    });
  });
});
