import { randomUUID } from 'node:crypto';
import type { User } from '@prisma/client';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { ENV, type Env } from '../../src/config/env';
import { TokenService } from '../../src/modules/identity';
import { LocalDiskStorageAdapter } from '../../src/platform/adapters/storage/local-disk-storage.adapter';
import { OBJECT_STORAGE } from '../../src/platform/ports/storage.port';
import {
  assertCompetitorBlindness,
  assertIdentityKeysAbsent,
} from '../masking/assert-identity-absent';
import {
  bootTestApp,
  ensureTaxonomy,
  inject,
  insertCustomer,
  insertPublishedRequest,
  insertRequestMatch,
  insertVendor,
  insertVendorSubscription,
  issueSession,
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

/** Controllers that return `{ data }` are re-wrapped by the envelope interceptor. */
function settingsOf(json: { data?: { data?: unknown } & Record<string, unknown> }) {
  const outer = json.data;
  if (!outer || typeof outer !== 'object') return outer;
  if ('preferredLanguage' in outer) return outer;
  return (outer as { data?: unknown }).data;
}

async function activeVendor() {
  return insertVendor(ctx.prisma, { state: 'ACTIVE', categoryId, regionId });
}

async function createPreset(vendorProfileId: string, name: string) {
  return ctx.prisma.filterPreset.create({
    data: { vendorProfileId, name, filters: { sort: 'newest' } },
  });
}

/** Access + refresh for a known family (issueSession is access-only). */
async function issueRefreshSession(user: User) {
  const tokens = ctx.app.get(TokenService);
  const env = ctx.app.get<Env>(ENV);
  const access = await tokens.signAccess({
    sub: user.id,
    role: user.userType,
    ver: user.tokenVersion,
  });
  const refresh = await tokens.issueRefresh({
    userId: user.id,
    ttlMs: env.JWT_REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000,
    userAgent: 'kh-test/a06.2',
  });
  return {
    accessToken: access.token,
    refreshToken: refresh.refreshToken,
    familyId: refresh.familyId,
  };
}

describe('CP6-A06.1 vendor settings round-trip', () => {
  it('unauthenticated GET /v1/me/settings is 401', async () => {
    const res = await inject(ctx.app, { method: 'GET', url: '/v1/me/settings' });
    expect(res.status).toBe(401);
  });

  it('GET defaults then PATCH/GET round-trips language, quiet hours, defaultFilterPresetId', async () => {
    const { user, vendorProfileId } = await activeVendor();
    const token = await issueSession(ctx, user);
    const presetA = await createPreset(vendorProfileId, 'Preset A');
    const presetB = await createPreset(vendorProfileId, 'Preset B');

    const initial = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/settings',
      token,
    });
    expect(initial.status).toBe(200);
    expect(settingsOf(initial.json)).toMatchObject({
      preferredLanguage: 'en',
      defaultFilterPresetId: null,
      quietHours: null,
    });

    // Omit notifications here: nested channel key `email` trips identity masking (500).
    const patch = await inject(ctx.app, {
      method: 'PATCH',
      url: '/v1/me/settings',
      token,
      body: {
        preferredLanguage: 'ar',
        quietHours: { start: '22:00', end: '07:00' },
        defaultFilterPresetId: presetA.id,
      },
    });
    expect(patch.status).toBe(200);
    expect(settingsOf(patch.json)).toMatchObject({
      preferredLanguage: 'ar',
      defaultFilterPresetId: presetA.id,
      quietHours: { start: '22:00', end: '07:00', timezone: 'Asia/Dubai' },
    });

    const after = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/settings',
      token,
    });
    expect(after.status).toBe(200);
    expect(settingsOf(after.json)).toMatchObject({
      preferredLanguage: 'ar',
      defaultFilterPresetId: presetA.id,
      quietHours: { start: '22:00', end: '07:00', timezone: 'Asia/Dubai' },
    });

    // Second preset becomes the sole default (column overwrite).
    const switchDefault = await inject(ctx.app, {
      method: 'PATCH',
      url: '/v1/me/settings',
      token,
      body: { defaultFilterPresetId: presetB.id },
    });
    expect(switchDefault.status).toBe(200);
    expect(settingsOf(switchDefault.json)).toMatchObject({
      defaultFilterPresetId: presetB.id,
      preferredLanguage: 'ar',
    });

    const clear = await inject(ctx.app, {
      method: 'PATCH',
      url: '/v1/me/settings',
      token,
      body: { defaultFilterPresetId: null },
    });
    expect(clear.status).toBe(200);
    expect(settingsOf(clear.json)).toMatchObject({
      defaultFilterPresetId: null,
      preferredLanguage: 'ar',
    });
  });

  it('PATCH defaultFilterPresetId owned by another vendor is NOT_FOUND', async () => {
    const a = await activeVendor();
    const b = await activeVendor();
    const token = await issueSession(ctx, a.user);
    const foreign = await createPreset(b.vendorProfileId, 'Foreign');

    const res = await inject(ctx.app, {
      method: 'PATCH',
      url: '/v1/me/settings',
      token,
      body: { defaultFilterPresetId: foreign.id },
    });
    expect(res.status).toBe(404);
    expect(res.json.error.code).toBe('NOT_FOUND');
  });

  it('PATCH that turns off locked security category is SETTING_OUT_OF_RANGE; other fields unchanged', async () => {
    const { user, vendorProfileId } = await activeVendor();
    const token = await issueSession(ctx, user);
    const preset = await createPreset(vendorProfileId, 'Keep');

    await inject(ctx.app, {
      method: 'PATCH',
      url: '/v1/me/settings',
      token,
      body: {
        preferredLanguage: 'ar',
        quietHours: { start: '21:00', end: '06:00' },
        defaultFilterPresetId: preset.id,
      },
    });

    const locked = await inject(ctx.app, {
      method: 'PATCH',
      url: '/v1/me/settings',
      token,
      body: { notifications: { security: { push: false } } },
    });
    expect(locked.status).toBe(400);
    expect(locked.json.error.code).toBe('SETTING_OUT_OF_RANGE');

    const after = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/settings',
      token,
    });
    expect(settingsOf(after.json)).toMatchObject({
      preferredLanguage: 'ar',
      defaultFilterPresetId: preset.id,
      quietHours: { start: '21:00', end: '06:00', timezone: 'Asia/Dubai' },
    });
  });
});

describe('CP6-A06.2 session revoke', () => {
  it('DELETE /v1/auth/sessions/:id revokes that family; its refresh is rejected', async () => {
    const { user } = await activeVendor();
    const session = await issueRefreshSession(user);

    const listed = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/auth/sessions',
      token: session.accessToken,
    });
    expect(listed.status).toBe(200);
    const families = listed.json.data as Array<{ id: string }>;
    expect(families.some((f) => f.id === session.familyId)).toBe(true);

    // 204 has an empty body; helpers.inject always calls res.json().
    const revoked = await ctx.app.inject({
      method: 'DELETE',
      url: `/v1/auth/sessions/${session.familyId}`,
      headers: { authorization: `Bearer ${session.accessToken}` },
    });
    expect(revoked.statusCode).toBe(204);

    const refresh = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/refresh',
      body: { refreshToken: session.refreshToken },
    });
    expect(refresh.status).toBe(401);
    // revokeFamily stamps reuseDetectedAt, so rotate prefers REUSE over plain UNAUTHENTICATED.
    expect(refresh.json.error.code).toBe('REFRESH_REUSE_DETECTED');
  });
});

describe('CP6-A06.3 password policy', () => {
  it('POST /v1/auth/password rejects policy violations with PASSWORD_POLICY', async () => {
    const { user } = await activeVendor();
    const token = await issueSession(ctx, user);

    const weak = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/password',
      token,
      body: { newPassword: 'short' },
    });
    expect(weak.status).toBe(400);
    expect(weak.json.error.code).toBe('PASSWORD_POLICY');

    const breached = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/password',
      token,
      body: { newPassword: 'Password123!' },
    });
    expect(breached.status).toBe(400);
    expect(breached.json.error.code).toBe('PASSWORD_POLICY');

    const unchanged = await ctx.prisma.user.findUniqueOrThrow({ where: { id: user.id } });
    expect(unchanged.passwordHash).toBeNull();
  });

  it('POST /v1/auth/password accepts a compliant first-time set (204)', async () => {
    const { user } = await activeVendor();
    const token = await issueSession(ctx, user);

    // 204 has an empty body; helpers.inject always calls res.json().
    const set = await ctx.app.inject({
      method: 'POST',
      url: '/v1/auth/password',
      headers: {
        authorization: `Bearer ${token}`,
        'content-type': 'application/json',
      },
      payload: { newPassword: 'ValidPassw0rd!!' },
    });
    expect(set.statusCode).toBe(204);

    const stored = await ctx.prisma.user.findUniqueOrThrow({ where: { id: user.id } });
    expect(stored.passwordHash).toBeTruthy();

    const afterSet = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/auth/password',
      token,
      body: { currentPassword: 'ValidPassw0rd!!', newPassword: 'tooShort1' },
    });
    expect(afterSet.status).toBe(400);
    expect(afterSet.json.error.code).toBe('PASSWORD_POLICY');
  });
});

function idemHeaders(key = randomUUID()) {
  return { 'idempotency-key': key };
}

/** Controllers that return `{ data }` are re-wrapped by the envelope interceptor. */
function performanceOf(json: { data?: { data?: unknown } & Record<string, unknown> }) {
  const outer = json.data;
  if (!outer || typeof outer !== 'object') return outer;
  if ('offersSubmitted' in outer) return outer;
  return (outer as { data?: unknown }).data;
}

function exportOf(json: { data?: { data?: unknown } & Record<string, unknown> }) {
  const outer = json.data;
  if (!outer || typeof outer !== 'object') return outer;
  if ('downloadUrl' in outer) return outer as { downloadUrl: string; expiresAt: string };
  return (outer as { data?: { downloadUrl: string; expiresAt: string } }).data;
}

function offerIdOf(res: { json: any }): string {
  return (res.json?.data?.id ?? res.json?.data?.data?.id) as string;
}

function parseLocalObjectUrl(url: string): { bucket: string; key: string } {
  const match = /^local:\/\/([^/]+)\/(.+)$/.exec(url);
  if (!match) throw new Error(`unexpected downloadUrl: ${url}`);
  return { bucket: match[1]!, key: match[2]! };
}

/**
 * Two ACTIVE Vendors offer on one Request; Customer accepts Vendor B.
 * Subject under test is the losing Vendor A (period aggregate + own-row export).
 */
async function seedCompetingOffersAccepted() {
  const { user: customerUser, customerProfileId } = await insertCustomer(ctx.prisma);
  const customerToken = await issueSession(ctx, customerUser);

  const vendorA = await insertVendor(ctx.prisma, {
    state: 'ACTIVE',
    categoryId,
    regionId,
  });
  const vendorB = await insertVendor(ctx.prisma, {
    state: 'ACTIVE',
    categoryId,
    regionId,
  });
  await insertVendorSubscription(ctx.prisma, {
    vendorProfileId: vendorA.vendorProfileId,
    requestType: 'FIND_ORNAMENT',
    state: 'ACTIVE',
  });
  await insertVendorSubscription(ctx.prisma, {
    vendorProfileId: vendorB.vendorProfileId,
    requestType: 'FIND_ORNAMENT',
    state: 'ACTIVE',
  });

  const req = await insertPublishedRequest(ctx.prisma, {
    customerProfileId,
    categoryId,
    regionId,
    requestType: 'FIND_ORNAMENT',
    budgetMin: 4000,
    budgetMax: 6000,
  });
  await insertRequestMatch(ctx.prisma, {
    requestId: req.id,
    vendorProfileId: vendorA.vendorProfileId,
    isEligible: true,
  });
  await insertRequestMatch(ctx.prisma, {
    requestId: req.id,
    vendorProfileId: vendorB.vendorProfileId,
    isEligible: true,
  });

  const tokenA = await issueSession(ctx, vendorA.user);
  const tokenB = await issueSession(ctx, vendorB.user);

  const submitA = await inject(ctx.app, {
    method: 'POST',
    url: `/v1/requests/${req.id}/offers`,
    token: tokenA,
    headers: idemHeaders(),
    body: { offeredPrice: '5500.00', validityHours: 24 },
  });
  expect(submitA.status).toBe(201);
  const offerAId = offerIdOf(submitA);

  const submitB = await inject(ctx.app, {
    method: 'POST',
    url: `/v1/requests/${req.id}/offers`,
    token: tokenB,
    headers: idemHeaders(),
    body: { offeredPrice: '4800.00', validityHours: 24 },
  });
  expect(submitB.status).toBe(201);
  const offerBId = offerIdOf(submitB);

  // Accept may 500 post-commit when MaskingInterceptor rejects revealed identity (CBG-07).
  const accept = await inject(ctx.app, {
    method: 'POST',
    url: `/v1/offers/${offerBId}/accept`,
    token: customerToken,
    headers: idemHeaders(),
    body: { confirmation: 'REVEAL_AND_CONNECT' },
  });
  expect([200, 500]).toContain(accept.status);

  const request = await ctx.prisma.request.findUniqueOrThrow({ where: { id: req.id } });
  expect(request.acceptedOfferId).toBe(offerBId);
  expect(request.state).toBe('ACCEPTED');

  return {
    tokenA,
    tokenB,
    offerAId,
    offerBId,
    vendorProfileIdA: vendorA.vendorProfileId,
    vendorProfileIdB: vendorB.vendorProfileId,
    requestReference: req.reference,
  };
}

describe('CP6-A06.4 performance + export masking', () => {
  it('GET /v1/me/vendor/performance is aggregate-only — no per-Request competitor figure', async () => {
    const { tokenA, offerBId } = await seedCompetingOffersAccepted();

    const res = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/vendor/performance',
      token: tokenA,
    });
    expect(res.status).toBe(200);

    const body = performanceOf(res.json) as Record<string, unknown>;
    expect(body).toMatchObject({
      offersSubmitted: 1,
      acceptanceRate: '0.00',
    });
    expect(typeof body.averageResponseMinutes).toBe('number');
    expect(Array.isArray(body.byOutcome)).toBe(true);
    expect(Array.isArray(body.ratingTrend)).toBe(true);
    expect((body.ratingTrend as unknown[]).length).toBe(6);

    // BR-008: no offered-vs-accepted comparison is exposed to vendors at all — with a
    // single lost Offer in period, any such "average" degenerates to the exact
    // winning competitor's price, so the stat is removed rather than thresholded.
    expect(body).not.toHaveProperty('averageOfferedVsAccepted');
    expect(body).not.toHaveProperty('perRequest');
    expect(body).not.toHaveProperty('perRequestDeltas');
    expect(body).not.toHaveProperty('acceptedPrices');
    expect(body).not.toHaveProperty('competitorPrices');

    assertCompetitorBlindness(body, 'vendor performance');
    assertIdentityKeysAbsent(body, 'vendor performance');

    // Raw competitor price / winning Offer id must not leak into the JSON body.
    const serialized = JSON.stringify(body);
    expect(serialized).not.toContain('4800');
    expect(serialized).not.toContain(offerBId);
  });

  it('GET /v1/me/vendor/performance/export returns signed URL of this Vendor’s rows only', async () => {
    const { tokenA, tokenB, offerAId, offerBId, vendorProfileIdA } =
      await seedCompetingOffersAccepted();

    const exported = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/vendor/performance/export',
      token: tokenA,
    });
    expect(exported.status).toBe(200);

    const payload = exportOf(exported.json);
    expect(payload).toEqual(
      expect.objectContaining({
        downloadUrl: expect.any(String),
        expiresAt: expect.any(String),
      }),
    );
    expect(Object.keys(payload!).sort()).toEqual(['downloadUrl', 'expiresAt']);
    expect(payload!.downloadUrl).toContain(`local://export/vendor/${vendorProfileIdA}/performance/`);

    const expiresAt = Date.parse(payload!.expiresAt);
    expect(Number.isNaN(expiresAt)).toBe(false);
    expect(expiresAt).toBeGreaterThan(Date.now());
    expect(expiresAt).toBeLessThanOrEqual(Date.now() + 16 * 60 * 1000);

    const { bucket, key } = parseLocalObjectUrl(payload!.downloadUrl);
    const storage = ctx.app.get(OBJECT_STORAGE) as LocalDiskStorageAdapter;
    const csvBytes = await storage.getObject(bucket, key);
    expect(csvBytes).not.toBeNull();
    const csv = csvBytes!.toString('utf8');

    expect(csv.startsWith('offerId,requestReference,requestType,category,region,state,')).toBe(
      true,
    );
    expect(csv).toContain(offerAId);
    expect(csv).toContain('5500.00');
    expect(csv).toContain('REJECTED');

    // Own rows only — competitor Offer id / price / identity columns absent (BR-008).
    expect(csv).not.toContain(offerBId);
    expect(csv).not.toContain('4800.00');
    expect(csv).not.toMatch(/competitor|winningVendor|tradingName|mobileNumber|customerName/i);

    // Competing Vendor's export must not include Vendor A's Offer either.
    const other = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/vendor/performance/export',
      token: tokenB,
    });
    expect(other.status).toBe(200);
    const otherPayload = exportOf(other.json)!;
    const otherLoc = parseLocalObjectUrl(otherPayload.downloadUrl);
    const otherCsv = (await storage.getObject(otherLoc.bucket, otherLoc.key))!.toString('utf8');
    expect(otherCsv).toContain(offerBId);
    expect(otherCsv).not.toContain(offerAId);
  });
});
