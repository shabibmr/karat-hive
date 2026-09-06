import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import {
  bootTestApp,
  ensureTaxonomy,
  inject,
  insertVendor,
  issueSession,
  putKycBytes,
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

async function intent(token: string, byteSize = 12) {
  return inject(ctx.app, {
    method: 'POST',
    url: '/v1/media/upload-intent',
    token,
    headers: { 'idempotency-key': randomUUID() },
    body: {
      purpose: 'KYC_DOCUMENT',
      contentType: 'application/pdf',
      byteSize,
    },
  });
}

describe('vendor media + documents (minted JWT)', () => {
  it('rejects upload-intent without Idempotency-Key', async () => {
    const { user } = await insertVendor(ctx.prisma, { state: 'PENDING' });
    const token = await issueSession(ctx, user);
    const res = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/media/upload-intent',
      token,
      body: { purpose: 'KYC_DOCUMENT', contentType: 'application/pdf', byteSize: 12 },
    });
    expect(res.status).toBe(400);
    expect(res.json.error.code).toBe('IDEMPOTENCY_KEY_REQUIRED');
  });

  it('uploads both mandatory KYC docs, audits intent, emits vendor.documents.submitted', async () => {
    const { user } = await insertVendor(ctx.prisma, { state: 'PENDING' });
    const token = await issueSession(ctx, user);

    for (const documentType of ['TRADE_LICENCE', 'EMIRATES_ID'] as const) {
      const bytes = Buffer.from(`pdf-${documentType}`);
      const started = await intent(token, bytes.length);
      expect(started.status).toBe(201);
      const key = started.json.data.key as string;
      await putKycBytes(ctx, user, key, bytes, 'application/pdf');
      const complete = await inject(ctx.app, {
        method: 'POST',
        url: `/v1/media/${key}/complete`,
        token,
      });
      expect(complete.status).toBe(200);
      expect(complete.json.data.state).toBe('READY');
      const attached = await inject(ctx.app, {
        method: 'POST',
        url: '/v1/me/vendor/documents',
        token,
        body: { documentType, mediaKey: key },
      });
      expect(attached.status).toBe(200);
    }

    const intents = await ctx.prisma.auditLog.findMany({ where: { action: 'KYC_UPLOAD_INTENT' } });
    expect(intents).toHaveLength(2);
    const submitted = await ctx.prisma.outboxEvent.findMany({
      where: { eventType: 'vendor.documents.submitted' },
    });
    expect(submitted.length).toBeGreaterThanOrEqual(1);
  });

  it('complete with size mismatch is 409 UPLOAD_NOT_COMPLETED', async () => {
    const { user } = await insertVendor(ctx.prisma, { state: 'PENDING' });
    const token = await issueSession(ctx, user);
    const started = await intent(token, 100);
    const key = started.json.data.key as string;
    await putKycBytes(ctx, user, key, Buffer.from('short'), 'application/pdf');
    const complete = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/media/${key}/complete`,
      token,
    });
    expect(complete.status).toBe(409);
    expect(complete.json.error.code).toBe('UPLOAD_NOT_COMPLETED');
  });

  it('deletes unattached media and rejects delete after attach', async () => {
    const { user } = await insertVendor(ctx.prisma, { state: 'PENDING' });
    const token = await issueSession(ctx, user);
    const bytes = Buffer.from('pdf-unattached');
    const started = await intent(token, bytes.length);
    const key = started.json.data.key as string;
    await putKycBytes(ctx, user, key, bytes, 'application/pdf');
    await inject(ctx.app, { method: 'POST', url: `/v1/media/${key}/complete`, token });

    const del = await inject(ctx.app, { method: 'DELETE', url: `/v1/media/${key}`, token });
    expect(del.status).toBe(204);

    const bytes2 = Buffer.from('pdf-attached');
    const started2 = await intent(token, bytes2.length);
    const key2 = started2.json.data.key as string;
    await putKycBytes(ctx, user, key2, bytes2, 'application/pdf');
    await inject(ctx.app, { method: 'POST', url: `/v1/media/${key2}/complete`, token });
    await inject(ctx.app, {
      method: 'POST',
      url: '/v1/me/vendor/documents',
      token,
      body: { documentType: 'TRADE_LICENCE', mediaKey: key2 },
    });
    const del2 = await inject(ctx.app, { method: 'DELETE', url: `/v1/media/${key2}`, token });
    expect(del2.status).toBe(409);
    expect(del2.json.error.code).toBe('CONFLICT');
  });

  it('refuses categories before VERIFIED and serves dashboard when ACTIVE', async () => {
    const pending = await insertVendor(ctx.prisma, { state: 'PENDING' });
    const pendingToken = await issueSession(ctx, pending.user);
    const early = await inject(ctx.app, {
      method: 'PUT',
      url: '/v1/me/vendor/categories',
      token: pendingToken,
      body: { categoryIds: [categoryId] },
    });
    expect(early.status).toBe(403);
    expect(early.json.error.code).toBe('VENDOR_NOT_ACTIVE');

    const active = await insertVendor(ctx.prisma, {
      state: 'ACTIVE',
      categoryId,
      regionId,
    });
    const activeToken = await issueSession(ctx, active.user);
    const dash = await inject(ctx.app, { method: 'GET', url: '/v1/me/dashboard', token: activeToken });
    expect(dash.status).toBe(200);
    expect(dash.json.data.newRequests.count).toBe(0);
  });

  it('resubmit is 409 from PENDING and 200 from REJECTED', async () => {
    const pending = await insertVendor(ctx.prisma, { state: 'PENDING' });
    const pendingToken = await issueSession(ctx, pending.user);
    const bad = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/me/vendor/resubmit',
      token: pendingToken,
    });
    expect(bad.status).toBe(409);

    const rejected = await insertVendor(ctx.prisma, { state: 'REJECTED' });
    const rejectedToken = await issueSession(ctx, rejected.user);
    const ok = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/me/vendor/resubmit',
      token: rejectedToken,
    });
    expect(ok.status).toBe(200);
    expect(ok.json.data.lifecycle).toBe('PENDING_VERIFICATION');
  });
});
