import { describe, expect, it, vi } from 'vitest';
import { ExecutionContext, HttpStatus } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from './auth.guard';
import { ALLOW_SUSPENDED_KEY } from './allow-suspended.decorator';
import { IS_ADMIN_ONLY_KEY } from './admin-only.decorator';
import { IS_PUBLIC_KEY } from './public.decorator';
import { VIEWER_CONTEXT_KEY, type ViewerContext } from './viewer-context';
import { ApiException } from '../errors/api-exception';
import { ErrorCode } from '../errors/error-codes';
import {
  type SessionQuery,
  type TokenService,
  type UserForViewer,
} from '../../modules/identity';

function createMockContext(headers: Record<string, string | undefined> = {}, url = '') {
  const request: {
    headers: Record<string, string | undefined>;
    url: string;
    [VIEWER_CONTEXT_KEY]?: ViewerContext;
  } = {
    headers,
    url,
  };
  const context = {
    getHandler: vi.fn(),
    getClass: vi.fn(),
    switchToHttp: () => ({
      getRequest: () => request,
    }),
  } as unknown as ExecutionContext;
  return { context, request };
}

const mockUser: UserForViewer = {
  id: 'usr-1',
  userType: 'CUSTOMER',
  tokenVersion: 1,
  accountState: 'ACTIVE',
  preferredLanguage: 'en',
  deletedAt: null,
  vendorProfileId: null,
  vendorVerificationState: null,
  vendorActivatedAt: null,
  customerProfileId: 'cust-1',
  adminProfileId: null,
};

describe('AuthGuard', () => {
  it('allows access when route is marked public', async () => {
    const reflector = {
      getAllAndOverride: vi.fn((key) => key === IS_PUBLIC_KEY),
    } as unknown as Reflector;
    const tokens = {} as TokenService;
    const sessions = {} as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context } = createMockContext();

    const allowed = await guard.canActivate(context);
    expect(allowed).toBe(true);
  });

  it('rejects when authorization header is missing', async () => {
    const reflector = {
      getAllAndOverride: vi.fn(() => false),
    } as unknown as Reflector;
    const tokens = {} as TokenService;
    const sessions = {} as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context } = createMockContext({});

    await expect(guard.canActivate(context)).rejects.toThrow(ApiException);
    await expect(guard.canActivate(context)).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });
  });

  it('rejects when authorization header is not Bearer', async () => {
    const reflector = {
      getAllAndOverride: vi.fn(() => false),
    } as unknown as Reflector;
    const tokens = {} as TokenService;
    const sessions = {} as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context } = createMockContext({ authorization: 'Basic dXNlcjpwYXNz' });

    await expect(guard.canActivate(context)).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });
  });

  it('rejects when Bearer token is empty after trimming', async () => {
    const reflector = {
      getAllAndOverride: vi.fn(() => false),
    } as unknown as Reflector;
    const tokens = {} as TokenService;
    const sessions = {} as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context } = createMockContext({ authorization: 'Bearer    ' });

    await expect(guard.canActivate(context)).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });
  });

  it('normalizes Bearer header case-insensitively and with surrounding whitespace', async () => {
    const reflector = {
      getAllAndOverride: vi.fn(() => false),
    } as unknown as Reflector;
    const tokens = {
      isFirebaseToken: vi.fn().mockReturnValue(false),
      verifyAccess: vi.fn().mockResolvedValue({ sub: 'usr-1', role: 'CUSTOMER', ver: 1 }),
    } as unknown as TokenService;
    const sessions = {
      findUserForViewer: vi.fn().mockResolvedValue(mockUser),
    } as unknown as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context, request } = createMockContext({
      authorization: '   bEaReR    valid-token   ',
    });

    const allowed = await guard.canActivate(context);
    expect(allowed).toBe(true);
    expect(tokens.verifyAccess).toHaveBeenCalledWith('valid-token');
    expect(request[VIEWER_CONTEXT_KEY]?.userId).toBe('usr-1');
  });

  it('rejects soft-deleted user with UNAUTHENTICATED', async () => {
    const reflector = {
      getAllAndOverride: vi.fn(() => false),
    } as unknown as Reflector;
    const tokens = {
      isFirebaseToken: vi.fn().mockReturnValue(false),
      verifyAccess: vi.fn().mockResolvedValue({ sub: 'usr-1', role: 'CUSTOMER', ver: 1 }),
    } as unknown as TokenService;
    const sessions = {
      findUserForViewer: vi.fn().mockResolvedValue({ ...mockUser, deletedAt: new Date() }),
    } as unknown as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context } = createMockContext({ authorization: 'Bearer token' });

    await expect(guard.canActivate(context)).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });
  });

  it('rejects suspended user when route does not allow suspended', async () => {
    const reflector = {
      getAllAndOverride: vi.fn((key) => {
        if (key === ALLOW_SUSPENDED_KEY) return false;
        return false;
      }),
    } as unknown as Reflector;
    const tokens = {
      isFirebaseToken: vi.fn().mockReturnValue(false),
      verifyAccess: vi.fn().mockResolvedValue({ sub: 'usr-1', role: 'CUSTOMER', ver: 1 }),
    } as unknown as TokenService;
    const sessions = {
      findUserForViewer: vi.fn().mockResolvedValue({ ...mockUser, accountState: 'SUSPENDED' }),
    } as unknown as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context } = createMockContext({ authorization: 'Bearer token' });

    await expect(guard.canActivate(context)).rejects.toMatchObject({
      status: HttpStatus.FORBIDDEN,
      errorCode: ErrorCode.ACCOUNT_SUSPENDED,
    });
  });

  it('rejects deactivated user when route does not allow suspended', async () => {
    const reflector = {
      getAllAndOverride: vi.fn((key) => {
        if (key === ALLOW_SUSPENDED_KEY) return false;
        return false;
      }),
    } as unknown as Reflector;
    const tokens = {
      isFirebaseToken: vi.fn().mockReturnValue(false),
      verifyAccess: vi.fn().mockResolvedValue({ sub: 'usr-1', role: 'CUSTOMER', ver: 1 }),
    } as unknown as TokenService;
    const sessions = {
      findUserForViewer: vi.fn().mockResolvedValue({ ...mockUser, accountState: 'DEACTIVATED' }),
    } as unknown as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context } = createMockContext({ authorization: 'Bearer token' });

    await expect(guard.canActivate(context)).rejects.toMatchObject({
      status: HttpStatus.FORBIDDEN,
      errorCode: ErrorCode.ACCOUNT_DEACTIVATED,
    });
  });

  it('allows suspended user when route has @AllowSuspended()', async () => {
    const reflector = {
      getAllAndOverride: vi.fn((key) => {
        if (key === ALLOW_SUSPENDED_KEY) return true;
        return false;
      }),
    } as unknown as Reflector;
    const tokens = {
      isFirebaseToken: vi.fn().mockReturnValue(false),
      verifyAccess: vi.fn().mockResolvedValue({ sub: 'usr-1', role: 'CUSTOMER', ver: 1 }),
    } as unknown as TokenService;
    const sessions = {
      findUserForViewer: vi.fn().mockResolvedValue({ ...mockUser, accountState: 'SUSPENDED' }),
    } as unknown as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context, request } = createMockContext({ authorization: 'Bearer token' });

    const allowed = await guard.canActivate(context);
    expect(allowed).toBe(true);
    expect(request[VIEWER_CONTEXT_KEY]?.accountState).toBe('SUSPENDED');
  });

  it('allows deactivated user when route has @AllowSuspended()', async () => {
    const reflector = {
      getAllAndOverride: vi.fn((key) => {
        if (key === ALLOW_SUSPENDED_KEY) return true;
        return false;
      }),
    } as unknown as Reflector;
    const tokens = {
      isFirebaseToken: vi.fn().mockReturnValue(false),
      verifyAccess: vi.fn().mockResolvedValue({ sub: 'usr-1', role: 'CUSTOMER', ver: 1 }),
    } as unknown as TokenService;
    const sessions = {
      findUserForViewer: vi.fn().mockResolvedValue({ ...mockUser, accountState: 'DEACTIVATED' }),
    } as unknown as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context, request } = createMockContext({ authorization: 'Bearer token' });

    const allowed = await guard.canActivate(context);
    expect(allowed).toBe(true);
    expect(request[VIEWER_CONTEXT_KEY]?.accountState).toBe('DEACTIVATED');
  });

  it('rejects non-admin user on /v1/admin/* route with NOT_FOUND', async () => {
    const reflector = {
      getAllAndOverride: vi.fn(() => false),
    } as unknown as Reflector;
    const tokens = {
      isFirebaseToken: vi.fn().mockReturnValue(false),
      verifyAccess: vi.fn().mockResolvedValue({ sub: 'usr-1', role: 'CUSTOMER', ver: 1 }),
    } as unknown as TokenService;
    const sessions = {
      findUserForViewer: vi.fn().mockResolvedValue(mockUser),
    } as unknown as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context } = createMockContext(
      { authorization: 'Bearer token' },
      '/v1/admin/categories',
    );

    await expect(guard.canActivate(context)).rejects.toMatchObject({
      status: HttpStatus.NOT_FOUND,
      errorCode: ErrorCode.NOT_FOUND,
    });
  });

  it('rejects non-admin user on route with @AdminOnly() with NOT_FOUND', async () => {
    const reflector = {
      getAllAndOverride: vi.fn((key) => key === IS_ADMIN_ONLY_KEY),
    } as unknown as Reflector;
    const tokens = {
      isFirebaseToken: vi.fn().mockReturnValue(false),
      verifyAccess: vi.fn().mockResolvedValue({ sub: 'usr-1', role: 'CUSTOMER', ver: 1 }),
    } as unknown as TokenService;
    const sessions = {
      findUserForViewer: vi.fn().mockResolvedValue(mockUser),
    } as unknown as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context } = createMockContext({ authorization: 'Bearer token' }, '/v1/some-route');

    await expect(guard.canActivate(context)).rejects.toMatchObject({
      status: HttpStatus.NOT_FOUND,
      errorCode: ErrorCode.NOT_FOUND,
    });
  });

  it('allows admin user on /v1/admin/* route and route with @AdminOnly()', async () => {
    const adminUser: UserForViewer = {
      ...mockUser,
      id: 'adm-1',
      userType: 'ADMIN',
      adminProfileId: 'ap-1',
    };
    const reflector = {
      getAllAndOverride: vi.fn((key) => key === IS_ADMIN_ONLY_KEY),
    } as unknown as Reflector;
    const tokens = {
      isFirebaseToken: vi.fn().mockReturnValue(false),
      verifyAccess: vi.fn().mockResolvedValue({ sub: 'adm-1', role: 'ADMIN', ver: 1 }),
    } as unknown as TokenService;
    const sessions = {
      findUserForViewer: vi.fn().mockResolvedValue(adminUser),
    } as unknown as SessionQuery;

    const guard = new AuthGuard(reflector, tokens, sessions);
    const { context, request } = createMockContext(
      { authorization: 'Bearer token' },
      '/v1/admin/categories',
    );

    const allowed = await guard.canActivate(context);
    expect(allowed).toBe(true);
    expect(request[VIEWER_CONTEXT_KEY]?.role).toBe('ADMIN');
  });

  describe('G2-A12 — Google bearer rejected on domain routes', () => {
    it('rejects a Firebase ID token on GET /v1/me with UNAUTHENTICATED', async () => {
      const reflector = {
        getAllAndOverride: vi.fn(() => false),
      } as unknown as Reflector;
      const tokens = {
        isFirebaseToken: vi.fn().mockReturnValue(true),
        verifyAccess: vi.fn(),
      } as unknown as TokenService;
      const sessions = {
        findUserForViewer: vi.fn(),
      } as unknown as SessionQuery;

      const guard = new AuthGuard(reflector, tokens, sessions);
      const { context } = createMockContext(
        { authorization: 'Bearer firebase.rs256.jwt.token' },
        '/v1/me',
      );

      await expect(guard.canActivate(context)).rejects.toMatchObject({
        status: HttpStatus.UNAUTHORIZED,
        errorCode: ErrorCode.UNAUTHENTICATED,
      });
      expect(tokens.isFirebaseToken).toHaveBeenCalledWith('firebase.rs256.jwt.token');
      expect(tokens.verifyAccess).not.toHaveBeenCalled();
      expect(sessions.findUserForViewer).not.toHaveBeenCalled();
    });

    it('still verifies a Karat Hive access token', async () => {
      const reflector = {
        getAllAndOverride: vi.fn(() => false),
      } as unknown as Reflector;
      const tokens = {
        isFirebaseToken: vi.fn().mockReturnValue(false),
        verifyAccess: vi.fn().mockResolvedValue({ sub: 'usr-1', role: 'CUSTOMER', ver: 1 }),
      } as unknown as TokenService;
      const sessions = {
        findUserForViewer: vi.fn().mockResolvedValue(mockUser),
      } as unknown as SessionQuery;

      const guard = new AuthGuard(reflector, tokens, sessions);
      const { context, request } = createMockContext({
        authorization: 'Bearer kh-access-token',
      });

      const allowed = await guard.canActivate(context);
      expect(allowed).toBe(true);
      expect(tokens.verifyAccess).toHaveBeenCalledWith('kh-access-token');
      expect(request[VIEWER_CONTEXT_KEY]?.userId).toBe('usr-1');
    });
  });
});
