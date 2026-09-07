import { describe, expect, it, vi } from 'vitest';
import { SessionQuery } from './session.query';
import { hashToken } from './token.service';
import type { PrismaService } from '../../../platform/db/prisma.service';

describe('SessionQuery - findUserByFirebaseClaims (G2-A01 read-only)', () => {
  const mockUserRow = {
    id: 'user-123',
    userType: 'VENDOR' as const,
    tokenVersion: 0,
    accountState: 'ACTIVE' as const,
    preferredLanguage: 'en' as const,
    deletedAt: null,
    customerProfile: null,
    vendorProfile: {
      id: 'vp-123',
      verificationState: 'REGISTERED' as const,
      activatedAt: null,
    },
    adminProfile: null,
  };

  it('resolves user via existing OauthBinding', async () => {
    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue({
          id: 'ob-1',
          userId: 'user-123',
          provider: 'GOOGLE',
          subjectHash: hashToken('fb-uid-1'),
        }),
      },
      user: {
        findUnique: vi.fn().mockResolvedValue(mockUserRow),
      },
    } as unknown as PrismaService;

    const query = new SessionQuery(prisma);
    const viewer = await query.findUserByFirebaseClaims({
      uid: 'fb-uid-1',
      email: 'vendor@example.com',
    });

    expect(viewer).not.toBeNull();
    expect(viewer?.id).toBe('user-123');
    expect(viewer?.vendorProfileId).toBe('vp-123');
    expect(viewer?.vendorVerificationState).toBe('REGISTERED');
    expect(prisma.oauthBinding.findUnique).toHaveBeenCalledWith({
      where: { subjectHash: hashToken('fb-uid-1') },
    });
  });

  it('finds user by verified email when not bound (G2-A02)', async () => {
    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
      },
      user: {
        findUnique: vi.fn().mockImplementation(({ where }) => {
          if (where.email === 'vendor@example.com') {
            return Promise.resolve(mockUserRow);
          }
          if (where.id === 'user-123') {
            return Promise.resolve(mockUserRow);
          }
          return Promise.resolve(null);
        }),
      },
    } as unknown as PrismaService;

    const query = new SessionQuery(prisma);
    const viewer = await query.findUserByFirebaseClaims({
      uid: 'fb-uid-2',
      email: 'vendor@example.com',
      emailVerified: true,
    });

    expect(viewer).not.toBeNull();
    expect(viewer?.id).toBe('user-123');
  });

  it('refuses to match user by unverified email (G2-A02)', async () => {
    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
      },
      user: {
        findUnique: vi.fn().mockResolvedValue(mockUserRow),
      },
    } as unknown as PrismaService;

    const query = new SessionQuery(prisma);
    const viewer = await query.findUserByFirebaseClaims({
      uid: 'fb-uid-unverified',
      email: 'vendor@example.com',
      emailVerified: false,
    });

    expect(viewer).toBeNull();
    expect(prisma.user.findUnique).not.toHaveBeenCalledWith({
      where: { email: 'vendor@example.com' },
    });
  });

  it('finds user by valid E.164 phone when not bound', async () => {
    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
      },
      user: {
        findUnique: vi.fn().mockImplementation(({ where }) => {
          if (where.mobileNumber === '+971501112233') {
            return Promise.resolve(mockUserRow);
          }
          if (where.id === 'user-123') {
            return Promise.resolve(mockUserRow);
          }
          return Promise.resolve(null);
        }),
      },
    } as unknown as PrismaService;

    const query = new SessionQuery(prisma);
    const viewer = await query.findUserByFirebaseClaims({
      uid: 'fb-uid-3',
      phoneNumber: '+971501112233',
    });

    expect(viewer).not.toBeNull();
    expect(viewer?.id).toBe('user-123');
  });

  it('returns null and does NOT create user when user does not exist (G2-A01, G2-A06)', async () => {
    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
      },
      user: {
        findUnique: vi.fn().mockResolvedValue(null),
      },
    } as unknown as PrismaService;

    const query = new SessionQuery(prisma);
    const viewer = await query.findUserByFirebaseClaims({
      uid: 'fb-uid-new',
      email: 'newuser@example.com',
      emailVerified: true,
      name: 'New User',
    });

    expect(viewer).toBeNull();
  });
});

