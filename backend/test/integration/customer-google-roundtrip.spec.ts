import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import {
  bootCustomerTestApp,
  injectJson,
  resetCustomerDb,
  uniqueSuffix,
  type CustomerTestApp,
} from './customer-app.helpers';

/**
 * CBG-06 / G2-I13 — Customer Google (Firebase) round trip.
 *
 * Google ID token -> POST /v1/auth/google/session for a brand-new identity must
 * NOT auto-provision (401 UNAUTHENTICATED, zero user rows) -> register the
 * Customer with a verified mobile + terms acceptance, binding the same Google
 * subject -> google/session now issues a SessionBundle -> GET /v1/me returns a
 * `customer` profile carrying liveRequestCount / canCreateRequest / oauthBound.
 *
 * Guards adr/0010 (Google is the only login; there is no separate oauth/bind
 * step and an unbound token never creates a user).
 */
describe('CBG-06 Customer Google round trip (G2-I13)', () => {
  let ctx: CustomerTestApp;

  beforeAll(async () => {
    ctx = await bootCustomerTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  beforeEach(async () => {
    await resetCustomerDb(ctx.prisma);
  });

  it('does not auto-provision an unbound Google token, then completes the bound round trip', async () => {
    const suffix = uniqueSuffix();
    const googleUid = `google-uid-${suffix}`;
    const email = `cust.${suffix}@gmail.example`;
    const mobileNumber = `+9715${suffix.replace(/\D/g, '').padEnd(8, '0').slice(0, 8)}`;

    const idToken = await ctx.mintGoogleToken({
      uid: googleUid,
      email,
      emailVerified: true,
      name: 'Aisha Customer',
    });

    // 1. Brand-new identity -> google/session must refuse, not provision.
    const usersBefore = await ctx.prisma.user.count();
    const first = await injectJson(ctx.app, {
      method: 'POST',
      url: '/v1/auth/google/session',
      body: { idToken },
    });
    expect(first.status).toBe(401);
    expect(first.json?.error?.code).toBe('UNAUTHENTICATED');

    // Negative path: no user row (and no oauth binding) was created.
    expect(await ctx.prisma.user.count()).toBe(usersBefore);
    expect(await ctx.prisma.oauthBinding.count()).toBe(0);
    expect(await ctx.prisma.customerProfile.count()).toBe(0);

    // 2. Prove the mobile with an OTP challenge (REGISTER_CUSTOMER).
    const otpReq = await injectJson(ctx.app, {
      method: 'POST',
      url: '/v1/auth/otp/request',
      body: { mobileNumber, purpose: 'REGISTER_CUSTOMER' },
    });
    expect(otpReq.status).toBe(201);
    const challengeId = otpReq.json.data.challengeId as string;

    const otpVerify = await injectJson(ctx.app, {
      method: 'POST',
      url: '/v1/auth/otp/verify',
      body: { challengeId, code: '000000' },
    });
    expect(otpVerify.status).toBe(200);

    // 3. Register the Customer, binding the Google subject + accepting terms.
    const register = await injectJson(ctx.app, {
      method: 'POST',
      url: '/v1/auth/register/customer',
      body: {
        challengeId,
        firebaseToken: idToken,
        displayName: 'Aisha Customer',
        termsVersion: '1.0',
        privacyVersion: '1.0',
        preferredLanguage: 'en',
      },
    });
    expect(register.status, register.raw).toBe(201);
    const bundle = register.json.data;
    expect(bundle.accessToken).toBeTypeOf('string');
    expect(bundle.refreshToken).toBeTypeOf('string');
    expect(bundle.user.userType).toBe('CUSTOMER');

    // Exactly one user + one Google binding now exist.
    expect(await ctx.prisma.user.count()).toBe(1);
    expect(await ctx.prisma.oauthBinding.count()).toBe(1);

    // 4. Same Google token now resolves to a session (binding hit, no re-register).
    const second = await injectJson(ctx.app, {
      method: 'POST',
      url: '/v1/auth/google/session',
      body: { idToken },
    });
    expect(second.status, second.raw).toBe(200);
    const session = second.json.data;
    expect(session.accessToken).toBeTypeOf('string');
    expect(session.refreshToken).toBeTypeOf('string');
    expect(session.accessExpiresAt).toBeTypeOf('string');
    expect(session.user.userType).toBe('CUSTOMER');
    // google/session did not create a second user row.
    expect(await ctx.prisma.user.count()).toBe(1);

    // 5. GET /v1/me carries the customer profile + its request-quota fields.
    const me = await injectJson(ctx.app, {
      method: 'GET',
      url: '/v1/me',
      token: session.accessToken,
    });
    expect(me.status, me.raw).toBe(200);
    const profile = me.json.data;
    expect(profile.userType).toBe('CUSTOMER');
    expect(profile.oauthBound).toBe(true);
    expect(profile.customer).toBeDefined();
    expect(profile.customer.displayName).toBe('Aisha Customer');
    expect(profile.customer.liveRequestCount).toBe(0);
    expect(profile.customer.canCreateRequest).toBe(true);
  });

  it('an unbound Google token with an unverified email still never provisions', async () => {
    const suffix = uniqueSuffix();
    const idToken = await ctx.mintGoogleToken({
      uid: `google-uid-${suffix}`,
      email: `unverified.${suffix}@gmail.example`,
      emailVerified: false,
    });

    const res = await injectJson(ctx.app, {
      method: 'POST',
      url: '/v1/auth/google/session',
      body: { idToken },
    });

    expect(res.status).toBe(401);
    expect(res.json?.error?.code).toBe('UNAUTHENTICATED');
    expect(await ctx.prisma.user.count()).toBe(0);
    expect(await ctx.prisma.oauthBinding.count()).toBe(0);
  });
});
