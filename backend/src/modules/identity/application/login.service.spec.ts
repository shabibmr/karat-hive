import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import type { User } from '@prisma/client';
import { LoginService } from './login.service';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { Clock } from '../../../shared/clock';
import type { Env } from '../../../config/env';
import type { PasswordHasher } from '../../../platform/ports/password-hasher.port';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { UserRepository } from '../repository/user.repository';
import type { SessionService } from './session.service';
import type { AuditWriter } from '../../audit';
import type { VendorOnboardingService } from '../../vendor-onboarding';
import type { SessionBundle } from '../presenter/session.presenter';

describe('LoginService', () => {
  let service: LoginService;
  let env: Env;
  let hasher: PasswordHasher;
  let clock: Clock;
  let prisma: PrismaService;
  let users: UserRepository;
  let session: SessionService;
  let audit: AuditWriter;
  let vendors: VendorOnboardingService;

  const mockAdminUser: User = {
    id: 'admin-1',
    mobileNumber: '+971500000001',
    mobileVerifiedAt: new Date(),
    email: 'admin@karathive.ae',
    emailVerifiedAt: new Date(),
    emailPending: null,
    passwordHash: 'scrypt$salt$hash',
    userType: 'ADMIN',
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    tokenVersion: 0,
    termsVersion: '1.0',
    privacyVersion: '1.0',
    termsAcceptedAt: new Date(),
    quietHoursStart: null,
    quietHoursEnd: null,
    lastLoginAt: null,
    failedLoginAttempts: 0,
    lockedUntil: null,
    deletedAt: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockBundle: SessionBundle = {
    accessToken: 'access-token',
    accessExpiresAt: new Date().toISOString(),
    refreshToken: 'refresh-token',
    refreshExpiresAt: new Date().toISOString(),
    me: {
      userId: 'admin-1',
      userType: 'ADMIN',
      accountState: 'ACTIVE',
      mobileNumber: '+971500000001',
      email: 'admin@karathive.ae',
      preferredLanguage: 'en',
      admin: { displayName: 'Platform Admin' },
    },
  };

  beforeEach(() => {
    env = {
      LOGIN_MAX_FAILURES: 5,
      LOGIN_LOCK_MINUTES: 15,
    } as unknown as Env;

    hasher = {
      hash: vi.fn(),
      verify: vi.fn().mockResolvedValue(true),
    };

    clock = {
      now: vi.fn().mockReturnValue(new Date('2026-09-04T00:00:00Z')),
    } as unknown as Clock;

    prisma = {
      $transaction: vi.fn().mockImplementation(async (cb) => cb({})),
    } as unknown as PrismaService;

    users = {
      findByEmail: vi.fn(),
      findById: vi.fn(),
      findByMobile: vi.fn(),
      findAdminProfile: vi.fn(),
      applyLockState: vi.fn().mockResolvedValue(undefined),
      touchLogin: vi.fn().mockResolvedValue(undefined),
      setPreferredLanguage: vi.fn(),
      createVendorUser: vi.fn(),
    } as unknown as UserRepository;

    session = {
      issueFor: vi.fn().mockResolvedValue(mockBundle),
    } as unknown as SessionService;

    audit = {
      append: vi.fn().mockResolvedValue(undefined),
    } as unknown as AuditWriter;

    vendors = {
      assertMayAuthenticate: vi.fn(),
    } as unknown as VendorOnboardingService;

    service = new LoginService(env, hasher, clock, prisma, users, session, audit, vendors);
  });

  it('authenticates admin with valid email and password, auditing success and resetting attempts', async () => {
    vi.mocked(users.findByEmail).mockResolvedValue({
      ...mockAdminUser,
      failedLoginAttempts: 2,
    });
    vi.mocked(hasher.verify).mockResolvedValue(true);

    const result = await service.loginWithPassword('admin@karathive.ae', 'valid-password', {
      ip: '127.0.0.1',
      userAgent: 'test-agent',
    });

    expect(result).toBe(mockBundle);
    expect(users.applyLockState).toHaveBeenCalledWith('admin-1', {
      failedLoginAttempts: 0,
      lockedUntil: null,
    });
    expect(audit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        action: 'ADMIN_LOGIN',
        actorUserId: 'admin-1',
        afterValue: { success: true },
      }),
    );
  });

  it('rejects unknown email with 401 UNAUTHENTICATED and records audit entry', async () => {
    vi.mocked(users.findByEmail).mockResolvedValue(null);

    await expect(
      service.loginWithPassword('unknown@karathive.ae', 'password', { ip: '127.0.0.1' }),
    ).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });

    expect(audit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        action: 'ADMIN_LOGIN',
        actorUserId: null,
        afterValue: { success: false, reason: 'UNKNOWN_USER' },
      }),
    );
  });

  it('rejects incorrect password with 401 UNAUTHENTICATED, increments failure counter, and audits failure', async () => {
    vi.mocked(users.findByEmail).mockResolvedValue({
      ...mockAdminUser,
      failedLoginAttempts: 1,
    });
    vi.mocked(hasher.verify).mockResolvedValue(false);

    await expect(
      service.loginWithPassword('admin@karathive.ae', 'wrong-password', { ip: '127.0.0.1' }),
    ).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });

    expect(users.applyLockState).toHaveBeenCalledWith('admin-1', {
      failedLoginAttempts: 2,
      lockedUntil: null,
    });
    expect(audit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        action: 'ADMIN_LOGIN',
        actorUserId: 'admin-1',
        afterValue: { success: false, reason: 'BAD_PASSWORD' },
      }),
    );
  });

  it('locks admin account after 3 failed attempts with 423 ACCOUNT_LOCKED and writes audit', async () => {
    vi.mocked(users.findByEmail).mockResolvedValue({
      ...mockAdminUser,
      failedLoginAttempts: 2, // 3rd failure
    });
    vi.mocked(hasher.verify).mockResolvedValue(false);

    await expect(
      service.loginWithPassword('admin@karathive.ae', 'wrong-password', { ip: '127.0.0.1' }),
    ).rejects.toMatchObject({
      status: HttpStatus.LOCKED,
      errorCode: ErrorCode.ACCOUNT_LOCKED,
    });

    expect(users.applyLockState).toHaveBeenCalledWith(
      'admin-1',
      expect.objectContaining({
        failedLoginAttempts: 0,
        lockedUntil: expect.any(Date),
      }),
    );
    expect(audit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        action: 'ADMIN_ACCOUNT_LOCKED',
        actorUserId: 'admin-1',
      }),
    );
  });

  it('rejects login immediately if admin account is currently locked', async () => {
    const lockExpiry = new Date('2026-09-04T00:30:00Z');
    vi.mocked(users.findByEmail).mockResolvedValue({
      ...mockAdminUser,
      lockedUntil: lockExpiry,
    });

    await expect(
      service.loginWithPassword('admin@karathive.ae', 'password', {}),
    ).rejects.toMatchObject({
      status: HttpStatus.LOCKED,
      errorCode: ErrorCode.ACCOUNT_LOCKED,
    });
  });

  it('rejects suspended admin with 403 ACCOUNT_SUSPENDED', async () => {
    vi.mocked(users.findByEmail).mockResolvedValue({
      ...mockAdminUser,
      accountState: 'SUSPENDED',
    });
    vi.mocked(hasher.verify).mockResolvedValue(true);

    await expect(
      service.loginWithPassword('admin@karathive.ae', 'password', {}),
    ).rejects.toMatchObject({
      status: HttpStatus.FORBIDDEN,
      errorCode: ErrorCode.ACCOUNT_SUSPENDED,
    });
  });

  it('rejects deactivated admin with 403 ACCOUNT_DEACTIVATED', async () => {
    vi.mocked(users.findByEmail).mockResolvedValue({
      ...mockAdminUser,
      accountState: 'DEACTIVATED',
    });
    vi.mocked(hasher.verify).mockResolvedValue(true);

    await expect(
      service.loginWithPassword('admin@karathive.ae', 'password', {}),
    ).rejects.toMatchObject({
      status: HttpStatus.FORBIDDEN,
      errorCode: ErrorCode.ACCOUNT_DEACTIVATED,
    });
  });

  it('rejects CUSTOMER user on password login route with 401 UNAUTHENTICATED', async () => {
    vi.mocked(users.findByEmail).mockResolvedValue({
      ...mockAdminUser,
      userType: 'CUSTOMER',
    });
    vi.mocked(hasher.verify).mockResolvedValue(true);

    await expect(
      service.loginWithPassword('customer@karathive.ae', 'password', {}),
    ).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });
  });
});
