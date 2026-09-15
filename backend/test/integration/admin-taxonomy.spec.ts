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

describe('admin taxonomy (minted JWT)', () => {
  it('unauthenticated GET is 401', async () => {
    const res = await inject(ctx.app, { method: 'GET', url: '/v1/admin/categories' });
    expect(res.status).toBe(401);
  });

  it('vendor token on /v1/admin/categories is 404 NOT_FOUND', async () => {
    const { user } = await insertVendor(ctx.prisma, { state: 'PENDING' });
    const token = await issueSession(ctx, user);
    const res = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/admin/categories',
      token,
    });
    expect(res.status).toBe(404);
    expect(res.json.error.code).toBe('NOT_FOUND');
  });

  it('admin creates, updates, and lists a flat category, persisting icon', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const token = await issueSession(ctx, admin);

    const created = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { nameEn: 'Jewellery', nameAr: 'مجوهرات', icon: 'diamond', displayOrder: 1 },
    });
    expect(created.status).toBe(201);
    expect(created.json.data.icon).toBe('diamond');
    expect(created.json.data.parentId).toBeUndefined();
    expect(created.json.data.children).toBeUndefined();
    const categoryId = created.json.data.id as string;

    const updated = await inject(ctx.app, {
      method: 'PATCH',
      url: `/v1/admin/categories/${categoryId}`,
      token,
      body: { nameEn: 'Fine Jewellery' },
    });
    expect(updated.status).toBe(200);
    expect(updated.json.data.nameEn).toBe('Fine Jewellery');

    const list = await inject(ctx.app, { method: 'GET', url: '/v1/admin/categories', token });
    expect(list.status).toBe(200);
    expect(list.json.data.some((c: { id: string }) => c.id === categoryId)).toBe(true);
  });

  it('deactivates an in-use category and keeps vendor associations', async () => {
    const { categoryId } = await ensureTaxonomy(ctx.prisma);
    const vendor = await insertVendor(ctx.prisma, {
      state: 'VERIFIED',
      categoryId,
      regionId: (await ctx.prisma.region.findFirstOrThrow()).id,
    });
    expect(vendor.vendorProfileId).toBeTruthy();

    const admin = await insertAdmin(ctx.prisma);
    const token = await issueSession(ctx, admin);
    const res = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/admin/categories/${categoryId}/deactivate`,
      token,
    });
    expect(res.status).toBe(200);
    expect(res.json.data.isActive).toBe(false);
    const joins = await ctx.prisma.vendorCategory.count({ where: { categoryId } });
    expect(joins).toBe(1);
  });
});
