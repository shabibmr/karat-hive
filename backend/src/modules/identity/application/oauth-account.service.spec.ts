import { describe, expect, it, vi } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { Clock } from '../../../shared/clock';
import { OAuthAccountService } from './oauth-account.service';
import { hashToken } from './token.service';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';
import type { FirebaseTokenService } from './firebase-token.service';
import type { SessionService } from './session.service';

describe('OAuthAccountService', () => {
  const mockNow = new Date('2026-09-07T00:00:00Z');
  const mockClock: Clock = { now: () => mockNow } as Clock;

  const mockUser = {
    id: 'user-existing-1',
    mobileNumber: '+971501112233',
    email: 'test@example.com',
    userType: 'CUSTOMER' as const,
    accountState: 'ACTIVE' as const,
    preferredLanguage: 'en' as const,
    tokenVersion: 1,
    deletedAt: null,
  };

  const mockSessionBundle = {
    accessToken: 'mock-access',
    accessExpiresAt: '2026-09-07T00:15:00Z',
    refreshToken: 'mock-refresh',
    refreshExpiresAt: '2026-09-21T00:00:00Z',
    me: {
      userId: 'user-existing-1',
      userType: 'CUSTOMER' as const,
      accountState: 'ACTIVE' as const,
      mobileNumber: '+971501112233',
      email: 'test@example.com',
      preferredLanguage: 'en' as const,
    },
  };

  it('issues session when user is already bound via OauthBinding (G2-A10)', async () => {
    const firebaseTokens = {
      verify: vi.fn().mockResolvedValue({
        uid: 'google-uid-1',
        email: 'test@example.com',
        emailVerified: true,
      }),
    } as unknown as FirebaseTokenService;

    const sessionService = {
      issueFor: vi.fn().mockResolvedValue(mockSessionBundle),
    } as unknown as SessionService;

    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue({
          id: 'ob-1',
          userId: 'user-existing-1',
          user: mockUser,
        }),
      },
    } as unknown as PrismaService;

    const audit = { append: vi.fn() } as unknown as AuditWriter;

    const service = new OAuthAccountService(
      prisma,
      firebaseTokens,
      sessionService,
      mockClock,
      audit,
    );

    const res = await service.createSessionFromFirebase('valid-firebase-token', {});
    expect(res).toEqual(mockSessionBundle);
    expect(sessionService.issueFor).toHaveBeenCalledWith(mockUser, {});
    expect(prisma.oauthBinding.findUnique).toHaveBeenCalledWith({
      where: { subjectHash: hashToken('google-uid-1') },
      include: { user: true },
    });
  });

  it('binds existing user and issues session when matching verified email is found (G2-A02, G2-A10)', async () => {
    const firebaseTokens = {
      verify: vi.fn().mockResolvedValue({
        uid: 'google-uid-2',
        email: 'test@example.com',
        emailVerified: true,
      }),
    } as unknown as FirebaseTokenService;

    const sessionService = {
      issueFor: vi.fn().mockResolvedValue(mockSessionBundle),
    } as unknown as SessionService;

    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
        upsert: vi.fn().mockResolvedValue({ id: 'ob-new' }),
      },
      user: {
        findUnique: vi.fn().mockResolvedValue(mockUser),
      },
    } as unknown as PrismaService;

    const audit = { append: vi.fn().mockResolvedValue(undefined) } as unknown as AuditWriter;

    const service = new OAuthAccountService(
      prisma,
      firebaseTokens,
      sessionService,
      mockClock,
      audit,
    );

    const res = await service.createSessionFromFirebase('valid-firebase-token', { ip: '127.0.0.1' });
    expect(res).toEqual(mockSessionBundle);
    expect(prisma.oauthBinding.upsert).toHaveBeenCalledWith({
      where: {
        userId_provider: {
          userId: 'user-existing-1',
          provider: 'GOOGLE',
        },
      },
      create: {
        userId: 'user-existing-1',
        provider: 'GOOGLE',
        subjectHash: hashToken('google-uid-2'),
        boundAt: mockNow,
      },
      update: {
        subjectHash: hashToken('google-uid-2'),
        boundAt: mockNow,
      },
    });
    expect(audit.append).toHaveBeenCalled();
  });

  it('throws 401 UNAUTHENTICATED when user does not exist (G2-A01, G2-A06, G2-A10)', async () => {
    const firebaseTokens = {
      verify: vi.fn().mockResolvedValue({
        uid: 'google-uid-unregistered',
        email: 'unregistered@example.com',
        emailVerified: true,
      }),
    } as unknown as FirebaseTokenService;

    const sessionService = { issueFor: vi.fn() } as unknown as SessionService;

    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
      },
      user: {
        findUnique: vi.fn().mockResolvedValue(null),
      },
    } as unknown as PrismaService;

    const audit = { append: vi.fn() } as unknown as AuditWriter;

    const service = new OAuthAccountService(
      prisma,
      firebaseTokens,
      sessionService,
      mockClock,
      audit,
    );

    await expect(
      service.createSessionFromFirebase('unregistered-token', {}),
    ).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });
  });

  it('refuses to bind unverified email and throws UNAUTHENTICATED (G2-A02)', async () => {
    const firebaseTokens = {
      verify: vi.fn().mockResolvedValue({
        uid: 'google-uid-unverified-email',
        email: 'test@example.com',
        emailVerified: false,
      }),
    } as unknown as FirebaseTokenService;

    const sessionService = { issueFor: vi.fn() } as unknown as SessionService;

    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
      },
      user: {
        findUnique: vi.fn(),
      },
    } as unknown as PrismaService;

    const audit = { append: vi.fn() } as unknown as AuditWriter;

    const service = new OAuthAccountService(
      prisma,
      firebaseTokens,
      sessionService,
      mockClock,
      audit,
    );

    await expect(
      service.createSessionFromFirebase('unverified-email-token', {}),
    ).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });
    expect(prisma.user.findUnique).not.toHaveBeenCalled();
  });
});
