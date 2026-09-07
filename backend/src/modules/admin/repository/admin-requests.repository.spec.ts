import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  Direction,
  OfferState,
  RequestState,
  RequestType,
} from '@prisma/client';
import { AdminRequestsRepository } from './admin-requests.repository';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';

describe('AdminRequestsRepository', () => {
  let repo: AdminRequestsRepository;
  let prisma: PrismaService;
  let audit: AuditWriter;

  const mockRequestRow = {
    id: 'req-1',
    reference: 'REQ-2026-0001',
    customerProfileId: 'cust-1',
    requestType: RequestType.FIND_ORNAMENT,
    direction: Direction.BUY,
    state: RequestState.PUBLISHED,
    categoryId: 'cat-1',
    regionId: 'reg-1',
    notes: 'Looking for 22k necklace',
    indicativeValue: '5000.00',
    budgetMin: '4000.00',
    budgetMax: '6000.00',
    budgetIsFlexible: true,
    offerCount: 2,
    publishedAt: new Date('2026-09-01T10:00:00.000Z'),
    expiresAt: new Date('2026-09-03T10:00:00.000Z'),
    createdAt: new Date('2026-09-01T09:00:00.000Z'),
    updatedAt: new Date('2026-09-01T10:00:00.000Z'),
    customerProfile: {
      id: 'cust-1',
      userId: 'user-c-1',
      displayName: 'Fatima Al-Nuaimi',
      user: {
        id: 'user-c-1',
        mobileNumber: '+971501234567',
        email: 'fatima@example.com',
        accountState: 'ACTIVE',
      },
    },
    category: {
      id: 'cat-1',
      nameEn: 'Necklaces',
      nameAr: 'قلائد',
    },
    region: {
      id: 'reg-1',
      nameEn: 'Dubai',
      nameAr: 'دبي',
    },
  };

  beforeEach(() => {
    prisma = {
      request: {
        findMany: vi.fn(),
        findUnique: vi.fn(),
        count: vi.fn(),
        update: vi.fn(),
      },
      offer: {
        updateMany: vi.fn(),
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

    repo = new AdminRequestsRepository(prisma, audit);
  });

  describe('listRequests', () => {
    it('applies all filters and pagination correctly', async () => {
      vi.mocked(prisma.request.count).mockResolvedValue(1);
      vi.mocked(prisma.request.findMany).mockResolvedValue([mockRequestRow] as any);

      const result = await repo.listRequests(
        {
          requestType: RequestType.FIND_ORNAMENT,
          direction: Direction.BUY,
          state: RequestState.PUBLISHED,
          categoryId: 'cat-1',
          regionId: 'reg-1',
          valueMin: 1000,
          valueMax: 10000,
          zeroOffers: false,
          q: 'necklace',
        },
        'cursor-req-0',
        10,
      );

      expect(prisma.request.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            requestType: RequestType.FIND_ORNAMENT,
            direction: Direction.BUY,
            state: RequestState.PUBLISHED,
            categoryId: 'cat-1',
            regionId: 'reg-1',
            OR: [
              { reference: { contains: 'necklace', mode: 'insensitive' } },
              { notes: { contains: 'necklace', mode: 'insensitive' } },
            ],
          }),
          take: 11,
          cursor: { id: 'cursor-req-0' },
          skip: 1,
        }),
      );

      expect(result.items).toHaveLength(1);
      expect(result.total).toBe(1);
      expect(result.hasMore).toBe(false);
      expect(result.nextCursor).toBeNull();
    });

    it('filters by zeroOffers: true', async () => {
      vi.mocked(prisma.request.count).mockResolvedValue(0);
      vi.mocked(prisma.request.findMany).mockResolvedValue([]);

      await repo.listRequests({ zeroOffers: true });

      expect(prisma.request.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            offerCount: 0,
          }),
        }),
      );
    });
  });

  describe('findRequestById', () => {
    it('returns full request detail including media, matches, offers, connection, and notes', async () => {
      vi.mocked(prisma.request.findUnique).mockResolvedValue({
        ...mockRequestRow,
        media: [],
        matches: [
          {
            vendorProfileId: 'v-1',
            isEligible: true,
            matchedAt: new Date('2026-09-01T09:30:00.000Z'),
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
            state: OfferState.PENDING,
            offeredPrice: '4800.00',
            makingCharges: '200.00',
            ratePerGram: '250.00',
            deliveryTimeframe: '2 days',
            warrantyTerms: '1 year',
            vendorNote: 'High purity',
            validityHours: 24,
            expiresAt: new Date('2026-09-02T10:00:00.000Z'),
            revisionCount: 0,
            submittedAt: new Date('2026-09-01T10:00:00.000Z'),
            decidedAt: null,
            declineReason: null,
            createdAt: new Date('2026-09-01T10:00:00.000Z'),
            updatedAt: new Date('2026-09-01T10:00:00.000Z'),
            vendorProfile: {
              id: 'v-1',
              legalBusinessName: 'Gold Star LLC',
              tradingName: 'Gold Star',
              user: { mobileNumber: '+971509999999' },
            },
          },
        ],
        connections: [],
        acceptedOffer: null,
      } as any);

      vi.mocked(prisma.adminNote.findMany).mockResolvedValue([
        {
          id: 'note-1',
          entityType: 'request',
          entityId: 'req-1',
          text: 'Verified customer details via call',
          authorAdminId: 'admin-prof-1',
          createdAt: new Date('2026-09-01T11:00:00.000Z'),
          author: { displayName: 'Compliance Admin' },
        },
      ] as any);

      vi.mocked(prisma.auditLog.findMany).mockResolvedValue([
        {
          id: 'audit-1',
          action: 'REQUEST_REMOVED',
          entityType: 'request',
          entityId: 'req-1',
          actorUserId: 'admin-user-1',
          occurredAt: new Date('2026-09-01T12:00:00.000Z'),
          beforeValue: { state: 'PUBLISHED' },
          afterValue: { state: 'REMOVED', reasonText: 'Policy violation' },
          actor: { email: 'admin@karathive.ae' },
        },
      ] as any);

      const result = await repo.findRequestById('req-1');

      expect(result).not.toBeNull();
      expect(result!.id).toBe('req-1');
      expect(result!.notes).toHaveLength(1);
      expect(result!.transitions).toHaveLength(1);
    });

    it('returns null when request is not found', async () => {
      vi.mocked(prisma.request.findUnique).mockResolvedValue(null);
      vi.mocked(prisma.adminNote.findMany).mockResolvedValue([]);
      vi.mocked(prisma.auditLog.findMany).mockResolvedValue([]);

      const result = await repo.findRequestById('unknown-id');
      expect(result).toBeNull();
    });
  });

  describe('removeRequest', () => {
    it('transitions request to REMOVED, withdraws pending offers, and records audit', async () => {
      vi.mocked(prisma.request.findUnique).mockResolvedValue({
        ...mockRequestRow,
        state: RequestState.PUBLISHED,
      } as any);

      vi.mocked(prisma.request.update).mockResolvedValue({
        ...mockRequestRow,
        state: RequestState.REMOVED,
        cancellationReason: 'Policy violation: prohibited gemstones',
      } as any);

      vi.mocked(prisma.offer.updateMany).mockResolvedValue({ count: 2 } as any);
      vi.mocked(prisma.adminProfile.findFirst).mockResolvedValue({
        id: 'admin-prof-1',
        userId: 'admin-user-1',
      } as any);

      const result = await repo.removeRequest(
        'req-1',
        'admin-user-1',
        'POLICY_VIOLATION',
        'Policy violation: prohibited gemstones',
        'Terms Clause 4.2',
        '192.168.1.1',
      );

      expect(prisma.request.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'req-1' },
          data: {
            state: RequestState.REMOVED,
            cancellationReason: 'Policy violation: prohibited gemstones',
          },
        }),
      );

      expect(prisma.offer.updateMany).toHaveBeenCalledWith({
        where: {
          requestId: 'req-1',
          state: OfferState.PENDING,
        },
        data: {
          state: OfferState.WITHDRAWN_BY_SYSTEM,
          declineReason: 'OTHER',
        },
      });

      expect(audit.append).toHaveBeenCalledWith(
        prisma,
        expect.objectContaining({
          actorUserId: 'admin-user-1',
          action: 'REQUEST_REMOVED',
          entityType: 'request',
          entityId: 'req-1',
          afterValue: expect.objectContaining({
            state: RequestState.REMOVED,
            reasonCode: 'POLICY_VIOLATION',
            reasonText: 'Policy violation: prohibited gemstones',
            policyClause: 'Terms Clause 4.2',
          }),
          ipAddress: '192.168.1.1',
        }),
      );

      expect(result.state).toBe(RequestState.REMOVED);
    });

    it('throws 404 when request is not found', async () => {
      vi.mocked(prisma.request.findUnique).mockResolvedValue(null);

      await expect(
        repo.removeRequest('unknown-id', 'admin-user-1', undefined, 'Some reason'),
      ).rejects.toThrow();
    });

    it('throws 409 when request is already REMOVED', async () => {
      vi.mocked(prisma.request.findUnique).mockResolvedValue({
        ...mockRequestRow,
        state: RequestState.REMOVED,
      } as any);

      await expect(
        repo.removeRequest('req-1', 'admin-user-1', undefined, 'Duplicate remove'),
      ).rejects.toThrow();
    });
  });

  describe('addRequestNote', () => {
    it('creates admin note and writes to audit log', async () => {
      vi.mocked(prisma.request.findUnique).mockResolvedValue({ id: 'req-1' } as any);
      vi.mocked(prisma.adminProfile.findFirst).mockResolvedValue({
        id: 'admin-prof-1',
        userId: 'admin-user-1',
      } as any);

      vi.mocked(prisma.adminNote.create).mockResolvedValue({
        id: 'note-1',
        entityType: 'request',
        entityId: 'req-1',
        text: 'Followed up with customer',
        authorAdminId: 'admin-prof-1',
        createdAt: new Date('2026-09-01T12:00:00.000Z'),
        author: { displayName: 'Support Lead' },
      } as any);

      const note = await repo.addRequestNote('req-1', 'admin-user-1', 'Followed up with customer');

      expect(prisma.adminNote.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: {
            entityType: 'request',
            entityId: 'req-1',
            authorAdminId: 'admin-prof-1',
            text: 'Followed up with customer',
          },
        }),
      );

      expect(audit.append).toHaveBeenCalledWith(
        prisma,
        expect.objectContaining({
          actorUserId: 'admin-user-1',
          action: 'ADMIN_NOTE_ADDED',
          entityType: 'request',
          entityId: 'req-1',
        }),
      );

      expect(note.text).toBe('Followed up with customer');
    });

    it('throws 403 if admin profile is not found', async () => {
      vi.mocked(prisma.request.findUnique).mockResolvedValue({ id: 'req-1' } as any);
      vi.mocked(prisma.adminProfile.findFirst).mockResolvedValue(null);

      await expect(
        repo.addRequestNote('req-1', 'invalid-admin', 'Note content'),
      ).rejects.toThrow();
    });
  });
});
