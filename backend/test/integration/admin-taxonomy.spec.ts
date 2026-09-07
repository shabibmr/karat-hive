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

  it('admin creates root + child, rejects a third level, persists icon', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const token = await issueSession(ctx, admin);

    const root = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { nameEn: 'Jewellery', nameAr: 'مجوهرات', icon: 'diamond', displayOrder: 1 },
    });
    expect(root.status).toBe(201);
    expect(root.json.data.icon).toBe('diamond');
    const rootId = root.json.data.id as string;

    const child = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { parentId: rootId, nameEn: 'Rings', nameAr: 'خواتم' },
    });
    expect(child.status).toBe(201);
    const childId = child.json.data.id as string;

    const grandchild = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { parentId: childId, nameEn: 'Too Deep', nameAr: 'عميق' },
    });
    expect(grandchild.status).toBe(422);
    expect(grandchild.json.error.code).toBe('VALIDATION_FAILED');
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
