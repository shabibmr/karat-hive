import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import type { User } from '@prisma/client';
import { RegistrationService } from './registration.service';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { Clock } from '../../../shared/clock';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { OtpService } from './otp.service';
import type { SessionService } from './session.service';
import type { UserRepository } from '../repository/user.repository';
import type { TaxonomyQuery } from '../../taxonomy';
import type { VendorOnboardingService } from '../../vendor-onboarding';
import type { AuditWriter } from '../../audit';
import type { FirebaseTokenService } from './firebase-token.service';
import type { SessionBundle } from '../presenter/session.presenter';

describe('RegistrationService - registerCustomer', () => {
  let service: RegistrationService;
  let prisma: PrismaService;
  let clock: Clock;
  let otp: OtpService;
  let session: SessionService;
  let users: UserRepository;
  let taxonomy: TaxonomyQuery;
  let vendors: VendorOnboardingService;
  let audit: AuditWriter;
  let firebaseTokens: FirebaseTokenService;

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

  const mockBundle: SessionBundle = {
    accessToken: 'access-token',
    accessExpiresAt: new Date().toISOString(),
    refreshToken: 'refresh-token',
    refreshExpiresAt: new Date().toISOString(),
    me: {
      userId: 'cust-1',
      userType: 'CUSTOMER',
      accountState: 'ACTIVE',
      mobileNumber: '+971501112233',
      email: 'customer@example.com',
      preferredLanguage: 'en',
      customer: {
        displayName: 'Fatima Al-Nuaimi',
        photoUrl: null,
        defaultRegion: null,
        rating: null,
        reviewCount: 0,
        connectionCount: 0,
      },
    },
  };

  beforeEach(() => {
    clock = {
      now: vi.fn().mockReturnValue(new Date('2026-09-06T10:00:00Z')),
    } as unknown as Clock;

    const mockTx = {
      oauthBinding: { create: vi.fn().mockResolvedValue({}) },
    };

    prisma = {
      $transaction: vi.fn().mockImplementation(async (cb) => cb(mockTx)),
    } as unknown as PrismaService;

    otp = {
      requireVerified: vi.fn().mockResolvedValue({
        id: 'chal-1',
        mobileNumber: '+971501112233',
        purpose: 'REGISTER_CUSTOMER',
      }),
    } as unknown as OtpService;

    session = {
      issueFor: vi.fn().mockResolvedValue(mockBundle),
    } as unknown as SessionService;

    users = {
      findByMobile: vi.fn().mockResolvedValue(null),
      findByEmail: vi.fn().mockResolvedValue(null),
      createCustomerUser: vi.fn().mockResolvedValue(mockCustomerUser),
      createCustomerProfile: vi.fn().mockResolvedValue({ id: 'cp-1' }),
    } as unknown as UserRepository;

    taxonomy = {
      assertActive: vi.fn().mockResolvedValue(undefined),
    } as unknown as TaxonomyQuery;

    vendors = {} as unknown as VendorOnboardingService;

    audit = {
      append: vi.fn().mockResolvedValue(undefined),
    } as unknown as AuditWriter;

    firebaseTokens = {
      verify: vi.fn(),
    } as unknown as FirebaseTokenService;

    service = new RegistrationService(
      prisma,
      clock,
      otp,
      session,
      users,
      taxonomy,
      vendors,
      audit,
      firebaseTokens,
    );
  });

  it('registers a customer successfully via OTP challenge', async () => {
    const result = await service.registerCustomer(
      {
        challengeId: 'chal-1',
        displayName: 'Fatima Al-Nuaimi',
        email: 'customer@example.com',
        preferredLanguage: 'en',
        termsVersion: '1.0',
        privacyVersion: '1.0',
      },
      { ip: '127.0.0.1' },
    );

    expect(result).toBe(mockBundle);
    expect(otp.requireVerified).toHaveBeenCalledWith('chal-1', 'REGISTER_CUSTOMER');
    expect(users.createCustomerUser).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        mobileNumber: '+971501112233',
        email: 'customer@example.com',
        preferredLanguage: 'en',
        termsVersion: '1.0',
        privacyVersion: '1.0',
      }),
    );
    expect(users.createCustomerProfile).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        userId: 'cust-1',
        displayName: 'Fatima Al-Nuaimi',
      }),
    );
    expect(audit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        action: 'CUSTOMER_REGISTERED',
        actorUserId: 'cust-1',
      }),
    );
  });

  it('rejects if mobile number is already registered with 409 MOBILE_ALREADY_REGISTERED', async () => {
    vi.mocked(users.findByMobile).mockResolvedValue(mockCustomerUser);

    await expect(
      service.registerCustomer(
        {
          challengeId: 'chal-1',
          displayName: 'Fatima',
          termsVersion: '1.0',
          privacyVersion: '1.0',
        },
        {},
      ),
    ).rejects.toMatchObject({
      status: HttpStatus.CONFLICT,
      errorCode: ErrorCode.MOBILE_ALREADY_REGISTERED,
    });
  });

  it('rejects if email is already registered with 409 EMAIL_ALREADY_REGISTERED', async () => {
    vi.mocked(users.findByEmail).mockResolvedValue(mockCustomerUser);

    await expect(
      service.registerCustomer(
        {
          challengeId: 'chal-1',
          displayName: 'Fatima',
          email: 'duplicate@example.com',
          termsVersion: '1.0',
          privacyVersion: '1.0',
        },
        {},
      ),
    ).rejects.toMatchObject({
      status: HttpStatus.CONFLICT,
      errorCode: ErrorCode.EMAIL_ALREADY_REGISTERED,
    });
  });

  it('registers a customer with Firebase token linking OauthBinding', async () => {
    vi.mocked(firebaseTokens.verify).mockResolvedValue({
      uid: 'fb-user-999',
      email: 'customer-fb@example.com',
      emailVerified: true,
      phoneNumber: '+971509998877',
      name: 'Google Customer',
    });

    const result = await service.registerCustomer(
      {
        firebaseToken: 'valid-firebase-jwt',
        displayName: 'Google Customer',
        termsVersion: '1.0',
        privacyVersion: '1.0',
      },
      { ip: '127.0.0.1' },
    );

    expect(result).toBe(mockBundle);
    expect(firebaseTokens.verify).toHaveBeenCalledWith('valid-firebase-jwt');
    expect(users.createCustomerUser).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        mobileNumber: '+971509998877',
        email: 'customer-fb@example.com',
      }),
    );
  });
});

describe('RegistrationService - registerVendor (G2-A11 Google completer)', () => {
  let service: RegistrationService;
  let prisma: PrismaService;
  let clock: Clock;
  let otp: OtpService;
  let session: SessionService;
  let users: UserRepository;
  let taxonomy: TaxonomyQuery;
  let vendors: VendorOnboardingService;
  let audit: AuditWriter;
  let firebaseTokens: FirebaseTokenService;
  let mockTx: { oauthBinding: { create: ReturnType<typeof vi.fn> } };

  const mockVendorUser: User = {
    id: 'ven-1',
    mobileNumber: '+971501234567',
    mobileVerifiedAt: new Date('2026-09-07T10:00:00Z'),
    email: 'shop@example.com',
    emailVerifiedAt: null,
    emailPending: null,
    passwordHash: null,
    userType: 'VENDOR',
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    tokenVersion: 0,
    termsVersion: '1.0',
    privacyVersion: '1.0',
    termsAcceptedAt: new Date('2026-09-07T10:00:00Z'),
    quietHoursStart: null,
    quietHoursEnd: null,
    lastLoginAt: null,
    failedLoginAttempts: 0,
    lockedUntil: null,
    deletedAt: null,
    createdAt: new Date('2026-09-07T10:00:00Z'),
    updatedAt: new Date('2026-09-07T10:00:00Z'),
  };

  const vendorBody = {
    legalBusinessName: 'Gold House LLC',
    tradingName: 'Gold House',
    tradeLicenceNumber: 'TL-123',
    licenceExpiryDate: '2027-01-01',
    businessAddress: 'Dubai',
    contactPersonName: 'Ali',
    businessEmail: 'shop@example.com',
    regionId: '11111111-1111-1111-1111-111111111111',
    categoryIds: ['22222222-2222-2222-2222-222222222222'],
    servedRegionIds: ['11111111-1111-1111-1111-111111111111'],
    termsVersion: '1.0',
    privacyVersion: '1.0',
  };

  beforeEach(() => {
    clock = {
      now: vi.fn().mockReturnValue(new Date('2026-09-07T10:00:00Z')),
    } as unknown as Clock;

    mockTx = {
      oauthBinding: { create: vi.fn().mockResolvedValue({}) },
    };

    prisma = {
      $transaction: vi.fn().mockImplementation(async (cb) => cb(mockTx)),
    } as unknown as PrismaService;

    otp = {
      requireVerified: vi.fn().mockResolvedValue({
        id: 'chal-v1',
        mobileNumber: '+971501234567',
        purpose: 'REGISTER_VENDOR',
      }),
    } as unknown as OtpService;

    session = {
      issueFor: vi.fn().mockResolvedValue({ accessToken: 'a' }),
    } as unknown as SessionService;

    users = {
      findByMobile: vi.fn().mockResolvedValue(null),
      findByEmail: vi.fn().mockResolvedValue(null),
      createVendorUser: vi.fn().mockResolvedValue(mockVendorUser),
    } as unknown as UserRepository;

    taxonomy = {
      assertActive: vi.fn().mockResolvedValue(undefined),
    } as unknown as TaxonomyQuery;

    vendors = {
      licenceExists: vi.fn().mockResolvedValue(false),
      createProfile: vi.fn().mockResolvedValue({ id: 'vp-1' }),
    } as unknown as VendorOnboardingService;

    audit = { append: vi.fn() } as unknown as AuditWriter;
    firebaseTokens = { verify: vi.fn() } as unknown as FirebaseTokenService;

    service = new RegistrationService(
      prisma,
      clock,
      otp,
      session,
      users,
      taxonomy,
      vendors,
      audit,
      firebaseTokens,
    );
  });

  it('registers a vendor with Firebase token and links OauthBinding', async () => {
    vi.mocked(firebaseTokens.verify).mockResolvedValue({
      uid: 'fb-vendor-1',
      email: 'shop@example.com',
      emailVerified: true,
      phoneNumber: '+971501234567',
      name: 'Ali',
    });

    await service.registerVendor(
      { ...vendorBody, firebaseToken: 'vendor-firebase-jwt' },
      { ip: '127.0.0.1' },
    );

    expect(firebaseTokens.verify).toHaveBeenCalledWith('vendor-firebase-jwt');
    expect(otp.requireVerified).not.toHaveBeenCalled();
    expect(users.createVendorUser).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ mobileNumber: '+971501234567', email: 'shop@example.com' }),
    );
    expect(mockTx.oauthBinding.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          userId: 'ven-1',
          provider: 'GOOGLE',
        }),
      }),
    );
  });

  it('rejects Google vendor register without E.164 mobile', async () => {
    vi.mocked(firebaseTokens.verify).mockResolvedValue({
      uid: 'fb-vendor-2',
      email: 'shop@example.com',
      emailVerified: true,
      phoneNumber: undefined,
      name: 'Ali',
    });

    await expect(
      service.registerVendor({ ...vendorBody, firebaseToken: 'no-phone-jwt' }, {}),
    ).rejects.toMatchObject({
      status: HttpStatus.UNPROCESSABLE_ENTITY,
      errorCode: ErrorCode.VALIDATION_FAILED,
    });
  });
});
