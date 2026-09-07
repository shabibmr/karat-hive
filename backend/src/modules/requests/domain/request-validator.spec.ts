import { describe, expect, it } from 'vitest';
import type { Request } from '@prisma/client';
import { Prisma } from '@prisma/client';
import { validateRequestForPublish } from './request-validator';
import { ApiException } from '../../../edge/errors/api-exception';

describe('request-validator', () => {
  const baseRequest: Request = {
    id: 'req-1',
    reference: null,
    customerProfileId: 'cust-1',
    requestType: 'FIND_ORNAMENT',
    direction: 'BUY',
    state: 'DRAFT',
    categoryId: 'cat-1',
    regionId: 'reg-1',
    notes: 'A simple note',
    weightGrams: null,
    weightIsApproximate: false,
    purityKarat: 'K18',
    ornamentType: 'RING',
    condition: null,
    denominationGrams: null,
    quantity: null,
    mintOrRefiner: null,
    budgetMin: null,
    budgetMax: null,
    budgetIsFlexible: false,
    indicativeValue: null,
    goldRateId: null,
    gemstones: null,
    publishedAt: null,
    expiresAt: null,
    expiryWarnedAt: null,
    draftPurgeWarnedAt: null,
    offerCount: 0,
    acceptedOfferId: null,
    cancellationReason: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  it('passes valid FIND_ORNAMENT request with at least 1 image', () => {
    expect(() =>
      validateRequestForPublish({
        request: { ...baseRequest, requestType: 'FIND_ORNAMENT', ornamentType: 'RING', purityKarat: 'K18' },
        mediaCount: 1,
      }),
    ).not.toThrow();
  });

  it('fails FIND_ORNAMENT without ornamentType', () => {
    expect(() =>
      validateRequestForPublish({
        request: { ...baseRequest, requestType: 'FIND_ORNAMENT', ornamentType: null },
        mediaCount: 1,
      }),
    ).toThrow(ApiException);
  });

  it('fails FIND_ORNAMENT without reference image', () => {
    expect(() =>
      validateRequestForPublish({
        request: { ...baseRequest, requestType: 'FIND_ORNAMENT', ornamentType: 'RING' },
        mediaCount: 0,
      }),
    ).toThrow(ApiException);
  });

  it('passes valid SELL_OLD_GOLD request with weight and purity', () => {
    expect(() =>
      validateRequestForPublish({
        request: {
          ...baseRequest,
          requestType: 'SELL_OLD_GOLD',
          direction: 'SELL',
          weightGrams: new Prisma.Decimal(15.5),
          purityKarat: 'K21',
        },
        mediaCount: 0,
      }),
    ).not.toThrow();
  });

  it('fails SELL_OLD_GOLD without weight', () => {
    expect(() =>
      validateRequestForPublish({
        request: {
          ...baseRequest,
          requestType: 'SELL_OLD_GOLD',
          direction: 'SELL',
          weightGrams: null,
          purityKarat: 'K21',
        },
        mediaCount: 0,
      }),
    ).toThrow(ApiException);
  });

  it('passes valid GOLD_COIN request', () => {
    expect(() =>
      validateRequestForPublish({
        request: {
          ...baseRequest,
          requestType: 'GOLD_COIN',
          direction: 'BUY',
          purityKarat: 'K24',
          denominationGrams: new Prisma.Decimal(10),
          quantity: 2,
        },
        mediaCount: 0,
      }),
    ).not.toThrow();
  });

  it('fails GOLD_COIN without quantity or denomination', () => {
    expect(() =>
      validateRequestForPublish({
        request: {
          ...baseRequest,
          requestType: 'GOLD_COIN',
          direction: 'BUY',
          purityKarat: 'K24',
          denominationGrams: null,
          quantity: null,
        },
        mediaCount: 0,
      }),
    ).toThrow(ApiException);
  });

  it('passes valid GOLD_BULLION request', () => {
    expect(() =>
      validateRequestForPublish({
        request: {
          ...baseRequest,
          requestType: 'GOLD_BULLION',
          direction: 'BUY',
          purityKarat: 'K24',
          weightGrams: new Prisma.Decimal(50),
        },
        mediaCount: 0,
      }),
    ).not.toThrow();
  });
});
