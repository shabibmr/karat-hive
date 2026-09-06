import { describe, expect, it } from 'vitest';
import { firstValueFrom, of } from 'rxjs';
import { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ApiException } from '../../src/edge/errors/api-exception';
import { ErrorCode } from '../../src/edge/errors/error-codes';
import {
  COMPETITOR_KEYS,
  findCompetitorLeak,
  findIdentityKey,
} from '../../src/edge/masking/identity-keys';
import { MaskingInterceptor } from '../../src/edge/masking/masking.interceptor';
import {
  assertCompetitorBlindness,
  assertIdentityKeysAbsent,
  assertVendorPresenterMasking,
} from './assert-identity-absent';

function mockContext(): ExecutionContext {
  return {
    getHandler: () => Function,
    getClass: () => class TestVendorFeedController {},
  } as unknown as ExecutionContext;
}

/**
 * Builds a compliant RequestForVendor fixture matching API-Route-Inventory §4.7.
 */
function buildValidRequestForVendor(overrides: Record<string, unknown> = {}) {
  return {
    id: '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    reference: 'REQ-2026-0001',
    requestType: 'FIND_ORNAMENT',
    direction: 'BUY',
    state: 'PUBLISHED',
    category: {
      id: 'cat-1',
      nameEn: 'Gold Bangles',
      nameAr: 'أساور ذهب',
      isActive: true,
      displayOrder: 1,
    },
    region: {
      id: 'reg-dxb',
      nameEn: 'Dubai',
      nameAr: 'دبي',
      isActive: true,
      displayOrder: 1,
    },
    notes: 'Looking for 22K bangle with floral carving',
    weightGrams: '15.50',
    weightIsApproximate: false,
    purityKarat: 22,
    budgetMin: '4000.00',
    budgetMax: '4500.00',
    budgetIsFlexible: true,
    publishedAt: '2026-09-07T00:00:00.000Z',
    expiresAt: '2026-09-09T00:00:00.000Z',
    offerCount: 2, // Permitted: integer aggregate count (BR-008)
    media: [
      {
        id: 'med-1',
        key: 'requests/req-1/img1.jpg',
        state: 'READY',
        purpose: 'REQUEST_IMAGE',
        contentType: 'image/jpeg',
        byteSize: 102400,
        displayOrder: 0,
        thumbnailUrl: 'https://cdn.karathive.com/thumb/1.jpg',
        displayUrl: 'https://cdn.karathive.com/disp/1.jpg',
      },
    ],
    customer: {
      // MaskedCustomer per API-Route-Inventory §4.4
      label: 'Customer · Dubai',
      region: {
        id: 'reg-dxb',
        nameEn: 'Dubai',
        nameAr: 'دبي',
        isActive: true,
        displayOrder: 1,
      },
      connectionCount: 5,
      rating: {
        average: '4.8',
        count: 12,
        distribution: { '1': 0, '2': 0, '3': 1, '4': 2, '5': 9 },
        limitedHistory: false,
      },
    },
    viewedAt: '2026-09-07T01:00:00.000Z',
    createdAt: '2026-09-07T00:00:00.000Z',
    updatedAt: '2026-09-07T00:00:00.000Z',
    ...overrides,
  };
}

/**
 * Builds a compliant /v1/matches collection response.
 */
function buildValidMatchesPayload() {
  return {
    data: [
      buildValidRequestForVendor(),
      buildValidRequestForVendor({
        id: '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb7e',
        reference: 'REQ-2026-0002',
        offerCount: 1,
        myOffer: {
          id: 'off-own-01',
          state: 'PENDING',
          offeredPrice: '4200.00',
          submittedAt: '2026-09-07T01:30:00.000Z',
        },
      }),
    ],
    meta: {
      requestId: 'req-track-matches-1',
      serverTime: '2026-09-07T02:00:00.000Z',
      nextCursor: null,
    },
  };
}

/**
 * Builds a compliant /v1/me/dashboard response.
 */
function buildValidDashboardPayload() {
  return {
    data: {
      newRequests: {
        count: 2,
        preview: [buildValidRequestForVendor()],
      },
      pendingOffers: {
        count: 1,
        expiringWithin24h: 0,
      },
      activeConnections: {
        count: 3,
        noTalkCount: 0,
      },
      rating: {
        average: '4.9',
        count: 25,
        distribution: { '1': 0, '2': 0, '3': 0, '4': 2, '5': 23 },
        limitedHistory: false,
      },
      subscriptions: [
        {
          requestType: 'FIND_ORNAMENT',
          state: 'ACTIVE',
          expiresAt: '2026-10-01T00:00:00.000Z',
        },
      ],
      goldRates: null,
    },
    meta: {
      requestId: 'req-dash-1',
      serverTime: '2026-09-07T02:00:00.000Z',
    },
  };
}

describe('CP2-A14 Masking Spec Extension — Vendor Feed & Presenters', () => {
  describe('1. Baseline Compliant Payloads', () => {
    it('accepts compliant RequestForVendor without identity or competitor leaks', () => {
      const payload = { data: buildValidRequestForVendor() };
      expect(() => assertVendorPresenterMasking(payload, 'GET /v1/requests/:id')).not.toThrow();
    });

    it('accepts compliant /v1/matches payload with pagination meta', () => {
      const payload = buildValidMatchesPayload();
      expect(() => assertVendorPresenterMasking(payload, 'GET /v1/matches')).not.toThrow();
    });

    it('accepts compliant /v1/me/dashboard payload with newRequests preview', () => {
      const payload = buildValidDashboardPayload();
      expect(() => assertVendorPresenterMasking(payload, 'GET /v1/me/dashboard')).not.toThrow();
    });

    it('permits vendor own offer summary (myOffer) without violating competitor blindness', () => {
      const requestWithMyOffer = buildValidRequestForVendor({
        myOffer: {
          id: 'off-vendor-mine',
          state: 'PENDING',
          offeredPrice: '4250.00',
          submittedAt: '2026-09-07T01:15:00.000Z',
        },
      });
      expect(() =>
        assertVendorPresenterMasking(requestWithMyOffer, 'Request with myOffer'),
      ).not.toThrow();
    });
  });

  describe('2. Customer Identity Masking (BR-006 / NFR-013)', () => {
    const prohibitedCustomerKeys = [
      'customerName',
      'displayName',
      'mobileNumber',
      'mobile',
      'email',
      'customerEmail',
      'exactAddress',
      'addressLine1',
      'addressLine2',
      'customerProfileId',
      'customerId',
      'nationalId',
      'emiratesId',
      'photoUrl',
      'contactPersonName',
    ];

    prohibitedCustomerKeys.forEach((key) => {
      it(`fails if customer identity key "${key}" is present as string`, () => {
        const payload = buildValidRequestForVendor();
        (payload.customer as Record<string, unknown>)[key] = 'leaked-value';
        expect(() => assertIdentityKeysAbsent(payload)).toThrow();
      });

      it(`fails if customer identity key "${key}" is present as null (BR-006: absent, not null)`, () => {
        const payload = buildValidRequestForVendor();
        (payload.customer as Record<string, unknown>)[key] = null;
        expect(() => assertIdentityKeysAbsent(payload)).toThrow();
        expect(findIdentityKey(payload)).toBe(key);
      });

      it(`fails if customer identity key "${key}" is present as empty string`, () => {
        const payload = buildValidRequestForVendor();
        (payload.customer as Record<string, unknown>)[key] = '';
        expect(() => assertIdentityKeysAbsent(payload)).toThrow();
        expect(findIdentityKey(payload)).toBe(key);
      });

      it(`fails if customer identity key "${key}" is leaked at root of RequestForVendor`, () => {
        const payload = buildValidRequestForVendor({ [key]: 'leaked-at-root' });
        expect(() => assertIdentityKeysAbsent(payload)).toThrow();
      });
    });

    it('fails when JSON serialization preserves an explicit null customer identity key', () => {
      const raw = buildValidRequestForVendor();
      (raw.customer as Record<string, unknown>)['mobileNumber'] = null;
      const serialized = JSON.stringify(raw);
      const deserialized = JSON.parse(serialized);

      expect(deserialized.customer).toHaveProperty('mobileNumber');
      expect(() => assertIdentityKeysAbsent(deserialized)).toThrow();
    });
  });

  describe('3. Competitor Blindness (BR-008)', () => {
    const prohibitedCompetitorKeys = Array.from(COMPETITOR_KEYS);

    prohibitedCompetitorKeys.forEach((key) => {
      it(`fails if competitor key "${key}" is present with value`, () => {
        const payload = buildValidRequestForVendor({ [key]: 'prohibited' });
        expect(() => assertCompetitorBlindness(payload)).toThrow();
        expect(findCompetitorLeak(payload)).toBe(key);
      });

      it(`fails if competitor key "${key}" is present as null`, () => {
        const payload = buildValidRequestForVendor({ [key]: null });
        expect(() => assertCompetitorBlindness(payload)).toThrow();
        expect(findCompetitorLeak(payload)).toBe(key);
      });
    });

    it('fails if raw competing offers array is included on RequestForVendor', () => {
      const payload = buildValidRequestForVendor({
        offers: [
          {
            id: 'off-competitor-1',
            vendorId: 'vend-other',
            offeredPrice: '3900.00',
          },
        ],
      });
      expect(() => assertCompetitorBlindness(payload)).toThrow();
      expect(findCompetitorLeak(payload)).toBe('offers');
    });

    it('permits aggregate offerCount integer (BR-008)', () => {
      const payload1 = buildValidRequestForVendor({ offerCount: 0 });
      const payload2 = buildValidRequestForVendor({ offerCount: 42 });
      expect(() => assertCompetitorBlindness(payload1)).not.toThrow();
      expect(() => assertCompetitorBlindness(payload2)).not.toThrow();
    });

    it('fails if winningPrice is leaked even on awarded/closed requests', () => {
      const payload = buildValidRequestForVendor({
        state: 'AWARDED',
        awardedElsewhere: true,
        winningPrice: '3800.00',
      });
      expect(() => assertCompetitorBlindness(payload)).toThrow();
      expect(findCompetitorLeak(payload)).toBe('winningPrice');
    });

    it('fails if winningVendor identity is leaked on closed requests', () => {
      const payload = buildValidRequestForVendor({
        state: 'AWARDED',
        awardedElsewhere: true,
        winningVendor: 'Competitor Gold LLC',
      });
      expect(() => assertCompetitorBlindness(payload)).toThrow();
      expect(findCompetitorLeak(payload)).toBe('winningVendor');
    });
  });

  describe('4. MaskingInterceptor Enforcement on Vendor Routes', () => {
    it('passes compliant /v1/matches payload without modification', async () => {
      const reflector = {
        getAllAndOverride: () => false,
      } as unknown as Reflector;
      const interceptor = new MaskingInterceptor(reflector);
      const matchesPayload = buildValidMatchesPayload();

      const result = await firstValueFrom(
        interceptor.intercept(mockContext(), {
          handle: () => of(matchesPayload),
        }),
      );
      expect(result).toEqual(matchesPayload);
    });

    it('500s when RequestForVendor serialises customer mobileNumber', async () => {
      const reflector = {
        getAllAndOverride: () => false,
      } as unknown as Reflector;
      const interceptor = new MaskingInterceptor(reflector);

      const leakingRequest = buildValidRequestForVendor();
      (leakingRequest.customer as Record<string, unknown>)['mobileNumber'] = '+971501234567';

      try {
        await firstValueFrom(
          interceptor.intercept(mockContext(), {
            handle: () => of({ data: leakingRequest }),
          }),
        );
        expect.fail('Customer mobileNumber must not pass MaskingInterceptor');
      } catch (err) {
        expect(err).toBeInstanceOf(ApiException);
        expect((err as ApiException).getStatus()).toBe(500);
        expect((err as ApiException).errorCode).toBe(ErrorCode.INTERNAL);
      }
    });

    it('500s when RequestForVendor serialises competitorPrice (BR-008)', async () => {
      const reflector = {
        getAllAndOverride: () => false,
      } as unknown as Reflector;
      const interceptor = new MaskingInterceptor(reflector);

      const leakingRequest = buildValidRequestForVendor({
        competitorPrice: '3950.00',
      });

      try {
        await firstValueFrom(
          interceptor.intercept(mockContext(), {
            handle: () => of({ data: leakingRequest }),
          }),
        );
        expect.fail('competitorPrice must not pass MaskingInterceptor');
      } catch (err) {
        expect(err).toBeInstanceOf(ApiException);
        expect((err as ApiException).getStatus()).toBe(500);
        expect((err as ApiException).errorCode).toBe(ErrorCode.INTERNAL);
      }
    });

    it('500s when RequestForVendor serialises winningPrice (BR-008)', async () => {
      const reflector = {
        getAllAndOverride: () => false,
      } as unknown as Reflector;
      const interceptor = new MaskingInterceptor(reflector);

      const leakingRequest = buildValidRequestForVendor({
        winningPrice: '3500.00',
      });

      try {
        await firstValueFrom(
          interceptor.intercept(mockContext(), {
            handle: () => of({ data: leakingRequest }),
          }),
        );
        expect.fail('winningPrice must not pass MaskingInterceptor');
      } catch (err) {
        expect(err).toBeInstanceOf(ApiException);
        expect((err as ApiException).getStatus()).toBe(500);
        expect((err as ApiException).errorCode).toBe(ErrorCode.INTERNAL);
      }
    });

    it('500s when RequestForVendor serialises competingOffers (BR-008)', async () => {
      const reflector = {
        getAllAndOverride: () => false,
      } as unknown as Reflector;
      const interceptor = new MaskingInterceptor(reflector);

      const leakingRequest = buildValidRequestForVendor({
        competingOffers: [{ id: 'off-1', price: '4000' }],
      });

      try {
        await firstValueFrom(
          interceptor.intercept(mockContext(), {
            handle: () => of({ data: leakingRequest }),
          }),
        );
        expect.fail('competingOffers must not pass MaskingInterceptor');
      } catch (err) {
        expect(err).toBeInstanceOf(ApiException);
        expect((err as ApiException).getStatus()).toBe(500);
        expect((err as ApiException).errorCode).toBe(ErrorCode.INTERNAL);
      }
    });
  });
});
