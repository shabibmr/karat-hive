import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import {
  bootTestApp,
  ensureTaxonomy,
  inject,
  insertAdmin,
  insertVendor,
  issueSession,
  resetDb,
  type TestApp,
} from './helpers';

let ctx: TestApp;

beforeAll(async () => {
  ctx = await bootTestApp();
});

afterAll(async () => {
  await ctx.close();
});

beforeEach(async () => {
  await resetDb(ctx.prisma);
  await ensureTaxonomy(ctx.prisma);
});

describe('admin vendor verification (minted JWT)', () => {
  it('unauthenticated GET verification-queue is 401', async () => {
    const res = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/admin/verification-queue',
    });
    expect(res.status).toBe(401);
  });

  it('vendor token on /v1/admin/verification-queue is 404 NOT_FOUND', async () => {
    const { user } = await insertVendor(ctx.prisma, { state: 'PENDING' });
    const token = await issueSession(ctx, user);
    const res = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/admin/verification-queue',
      token,
    });
    expect(res.status).toBe(404);
    expect(res.json.error.code).toBe('NOT_FOUND');
  });

  it('lists pending vendors oldest-first and applies verify / reject / request-info', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const adminToken = await issueSession(ctx, admin);

    const older = await insertVendor(ctx.prisma, { state: 'PENDING' });
    await ctx.prisma.vendorProfile.update({
      where: { id: older.vendorProfileId },
      data: { createdAt: new Date('2026-01-01T00:00:00Z') },
    });

    const newer = await insertVendor(ctx.prisma, { state: 'PENDING' });
    await ctx.prisma.vendorProfile.update({
      where: { id: newer.vendorProfileId },
      data: { createdAt: new Date('2026-01-02T00:00:00Z') },
    });

    const queue = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/admin/verification-queue',
      token: adminToken,
    });
    expect(queue.status).toBe(200);
    expect(queue.json.data).toHaveLength(2);
    expect(queue.json.data[0].id).toBe(older.vendorProfileId);
    expect(queue.json.data[0].oldestWaitingHours).toBeGreaterThanOrEqual(0);

    const requestInfo = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/admin/vendors/${newer.vendorProfileId}/request-info`,
      token: adminToken,
      body: { message: 'Please upload a clearer trade licence scan.' },
    });
    expect(requestInfo.status).toBe(200);

    const detail = await inject(ctx.app, {
      method: 'GET',
      url: `/v1/admin/vendors/${newer.vendorProfileId}`,
      token: adminToken,
    });
    expect(detail.status).toBe(200);
    expect(detail.json.data.verificationMessage).toBe(
      'Please upload a clearer trade licence scan.',
    );
    expect(detail.json.data.verificationState).toBe('PENDING_VERIFICATION');

    const reject = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/admin/vendors/${newer.vendorProfileId}/reject`,
      token: adminToken,
      body: { rationale: 'Licence document is illegible.' },
    });
    expect(reject.status).toBe(200);

    const rejectedProfile = await ctx.prisma.vendorProfile.findUnique({
      where: { id: newer.vendorProfileId },
    });
    expect(rejectedProfile?.verificationState).toBe('REJECTED');

    const verify = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/admin/vendors/${older.vendorProfileId}/verify`,
      token: adminToken,
      body: { rationale: 'All KYC documents acceptable.' },
    });
    expect(verify.status).toBe(200);

    const verifiedProfile = await ctx.prisma.vendorProfile.findUnique({
      where: { id: older.vendorProfileId },
    });
    expect(verifiedProfile?.verificationState).toBe('VERIFIED');
    expect(verifiedProfile?.verifiedByAdminId).toBeTruthy();

    const auditRows = await ctx.prisma.auditLog.findMany({
      where: { entityId: older.vendorProfileId },
      orderBy: { occurredAt: 'asc' },
    });
    expect(auditRows.some((row) => row.action === 'VENDOR_VERIFIED')).toBe(true);
  });

  it('filters vendor list by verificationState', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const adminToken = await issueSession(ctx, admin);
    await insertVendor(ctx.prisma, { state: 'PENDING' });
    const { categoryId, regionId } = await ensureTaxonomy(ctx.prisma);
    await insertVendor(ctx.prisma, { state: 'VERIFIED', categoryId, regionId });

    const pendingOnly = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/admin/vendors?verificationState=PENDING_VERIFICATION',
      token: adminToken,
    });
    expect(pendingOnly.status).toBe(200);
    expect(pendingOnly.json.data).toHaveLength(1);
    expect(pendingOnly.json.data[0].verificationState).toBe('PENDING_VERIFICATION');
    expect(pendingOnly.json.meta.hasMore).toBe(false);
  });
});
