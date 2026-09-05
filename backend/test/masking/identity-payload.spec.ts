import { describe, expect, it } from 'vitest';
import { firstValueFrom, of } from 'rxjs';
import { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ApiException } from '../../src/edge/errors/api-exception';
import { ErrorCode } from '../../src/edge/errors/error-codes';
import { findIdentityKey } from '../../src/edge/masking/identity-keys';
import { MaskingInterceptor } from '../../src/edge/masking/masking.interceptor';
import { REVEALS_IDENTITY_KEY } from '../../src/edge/masking/reveals-identity.decorator';
import { assertIdentityKeysAbsent } from './assert-identity-absent';

function mockContext(): ExecutionContext {
  return {
    getHandler: () => Function,
    getClass: () => class TestController {},
  } as unknown as ExecutionContext;
}

describe('masking: identity keys absent, not null (CP1-A07b)', () => {
  it('treats a null identity field as a leak, not a masked value', () => {
    expect(findIdentityKey({ data: { vendor: { mobileNumber: null } } })).toBe('mobileNumber');
    expect(findIdentityKey({ data: { email: '' } })).toBe('email');
    expect(findIdentityKey({ data: { displayName: undefined } })).toBe('displayName');
  });

  it('accepts public taxonomy-shaped payloads with no identity keys', () => {
    const categories = {
      data: [
        {
          id: 'cat-1',
          parentId: null,
          nameEn: 'Jewellery',
          nameAr: 'مجوهرات',
          displayOrder: 0,
          isActive: true,
          children: [],
        },
      ],
      meta: { requestId: 'r', serverTime: 't', nextCursor: null },
    };
    assertIdentityKeysAbsent(categories, 'GET /v1/categories');
  });

  it('500s a masked route that serialises an identity key, including null', async () => {
    const reflector = {
      getAllAndOverride: () => false,
    } as unknown as Reflector;
    const interceptor = new MaskingInterceptor(reflector);

    await expect(
      firstValueFrom(
        interceptor.intercept(mockContext(), {
          handle: () => of({ data: { mobileNumber: '+971501234567' } }),
        }),
      ),
    ).rejects.toBeInstanceOf(ApiException);

    try {
      await firstValueFrom(
        interceptor.intercept(mockContext(), {
          handle: () => of({ data: { mobileNumber: null } }),
        }),
      );
      expect.fail('null identity key must not pass the interceptor');
    } catch (err) {
      expect(err).toBeInstanceOf(ApiException);
      expect((err as ApiException).getStatus()).toBe(500);
      expect((err as ApiException).errorCode).toBe(ErrorCode.INTERNAL);
    }
  });

  it('does not 500 an identity-returning handler flagged @RevealsIdentity', async () => {
    const reflector = {
      getAllAndOverride: (key: string) => key === REVEALS_IDENTITY_KEY,
    } as unknown as Reflector;
    const interceptor = new MaskingInterceptor(reflector);
    const body = {
      data: {
        accessToken: 'tok',
        user: { userId: 'u1', mobileNumber: '+971500000090', email: 'dev.vendor@karathive.test' },
      },
      meta: { requestId: 'r' },
    };
    await expect(
      firstValueFrom(
        interceptor.intercept(mockContext(), {
          handle: () => of(body),
        }),
      ),
    ).resolves.toEqual(body);
  });
});
