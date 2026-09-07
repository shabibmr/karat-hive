import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import type { User, VendorProfile } from '@prisma/client';
import { AdminVendorService } from './admin-vendor.service';
import type { AdminVendorRepository } from '../repository/admin-vendor.repository';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { ObjectStorage } from '../../../platform/ports/storage.port';
import type { AuditWriter } from '../../audit';
import type { Env } from '../../../config/env';
import { Clock } from '../../../shared/clock';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';

describe('AdminVendorService', () => {
  let service: AdminVendorService;
  let repo: AdminVendorRepository;
  let prisma: PrismaService;
  let storage: ObjectStorage;
  let audit: AuditWriter;
  let clock: Clock;
  let env: Env;

  const mockAdminViewer: ViewerContext = {
    userId: 'admin-user-1',
    role: 'ADMIN',
    tokenVersion: 1,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    vendorProfileId: null,
    vendorVerificationState: null,
    vendorActivatedAt: null,
    customerProfileId: null,
    adminProfileId: 'admin-prof-1',
  };

  const clientInfo = { ip: '127.0.0.1', userAgent: 'vitest-agent' };

  const fixedNow = new Date('2026-09-07T12:00:00.000Z');

  const mockUser: User = {
    id: 'user-vendor-1',
    mobileNumber: '+971501234567',
    mobileVerifiedAt: new Date('2026-09-01T10:00:00.000Z'),
    email: 'gold@example.com',
    emailVerifiedAt: new Date('2026-09-01T10:00:00.000Z'),
    emailPending: null,
    passwordHash: 'hash',
    userType: 'VENDOR',
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    tokenVersion: 1,
    termsVersion: 'v1.0',
    privacyVersion: 'v1.0',
    termsAcceptedAt: new Date('2026-09-01T10:00:00.000Z'),
    quietHoursStart: null,
    quietHoursEnd: null,
    lastLoginAt: new Date('2026-09-06T10:00:00.000Z'),
    failedLoginAttempts: 0,
    lockedUntil: null,
    deletedAt: null,
    createdAt: new Date('2026-09-01T10:00:00.000Z'),
    updatedAt: new Date('2026-09-01T10:00:00.000Z'),
  };

  const mockVendorProfile: VendorProfile = {
    id: 'vendor-1',
    userId: 'user-vendor-1',
    legalBusinessName: 'Al Karat Gold LLC',
    tradingName: 'Al Karat',
    tradeLicenceNumber: 'CN-1234567',
    licenceExpiryDate: new Date('2027-01-01T00:00:00.000Z'),
    businessAddress: 'Gold Souk, Deira, Dubai',
    contactPersonName: 'Rashid Khan',
    businessEmail: 'info@alkarat.ae',
    logoMediaId: null,
    description: 'Premier Gold Merchant',
    verificationState: 'PENDING_VERIFICATION',
    activatedAt: null,
    verifiedAt: null,
    verifiedByAdminId: null,
    verificationNotes: null,
    verificationMessage: null,
    businessHours: null,
    awayMode: false,
    aggregateRating: null,
    reviewCount: 0,
    ratingTrend: null,
    offersSubmittedCount: 10,
    offersAcceptedCount: 8,
    createdAt: new Date('2026-09-05T12:00:00.000Z'),
    updatedAt: new Date('2026-09-05T12:00:00.000Z'),
  };

  const mockVendorDetailRow = {
    ...mockVendorProfile,
    user: mockUser,
    documents: [
      {
        id: 'doc-1',
        vendorProfileId: 'vendor-1',
        documentType: 'TRADE_LICENCE' as const,
        mediaId: 'media-1',
        expiryDate: new Date('2027-01-01T00:00:00.000Z'),
        verified: false,
        reminderSentAt: null,
        uploadedAt: new Date('2026-09-05T12:00:00.000Z'),
        createdAt: new Date('2026-09-05T12:00:00.000Z'),
        updatedAt: new Date('2026-09-05T12:00:00.000Z'),
        media: {
          id: 'media-1',
          ownerUserId: 'user-vendor-1',
          purpose: 'KYC_DOCUMENT' as const,
          state: 'READY' as const,
          key: 'doc-key-1',
          bucket: 'kyc-bucket',
          contentType: 'application/pdf',
          byteSize: 1024,
          sha256: 'sha256',
          width: null,
          height: null,
          durationSeconds: null,
          quarantineReason: null,
          uploadedAt: new Date('2026-09-05T12:00:00.000Z'),
          createdAt: new Date('2026-09-05T12:00:00.000Z'),
          updatedAt: new Date('2026-09-05T12:00:00.000Z'),
        },
      },
    ],
    categories: [
      {
        id: 'vc-1',
        vendorProfileId: 'vendor-1',
        categoryId: 'cat-1',
        createdAt: new Date(),
        category: {
          id: 'cat-1',
          parentId: null,
          nameEn: 'Gold Bars',
          nameAr: 'سبائك ذهبية',
          icon: null,
          displayOrder: 1,
          isActive: true,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      },
    ],
    regions: [
      {
        id: 'vr-1',
        vendorProfileId: 'vendor-1',
        regionId: 'reg-1',
        createdAt: new Date(),
        region: {
          id: 'reg-1',
          parentId: null,
          nameEn: 'Dubai',
          nameAr: 'دبي',
          displayOrder: 1,
          isActive: true,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      },
    ],
    verifiedByAdmin: null,
    notes: [],
    subscriptions: [],
  };

  beforeEach(() => {
    env = {
      SUPABASE_STORAGE_BUCKET_KYC: 'test-kyc-bucket',
    } as unknown as Env;

    storage = {
      createSignedDownloadUrl: vi.fn().mockResolvedValue({
        url: 'https://storage.karathive.ae/signed-doc.pdf',
        expiresAt: new Date('2026-09-07T12:15:00.000Z'),
      }),
    } as unknown as ObjectStorage;

    prisma = {
      $transaction: vi.fn().mockImplementation(async (cb) => cb({})),
    } as unknown as PrismaService;

    clock = {
      now: vi.fn().mockReturnValue(fixedNow),
    } as unknown as Clock;

    repo = {
      findVerificationQueue: vi.fn(),
      listVerificationQueue: vi.fn(),
      listVendors: vi.fn(),
      findVendorById: vi.fn(),
      findVendorDetail: vi.fn(),
      updateVerificationState: vi.fn(),
      updateAccountState: vi.fn(),
      addNote: vi.fn(),
      findVendorDocument: vi.fn(),
    } as unknown as AdminVendorRepository;

    audit = {
      append: vi.fn().mockResolvedValue(undefined),
    } as unknown as AuditWriter;

    service = new AdminVendorService(env, storage, prisma, clock, repo, audit);
  });

  describe('getVerificationQueue', () => {
    it('returns pending verification queue items with oldestWaitingHours calculated', async () => {
      vi.mocked(repo.findVerificationQueue).mockResolvedValue([
        {
          ...mockVendorProfile,
          user: mockUser,
          oldestWaitingHours: 48,
        },
      ] as any);

      const result = await service.getVerificationQueue();

      expect(result).toHaveLength(1);
      expect(result[0]!.id).toBe('vendor-1');
      expect(result[0]!.legalBusinessName).toBe('Al Karat Gold LLC');
      expect(result[0]!.oldestWaitingHours).toBe(48);
    });
  });

  describe('getVendors', () => {
    it('returns filtered and paginated vendors list', async () => {
      vi.mocked(repo.listVendors).mockResolvedValue({
        items: [{ ...mockVendorProfile, user: mockUser }],
        total: 1,
        nextCursor: null,
        hasMore: false,
      } as any);

      const result = await service.getVendors({
        verificationState: 'PENDING_VERIFICATION',
        q: 'Al Karat',
      });

      expect(result.data).toHaveLength(1);
      expect(result.data[0]!.legalBusinessName).toBe('Al Karat Gold LLC');
      expect(result.meta.total).toBe(1);
      expect(result.meta.hasMore).toBe(false);
    });
  });

  describe('getVendorDetail', () => {
    it('returns unmasked vendor detail if vendor exists', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue(mockVendorDetailRow as any);

      const result = await service.getVendorDetail('vendor-1');

      expect(result.id).toBe('vendor-1');
      expect(result.legalBusinessName).toBe('Al Karat Gold LLC');
      expect(result.mobileNumber).toBe('+971501234567');
      expect(result.documents).toHaveLength(1);
      expect(result.documents[0]!.documentType).toBe('TRADE_LICENCE');
      expect(result.categories).toEqual(['Gold Bars']);
      expect(result.regions).toEqual(['Dubai']);
    });

    it('throws 404 NOT_FOUND if vendor does not exist', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue(null);

      await expect(service.getVendorDetail('non-existent')).rejects.toMatchObject({
        errorCode: ErrorCode.NOT_FOUND,
      });
      await expect(service.getVendorDetail('non-existent')).rejects.toThrow(ApiException);
    });
  });

  describe('verifyVendor', () => {
    it('successfully approves a vendor and advances to ACTIVE when taxonomy exists', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue(mockVendorDetailRow as any);
      vi.mocked(repo.updateVerificationState).mockResolvedValue({
        ...mockVendorProfile,
        verificationState: 'VERIFIED',
        activatedAt: fixedNow,
        user: mockUser,
      } as any);

      const result = await service.verifyVendor(mockAdminViewer, 'vendor-1', 'KYC verified successfully');

      expect(repo.updateVerificationState).toHaveBeenCalledWith(
        'vendor-1',
        'VERIFIED',
        'admin-user-1',
        'KYC verified successfully',
      );
      expect(result.lifecycle).toBe('ACTIVE');
    });

    it('throws 409 ILLEGAL_VENDOR_TRANSITION when transition is not allowed', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue({
        ...mockVendorDetailRow,
        verificationState: 'REGISTERED', // REGISTERED cannot transition directly to VERIFIED
      } as any);

      await expect(
        service.verifyVendor(mockAdminViewer, 'vendor-1', 'Approved'),
      ).rejects.toMatchObject({
        errorCode: ErrorCode.ILLEGAL_VENDOR_TRANSITION,
      });
    });
  });

  describe('rejectVendor', () => {
    it('successfully rejects vendor with rationale', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue(mockVendorDetailRow as any);
      vi.mocked(repo.updateVerificationState).mockResolvedValue({
        ...mockVendorProfile,
        verificationState: 'REJECTED',
        user: mockUser,
      } as any);

      const result = await service.rejectVendor(
        mockAdminViewer,
        'vendor-1',
        'Trade licence expired and illegible',
      );

      expect(repo.updateVerificationState).toHaveBeenCalledWith(
        'vendor-1',
        'REJECTED',
        'admin-user-1',
        'Trade licence expired and illegible',
        'Trade licence expired and illegible',
      );
      expect(result.lifecycle).toBe('REJECTED');
    });
  });

  describe('requestInfo', () => {
    it('sets vendor-facing verificationMessage and retains PENDING_VERIFICATION', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue(mockVendorDetailRow as any);
      vi.mocked(repo.updateVerificationState).mockResolvedValue({
        ...mockVendorProfile,
        verificationState: 'PENDING_VERIFICATION',
        verificationMessage: 'Please upload a clearer scan of your Emirates ID',
        user: mockUser,
      } as any);

      const result = await service.requestInfo(
        mockAdminViewer,
        'vendor-1',
        'Please upload a clearer scan of your Emirates ID',
      );

      expect(repo.updateVerificationState).toHaveBeenCalledWith(
        'vendor-1',
        'PENDING_VERIFICATION',
        'admin-user-1',
        undefined,
        'Please upload a clearer scan of your Emirates ID',
      );
      expect(result.lifecycle).toBe('PENDING_VERIFICATION');
    });
  });

  describe('lifecycle actions', () => {
    it('activateVendor sets accountState to ACTIVE', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue(mockVendorDetailRow as any);
      vi.mocked(repo.updateAccountState).mockResolvedValue({
        vendorProfileId: 'vendor-1',
        accountState: 'ACTIVE',
      });

      const result = await service.activateVendor(mockAdminViewer, 'vendor-1', {
        reasonCode: 'COMPLIANCE_RESTORED',
        reasonText: 'Compliance documents updated',
      });

      expect(repo.updateAccountState).toHaveBeenCalledWith(
        'vendor-1',
        'ACTIVE',
        'admin-user-1',
        'COMPLIANCE_RESTORED',
        'Compliance documents updated',
      );
      expect(result.accountState).toBe('ACTIVE');
    });

    it('suspendVendor sets accountState to SUSPENDED', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue(mockVendorDetailRow as any);
      vi.mocked(repo.updateAccountState).mockResolvedValue({
        vendorProfileId: 'vendor-1',
        accountState: 'SUSPENDED',
      });

      const result = await service.suspendVendor(mockAdminViewer, 'vendor-1', {
        reasonCode: 'INVESTIGATION',
        reasonText: 'Suspicious transaction pattern under investigation',
      });

      expect(repo.updateAccountState).toHaveBeenCalledWith(
        'vendor-1',
        'SUSPENDED',
        'admin-user-1',
        'INVESTIGATION',
        'Suspicious transaction pattern under investigation',
      );
      expect(result.accountState).toBe('SUSPENDED');
      expect(result.lifecycle).toBe('SUSPENDED');
    });

    it('reactivateVendor restores accountState to ACTIVE', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue({
        ...mockVendorDetailRow,
        verificationState: 'VERIFIED',
        activatedAt: fixedNow,
      } as any);
      vi.mocked(repo.updateAccountState).mockResolvedValue({
        vendorProfileId: 'vendor-1',
        accountState: 'ACTIVE',
      });

      const result = await service.reactivateVendor(mockAdminViewer, 'vendor-1', {
        reasonCode: 'REINSTATED',
        reasonText: 'Investigation cleared',
      });

      expect(result.accountState).toBe('ACTIVE');
      expect(result.lifecycle).toBe('ACTIVE');
    });

    it('deactivateVendor sets accountState to DEACTIVATED', async () => {
      vi.mocked(repo.findVendorById).mockResolvedValue(mockVendorDetailRow as any);
      vi.mocked(repo.updateAccountState).mockResolvedValue({
        vendorProfileId: 'vendor-1',
        accountState: 'DEACTIVATED',
      });

      const result = await service.deactivateVendor(mockAdminViewer, 'vendor-1', {
        reasonCode: 'VENDOR_REQUEST',
        reasonText: 'Business ceased operations',
      });

      expect(result.accountState).toBe('DEACTIVATED');
      expect(result.lifecycle).toBe('DEACTIVATED');
    });
  });

  describe('getDocumentSignedUrl', () => {
    it('generates a 15-minute signed URL and records an audit row', async () => {
      vi.mocked(repo.findVendorDocument).mockResolvedValue({
        id: 'doc-1',
        vendorProfileId: 'vendor-1',
        documentType: 'TRADE_LICENCE',
        mediaId: 'media-1',
        media: {
          id: 'media-1',
          state: 'READY',
          key: 'tl-doc-key',
        },
        vendorProfile: {
          userId: 'user-vendor-1',
        },
      } as any);

      const result = await service.getDocumentSignedUrl(
        mockAdminViewer,
        clientInfo,
        'vendor-1',
        'doc-1',
      );

      expect(result.url).toBe('https://storage.karathive.ae/signed-doc.pdf');
      expect(storage.createSignedDownloadUrl).toHaveBeenCalledWith(
        'test-kyc-bucket',
        'vendor/vendor-1/KYC_DOCUMENT/tl-doc-key',
        900,
      );
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'VENDOR_DOCUMENT_VIEWED',
          entityType: 'vendor_document',
          entityId: 'doc-1',
          actorUserId: 'admin-user-1',
        }),
      );
    });

    it('rejects access if media is QUARANTINED', async () => {
      vi.mocked(repo.findVendorDocument).mockResolvedValue({
        id: 'doc-1',
        vendorProfileId: 'vendor-1',
        media: { state: 'QUARANTINED' },
      } as any);

      await expect(
        service.getDocumentSignedUrl(mockAdminViewer, clientInfo, 'vendor-1', 'doc-1'),
      ).rejects.toMatchObject({
        errorCode: ErrorCode.MEDIA_QUARANTINED,
      });
    });

    it('rejects access if media upload is not completed', async () => {
      vi.mocked(repo.findVendorDocument).mockResolvedValue({
        id: 'doc-1',
        vendorProfileId: 'vendor-1',
        media: { state: 'PENDING_UPLOAD' },
      } as any);

      await expect(
        service.getDocumentSignedUrl(mockAdminViewer, clientInfo, 'vendor-1', 'doc-1'),
      ).rejects.toMatchObject({
        errorCode: ErrorCode.UPLOAD_NOT_COMPLETED,
      });
    });
  });

  describe('addNote', () => {
    it('creates an admin note and returns formatted note view', async () => {
      vi.mocked(repo.addNote).mockResolvedValue({
        id: 'note-1',
        entityType: 'vendor_profile',
        entityId: 'vendor-1',
        text: 'Called vendor to confirm trade licence renewal status',
        authorAdminId: 'admin-prof-1',
        author: { displayName: 'Admin Sarah', user: mockUser },
        createdAt: fixedNow,
      } as any);

      const result = await service.addNote(
        mockAdminViewer,
        'vendor-1',
        'Called vendor to confirm trade licence renewal status',
      );

      expect(repo.addNote).toHaveBeenCalledWith(
        'vendor-1',
        'admin-user-1',
        'Called vendor to confirm trade licence renewal status',
      );
      expect(result.id).toBe('note-1');
      expect(result.text).toBe('Called vendor to confirm trade licence renewal status');
      expect(result.authorDisplayName).toBe('Admin Sarah');
    });
  });
});
