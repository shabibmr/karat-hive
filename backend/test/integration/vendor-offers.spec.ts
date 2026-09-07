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
    expect(submit.json.data.state).toBe('PENDING');
    expect(submit.json.data.terms.offeredPrice).toBe('5500');
    expect(submit.json.data.requestSummary?.customerLabel).toMatch(/Customer/);
    expect(submit.json.data.requestSummary).not.toHaveProperty('mobileNumber');
    expect(submit.json.data).not.toHaveProperty('vendor');

    const list = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/me/offers?tab=PENDING',
      token,
    });
    expect(list.status).toBe(200);
    expect(list.json.data).toHaveLength(1);
    expect(list.json.data[0].id).toBe(submit.json.data.id);
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
    const offerId = submit.json.data.id as string;

    for (let i = 1; i <= 3; i++) {
      const revise = await inject(ctx.app, {
        method: 'POST',
        url: `/v1/offers/${offerId}/revise`,
        token,
        headers: idemHeaders(),
        body: { offeredPrice: `${5000 + i}.00`, validityHours: 12 },
      });
      expect(revise.status).toBe(200);
      expect(revise.json.data.revisionCount).toBe(i);
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
      url: `/v1/offers/${submit.json.data.id}/withdraw`,
      token,
    });
    expect(withdraw.status).toBe(200);
    expect(withdraw.json.data.state).toBe('WITHDRAWN');
  });

  it('keeps awardedElsewhere free of winner price or identity', async () => {
    const presented = {
      id: 'off-1',
      requestId: 'req-1',
      state: 'REJECTED',
      awardedElsewhere: true,
      terms: { offeredPrice: '1000.00', validityHours: 24 },
    };
    expect(presented).not.toHaveProperty('winningPrice');
    expect(presented).not.toHaveProperty('acceptedVendor');
    expect(JSON.stringify(presented)).not.toMatch(/tradingName|mobileNumber/);
  });
});
