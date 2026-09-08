import { beforeEach, describe, expect, it, vi } from 'vitest';
import { Prisma } from '@prisma/client';
import type { PrismaService } from '../../../platform/db/prisma.service';
import { AdminRepository } from './admin.repository';

describe('AdminRepository', () => {
  let repo: AdminRepository;
  let prisma: PrismaService;

  beforeEach(() => {
    prisma = {
      adminNote: {
        create: vi.fn(),
        findMany: vi.fn(),
      },
    } as unknown as PrismaService;
    repo = new AdminRepository(prisma);
  });

  it('includes author displayName when creating an admin note', async () => {
    vi.mocked(prisma.adminNote.create).mockResolvedValue({
      id: 'note-1',
      entityType: 'vendors',
      entityId: 'ven-1',
      text: 'Called vendor',
      authorAdminId: 'admin-prof-1',
      author: { displayName: 'Admin Sarah' },
      createdAt: new Date('2026-09-08T10:00:00.000Z'),
    } as Awaited<ReturnType<typeof prisma.adminNote.create>>);

    const result = await repo.createAdminNote({
      entityType: 'vendors',
      entityId: 'ven-1',
      text: 'Called vendor',
      authorAdminId: 'admin-prof-1',
    });

    expect(prisma.adminNote.create).toHaveBeenCalledWith({
      data: {
        entityType: 'vendors',
        entityId: 'ven-1',
        text: 'Called vendor',
        authorAdminId: 'admin-prof-1',
      },
      include: {
        author: { select: { displayName: true } },
      },
    });
    expect(result.author).toEqual({ displayName: 'Admin Sarah' });
  });

  describe('listRequests (ADM-C-71)', () => {
    beforeEach(() => {
      prisma = {
        request: { findMany: vi.fn().mockResolvedValue([]) },
      } as unknown as PrismaService;
      repo = new AdminRepository(prisma);
    });

    it('applies requestType, direction, category, region, value range, and q in Prisma where', async () => {
      await repo.listRequests({
        q: 'necklace',
        state: 'PUBLISHED',
        requestType: 'FIND_ORNAMENT',
        direction: 'BUY',
        categoryId: 'cat-1',
        regionId: 'reg-1',
        minValue: 1000,
        maxValue: 10000,
        zeroOffers: false,
      });

      expect(prisma.request.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            state: 'PUBLISHED',
            requestType: 'FIND_ORNAMENT',
            direction: 'BUY',
            categoryId: 'cat-1',
            regionId: 'reg-1',
            OR: [
              { reference: { contains: 'necklace' } },
              { notes: { contains: 'necklace', mode: 'insensitive' } },
            ],
          }),
        }),
      );

      const where = vi.mocked(prisma.request.findMany).mock.calls[0]![0]!.where as Prisma.RequestWhereInput;
      expect(where.offerCount).toBeUndefined();
      expect(where.indicativeValue).toEqual({
        gte: new Prisma.Decimal(1000),
        lte: new Prisma.Decimal(10000),
      });
    });

    it('accepts valueMin/valueMax aliases for the Flutter minValue/maxValue names', async () => {
      await repo.listRequests({ valueMin: 250, valueMax: 800 });

      const where = vi.mocked(prisma.request.findMany).mock.calls[0]![0]!.where as Prisma.RequestWhereInput;
      expect(where.indicativeValue).toEqual({
        gte: new Prisma.Decimal(250),
        lte: new Prisma.Decimal(800),
      });
    });

    it('filters zeroOffers: true as offerCount = 0', async () => {
      await repo.listRequests({ zeroOffers: true });

      expect(prisma.request.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({ offerCount: 0 }),
        }),
      );
    });
  });

  describe('listOffers (ADM-C-71)', () => {
    beforeEach(() => {
      prisma = {
        offer: { findMany: vi.fn().mockResolvedValue([]) },
      } as unknown as PrismaService;
      repo = new AdminRepository(prisma);
    });

    it('applies state, vendorId, requestType, minPrice/maxPrice, and date range in Prisma where', async () => {
      await repo.listOffers({
        state: 'PENDING',
        vendorId: 'v-1',
        requestType: 'FIND_ORNAMENT',
        minPrice: 4000,
        maxPrice: 5000,
        dateFrom: '2026-09-01',
        dateTo: '2026-09-08',
      });

      expect(prisma.offer.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            state: 'PENDING',
            vendorProfileId: 'v-1',
            request: { requestType: 'FIND_ORNAMENT' },
            createdAt: {
              gte: new Date('2026-09-01T00:00:00.000Z'),
              lte: new Date('2026-09-08T23:59:59.999Z'),
            },
          }),
        }),
      );

      const where = vi.mocked(prisma.offer.findMany).mock.calls[0]![0]!.where as Prisma.OfferWhereInput;
      expect(where.offeredPrice).toEqual({
        gte: new Prisma.Decimal(4000),
        lte: new Prisma.Decimal(5000),
      });
    });

    it('accepts priceMin/priceMax aliases for Flutter minPrice/maxPrice', async () => {
      await repo.listOffers({ priceMin: 100, priceMax: 200 });

      const where = vi.mocked(prisma.offer.findMany).mock.calls[0]![0]!.where as Prisma.OfferWhereInput;
      expect(where.offeredPrice).toEqual({
        gte: new Prisma.Decimal(100),
        lte: new Prisma.Decimal(200),
      });
    });
  });

  describe('findRequest (ADM-C-72)', () => {
    const publishedAt = new Date('2026-09-01T10:00:00.000Z');
    const matchedAt = new Date('2026-09-01T10:05:00.000Z');
    const submittedAt = new Date('2026-09-01T12:00:00.000Z');

    const requestRow = {
      id: 'req-1',
      reference: 'REQ-2026-0001',
      state: 'PUBLISHED',
      offerCount: 1,
      publishedAt,
      expiresAt: new Date('2026-09-03T10:00:00.000Z'),
      createdAt: new Date('2026-09-01T09:00:00.000Z'),
      updatedAt: publishedAt,
      cancellationReason: null,
      notes: 'Looking for 22k necklace',
      customerProfile: {
        id: 'cust-1',
        displayName: 'Fatima Al-Nuaimi',
        user: { id: 'user-c-1', mobileNumber: '+971501234567', email: 'fatima@example.com' },
      },
      category: { id: 'cat-1', nameEn: 'Necklaces' },
      region: { id: 'reg-1', nameEn: 'Dubai' },
      media: [],
      matches: [
        {
          vendorProfileId: 'v-1',
          isEligible: true,
          matchedAt,
          viewedAt: null,
          vendorProfile: {
            id: 'v-1',
            legalBusinessName: 'Gold Star LLC',
            tradingName: 'Gold Star',
            tradeLicenceNumber: 'TL-999',
            user: { id: 'u-v-1', mobileNumber: '+971509999999', email: 'v@goldstar.ae' },
          },
        },
      ],
      offers: [
        {
          id: 'off-1',
          state: 'PENDING',
          submittedAt,
          decidedAt: null,
          vendorProfile: { id: 'v-1', legalBusinessName: 'Gold Star LLC' },
        },
      ],
      connections: [
        {
          id: 'conn-1',
          state: 'ACTIVE',
          vendorProfileId: 'v-1',
          customerProfileId: 'cust-1',
          identityRevealedAt: new Date('2026-09-01T16:00:00.000Z'),
          vendorProfile: {
            id: 'v-1',
            legalBusinessName: 'Gold Star LLC',
            tradingName: 'Gold Star',
            user: { id: 'u-v-1', mobileNumber: '+971509999999' },
          },
          customerProfile: {
            id: 'cust-1',
            displayName: 'Fatima Al-Nuaimi',
            user: { id: 'user-c-1', mobileNumber: '+971501234567' },
          },
        },
      ],
      acceptedOffer: null,
    };

    beforeEach(() => {
      prisma = {
        request: { findUnique: vi.fn() },
        auditLog: { findMany: vi.fn().mockResolvedValue([]) },
      } as unknown as PrismaService;
      repo = new AdminRepository(prisma);
    });

    it('loads matches, deep connections, and audit-derived transitions', async () => {
      vi.mocked(prisma.request.findUnique).mockResolvedValue(requestRow as never);
      vi.mocked(prisma.auditLog.findMany).mockResolvedValue([
        {
          action: 'REQUEST_PUBLISHED',
          actorUserId: 'user-c-1',
          occurredAt: publishedAt,
          beforeValue: { state: 'DRAFT' },
          afterValue: { state: 'PUBLISHED' },
          actor: { email: 'fatima@example.com' },
        },
      ] as never);

      const result = await repo.findRequest('req-1');

      expect(prisma.request.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'req-1' },
          include: expect.objectContaining({
            matches: expect.objectContaining({
              include: { vendorProfile: { include: { user: true } } },
            }),
            connections: expect.objectContaining({
              include: expect.objectContaining({
                vendorProfile: { include: { user: true } },
                customerProfile: { include: { user: true } },
              }),
            }),
          }),
        }),
      );
      expect(prisma.auditLog.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { entityType: 'request', entityId: 'req-1' },
        }),
      );

      expect(result).not.toBeNull();
      expect(result!.notes).toBe('Looking for 22k necklace');
      expect(result!.matches).toHaveLength(1);
      expect(result!.connections[0].vendorProfile.legalBusinessName).toBe('Gold Star LLC');
      expect(result!.connections[0].customerProfile.displayName).toBe('Fatima Al-Nuaimi');

      expect(result!.matchedVendors).toHaveLength(1);
      expect(result!.matchedVendors[0]).toMatchObject({
        vendorProfileId: 'v-1',
        isEligible: true,
        vendor: {
          id: 'v-1',
          legalBusinessName: 'Gold Star LLC',
          tradingName: 'Gold Star',
        },
      });

      expect(result!.transitions.length).toBeGreaterThan(0);
      expect(result!.timeline).toEqual(result!.transitions);
      expect(result!.transitions.some((t) => t.toState === 'PUBLISHED')).toBe(true);
    });

    it('returns null when the request is missing', async () => {
      vi.mocked(prisma.request.findUnique).mockResolvedValue(null);

      await expect(repo.findRequest('missing')).resolves.toBeNull();
    });
  });

  describe('findOffer (ADM-C-73)', () => {
    const submittedAt = new Date('2026-09-01T12:00:00.000Z');
    const revisedAt = new Date('2026-09-01T14:00:00.000Z');

    const offerRow = {
      id: 'off-1',
      requestId: 'req-1',
      vendorProfileId: 'v-1',
      state: 'PENDING',
      offeredPrice: '14850.00',
      makingCharges: '450.00',
      ratePerGram: '275.00',
      deliveryTimeframe: '2 days',
      warrantyTerms: '1 year',
      vendorNote: 'Revised after gold move',
      validityHours: 24,
      expiresAt: new Date('2026-09-02T12:00:00.000Z'),
      revisionCount: 1,
      submittedAt,
      decidedAt: null,
      declineReason: null,
      createdAt: submittedAt,
      updatedAt: revisedAt,
      vendorProfile: {
        id: 'v-1',
        legalBusinessName: 'Al Baraka Jewellers LLC',
        tradingName: 'Al Baraka',
        user: { id: 'u-v-1', mobileNumber: '+971508888888', email: 'sales@albaraka.ae' },
      },
      request: {
        id: 'req-1',
        acceptedOfferId: null,
        acceptedOffer: null,
        customerProfile: {
          id: 'cust-1',
          displayName: 'Fatima Al-Nuaimi',
          user: { id: 'user-c-1' },
        },
      },
      revisions: [
        {
          id: 'rev-1',
          offerId: 'off-1',
          revisionNumber: 1,
          revisedAt,
          previousTerms: {
            offeredPrice: '15450.00',
            makingCharges: '600.00',
            ratePerGram: '270.00',
            deliveryTimeframe: '3-4 business days',
            vendorNote: 'Original submission',
          },
        },
      ],
      media: [],
      connection: null,
    };

    beforeEach(() => {
      prisma = {
        offer: { findUnique: vi.fn() },
        auditLog: { findMany: vi.fn().mockResolvedValue([]) },
      } as unknown as PrismaService;
      repo = new AdminRepository(prisma);
    });

    it('projects revision term columns and attaches state transitions', async () => {
      vi.mocked(prisma.offer.findUnique).mockResolvedValue(offerRow as never);
      vi.mocked(prisma.auditLog.findMany).mockResolvedValue([
        {
          action: 'OFFER_REVISED',
          actorUserId: 'u-v-1',
          occurredAt: revisedAt,
          beforeValue: { state: 'PENDING' },
          afterValue: { state: 'PENDING', reasonText: 'Price update' },
          actor: { email: 'sales@albaraka.ae' },
        },
      ] as never);

      const result = await repo.findOffer('off-1');

      expect(prisma.offer.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'off-1' },
          include: expect.objectContaining({
            revisions: expect.objectContaining({
              orderBy: { revisionNumber: 'desc' },
            }),
          }),
        }),
      );
      expect(prisma.auditLog.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { entityType: 'offer', entityId: 'off-1' },
        }),
      );

      expect(result).not.toBeNull();
      expect(result!.revisions).toHaveLength(1);
      expect(result!.revisions[0]).toMatchObject({
        id: 'rev-1',
        revisionNumber: 1,
        offeredPrice: 15450,
        makingCharges: 600,
        ratePerGram: 270,
        previousTerms: expect.objectContaining({ offeredPrice: '15450.00' }),
      });

      expect(result!.transitions.length).toBeGreaterThan(0);
      expect(result!.stateTransitions).toEqual(result!.transitions);
      expect(result!.transitions.some((t) => t.transition === 'OFFER_SUBMITTED')).toBe(true);
      expect(result!.transitions.some((t) => t.reason === 'Price update')).toBe(true);
    });

    it('returns null when the offer is missing', async () => {
      vi.mocked(prisma.offer.findUnique).mockResolvedValue(null);

      await expect(repo.findOffer('missing')).resolves.toBeNull();
    });
  });
});
