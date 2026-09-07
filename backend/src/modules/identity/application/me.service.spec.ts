import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import type { DataSubjectRequest, User } from '@prisma/client';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { Clock } from '../../../shared/clock';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';
import type { VendorOnboardingService } from '../../vendor-onboarding';
import { DELETION_AWAITING_CONFIRMATION, type UserRepository } from '../repository/user.repository';
import type { OtpService } from './otp.service';
import { MeService } from './me.service';

describe('MeService', () => {
  let service: MeService;
  let users: UserRepository;
  let vendors: VendorOnboardingService;
  let otp: OtpService;
  let prisma: PrismaService;
  let clock: Clock;
  let audit: AuditWriter;

  const now = new Date('2026-09-07T10:00:00Z');

  const mockCustomerUser: User = {
    id: 'cust-1',
    mobileNumber: '+971501112233',
    mobileVerifiedAt: new Date('2026-09-06T10:00:00Z'),
    email: 'customer@example.com',
    emailVerifiedAt: null,
    emailPending: null,
    passwordHash: null,
    userType: 'CUSTOMER',
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    tokenVersion: 0,
    termsVersion: '1.0',
    privacyVersion: '1.0',
    termsAcceptedAt: new Date('2026-09-06T10:00:00Z'),
    quietHoursStart: null,
    quietHoursEnd: null,
    lastLoginAt: null,
    failedLoginAttempts: 0,
    lockedUntil: null,
    deletedAt: null,
    createdAt: new Date('2026-09-06T10:00:00Z'),
    updatedAt: new Date('2026-09-06T10:00:00Z'),
  };

  const customerViewer: ViewerContext = {
    userId: 'cust-1',
    role: 'CUSTOMER',
    tokenVersion: 0,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    vendorProfileId: null,
    vendorVerificationState: null,
    vendorActivatedAt: null,
    customerProfileId: 'cp-1',
    adminProfileId: null,
  };

  const vendorViewer: ViewerContext = {
    ...customerViewer,
    userId: 'ven-1',
    role: 'VENDOR',
    vendorProfileId: 'vp-1',
    customerProfileId: null,
  };

  const adminViewer: ViewerContext = {
    ...customerViewer,
    userId: 'adm-1',
    role: 'ADMIN',
    customerProfileId: null,
    adminProfileId: 'ap-1',
  };

  beforeEach(() => {
    users = {
      findById: vi.fn().mockResolvedValue(mockCustomerUser),
      findByMobile: vi.fn().mockResolvedValue(null),
      findCustomerProfile: vi.fn(),
      findAdminProfile: vi.fn(),
      setPreferredLanguage: vi.fn().mockResolvedValue(undefined),
      updateCustomerProfile: vi.fn().mockResolvedValue({} as never),
      hasOauthBinding: vi.fn().mockResolvedValue(true),
      countLiveRequestsForCustomer: vi.fn().mockResolvedValue(1),
      updateMobile: vi.fn().mockImplementation(async (_tx, id, mobileNumber, mobileVerifiedAt) => ({
        ...mockCustomerUser,
        id,
        mobileNumber,
        mobileVerifiedAt,
      })),
      setAccountState: vi.fn().mockImplementation(async (_tx, id, accountState) => ({
        ...mockCustomerUser,
        id,
        accountState,
      })),
      countActiveConnectionsForVendor: vi.fn().mockResolvedValue(0),
      hasConnectionCreatedSince: vi.fn().mockResolvedValue(false),
      closeLiveRequestsForCustomer: vi.fn().mockResolvedValue(undefined),
      createDataSubjectRequest: vi.fn(),
      findDataSubjectRequest: vi.fn(),
      findPendingDeletionRequest: vi.fn().mockResolvedValue(null),
      confirmDataSubjectRequest: vi.fn(),
    } as unknown as UserRepository;

    vendors = {
      vendorMeForUser: vi.fn(),
    } as unknown as VendorOnboardingService;

    otp = {
      requireVerified: vi.fn(),
      issueChallenge: vi.fn().mockResolvedValue({
        challengeId: 'chal-new',
        expiresAt: new Date('2026-09-07T10:05:00Z'),
        retryAfterSeconds: 60,
      }),
      verifyChallenge: vi.fn(),
    } as unknown as OtpService;

    prisma = {
      $transaction: vi.fn().mockImplementation(async (cb: (tx: unknown) => Promise<unknown>) =>
        cb({}),
      ),
    } as unknown as PrismaService;

    clock = { now: vi.fn().mockReturnValue(now) } as unknown as Clock;
    audit = { append: vi.fn().mockResolvedValue(undefined) } as unknown as AuditWriter;

    service = new MeService(users, vendors, otp, prisma, clock, audit);
  });

  it('formats customer profile data in forUser when user is CUSTOMER', async () => {
    vi.mocked(users.findCustomerProfile).mockResolvedValue({
      id: 'cp-1',
      userId: 'cust-1',
      displayName: 'Fatima Al-Nuaimi',
      photoMediaId: 'media-1',
      defaultRegionId: 'reg-1',
      aggregateRating: '4.8' as unknown as import('@prisma/client').Prisma.Decimal,
      reviewCount: 5,
      connectionCount: 3,
      createdAt: new Date(),
      updatedAt: new Date(),
      defaultRegion: { id: 'reg-1', nameEn: 'Dubai', nameAr: 'دبي' },
      photoMedia: { id: 'media-1', key: 'cust-photo-key' },
    });

    const result = await service.forUser(mockCustomerUser);

    expect(result.userId).toBe('cust-1');
    expect(result.userType).toBe('CUSTOMER');
    expect(result.oauthBound).toBe(true);
    expect(result.customer).toBeDefined();
    expect(result.customer?.displayName).toBe('Fatima Al-Nuaimi');
    expect(result.customer?.photoUrl).toBe('/v1/media/cust-photo-key');
    expect(result.customer?.defaultRegion).toEqual({
      id: 'reg-1',
      nameEn: 'Dubai',
      nameAr: 'دبي',
    });
    expect(result.customer?.rating).toEqual({
      average: 4.8,
      count: 5,
    });
    expect(result.customer?.reviewCount).toBe(5);
    expect(result.customer?.connectionCount).toBe(3);
    expect(result.customer?.liveRequestCount).toBe(1);
    expect(result.customer?.canCreateRequest).toBe(true);
    expect(result.vendor).toBeUndefined();
    expect(result.admin).toBeUndefined();
  });

  it('updates customer profile on patch when viewer role is CUSTOMER', async () => {
    vi.mocked(users.findCustomerProfile).mockResolvedValue({
      id: 'cp-1',
      userId: 'cust-1',
      displayName: 'Fatima Updated',
      photoMediaId: null,
      defaultRegionId: 'reg-2',
      aggregateRating: null,
      reviewCount: 0,
      connectionCount: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
      defaultRegion: null,
      photoMedia: null,
    });

    const result = await service.patch(customerViewer, {
      displayName: 'Fatima Updated',
      defaultRegionId: 'reg-2',
      preferredLanguage: 'ar',
    });

    expect(users.setPreferredLanguage).toHaveBeenCalledWith('cust-1', 'ar');
    expect(users.updateCustomerProfile).toHaveBeenCalledWith('cust-1', {
      displayName: 'Fatima Updated',
      defaultRegionId: 'reg-2',
    });
    expect(result.customer?.displayName).toBe('Fatima Updated');
  });

  describe('changeMobile (G2-I07)', () => {
    it('applies a verified CHANGE_MOBILE challenge and releases the old number', async () => {
      vi.mocked(otp.requireVerified).mockResolvedValue({
        id: 'chal-1',
        mobileNumber: '+971509998877',
        purpose: 'CHANGE_MOBILE',
        consumedAt: now,
      } as never);
      vi.mocked(users.findCustomerProfile).mockResolvedValue(null);

      const result = await service.changeMobile(customerViewer, 'chal-1');

      expect(otp.requireVerified).toHaveBeenCalledWith('chal-1', 'CHANGE_MOBILE');
      expect(users.updateMobile).toHaveBeenCalledWith(
        expect.anything(),
        'cust-1',
        '+971509998877',
        now,
      );
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({ action: 'MOBILE_CHANGED' }),
      );
      expect(result.mobileNumber).toBe('+971509998877');
    });

    it('rejects a number already held by another user', async () => {
      vi.mocked(otp.requireVerified).mockResolvedValue({
        id: 'chal-1',
        mobileNumber: '+971509998877',
        purpose: 'CHANGE_MOBILE',
        consumedAt: now,
      } as never);
      vi.mocked(users.findByMobile).mockResolvedValue({
        ...mockCustomerUser,
        id: 'other-user',
        mobileNumber: '+971509998877',
      });

      await expect(service.changeMobile(customerViewer, 'chal-1')).rejects.toMatchObject({
        status: HttpStatus.CONFLICT,
        errorCode: ErrorCode.MOBILE_ALREADY_REGISTERED,
      });
      expect(users.updateMobile).not.toHaveBeenCalled();
    });

    it('rejects Admin callers', async () => {
      await expect(service.changeMobile(adminViewer, 'chal-1')).rejects.toMatchObject({
        status: HttpStatus.FORBIDDEN,
        errorCode: ErrorCode.FORBIDDEN,
      });
    });
  });

  describe('deactivate (G2-I08)', () => {
    it('closes live Requests and sets DEACTIVATED for a Customer', async () => {
      vi.mocked(users.findCustomerProfile).mockResolvedValue(null);

      const result = await service.deactivate(customerViewer);

      expect(users.closeLiveRequestsForCustomer).toHaveBeenCalledWith('cp-1', expect.anything());
      expect(users.setAccountState).toHaveBeenCalledWith(expect.anything(), 'cust-1', 'DEACTIVATED');
      expect(result.accountState).toBe('DEACTIVATED');
    });

    it('refuses a Vendor who still has an ACTIVE Connection', async () => {
      vi.mocked(users.findById).mockResolvedValue({
        ...mockCustomerUser,
        id: 'ven-1',
        userType: 'VENDOR',
      });
      vi.mocked(users.countActiveConnectionsForVendor).mockResolvedValue(1);

      await expect(service.deactivate(vendorViewer)).rejects.toMatchObject({
        status: HttpStatus.FORBIDDEN,
        errorCode: ErrorCode.FORBIDDEN,
      });
      expect(users.setAccountState).not.toHaveBeenCalled();
    });

    it('deactivates a Vendor with no ACTIVE Connection', async () => {
      const vendorUser = { ...mockCustomerUser, id: 'ven-1', userType: 'VENDOR' as const };
      vi.mocked(users.findById).mockResolvedValue(vendorUser);
      vi.mocked(users.setAccountState).mockResolvedValue({
        ...vendorUser,
        accountState: 'DEACTIVATED',
      });
      vi.mocked(vendors.vendorMeForUser).mockResolvedValue({
        lifecycle: 'DEACTIVATED',
        verificationState: 'VERIFIED',
        tradingName: 'Gold Co',
        legalBusinessName: 'Gold Co LLC',
        awaitingApproval: true,
        rating: { average: 0, count: 0 },
        reviewCount: 0,
        offersSubmittedCount: 0,
        offersAcceptedCount: 0,
        awayMode: false,
      });

      const result = await service.deactivate(vendorViewer);

      expect(users.closeLiveRequestsForCustomer).not.toHaveBeenCalled();
      expect(users.setAccountState).toHaveBeenCalledWith(expect.anything(), 'ven-1', 'DEACTIVATED');
      expect(result.accountState).toBe('DEACTIVATED');
    });
  });

  describe('deletion-requests (G2-I09)', () => {
    const pendingRow = {
      id: 'dsr-1',
      userId: 'cust-1',
      state: 'QUEUED',
      reason: DELETION_AWAITING_CONFIRMATION,
      createdAt: now,
      completedAt: null,
      actionedByAdminId: null,
      certificateMediaId: null,
    } as DataSubjectRequest;

    it('creates a pending request and issues a CHANGE_MOBILE OTP', async () => {
      vi.mocked(users.createDataSubjectRequest).mockResolvedValue(pendingRow);

      const result = await service.createDeletionRequest(customerViewer);

      expect(otp.issueChallenge).toHaveBeenCalledWith('+971501112233', 'CHANGE_MOBILE');
      expect(users.createDataSubjectRequest).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          userId: 'cust-1',
          state: 'QUEUED',
          reason: DELETION_AWAITING_CONFIRMATION,
        }),
      );
      expect(result).toMatchObject({
        id: 'dsr-1',
        state: 'QUEUED',
        challengeId: 'chal-new',
        retryAfterSeconds: 60,
      });
    });

    it('refuses create when a Connection was created in the last 30 days', async () => {
      vi.mocked(users.hasConnectionCreatedSince).mockResolvedValue(true);

      await expect(service.createDeletionRequest(customerViewer)).rejects.toMatchObject({
        status: HttpStatus.FORBIDDEN,
        errorCode: ErrorCode.FORBIDDEN,
      });
      expect(users.createDataSubjectRequest).not.toHaveBeenCalled();
    });

    it('confirms with a verified OTP and stubs worker completion as QUEUED', async () => {
      vi.mocked(users.findDataSubjectRequest).mockResolvedValue(pendingRow);
      vi.mocked(otp.requireVerified).mockResolvedValue({
        id: 'chal-1',
        mobileNumber: '+971501112233',
        purpose: 'CHANGE_MOBILE',
        consumedAt: now,
      } as never);
      vi.mocked(users.confirmDataSubjectRequest).mockResolvedValue({
        ...pendingRow,
        reason: null,
      });

      const result = await service.confirmDeletionRequest(customerViewer, 'dsr-1', 'chal-1');

      expect(otp.requireVerified).toHaveBeenCalledWith('chal-1', 'CHANGE_MOBILE');
      expect(users.confirmDataSubjectRequest).toHaveBeenCalledWith(expect.anything(), 'dsr-1');
      expect(users.closeLiveRequestsForCustomer).not.toHaveBeenCalled();
      expect(result).toEqual({
        id: 'dsr-1',
        state: 'QUEUED',
        createdAt: now.toISOString(),
      });
    });

    it('refuses confirm when a Connection was created in the last 30 days', async () => {
      vi.mocked(users.findDataSubjectRequest).mockResolvedValue(pendingRow);
      vi.mocked(users.hasConnectionCreatedSince).mockResolvedValue(true);

      await expect(
        service.confirmDeletionRequest(customerViewer, 'dsr-1', 'chal-1'),
      ).rejects.toMatchObject({
        status: HttpStatus.FORBIDDEN,
        errorCode: ErrorCode.FORBIDDEN,
      });
      expect(users.confirmDataSubjectRequest).not.toHaveBeenCalled();
    });

    it('refuses Vendor callers', async () => {
      await expect(service.createDeletionRequest(vendorViewer)).rejects.toMatchObject({
        status: HttpStatus.FORBIDDEN,
        errorCode: ErrorCode.FORBIDDEN,
      });
    });
  });
});
