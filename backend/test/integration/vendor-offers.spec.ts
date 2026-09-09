import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { OfferService } from '../../src/modules/offers';
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
  await ctx?.close();
});

beforeEach(async () => {
  await resetDb(ctx.prisma);
  ({ categoryId, regionId } = await ensureTaxonomy(ctx.prisma));
});

async function seedMatchedVendor() {
  const { user, vendorProfileId } = await insertVendor(ctx.prisma, {
    state: 'ACTIVE',
    categoryId,
    regionId,
  });
  await insertVendorSubscription(ctx.prisma, {
    vendorProfileId,
    requestType: 'FIND_ORNAMENT',
    state: 'ACTIVE',
  });
  const { customerProfileId } = await insertCustomer(ctx.prisma);
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
    vendorProfileId,
    isEligible: true,
  });
  const token = await issueSession(ctx, user);
  return { token, requestId: req.id, vendorProfileId };
}

function idemHeaders(key = randomUUID()) {
  return { 'idempotency-key': key };
}

/** Controllers return `{ data }`; EnvelopeInterceptor nests again when `meta` is absent. */
function offered(res: { json: any }) {
  const outer = res.json?.data;
  if (outer && typeof outer === 'object' && 'id' in outer) return outer;
  return outer?.data;
}

describe('CP3-A08 Vendor Offers Integration', () => {
  it('submits an offer and lists it under PENDING', async () => {
    const { token, requestId } = await seedMatchedVendor();

    const submit = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/requests/${requestId}/offers`,
      token,
      headers: idemHeaders(),
      body: {
        offeredPrice: '5500.00',
        validityHours: 24,
        vendorNote: 'Hallmarked 22K',
      },
    });

    expect(submit.status).toBe(201);
    const created = offered(submit);
    expect(created.state).toBe('PENDING');
    expect(created.terms.offeredPrice).toBe('5500');
    expect(created.requestSummary?.customerLabel).toMatch(/Customer/);
    expect(created.requestSummary).not.toHaveProperty('mobileNumber');
    expect(created).not.toHaveProperty('vendor');

    const list = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/offers?tab=PENDING',
      token,
    });
    expect(list.status).toBe(200);
    expect(list.json.data).toHaveLength(1);
    expect(list.json.data[0].id).toBe(created.id);
  });

  it('rejects a second pending offer on the same request', async () => {
    const { token, requestId } = await seedMatchedVendor();

    const first = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/requests/${requestId}/offers`,
      token,
      headers: idemHeaders(),
      body: { offeredPrice: '5000.00', validityHours: 24 },
    });
    expect(first.status).toBe(201);

    const second = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/requests/${requestId}/offers`,
      token,
      headers: idemHeaders(),
      body: { offeredPrice: '5100.00', validityHours: 24 },
    });
    expect(second.status).toBe(409);
    expect(second.json.error?.code).toBe('OFFER_ALREADY_PENDING');
  });

  it('enforces revision limit of 3', async () => {
    const { token, requestId } = await seedMatchedVendor();

    const submit = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/requests/${requestId}/offers`,
      token,
      headers: idemHeaders(),
      body: { offeredPrice: '5000.00', validityHours: 24 },
    });
    expect(submit.status).toBe(201);
    const offerId = offered(submit).id as string;

    for (let i = 1; i <= 3; i++) {
      const revise = await inject(ctx.app, {
        method: 'POST',
        url: `/v1/offers/${offerId}/revise`,
        token,
        headers: idemHeaders(),
        body: { offeredPrice: `${5000 + i}.00`, validityHours: 12 },
      });
      expect(revise.status).toBe(200);
      expect(offered(revise).revisionCount).toBe(i);
    }

    const fourth = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/offers/${offerId}/revise`,
      token,
      headers: idemHeaders(),
      body: { offeredPrice: '6000.00', validityHours: 12 },
    });
    expect(fourth.status).toBe(409);
    expect(fourth.json.error?.code).toBe('OFFER_REVISION_LIMIT');
  });

  it('rejects contact details in vendor note', async () => {
    const { token, requestId } = await seedMatchedVendor();

    const res = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/requests/${requestId}/offers`,
      token,
      headers: idemHeaders(),
      body: {
        offeredPrice: '5000.00',
        validityHours: 24,
        vendorNote: 'Call me on +971501234567',
      },
    });

    expect(res.status).toBe(422);
    expect(res.json.error?.code).toBe('CONTACT_DETAILS_IN_TEXT');
  });

  it('withdraws a pending offer', async () => {
    const { token, requestId } = await seedMatchedVendor();

    const submit = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/requests/${requestId}/offers`,
      token,
      headers: idemHeaders(),
      body: { offeredPrice: '5000.00', validityHours: 24 },
    });
    expect(submit.status).toBe(201);

    const withdraw = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/offers/${offered(submit).id}/withdraw`,
      token,
    });
    expect(withdraw.status).toBe(200);
    expect(offered(withdraw).state).toBe('WITHDRAWN');
  });

  it('after Customer accepts A, B CLOSED list has awardedElsewhere without winner price or identity', async () => {
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
      body: { offeredPrice: '5500.00', validityHours: 24, vendorNote: 'Vendor A terms' },
    });
    expect(submitA.status).toBe(201);
    const offerAId = offered(submitA).id as string;
    expect(offerAId).toBeTruthy();

    const submitB = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/requests/${req.id}/offers`,
      token: tokenB,
      headers: idemHeaders(),
      body: { offeredPrice: '4800.00', validityHours: 24, vendorNote: 'Vendor B terms' },
    });
    expect(submitB.status).toBe(201);
    const offerBId = offered(submitB).id as string;
    expect(offerBId).toBeTruthy();

    await inject(ctx.app, {
      method: 'POST',
      url: `/v1/offers/${offerAId}/accept`,
      token: customerToken,
      headers: idemHeaders(),
      body: { confirmation: 'REVEAL_AND_CONNECT' },
    });

    // Accept commits atomically even if the HTTP response is masked (CBG-07).
    const loser = await ctx.prisma.offer.findUnique({ where: { id: offerBId } });
    expect(loser?.state).toBe('REJECTED');

    const list = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/offers?tab=CLOSED',
      token: tokenB,
    });
    expect(list.status).toBe(200);
    expect(list.json.data).toHaveLength(1);

    const row = list.json.data[0];
    expect(row.id).toBe(offerBId);
    expect(row.state).toBe('REJECTED');
    expect(row.awardedElsewhere).toBe(true);
    expect(row.terms.offeredPrice).toBe('4800');
    expect(row).not.toHaveProperty('winningPrice');
    expect(row).not.toHaveProperty('winningVendor');
    expect(row).not.toHaveProperty('acceptedVendor');
    expect(row).not.toHaveProperty('vendor');

    const serialized = JSON.stringify(row);
    expect(serialized).not.toMatch(/tradingName|legalBusinessName|mobileNumber/);
    // Winner A's price must not leak into the loser's CLOSED row (BR-008).
    expect(serialized).not.toContain('5500');
  });

  it('marks a PENDING offer EXPIRED once the expiry sweep runs past expires_at', async () => {
    const { token, requestId } = await seedMatchedVendor();

    const submit = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/requests/${requestId}/offers`,
      token,
      headers: idemHeaders(),
      body: { offeredPrice: '5000.00', validityHours: 24 },
    });
    expect(submit.status).toBe(201);
    const offerId = offered(submit).id as string;

    // Backdate expires_at so the sweep treats this Offer as expired (FR-SYS-004).
    await ctx.prisma.offer.update({
      where: { id: offerId },
      data: { expiresAt: new Date(Date.now() - 60 * 60 * 1000) },
    });

    const offerService = ctx.app.get(OfferService);
    const sweptCount = await offerService.sweepExpiredOffers();
    expect(sweptCount).toBe(1);

    const expired = await ctx.prisma.offer.findUnique({ where: { id: offerId } });
    expect(expired?.state).toBe('EXPIRED');
    expect(expired?.decidedAt).toBeTruthy();

    // Re-running the sweep immediately must not re-process the now-terminal Offer.
    const secondSweep = await offerService.sweepExpiredOffers();
    expect(secondSweep).toBe(0);
  });

  it('sets expiry_warned_at exactly once when the T-6h warning sweep runs twice', async () => {
    const { token, requestId } = await seedMatchedVendor();

    const submit = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/requests/${requestId}/offers`,
      token,
      headers: idemHeaders(),
      body: { offeredPrice: '5000.00', validityHours: 24 },
    });
    expect(submit.status).toBe(201);
    const offerId = offered(submit).id as string;

    // Backdate expires_at into the T-6h warning window (FR-VEN-013 AC4).
    await ctx.prisma.offer.update({
      where: { id: offerId },
      data: { expiresAt: new Date(Date.now() + 3 * 60 * 60 * 1000) },
    });

    const offerService = ctx.app.get(OfferService);

    const firstSweep = await offerService.sweepExpiryWarnings();
    expect(firstSweep).toBe(1);

    const afterFirst = await ctx.prisma.offer.findUnique({ where: { id: offerId } });
    expect(afterFirst?.expiryWarnedAt).toBeTruthy();
    const warnedAt = afterFirst!.expiryWarnedAt!.getTime();

    const secondSweep = await offerService.sweepExpiryWarnings();
    expect(secondSweep).toBe(0);

    const afterSecond = await ctx.prisma.offer.findUnique({ where: { id: offerId } });
    expect(afterSecond?.expiryWarnedAt?.getTime()).toBe(warnedAt);

    const warningEvents = await ctx.prisma.outboxEvent.findMany({
      where: { eventType: 'offer.expiry.warning', aggregateId: offerId },
    });
    expect(warningEvents).toHaveLength(1);
  });
});
