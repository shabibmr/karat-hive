import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import {
  bootTestApp,
  ensureTaxonomy,
  inject,
  resetDb,
  type TestApp,
} from './helpers';

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

async function registeredVendor(mobile = '+971500000001') {
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
  const reg = await inject(ctx.app, {
    method: 'POST',
    url: '/v1/auth/register/vendor',
    body: {
      challengeId,
      legalBusinessName: 'Al Noor Gold LLC',
      tradingName: 'Al Noor',
      tradeLicenceNumber: `CN-${mobile.slice(-6)}`,
      licenceExpiryDate: '2028-01-01',
      businessAddress: 'Gold Souk, Deira',
      contactPersonName: 'Sara',
      businessEmail: `sara${mobile.slice(-4)}@alnoor.example`,
      regionId,
      categoryIds: [categoryId],
      servedRegionIds: [regionId],
      termsVersion: '1.0',
      privacyVersion: '1.0',
    },
  });
  return reg;
}

describe('vendor onboarding vertical', () => {
  it('registers a vendor into PENDING_VERIFICATION and returns a usable session', async () => {
    const reg = await registeredVendor();
    expect(reg.status).toBe(201);
    expect(reg.json.data.user.vendor.lifecycle).toBe('PENDING_VERIFICATION');
    expect(reg.json.data.accessToken).toBeTruthy();

    // masking interceptor must not 500 on the identity-bearing payload
    const me = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me',
      token: reg.json.data.accessToken,
    });
    expect(me.status).toBe(200);
    expect(me.json.data.vendor.lifecycle).toBe('PENDING_VERIFICATION');

    // outbox + audit rows written in the same transaction
    const events = await ctx.prisma.outboxEvent.findMany({
      where: { eventType: 'vendor.registered' },
    });
    expect(events).toHaveLength(1);
  });

  it('rejects a duplicate mobile number', async () => {
    await registeredVendor('+971500000002');
    const otp = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/otp/request',
      body: { mobileNumber: '+971500000002', purpose: 'REGISTER_VENDOR' },
    });
    expect(otp.status).toBe(409);
    expect(otp.json.error.code).toBe('MOBILE_ALREADY_REGISTERED');
  });

  it('rejects an unverified OTP challenge at register', async () => {
    const otp = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/otp/request',
      body: { mobileNumber: '+971500000003', purpose: 'REGISTER_VENDOR' },
    });
    const reg = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/register/vendor',
      body: {
        challengeId: otp.json.data.challengeId,
        legalBusinessName: 'X',
        tradingName: 'X',
        tradeLicenceNumber: 'CN-X',
        licenceExpiryDate: '2028-01-01',
        businessAddress: 'X',
        contactPersonName: 'X',
        businessEmail: 'x@x.example',
        regionId,
        categoryIds: [categoryId],
        servedRegionIds: [regionId],
        termsVersion: '1.0',
        privacyVersion: '1.0',
      },
    });
    expect(reg.status).toBe(422);
    expect(reg.json.error.code).toBe('VALIDATION_FAILED');
  });

  it('wrong OTP code is OTP_INVALID and increments attempts', async () => {
    const otp = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/otp/request',
      body: { mobileNumber: '+971500000004', purpose: 'LOGIN' },
    });
    const verify = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/otp/verify',
      body: { challengeId: otp.json.data.challengeId, code: '111111' },
    });
    expect(verify.status).toBe(401);
    expect(verify.json.error.code).toBe('OTP_INVALID');
  });

  it('categories/regions are refused before VERIFIED, then activate the vendor', async () => {
    const reg = await registeredVendor('+971500000005');
    const token = reg.json.data.accessToken;
    const vendorProfileId = reg.json.data.user.vendor.vendorProfileId;

    const early = await inject(ctx.app, {
      method: 'PUT',
      url: '/v1/me/vendor/categories',
      token,
      body: { categoryIds: [categoryId] },
    });
    expect(early.status).toBe(403);
    expect(early.json.error.code).toBe('VENDOR_NOT_ACTIVE');

    const verify = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/dev/vendors/${vendorProfileId}/verify`,
      headers: { 'x-dev-key': process.env.DEV_VERIFY_KEY! },
      body: { decision: 'VERIFY' },
    });
    // categories + regions already declared at registration -> straight to ACTIVE
    expect(verify.status).toBe(200);
    expect(verify.json.data.lifecycle).toBe('ACTIVE');

    const dash = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/dashboard',
      token,
    });
    expect(dash.status).toBe(200);
    expect(dash.json.data.newRequests.count).toBe(0);
  });

  it('dev-verify REQUEST_INFO surfaces verificationMessage on /v1/me (SAM-GAP-6)', async () => {
    const reg = await registeredVendor('+971500000006');
    const vendorProfileId = reg.json.data.user.vendor.vendorProfileId;
    await inject(ctx.app, {
      method: 'POST',
      url: `/v1/dev/vendors/${vendorProfileId}/verify`,
      headers: { 'x-dev-key': process.env.DEV_VERIFY_KEY! },
      body: { decision: 'REQUEST_INFO', message: 'Upload a clearer trade licence.' },
    });
    const me = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me',
      token: reg.json.data.accessToken,
    });
    expect(me.json.data.vendor.verificationMessage).toBe(
      'Upload a clearer trade licence.',
    );
  });

  it('dev-verify is a 404 without the dev key', async () => {
    const reg = await registeredVendor('+971500000007');
    const res = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/dev/vendors/${reg.json.data.user.vendor.vendorProfileId}/verify`,
      body: { decision: 'VERIFY' },
    });
    expect(res.status).toBe(404);
  });

  it('serves the taxonomy tree publicly', async () => {
    const cats = await inject(ctx.app, { method: 'GET', url: '/v1/categories' });
    expect(cats.status).toBe(200);
    expect(Array.isArray(cats.json.data)).toBe(true);
  });
});
