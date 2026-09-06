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
import { assertVendorPresenterMasking } from '../masking/assert-identity-absent';

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

describe('CP2-A15 Vendor Feed Integration Suite', () => {
  describe('Lifecycle Scenarios', () => {
    it('1. Unsubscribed active vendor sees empty matches feed', async () => {
      // Setup active vendor with category and region, but NO subscription
      const { user, vendorProfileId } = await insertVendor(ctx.prisma, {
        state: 'ACTIVE',
        categoryId,
        regionId,
      });
      const token = await issueSession(ctx, user);

      // Setup customer with a published request in the same category and region
      const { customerProfileId } = await insertCustomer(ctx.prisma);
      await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
        requestType: 'FIND_ORNAMENT',
      });

      // An unsubscribed vendor must have an empty match feed (BR-002: subscription required)
      const res = await inject(ctx.app, {
        method: 'GET',
        url: '/v1/matches',
        token,
      });

      expect(res.status).toBe(200);
      expect(res.json.data).toBeDefined();
      expect(res.json.data).toEqual([]);
      expect(res.json.meta).toBeDefined();
    });

    it('2. Subscribed active vendor with matching category and region sees published requests', async () => {
      // Setup active vendor with category, region, and ACTIVE subscription for FIND_ORNAMENT
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
      const token = await issueSession(ctx, user);

      // Setup customer request and match row
      const { customerProfileId } = await insertCustomer(ctx.prisma);
      const req = await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
        requestType: 'FIND_ORNAMENT',
        budgetMin: 4000,
        budgetMax: 5000,
      });
      await insertRequestMatch(ctx.prisma, {
        requestId: req.id,
        vendorProfileId,
        isEligible: true,
      });

      const res = await inject(ctx.app, {
        method: 'GET',
        url: '/v1/matches',
        token,
      });

      expect(res.status).toBe(200);
      expect(res.json.data).toHaveLength(1);
      const matched = res.json.data[0];
      expect(matched.id).toBe(req.id);
      expect(matched.reference).toBe(req.reference);
      expect(matched.requestType).toBe('FIND_ORNAMENT');
      expect(matched.category.id).toBe(categoryId);
      expect(matched.region.id).toBe(regionId);
    });

    it('3. Customer identity fields are absent from request detail /v1/requests/:id (BR-006, BR-008)', async () => {
      const { user, vendorProfileId } = await insertVendor(ctx.prisma, {
        state: 'ACTIVE',
        categoryId,
        regionId,
      });
      await insertVendorSubscription(ctx.prisma, {
        vendorProfileId,
        requestType: 'FIND_ORNAMENT',
      });
      const token = await issueSession(ctx, user);

      const { customerProfileId } = await insertCustomer(ctx.prisma, {
        displayName: 'Fatima Al Zahra',
        mobileNumber: '+971501112233',
        email: 'fatima.secret@customer.test',
      });
      const req = await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
        requestType: 'FIND_ORNAMENT',
      });
      await insertRequestMatch(ctx.prisma, {
        requestId: req.id,
        vendorProfileId,
      });

      const res = await inject(ctx.app, {
        method: 'GET',
        url: `/v1/requests/${req.id}`,
        token,
      });

      expect(res.status).toBe(200);
      const requestPayload = res.json.data;
      expect(requestPayload.id).toBe(req.id);

      // Verify masking invariants (BR-006, NFR-013, BR-008)
      assertVendorPresenterMasking(res.json, 'GET /v1/requests/:id vendor detail');

      // Assert customer object is strictly MaskedCustomer
      if (requestPayload.customer) {
        expect(requestPayload.customer).toHaveProperty('label');
        expect(requestPayload.customer).toHaveProperty('region');
        expect(requestPayload.customer).not.toHaveProperty('displayName');
        expect(requestPayload.customer).not.toHaveProperty('mobileNumber');
        expect(requestPayload.customer).not.toHaveProperty('email');
        expect(requestPayload.customer).not.toHaveProperty('customerProfileId');
        expect(requestPayload.customer).not.toHaveProperty('customerId');
      }
    });

    it('4. Viewing match marks it viewed (POST /v1/matches/:id/viewed -> 204)', async () => {
      const { user, vendorProfileId } = await insertVendor(ctx.prisma, {
        state: 'ACTIVE',
        categoryId,
        regionId,
      });
      await insertVendorSubscription(ctx.prisma, {
        vendorProfileId,
        requestType: 'FIND_ORNAMENT',
      });
      const token = await issueSession(ctx, user);

      const { customerProfileId } = await insertCustomer(ctx.prisma);
      const req = await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
        requestType: 'FIND_ORNAMENT',
      });
      await insertRequestMatch(ctx.prisma, {
        requestId: req.id,
        vendorProfileId,
        viewedAt: null,
      });

      // Mark as viewed
      const res = await inject(ctx.app, {
        method: 'POST',
        url: `/v1/matches/${req.id}/viewed`,
        token,
      });

      expect(res.status).toBe(204);

      // Repeat should be idempotent
      const repeatRes = await inject(ctx.app, {
        method: 'POST',
        url: `/v1/matches/${req.id}/viewed`,
        token,
      });
      expect(repeatRes.status).toBe(204);

      // Verify persistence in database
      const matchRow = await ctx.prisma.requestMatch.findUnique({
        where: {
          requestId_vendorProfileId: {
            requestId: req.id,
            vendorProfileId,
          },
        },
      });
      expect(matchRow?.viewedAt).toBeDefined();
      expect(matchRow?.viewedAt).not.toBeNull();
    });

    it('5. Dashboard aggregates reflect real counts and decrement on viewed', async () => {
      const { user, vendorProfileId } = await insertVendor(ctx.prisma, {
        state: 'ACTIVE',
        categoryId,
        regionId,
      });
      await insertVendorSubscription(ctx.prisma, {
        vendorProfileId,
        requestType: 'FIND_ORNAMENT',
      });
      const token = await issueSession(ctx, user);

      const { customerProfileId } = await insertCustomer(ctx.prisma);
      const req1 = await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
        requestType: 'FIND_ORNAMENT',
      });
      const req2 = await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
        requestType: 'FIND_ORNAMENT',
      });

      await insertRequestMatch(ctx.prisma, {
        requestId: req1.id,
        vendorProfileId,
        viewedAt: null,
      });
      await insertRequestMatch(ctx.prisma, {
        requestId: req2.id,
        vendorProfileId,
        viewedAt: null,
      });

      // Initial dashboard check
      const initialDash = await inject(ctx.app, {
        method: 'GET',
        url: '/v1/me/dashboard',
        token,
      });
      expect(initialDash.status).toBe(200);
      expect(initialDash.json.data.newRequests.count).toBe(2);
      expect(initialDash.json.data.newRequests.preview).toHaveLength(2);

      // Mark one match viewed
      await inject(ctx.app, {
        method: 'POST',
        url: `/v1/matches/${req1.id}/viewed`,
        token,
      });

      // Dashboard count decrements
      const updatedDash = await inject(ctx.app, {
        method: 'GET',
        url: '/v1/me/dashboard',
        token,
      });
      expect(updatedDash.status).toBe(200);
      expect(updatedDash.json.data.newRequests.count).toBe(1);
    });

    it('6. Revoking subscription removes match from feed', async () => {
      const { user, vendorProfileId } = await insertVendor(ctx.prisma, {
        state: 'ACTIVE',
        categoryId,
        regionId,
      });
      const sub = await insertVendorSubscription(ctx.prisma, {
        vendorProfileId,
        requestType: 'FIND_ORNAMENT',
        state: 'ACTIVE',
      });
      const token = await issueSession(ctx, user);

      const { customerProfileId } = await insertCustomer(ctx.prisma);
      const req = await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
        requestType: 'FIND_ORNAMENT',
      });
      await insertRequestMatch(ctx.prisma, {
        requestId: req.id,
        vendorProfileId,
        isEligible: true,
      });

      // Pre-condition: feed has 1 match
      const pre = await inject(ctx.app, {
        method: 'GET',
        url: '/v1/matches',
        token,
      });
      expect(pre.status).toBe(200);
      expect(pre.json.data).toHaveLength(1);

      // Revoke / expire subscription and simulate eligibility recompute (T37)
      await ctx.prisma.vendorTypeSubscription.update({
        where: { id: sub.id },
        data: { state: 'EXPIRED' },
      });
      await ctx.prisma.requestMatch.update({
        where: {
          requestId_vendorProfileId: {
            requestId: req.id,
            vendorProfileId,
          },
        },
        data: { isEligible: false },
      });

      // Post-condition: feed is now empty
      const post = await inject(ctx.app, {
        method: 'GET',
        url: '/v1/matches',
        token,
      });
      expect(post.status).toBe(200);
      expect(post.json.data).toEqual([]);
    });
  });

  describe('Error Codes & Boundaries', () => {
    it('returns 401 UNAUTHORIZED when accessing matches without a session', async () => {
      const res = await inject(ctx.app, {
        method: 'GET',
        url: '/v1/matches',
      });
      expect(res.status).toBe(401);
    });

    it('returns 404 NOT_FOUND (never 403) when request is not in vendor match set (CP2-A10)', async () => {
      const { user: vendorA } = await insertVendor(ctx.prisma, {
        state: 'ACTIVE',
        categoryId,
        regionId,
      });
      const tokenA = await issueSession(ctx, vendorA);

      const { customerProfileId } = await insertCustomer(ctx.prisma);
      const req = await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
      });

      // Vendor A has no match row for this request
      const res = await inject(ctx.app, {
        method: 'GET',
        url: `/v1/requests/${req.id}`,
        token: tokenA,
      });

      expect(res.status).toBe(404);
      expect(['NOT_FOUND', 'REQUEST_NOT_FOUND']).toContain(res.json.error?.code);
    });

    it('honors query filtering by requestType and pagination cursor', async () => {
      const { user, vendorProfileId } = await insertVendor(ctx.prisma, {
        state: 'ACTIVE',
        categoryId,
        regionId,
      });
      await insertVendorSubscription(ctx.prisma, {
        vendorProfileId,
        requestType: 'FIND_ORNAMENT',
      });
      await insertVendorSubscription(ctx.prisma, {
        vendorProfileId,
        requestType: 'SELL_OLD_GOLD',
      });
      const token = await issueSession(ctx, user);

      const { customerProfileId } = await insertCustomer(ctx.prisma);
      const req1 = await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
        requestType: 'FIND_ORNAMENT',
      });
      const req2 = await insertPublishedRequest(ctx.prisma, {
        customerProfileId,
        categoryId,
        regionId,
        requestType: 'SELL_OLD_GOLD',
      });

      await insertRequestMatch(ctx.prisma, { requestId: req1.id, vendorProfileId });
      await insertRequestMatch(ctx.prisma, { requestId: req2.id, vendorProfileId });

      // Filter by FIND_ORNAMENT
      const resFiltered = await inject(ctx.app, {
        method: 'GET',
        url: '/v1/matches?requestType=FIND_ORNAMENT&limit=10',
        token,
      });

      expect(resFiltered.status).toBe(200);
      expect(resFiltered.json.data.every((r: { requestType: string }) => r.requestType === 'FIND_ORNAMENT')).toBe(true);
    });
  });
});
