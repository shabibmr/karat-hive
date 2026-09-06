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

  it('lists the tree and honours includeInactive', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const token = await issueSession(ctx, admin);

    const root = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { nameEn: 'Bullion', nameAr: 'سبائك', displayOrder: 50 },
    });
    const rootId = root.json.data.id as string;
    await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { parentId: rootId, nameEn: 'Bars', nameAr: 'قضبان' },
    });
    await inject(ctx.app, {
      method: 'POST',
      url: `/v1/admin/categories/${rootId}/deactivate`,
      token,
    });

    // Admin default includes inactive nodes, nested under their parent.
    const all = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/admin/categories',
      token,
    });
    expect(all.status).toBe(200);
    const node = all.json.data.find((n: { id: string }) => n.id === rootId);
    expect(node).toBeDefined();
    expect(node.isActive).toBe(false);
    expect(node.children).toHaveLength(1);
    expect(node.children[0].nameEn).toBe('Bars');

    const activeOnly = await inject(ctx.app, {
      method: 'GET',
      url: '/v1/admin/categories?includeInactive=false',
      token,
    });
    expect(activeOnly.status).toBe(200);
    expect(activeOnly.json.data.some((n: { id: string }) => n.id === rootId)).toBe(false);
  });

  it('renames, reorders, and rejects a blank name', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const token = await issueSession(ctx, admin);

    const created = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { nameEn: 'Coins', nameAr: 'عملات', displayOrder: 7 },
    });
    const id = created.json.data.id as string;

    const renamed = await inject(ctx.app, {
      method: 'PATCH',
      url: `/v1/admin/categories/${id}`,
      token,
      body: { nameEn: 'Gold Coins', displayOrder: 3 },
    });
    expect(renamed.status).toBe(200);
    expect(renamed.json.data.nameEn).toBe('Gold Coins');
    expect(renamed.json.data.displayOrder).toBe(3);
    expect(renamed.json.data.nameAr).toBe('عملات');

    const blank = await inject(ctx.app, {
      method: 'PATCH',
      url: `/v1/admin/categories/${id}`,
      token,
      body: { nameEn: '   ' },
    });
    expect(blank.status).toBe(422);
    expect(blank.json.error.code).toBe('VALIDATION_FAILED');
    expect(blank.json.error.details.length).toBeGreaterThan(0);
  });

  it('reactivates a deactivated category via PATCH (BR-019: deactivate, never delete)', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const token = await issueSession(ctx, admin);

    const created = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { nameEn: 'Scrap', nameAr: 'خردة' },
    });
    const id = created.json.data.id as string;

    const off = await inject(ctx.app, {
      method: 'POST',
      url: `/v1/admin/categories/${id}/deactivate`,
      token,
    });
    expect(off.status).toBe(200);
    expect(off.json.data.isActive).toBe(false);

    const on = await inject(ctx.app, {
      method: 'PATCH',
      url: `/v1/admin/categories/${id}`,
      token,
      body: { isActive: true },
    });
    expect(on.status).toBe(200);
    expect(on.json.data.isActive).toBe(true);
  });

  it('exposes no DELETE route (BR-019)', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const token = await issueSession(ctx, admin);
    const created = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { nameEn: 'Doomed', nameAr: 'محكوم' },
    });
    const id = created.json.data.id as string;

    const res = await inject(ctx.app, {
      method: 'DELETE',
      url: `/v1/admin/categories/${id}`,
      token,
    });
    expect(res.status).toBe(404);

    // The category is still there — nothing was removed.
    const still = await ctx.prisma.category.findUnique({ where: { id } });
    expect(still).not.toBeNull();
  });

  it('rejects a malformed id with 422 rather than 500', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const token = await issueSession(ctx, admin);

    const res = await inject(ctx.app, {
      method: 'PATCH',
      url: '/v1/admin/categories/not-a-uuid',
      token,
      body: { nameEn: 'Whatever' },
    });
    expect(res.status).toBe(422);
    expect(res.json.error.code).toBe('VALIDATION_FAILED');
  });

  it('writes an audit row for each mutation', async () => {
    const admin = await insertAdmin(ctx.prisma);
    const token = await issueSession(ctx, admin);

    const created = await inject(ctx.app, {
      method: 'POST',
      url: '/v1/admin/categories',
      token,
      body: { nameEn: 'Audited', nameAr: 'مدقق' },
    });
    const id = created.json.data.id as string;
    await inject(ctx.app, {
      method: 'PATCH',
      url: `/v1/admin/categories/${id}`,
      token,
      body: { nameEn: 'Audited Twice' },
    });
    await inject(ctx.app, {
      method: 'POST',
      url: `/v1/admin/categories/${id}/deactivate`,
      token,
    });

    const actions = (
      await ctx.prisma.auditLog.findMany({ where: { entityId: id } })
    ).map((row) => row.action);
    expect(actions).toContain('CATEGORY_CREATE');
    expect(actions).toContain('CATEGORY_UPDATE');
    expect(actions).toContain('CATEGORY_DEACTIVATE');
  });
});
