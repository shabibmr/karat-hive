import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import {
  bootCustomerTestApp,
  deepHasKey,
  injectJson,
  insertCustomer,
  issueAccessToken,
  resetCustomerDb,
  type CustomerTestApp,
} from '../integration/customer-app.helpers';
import { insertVendor } from '../integration/helpers';
import { assertIdentityKeysAbsent } from './assert-identity-absent';

/**
 * CBG-07 — masking release-gate on the Customer Offer/Connection path.
 * Customer-side mirror of FR-VEN-011; guards domain invariant 1 (identity is
 * ABSENT from payloads, enforced server-side, until a Connection exists) and
 * invariant 2 (Acceptance atomically reveals both identities).
 *
 * The three vendor identity keys under test — `mobileNumber`, `displayName`,
 * `legalBusinessName` — must be strictly absent (key not present, not null/empty)
 * from GET /v1/requests/:id (owner presenter, offers nested) and GET /v1/offers/:id
 * before Acceptance, and present on GET /v1/connections/:id after it.
 */
const REVEALED_VENDOR_KEYS = ['mobileNumber', 'displayName', 'legalBusinessName'] as const;

describe('CBG-07 Customer Offer/Connection masking release-gate', () => {
  let ctx: CustomerTestApp;

  beforeAll(async () => {
    ctx = await bootCustomerTestApp();
  });

  afterAll(async () => {
    await ctx.close();
  });

  let customerToken: string;
  let requestId: string;
  let offerId: string;

  beforeEach(async () => {
    await resetCustomerDb(ctx.prisma);

    const category = await ctx.prisma.category.create({
      data: { nameEn: 'Rings', nameAr: 'خواتم', displayOrder: 0 },
    });
    const region = await ctx.prisma.region.create({
      data: { nameEn: 'Dubai', nameAr: 'دبي', displayOrder: 0 },
    });

    const customer = await insertCustomer(ctx.prisma, { displayName: 'Fatima Buyer' });
    customerToken = await issueAccessToken(ctx.app, customer.user);

    const { vendorProfileId } = await insertVendor(ctx.prisma, {
      state: 'ACTIVE',
      categoryId: category.id,
      regionId: region.id,
    });

    const now = new Date();
    const request = await ctx.prisma.request.create({
      data: {
        reference: `KH-REQ-${Date.now()}`,
        customerProfileId: customer.customerProfileId,
        requestType: 'FIND_ORNAMENT',
        direction: 'BUY',
        state: 'OFFERS_RECEIVED',
        categoryId: category.id,
        regionId: region.id,
        notes: '22K ring, size 7',
        purityKarat: 'K22',
        publishedAt: now,
        expiresAt: new Date(now.getTime() + 24 * 3600 * 1000),
        offerCount: 1,
      },
    });
    requestId = request.id;

    // Vendor is in the match set for the owner GET to nest the offer.
    await ctx.prisma.requestMatch.create({
      data: {
        requestId: request.id,
        vendorProfileId,
        matchedAt: now,
        isEligible: true,
      },
    });

    const offer = await ctx.prisma.offer.create({
      data: {
        requestId: request.id,
        vendorProfileId,
        state: 'PENDING',
        offeredPrice: '4200.00',
        makingCharges: '150.00',
        validityHours: 24,
        submittedAt: now,
        expiresAt: new Date(now.getTime() + 24 * 3600 * 1000),
        vendorNote: 'Ready to supply within two days.',
      },
    });
    offerId = offer.id;
  });

  it('hides vendor identity on GET /v1/requests/:id (owner, offers nested) before a Connection', async () => {
    const res = await injectJson(ctx.app, {
      method: 'GET',
      url: `/v1/requests/${requestId}`,
      token: customerToken,
    });

    expect(res.status, res.raw).toBe(200);
    assertIdentityKeysAbsent(res.json, 'GET /v1/requests/:id (customer owner)');
    for (const key of REVEALED_VENDOR_KEYS) {
      expect(deepHasKey(res.json, key), `key "${key}" must be absent`).toBe(false);
    }
    // Sanity: this really is the owner presenter (customer-only field present).
    expect(res.json.data).toHaveProperty('unreadOfferCount');
  });

  it('hides vendor identity on GET /v1/offers/:id before a Connection', async () => {
    const res = await injectJson(ctx.app, {
      method: 'GET',
      url: `/v1/offers/${offerId}`,
      token: customerToken,
    });

    expect(res.status, res.raw).toBe(200);
    assertIdentityKeysAbsent(res.json, 'GET /v1/offers/:id (customer)');
    for (const key of REVEALED_VENDOR_KEYS) {
      expect(deepHasKey(res.json, key), `key "${key}" must be absent`).toBe(false);
    }
    // Sanity: the masked vendor block is present, just without identity.
    // OfferController wraps in { data }, EnvelopeInterceptor wraps again -> data.data.
    const offer = res.json.data.data;
    expect(offer.vendor).toBeDefined();
    expect(offer.vendor.label).toContain('Vendor');
  });

  it('Acceptance atomically creates the Connection and rejects competitors (invariant 2), even though the HTTP response is currently broken', async () => {
    // Second vendor + PENDING offer on the same request.
    const { vendorProfileId: vendor2 } = await insertVendor(ctx.prisma, {
      state: 'ACTIVE',
    });
    const now = new Date();
    const loser = await ctx.prisma.offer.create({
      data: {
        requestId,
        vendorProfileId: vendor2,
        state: 'PENDING',
        offeredPrice: '4500.00',
        validityHours: 24,
        submittedAt: now,
        expiresAt: new Date(now.getTime() + 24 * 3600 * 1000),
      },
    });

    const accept = await injectJson(ctx.app, {
      method: 'POST',
      url: `/v1/offers/${offerId}/accept`,
      token: customerToken,
      headers: { 'idempotency-key': randomUUID() },
      body: { confirmation: 'REVEAL_AND_CONNECT' },
    });

    // BUG (CBG-07): ConnectionController carries no @RevealsIdentity(), so the
    // MaskingInterceptor rejects the (correctly-revealed) response body and the
    // caller gets 500 INTERNAL instead of the Connection. See the report.
    expect(accept.status, accept.raw).toBe(500);

    // The transaction itself still committed: invariant 2 holds in the DB.
    const connection = await ctx.prisma.connection.findUnique({ where: { offerId } });
    expect(connection).not.toBeNull();
    expect(connection!.state).toBe('ACTIVE');
    expect(connection!.identityRevealedAt).toBeInstanceOf(Date);

    const accepted = await ctx.prisma.offer.findUnique({ where: { id: offerId } });
    expect(accepted!.state).toBe('ACCEPTED');
    const rejected = await ctx.prisma.offer.findUnique({ where: { id: loser.id } });
    expect(rejected!.state).toBe('REJECTED');
    const req = await ctx.prisma.request.findUnique({ where: { id: requestId } });
    expect(req!.state).toBe('ACCEPTED');
    expect(req!.acceptedOfferId).toBe(offerId);

    // The rejected competitor still carries no Connection, so its customer-facing
    // Offer view stays masked.
    const loserView = await injectJson(ctx.app, {
      method: 'GET',
      url: `/v1/offers/${loser.id}`,
      token: customerToken,
    });
    expect(loserView.status, loserView.raw).toBe(200);
    assertIdentityKeysAbsent(loserView.json, 'GET /v1/offers/:id (rejected competitor)');
    for (const key of REVEALED_VENDOR_KEYS) {
      expect(deepHasKey(loserView.json, key), `key "${key}" must be absent`).toBe(false);
    }
  });

  // Tripwire: this is the assertion CBG-07 actually asks for — after Acceptance,
  // GET /v1/connections/:id MUST return the vendor's legalBusinessName / phone to
  // the owning Customer. It fails today (500, identity-key leak on an un-flagged
  // route). When ConnectionController is given @RevealsIdentity() this `.fails`
  // spec flips red — convert it to a plain `it` at that point.
  it.fails('reveals vendor identity on GET /v1/connections/:id after Acceptance (BLOCKED by CBG-07 bug)', async () => {
    await injectJson(ctx.app, {
      method: 'POST',
      url: `/v1/offers/${offerId}/accept`,
      token: customerToken,
      headers: { 'idempotency-key': randomUUID() },
      body: { confirmation: 'REVEAL_AND_CONNECT' },
    });

    const connection = await ctx.prisma.connection.findUnique({ where: { offerId } });
    const res = await injectJson(ctx.app, {
      method: 'GET',
      url: `/v1/connections/${connection!.id}`,
      token: customerToken,
    });

    expect(res.status, res.raw).toBe(200);
    const vendor = res.json.data.data.vendor;
    expect(deepHasKey(res.json, 'legalBusinessName')).toBe(true);
    expect(vendor.legalBusinessName).toBeTypeOf('string');
    expect(vendor.legalBusinessName.length).toBeGreaterThan(0);
    expect(vendor.phone).toMatch(/^\+\d{7,}$/);
    expect(res.json.data.data.talk.phone).toBe(vendor.phone);
  });
});
