import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { bootTestApp, ensureTaxonomy, inject, resetDb, type TestApp } from '../integration/helpers';
import { assertIdentityKeysAbsent } from './assert-identity-absent';

let ctx: TestApp;
let categoryId: string;
let regionId: string;

beforeAll(async () => {
  ctx = await bootTestApp();
});

afterAll(async () => {
  await ctx.close();
});

beforeEach(async () => {
  await resetDb(ctx.prisma);
  ({ categoryId, regionId } = await ensureTaxonomy(ctx.prisma));
});

async function registeredVendor(mobile = '+971500000011') {
  const otp = await inject(ctx.app, {
    method: 'POST',
    url: '/v1/auth/otp/request',
    body: { mobileNumber: mobile, purpose: 'REGISTER_VENDOR' },
  });
  const challengeId = otp.json.data.challengeId;
  await inject(ctx.app, {
    method: 'POST',
    url: '/v1/auth/otp/verify',
    body: { challengeId, code: '000000' },
  });
  return inject(ctx.app, {
    method: 'POST',
    url: '/v1/auth/register/vendor',
    body: {
      challengeId,
      legalBusinessName: 'Masking Spec LLC',
      tradingName: 'Mask Spec',
      tradeLicenceNumber: `MSK-${mobile.slice(-6)}`,
      licenceExpiryDate: '2028-01-01',
      businessAddress: 'Gold Souk, Deira',
      contactPersonName: 'Noor',
      businessEmail: `noor${mobile.slice(-4)}@mask.example`,
      regionId,
      categoryIds: [categoryId],
      servedRegionIds: [regionId],
      termsVersion: '1.0',
      privacyVersion: '1.0',
    },
  });
}

describe('CP1-A07b identity-returning handlers', () => {
  it('does not 500 on register, me, vendor profile, or documents', async () => {
    const reg = await registeredVendor();
    expect(reg.status, JSON.stringify(reg.json)).toBe(201);
    expect(reg.status).toBeLessThan(500);
    const token = reg.json.data.accessToken as string;

    const me = await inject(ctx.app, { method: 'GET', url: '/v1/me', token });
    expect(me.status).toBe(200);

    const profile = await inject(ctx.app, { method: 'GET', url: '/v1/me/vendor', token });
    expect(profile.status).toBe(200);

    const docs = await inject(ctx.app, { method: 'GET', url: '/v1/me/vendor/documents', token });
    expect(docs.status).toBe(200);

    const refresh = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/refresh',
      body: { refreshToken: reg.json.data.refreshToken },
    });
    expect(refresh.status).toBe(200);
  });

  it('keeps identity keys off public/masked catalogue payloads (absent, not null)', async () => {
    const health = await inject(ctx.app, { method: 'GET', url: '/health' });
    expect(health.status).toBe(200);
    assertIdentityKeysAbsent(health.json, 'GET /health');

    const categories = await inject(ctx.app, { method: 'GET', url: '/v1/categories' });
    expect(categories.status).toBe(200);
    assertIdentityKeysAbsent(categories.json, 'GET /v1/categories');

    const regions = await inject(ctx.app, { method: 'GET', url: '/v1/regions' });
    expect(regions.status).toBe(200);
    assertIdentityKeysAbsent(regions.json, 'GET /v1/regions');
  });
});
