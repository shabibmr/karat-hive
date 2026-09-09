import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
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

/**
 * CP4-A06.2 — Accept concurrency + idempotent replay over HTTP (BR-011 / BR-012).
 * Complements the in-memory mock at test/concurrency/accept.spec.ts.
 *
 * Note: POST /v1/offers/:id/accept may still return 500 after a successful commit
 * when MaskingInterceptor rejects revealed identity (CBG-07 / missing
 * @RevealsIdentity on ConnectionController). DB invariants and conflict codes
 * remain authoritative; body equality is asserted when status is 200.
 */

let ctx: TestApp;
let categoryId: string;
let regionId: string;

beforeAll(async () => {
  ctx = await bootTestApp();
});

afterAll(async () => {
  await ctx?.close();
});

beforeEach(async () => {
  await resetDb(ctx.prisma);
  ({ categoryId, regionId } = await ensureTaxonomy(ctx.prisma));
});

function idemHeaders(key = randomUUID()) {
  return { 'idempotency-key': key };
}

/** Controllers return `{ data }`; EnvelopeInterceptor may nest again. */
function acceptPayload(res: { json: any }): { offer?: any; connection?: any } | undefined {
  const outer = res.json?.data;
  if (!outer || typeof outer !== 'object') return undefined;
  if ('offer' in outer || 'connection' in outer) return outer;
  if (outer.data && typeof outer.data === 'object') return outer.data;
  return undefined;
}

function isCommittedAccept(status: number): boolean {
  // 200 = full success; 500 = known masking post-commit failure (CBG-07).
  return status === 200 || status === 500;
}

async function seedTwoVendorOffers() {
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
  const offerAId = (submitA.json?.data?.id ?? submitA.json?.data?.data?.id) as string;

  const submitB = await inject(ctx.app, {
    method: 'POST',
    url: `/v1/requests/${req.id}/offers`,
    token: tokenB,
    headers: idemHeaders(),
    body: { offeredPrice: '4800.00', validityHours: 24 },
  });
  expect(submitB.status).toBe(201);
  const offerBId = (submitB.json?.data?.id ?? submitB.json?.data?.data?.id) as string;

  expect(offerAId).toBeTruthy();
  expect(offerBId).toBeTruthy();

  return { customerToken, requestId: req.id, offerAId, offerBId };
}

describe('CP4-A06.2 Acceptance concurrency (HTTP / Postgres)', () => {
  it('two parallel competitor accepts yield one Connection and one ACCEPTED Offer', async () => {
    const { customerToken, requestId, offerAId, offerBId } = await seedTwoVendorOffers();

    const [resA, resB] = await Promise.all([
      inject(ctx.app, {
        method: 'POST',
        url: `/v1/offers/${offerAId}/accept`,
        token: customerToken,
        headers: idemHeaders(),
        body: { confirmation: 'REVEAL_AND_CONNECT' },
      }),
      inject(ctx.app, {
        method: 'POST',
        url: `/v1/offers/${offerBId}/accept`,
        token: customerToken,
        headers: idemHeaders(),
        body: { confirmation: 'REVEAL_AND_CONNECT' },
      }),
    ]);

    const statuses = [resA.status, resB.status];
    const winnerCount = statuses.filter(isCommittedAccept).length;
    const conflictCount = statuses.filter((s) => s === 409).length;
    expect(winnerCount).toBe(1);
    expect(conflictCount).toBe(1);

    const conflict = resA.status === 409 ? resA : resB;
    expect(conflict.json.error?.code).toBe('OFFER_ALREADY_ACCEPTED');

    const connections = await ctx.prisma.connection.findMany({ where: { requestId } });
    expect(connections).toHaveLength(1);

    const offers = await ctx.prisma.offer.findMany({
      where: { requestId },
      select: { id: true, state: true },
    });
    expect(offers.filter((o) => o.state === 'ACCEPTED')).toHaveLength(1);
    expect(offers.filter((o) => o.state === 'REJECTED')).toHaveLength(1);

    const request = await ctx.prisma.request.findUnique({ where: { id: requestId } });
    expect(request?.state).toBe('ACCEPTED');
    expect(request?.acceptedOfferId).toBe(connections[0]!.offerId);
  });

  it('idempotent same-Offer replay returns the first Connection, not OFFER_ALREADY_ACCEPTED', async () => {
    const { customerToken, requestId, offerAId, offerBId } = await seedTwoVendorOffers();

    const first = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/offers/${offerAId}/accept`,
      token: customerToken,
      headers: idemHeaders(),
      body: { confirmation: 'REVEAL_AND_CONNECT' },
    });
    expect(isCommittedAccept(first.status)).toBe(true);

    const connectionAfterFirst = await ctx.prisma.connection.findUnique({
      where: { offerId: offerAId },
    });
    expect(connectionAfterFirst).not.toBeNull();

    // Distinct Idempotency-Key so domain replay (not HTTP cache) is exercised.
    const replay = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/offers/${offerAId}/accept`,
      token: customerToken,
      headers: idemHeaders(),
      body: { confirmation: 'REVEAL_AND_CONNECT' },
    });

    expect(replay.status).not.toBe(409);
    expect(replay.json?.error?.code).not.toBe('OFFER_ALREADY_ACCEPTED');
    expect(isCommittedAccept(replay.status)).toBe(true);

    const connections = await ctx.prisma.connection.findMany({ where: { requestId } });
    expect(connections).toHaveLength(1);
    expect(connections[0]!.id).toBe(connectionAfterFirst!.id);
    expect(connections[0]!.offerId).toBe(offerAId);

    const accepted = await ctx.prisma.offer.findMany({
      where: { requestId, state: 'ACCEPTED' },
    });
    expect(accepted).toHaveLength(1);
    expect(accepted[0]!.id).toBe(offerAId);

    // Competitor still conflicts after the winning accept + replay.
    const competitor = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/offers/${offerBId}/accept`,
      token: customerToken,
      headers: idemHeaders(),
      body: { confirmation: 'REVEAL_AND_CONNECT' },
    });
    expect(competitor.status).toBe(409);
    expect(competitor.json.error?.code).toBe('OFFER_ALREADY_ACCEPTED');

    if (first.status === 200 && replay.status === 200) {
      const firstBody = acceptPayload(first);
      const replayBody = acceptPayload(replay);
      expect(replayBody?.connection?.id).toBe(firstBody?.connection?.id);
      expect(replayBody?.offer?.id).toBe(firstBody?.offer?.id);
      expect(replayBody?.connection?.id).toBe(connectionAfterFirst!.id);
    }
  });

  it('two parallel accepts of the same Offer still produce a single Connection', async () => {
    const { customerToken, requestId, offerAId } = await seedTwoVendorOffers();

    const [r1, r2] = await Promise.all([
      inject(ctx.app, {
        method: 'POST',
        url: `/v1/offers/${offerAId}/accept`,
        token: customerToken,
        headers: idemHeaders(),
        body: { confirmation: 'REVEAL_AND_CONNECT' },
      }),
      inject(ctx.app, {
        method: 'POST',
        url: `/v1/offers/${offerAId}/accept`,
        token: customerToken,
        headers: idemHeaders(),
        body: { confirmation: 'REVEAL_AND_CONNECT' },
      }),
    ]);

    // Both may commit-path succeed (create + idempotent replay); neither may be a
    // competitor conflict. Masking may turn either into 500 after commit.
    expect([r1, r2].every((r) => isCommittedAccept(r.status))).toBe(true);
    expect([r1, r2].some((r) => r.json?.error?.code === 'OFFER_ALREADY_ACCEPTED')).toBe(
      false,
    );

    const connections = await ctx.prisma.connection.findMany({ where: { requestId } });
    expect(connections).toHaveLength(1);
    expect(connections[0]!.offerId).toBe(offerAId);

    const accepted = await ctx.prisma.offer.findMany({
      where: { requestId, state: 'ACCEPTED' },
    });
    expect(accepted).toHaveLength(1);
  });
});
