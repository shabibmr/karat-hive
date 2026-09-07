import { describe, expect, it, vi, beforeEach } from 'vitest';
import { AdminVendorRepository } from './admin-vendor.repository';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';

describe('AdminVendorRepository', () => {
  let repo: AdminVendorRepository;
  let prisma: PrismaService;
  let audit: AuditWriter;

  const fixedNow = new Date('2026-09-07T12:00:00.000Z');

  beforeEach(() => {
    prisma = {
      vendorProfile: {
        findMany: vi.fn(),
        findUnique: vi.fn(),
        count: vi.fn(),
        update: vi.fn(),
      },
      vendorDocument: {
        findFirst: vi.fn(),
      },
      adminNote: {
        findMany: vi.fn(),
        create: vi.fn(),
      },
      user: {
        update: vi.fn(),
      },
      adminProfile: {
        findFirst: vi.fn(),
      },
      vendorCategory: {
        count: vi.fn(),
      },
      vendorRegion: {
        count: vi.fn(),
      },
      offer: {
        findMany: vi.fn(),
        updateMany: vi.fn(),
      },
      outboxEvent: {
        create: vi.fn(),
      },
      $transaction: vi.fn().mockImplementation(async (cb) => {
        return cb(prisma);
      }),
    } as unknown as PrismaService;

    audit = {
      append: vi.fn().mockResolvedValue(undefined),
    } as unknown as AuditWriter;

    repo = new AdminVendorRepository(prisma, audit);
  });

  describe('findVerificationQueue', () => {
    it('queries VendorProfile with PENDING_VERIFICATION ordered by createdAt ASC', async () => {
      const mockVendor = {
        id: 'v-1',
        legalBusinessName: 'Jeweller LLC',
        verificationState: 'PENDING_VERIFICATION',
        createdAt: new Date('2026-09-05T12:00:00.000Z'),
        user: { mobileNumber: '+971501111111' },
      };
      vi.mocked(prisma.vendorProfile.findMany).mockResolvedValue([mockVendor] as any);

      const result = await repo.findVerificationQueue();

      expect(prisma.vendorProfile.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { verificationState: 'PENDING_VERIFICATION' },
          orderBy: { createdAt: 'asc' },
        }),
      );
      expect(result).toHaveLength(1);
      expect(result[0]!.id).toBe('v-1');
      expect(typeof result[0]!.oldestWaitingHours).toBe('number');
    });
  });

  describe('listVendors', () => {
    it('applies filters for verificationState, accountState, regionId, categoryId, and q', async () => {
      vi.mocked(prisma.vendorProfile.count).mockResolvedValue(1);
      vi.mocked(prisma.vendorProfile.findMany).mockResolvedValue([
        {
          id: 'v-1',
          legalBusinessName: 'Al Baraka',
          user: { accountState: 'ACTIVE' },
        },
      ] as any);

      const result = await repo.listVendors(
        {
          verificationState: 'VERIFIED',
          accountState: 'ACTIVE',
          regionId: 'reg-uuid-1',
          categoryId: 'cat-uuid-1',
          q: 'Baraka',
        },
        { limit: 10, page: 1 },
      );

      expect(prisma.vendorProfile.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            verificationState: 'VERIFIED',
            user: { accountState: 'ACTIVE' },
            regions: { some: { regionId: 'reg-uuid-1' } },
            categories: { some: { categoryId: 'cat-uuid-1' } },
            OR: expect.arrayContaining([
              { legalBusinessName: { contains: 'Baraka', mode: 'insensitive' } },
            ]),
          }),
          take: 11,
        }),
      );
      expect(result.total).toBe(1);
      expect(result.items).toHaveLength(1);
    });
  });

  describe('findVendorById', () => {
    it('loads vendor profile unmasked with user, documents, categories, regions, verifiedByAdmin, and notes', async () => {
      const mockVendor = {
        id: 'v-1',
        legalBusinessName: 'Emirates Gold',
        user: { id: 'u-1', mobileNumber: '+971500000000' },
        documents: [],
        categories: [],
        regions: [],
        verifiedByAdmin: { id: 'ap-1', displayName: 'Super Admin' },
      };
      const mockNotes = [
        {
          id: 'note-1',
          text: 'Verified manually',
          author: { displayName: 'Super Admin' },
          createdAt: fixedNow,
        },
      ];
      vi.mocked(prisma.vendorProfile.findUnique).mockResolvedValue(mockVendor as any);
      vi.mocked(prisma.adminNote.findMany).mockResolvedValue(mockNotes as any);

      const result = await repo.findVendorById('v-1');

      expect(prisma.vendorProfile.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'v-1' },
          include: expect.objectContaining({
            user: true,
            documents: expect.anything(),
            categories: expect.anything(),
            regions: expect.anything(),
            verifiedByAdmin: expect.anything(),
          }),
        }),
      );
      expect(prisma.adminNote.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: {
            entityType: { in: ['vendor_profile', 'VENDOR'] },
            entityId: 'v-1',
          },
        }),
      );
      expect(result).not.toBeNull();
      expect(result!.notes).toHaveLength(1);
      expect(result!.notes[0]!.text).toBe('Verified manually');
    });
  });

  describe('updateVerificationState', () => {
    it('updates vendor to VERIFIED in transaction and records audit log and outbox event', async () => {
      vi.mocked(prisma.vendorProfile.findUnique).mockResolvedValue({
        id: 'v-1',
        userId: 'u-1',
        verificationState: 'PENDING_VERIFICATION',
        user: { id: 'u-1', accountState: 'ACTIVE' },
      } as any);
      vi.mocked(prisma.adminProfile.findFirst).mockResolvedValue({
        id: 'ap-1',
        userId: 'admin-u-1',
      } as any);
      vi.mocked(prisma.vendorCategory.count).mockResolvedValue(1);
      vi.mocked(prisma.vendorRegion.count).mockResolvedValue(1);
      vi.mocked(prisma.vendorProfile.update).mockResolvedValue({
        id: 'v-1',
        verificationState: 'VERIFIED',
        activatedAt: fixedNow,
        user: { id: 'u-1', accountState: 'ACTIVE' },
      } as any);

      const result = await repo.updateVerificationState(
        'v-1',
        'VERIFIED',
        'admin-u-1',
        'All documents in order',
      );

      expect(prisma.vendorProfile.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'v-1' },
          data: expect.objectContaining({
            verificationState: 'VERIFIED',
            verificationNotes: 'All documents in order',
            verificationMessage: null,
            activatedAt: expect.any(Date),
          }),
        }),
      );
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          actorUserId: 'admin-u-1',
          action: 'VENDOR_VERIFIED',
          entityType: 'vendor_profile',
          entityId: 'v-1',
        }),
      );
      expect(result.verificationState).toBe('VERIFIED');
    });
  });

  describe('updateAccountState', () => {
    it('updates user.accountState to SUSPENDED and withdraws pending offers', async () => {
      vi.mocked(prisma.vendorProfile.findUnique).mockResolvedValue({
        id: 'v-1',
        userId: 'u-1',
        verificationState: 'VERIFIED',
        user: { id: 'u-1', accountState: 'ACTIVE' },
      } as any);
      vi.mocked(prisma.adminProfile.findFirst).mockResolvedValue({
        id: 'ap-1',
        userId: 'admin-u-1',
      } as any);
      vi.mocked(prisma.offer.findMany).mockResolvedValue([
        { id: 'off-1', requestId: 'req-1' },
      ] as any);

      const result = await repo.updateAccountState(
        'v-1',
        'SUSPENDED',
        'admin-u-1',
        'POLICY_VIOLATION',
        'Suspicious behaviour',
      );

      expect(prisma.user.update).toHaveBeenCalledWith({
        where: { id: 'u-1' },
        data: { accountState: 'SUSPENDED' },
      });
      expect(prisma.offer.updateMany).toHaveBeenCalledWith({
        where: { vendorProfileId: 'v-1', state: 'PENDING' },
        data: { state: 'WITHDRAWN_BY_SYSTEM' },
      });
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'VENDOR_SUSPENDED',
          entityType: 'vendor_profile',
          entityId: 'v-1',
        }),
      );
      expect(result.accountState).toBe('SUSPENDED');
    });
  });

  describe('addNote', () => {
    it('creates AdminNote in transaction with AuditWriter', async () => {
      vi.mocked(prisma.vendorProfile.findUnique).mockResolvedValue({
        id: 'v-1',
      } as any);
      vi.mocked(prisma.adminProfile.findFirst).mockResolvedValue({
        id: 'ap-1',
        userId: 'admin-u-1',
      } as any);
      vi.mocked(prisma.adminNote.create).mockResolvedValue({
        id: 'n-1',
        entityType: 'vendor_profile',
        entityId: 'v-1',
        authorAdminId: 'ap-1',
        text: 'Followed up via phone call',
        createdAt: fixedNow,
      } as any);

      const result = await repo.addNote(
        'v-1',
        'admin-u-1',
        'Followed up via phone call',
      );

      expect(prisma.adminNote.create).toHaveBeenCalledWith({
        data: {
          entityType: 'vendor_profile',
          entityId: 'v-1',
          authorAdminId: 'ap-1',
          text: 'Followed up via phone call',
        },
        include: {
          author: { include: { user: true } },
        },
      });
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'ADMIN_NOTE_ADDED',
          entityType: 'vendor_profile',
          entityId: 'v-1',
        }),
      );
      expect(result.id).toBe('n-1');
    });
  });
});
