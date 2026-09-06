import { describe, expect, it, vi } from 'vitest';
import { SessionQuery } from './session.query';
import { hashToken } from './token.service';
import type { PrismaService } from '../../../platform/db/prisma.service';

describe('SessionQuery - findOrCreateUserForFirebase', () => {
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
    const viewer = await query.findOrCreateUserForFirebase({
      uid: 'fb-uid-1',
      email: 'vendor@example.com',
    });

    expect(viewer.id).toBe('user-123');
    expect(viewer.vendorProfileId).toBe('vp-123');
    expect(viewer.vendorVerificationState).toBe('REGISTERED');
    expect(prisma.oauthBinding.findUnique).toHaveBeenCalledWith({
      where: { subjectHash: hashToken('fb-uid-1') },
    });
  });

  it('links OauthBinding when matching user is found by email', async () => {
    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
        upsert: vi.fn().mockResolvedValue({ id: 'ob-2' }),
      },
      user: {
        findUnique: vi
          .fn()
          .mockImplementation(({ where }) => {
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
    const viewer = await query.findOrCreateUserForFirebase({
      uid: 'fb-uid-2',
      email: 'vendor@example.com',
    });

    expect(viewer.id).toBe('user-123');
    expect(prisma.oauthBinding.upsert).toHaveBeenCalledWith({
      where: {
        userId_provider: {
          userId: 'user-123',
          provider: 'GOOGLE',
        },
      },
      create: expect.objectContaining({
        userId: 'user-123',
        provider: 'GOOGLE',
        subjectHash: hashToken('fb-uid-2'),
      }),
      update: expect.objectContaining({
        subjectHash: hashToken('fb-uid-2'),
      }),
    });
  });

  it('links OauthBinding when matching user is found by mobileNumber', async () => {
    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
        upsert: vi.fn().mockResolvedValue({ id: 'ob-3' }),
      },
      user: {
        findUnique: vi
          .fn()
          .mockImplementation(({ where }) => {
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
    const viewer = await query.findOrCreateUserForFirebase({
      uid: 'fb-uid-3',
      phoneNumber: '+971501112233',
    });

    expect(viewer.id).toBe('user-123');
    expect(prisma.oauthBinding.upsert).toHaveBeenCalledWith({
      where: {
        userId_provider: {
          userId: 'user-123',
          provider: 'GOOGLE',
        },
      },
      create: expect.objectContaining({
        userId: 'user-123',
        provider: 'GOOGLE',
        subjectHash: hashToken('fb-uid-3'),
      }),
      update: expect.objectContaining({
        subjectHash: hashToken('fb-uid-3'),
      }),
    });
  });

  it('provisions new User, VendorProfile, and OauthBinding when user does not exist', async () => {
    const createdUser = { id: 'new-user-456' };
    const newMockUserRow = {
      ...mockUserRow,
      id: 'new-user-456',
      vendorProfile: {
        id: 'vp-456',
        verificationState: 'REGISTERED' as const,
        activatedAt: null,
      },
    };

    const mockTx = {
      user: {
        create: vi.fn().mockResolvedValue(createdUser),
      },
      vendorProfile: {
        create: vi.fn().mockResolvedValue({ id: 'vp-456' }),
      },
      oauthBinding: {
        create: vi.fn().mockResolvedValue({ id: 'ob-456' }),
      },
    };

    const prisma = {
      oauthBinding: {
        findUnique: vi.fn().mockResolvedValue(null),
      },
      user: {
        findUnique: vi.fn().mockImplementation(({ where }) => {
          if (where.id === 'new-user-456') {
            return Promise.resolve(newMockUserRow);
          }
          return Promise.resolve(null);
        }),
      },
      $transaction: vi.fn(async (cb: (tx: typeof mockTx) => Promise<unknown>) => cb(mockTx)),
    } as unknown as PrismaService;

    const query = new SessionQuery(prisma);
    const viewer = await query.findOrCreateUserForFirebase({
      uid: 'fb-uid-new',
      email: 'newvendor@example.com',
      emailVerified: true,
      name: 'New Vendor Shop',
    });

    expect(viewer.id).toBe('new-user-456');
    expect(viewer.vendorProfileId).toBe('vp-456');
    expect(viewer.vendorVerificationState).toBe('REGISTERED');

    expect(mockTx.user.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        userType: 'VENDOR',
        accountState: 'ACTIVE',
        email: 'newvendor@example.com',
        preferredLanguage: 'en',
      }),
    });

    expect(mockTx.vendorProfile.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        userId: 'new-user-456',
        verificationState: 'REGISTERED',
        legalBusinessName: 'New Vendor Shop',
      }),
    });

    expect(mockTx.oauthBinding.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        userId: 'new-user-456',
        provider: 'GOOGLE',
        subjectHash: hashToken('fb-uid-new'),
      }),
    });
  });
});
