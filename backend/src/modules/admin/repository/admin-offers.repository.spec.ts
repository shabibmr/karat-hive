import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  Direction,
  OfferState,
  RequestState,
  RequestType,
} from '@prisma/client';
import { AdminOffersRepository } from './admin-offers.repository';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';

describe('AdminOffersRepository', () => {
  let repo: AdminOffersRepository;
  let prisma: PrismaService;
  let audit: AuditWriter;

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
    revisionCount: 1,
    submittedAt: new Date('2026-09-01T12:00:00.000Z'),
    decidedAt: null,
    declineReason: null,
    createdAt: new Date('2026-09-01T12:00:00.000Z'),
    updatedAt: new Date('2026-09-01T14:00:00.000Z'),
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
    },
  };

  beforeEach(() => {
    prisma = {
      offer: {
        findMany: vi.fn(),
        findUnique: vi.fn(),
        count: vi.fn(),
      },
      adminNote: {
        findMany: vi.fn(),
        create: vi.fn(),
      },
      auditLog: {
        findMany: vi.fn(),
      },
      adminProfile: {
        findFirst: vi.fn(),
      },
      $transaction: vi.fn().mockImplementation(async (cb) => {
        return cb(prisma);
      }),
    } as unknown as PrismaService;

    audit = {
      append: vi.fn().mockResolvedValue(undefined),
    } as unknown as AuditWriter;

    repo = new AdminOffersRepository(prisma, audit);
  });

  describe('listOffers', () => {
    it('applies filters for state, vendorId, requestType, and price range', async () => {
      vi.mocked(prisma.offer.count).mockResolvedValue(1);
      vi.mocked(prisma.offer.findMany).mockResolvedValue([mockOfferRow] as any);

      const result = await repo.listOffers(
        {
          state: OfferState.PENDING,
          vendorId: 'v-1',
          requestType: RequestType.FIND_ORNAMENT,
          priceMin: 4000,
          priceMax: 5000,
        },
        'cursor-off-0',
        10,
      );

      expect(prisma.offer.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            state: OfferState.PENDING,
            vendorProfileId: 'v-1',
            request: { requestType: RequestType.FIND_ORNAMENT },
          }),
          take: 11,
          cursor: { id: 'cursor-off-0' },
          skip: 1,
        }),
      );

      expect(result.items).toHaveLength(1);
      expect(result.total).toBe(1);
      expect(result.hasMore).toBe(false);
      expect(result.nextCursor).toBeNull();
    });
  });

  describe('findOfferById', () => {
    it('returns full offer detail including revisions, media, notes, and parent request', async () => {
      vi.mocked(prisma.offer.findUnique).mockResolvedValue({
        ...mockOfferRow,
        revisions: [
          {
            id: 'rev-1',
            offerId: 'off-1',
            revisionNumber: 1,
            previousTerms: { offeredPrice: 4700 },
            revisedAt: new Date('2026-09-01T14:00:00.000Z'),
          },
        ],
        media: [],
        connection: null,
      } as any);

      vi.mocked(prisma.adminNote.findMany).mockResolvedValue([
        {
          id: 'note-1',
          entityType: 'offer',
          entityId: 'off-1',
          text: 'Price competitiveness check passed',
          authorAdminId: 'admin-prof-1',
          createdAt: new Date('2026-09-01T15:00:00.000Z'),
          author: { displayName: 'Marketplace Admin' },
        },
      ] as any);

      vi.mocked(prisma.auditLog.findMany).mockResolvedValue([]);

      const result = await repo.findOfferById('off-1');

      expect(result).not.toBeNull();
      expect(result!.id).toBe('off-1');
      expect(result!.revisions).toHaveLength(1);
      expect(result!.notes).toHaveLength(1);
    });

    it('returns null when offer is not found', async () => {
      vi.mocked(prisma.offer.findUnique).mockResolvedValue(null);
      vi.mocked(prisma.adminNote.findMany).mockResolvedValue([]);
      vi.mocked(prisma.auditLog.findMany).mockResolvedValue([]);

      const result = await repo.findOfferById('unknown-id');
      expect(result).toBeNull();
    });
  });

  describe('addOfferNote', () => {
    it('creates admin note for offer and appends to audit', async () => {
      vi.mocked(prisma.offer.findUnique).mockResolvedValue({ id: 'off-1' } as any);
      vi.mocked(prisma.adminProfile.findFirst).mockResolvedValue({
        id: 'admin-prof-1',
        userId: 'admin-user-1',
      } as any);

      vi.mocked(prisma.adminNote.create).mockResolvedValue({
        id: 'note-1',
        entityType: 'offer',
        entityId: 'off-1',
        text: 'Special warranty checked',
        authorAdminId: 'admin-prof-1',
        createdAt: new Date('2026-09-01T16:00:00.000Z'),
      } as any);

      const note = await repo.addOfferNote('off-1', 'admin-user-1', 'Special warranty checked');

      expect(prisma.adminNote.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: {
            entityType: 'offer',
            entityId: 'off-1',
            authorAdminId: 'admin-prof-1',
            text: 'Special warranty checked',
          },
        }),
      );

      expect(audit.append).toHaveBeenCalledWith(
        prisma,
        expect.objectContaining({
          actorUserId: 'admin-user-1',
          action: 'ADMIN_NOTE_ADDED',
          entityType: 'offer',
          entityId: 'off-1',
        }),
      );

      expect(note.text).toBe('Special warranty checked');
    });

    it('throws 404 when offer is not found', async () => {
      vi.mocked(prisma.offer.findUnique).mockResolvedValue(null);

      await expect(
        repo.addOfferNote('unknown-id', 'admin-user-1', 'Test note'),
      ).rejects.toThrow();
    });

    it('throws 403 when admin profile is not found', async () => {
      vi.mocked(prisma.offer.findUnique).mockResolvedValue({ id: 'off-1' } as any);
      vi.mocked(prisma.adminProfile.findFirst).mockResolvedValue(null);

      await expect(
        repo.addOfferNote('off-1', 'unknown-admin', 'Test note'),
      ).rejects.toThrow();
    });
  });
});
