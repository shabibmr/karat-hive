import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  Direction,
  OfferState,
  RequestState,
  RequestType,
} from '@prisma/client';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { AdminOffersService } from './admin-offers.service';
import type { AdminOffersRepository } from '../repository/admin-offers.repository';

describe('AdminOffersService', () => {
  let service: AdminOffersService;
  let repo: AdminOffersRepository;

  const mockOfferRow = {
    id: 'off-1',
    requestId: 'req-1',
    vendorProfileId: 'v-1',
    state: OfferState.PENDING,
    offeredPrice: '4500.00',
    makingCharges: '200.00',
    ratePerGram: '240.00',
    deliveryTimeframe: '3 days',
    warrantyTerms: 'Lifetime polish',
    vendorNote: 'Best price guaranteed',
    validityHours: 24,
    expiresAt: new Date('2026-09-02T12:00:00.000Z'),
    revisionCount: 0,
    submittedAt: new Date('2026-09-01T12:00:00.000Z'),
    decidedAt: null,
    declineReason: null,
    createdAt: new Date('2026-09-01T12:00:00.000Z'),
    updatedAt: new Date('2026-09-01T12:00:00.000Z'),
    vendorProfile: {
      id: 'v-1',
      legalBusinessName: 'Al Baraka Jewellers LLC',
      tradingName: 'Al Baraka',
      tradeLicenceNumber: 'TL-8888',
      user: {
        id: 'u-v-1',
        mobileNumber: '+971508888888',
        email: 'sales@albaraka.ae',
      },
    },
    request: {
      id: 'req-1',
      reference: 'REQ-2026-0001',
      requestType: RequestType.FIND_ORNAMENT,
      direction: Direction.BUY,
      state: RequestState.OFFERS_RECEIVED,
      indicativeValue: '5000.00',
      customerProfile: {
        id: 'cust-1',
        userId: 'user-c-1',
        displayName: 'Ayesha',
        user: {
          id: 'user-c-1',
          mobileNumber: '+971501111111',
          email: 'ayesha@example.com',
        },
      },
      category: { id: 'cat-1', nameEn: 'Bangles', nameAr: 'أساور' },
      region: { id: 'reg-1', nameEn: 'Sharjah', nameAr: 'الشارقة' },
      acceptedOfferId: null,
    },
  };

  beforeEach(() => {
    repo = {
      listOffers: vi.fn(),
      findOfferById: vi.fn(),
      addOfferNote: vi.fn(),
    } as unknown as AdminOffersRepository;

    service = new AdminOffersService(repo);
  });

  describe('listOffers', () => {
    it('returns formatted list and pagination metadata', async () => {
      vi.mocked(repo.listOffers).mockResolvedValue({
        items: [mockOfferRow as any],
        total: 1,
        nextCursor: null,
        hasMore: false,
      });

      const result = await service.listOffers({ state: OfferState.PENDING });

      expect(result.data).toHaveLength(1);
      expect(result.data[0]!.id).toBe('off-1');
      expect(result.data[0]!.vendor.mobileNumber).toBe('+971508888888');
      expect(result.data[0]!.request.customer?.mobileNumber).toBe('+971501111111');
      expect(result.meta.total).toBe(1);
    });

    it('throws 400 VALIDATION_FAILED when priceMin > priceMax', async () => {
      await expect(
        service.listOffers({ priceMin: 6000, priceMax: 3000 }),
      ).rejects.toMatchObject({
        errorCode: ErrorCode.VALIDATION_FAILED,
      });
    });
  });

  describe('getOfferDetail', () => {
    it('returns formatted detail and links winningOfferId when competitor was accepted', async () => {
      vi.mocked(repo.findOfferById).mockResolvedValue({
        ...mockOfferRow,
        state: OfferState.REJECTED,
        request: {
          ...mockOfferRow.request,
          acceptedOfferId: 'off-winner',
        },
        revisions: [],
        media: [],
        connection: null,
        notes: [],
        transitions: [],
      } as any);

      const result = await service.getOfferDetail('off-1');

      expect(result.id).toBe('off-1');
      expect(result.winningOfferId).toBe('off-winner');
    });

    it('throws 404 NOT_FOUND when offer does not exist', async () => {
      vi.mocked(repo.findOfferById).mockResolvedValue(null);

      await expect(service.getOfferDetail('unknown-id')).rejects.toMatchObject({
        errorCode: ErrorCode.NOT_FOUND,
      });
    });
  });

  describe('addNote', () => {
    it('validates content and calls repo.addOfferNote', async () => {
      vi.mocked(repo.addOfferNote).mockResolvedValue({
        id: 'note-1',
        text: 'Offer reviewed by senior manager',
        authorAdminId: 'admin-prof-1',
        createdAt: new Date('2026-09-01T15:00:00.000Z'),
        author: { displayName: 'Lead Admin' },
      } as any);

      const note = await service.addNote('off-1', 'admin-user-1', 'Offer reviewed by senior manager');

      expect(repo.addOfferNote).toHaveBeenCalledWith('off-1', 'admin-user-1', 'Offer reviewed by senior manager');
      expect(note.id).toBe('note-1');
      expect(note.text).toBe('Offer reviewed by senior manager');
    });

    it('throws 400 VALIDATION_FAILED when content is empty', async () => {
      await expect(service.addNote('off-1', 'admin-user-1', '   ')).rejects.toMatchObject({
        errorCode: ErrorCode.VALIDATION_FAILED,
      });
    });
  });
});
