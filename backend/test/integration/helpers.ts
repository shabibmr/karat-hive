import { randomUUID } from 'node:crypto';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { PrismaClient, type User } from '@prisma/client';
import { AppModule } from '../../src/app.module';
import { TokenService } from '../../src/modules/identity';
import { MediaService } from '../../src/modules/media';
import { OBJECT_STORAGE } from '../../src/platform/ports/storage.port';
import { LocalDiskStorageAdapter } from '../../src/platform/adapters/storage/local-disk-storage.adapter';
import { ENV, type Env } from '../../src/config/env';

export type TestApp = {
  app: NestFastifyApplication;
  prisma: PrismaClient;
  close: () => Promise<void>;
};

export async function bootTestApp(): Promise<TestApp> {
  process.env.NODE_ENV = 'test';
  process.env.OTP_DEV_MODE = 'fixed';
  process.env.OTP_FIXED_CODE = '000000';
  process.env.DEV_VERIFY_ENABLED = 'true';
  process.env.DEV_VERIFY_KEY = process.env.DEV_VERIFY_KEY ?? 'ci-dev-verify';
  process.env.JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET ?? 'integration-test-access-secret';

  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({ logger: false }),
    { logger: false },
  );
  await app.init();
  await app.getHttpAdapter().getInstance().ready();

  const prisma = new PrismaClient();
  await prisma.$connect();

  return {
    app,
    prisma,
    close: async () => {
      await prisma.$disconnect();
      await app.close();
    },
  };
}

export async function resetDb(prisma: PrismaClient): Promise<void> {
  await prisma.$executeRawUnsafe(`
    TRUNCATE TABLE
      audit_log, outbox_event, refresh_token, otp_challenge,
      vendor_document, vendor_category, vendor_region, vendor_type_subscription,
      request_match, request_media, offer, connection, request,
      media, vendor_profile, customer_profile, admin_profile, "user",
      rate_limit_bucket, idempotency_key
    RESTART IDENTITY CASCADE
  `);
}

export async function inject(
  app: NestFastifyApplication,
  opts: {
    method: string;
    url: string;
    body?: unknown;
    token?: string;
    headers?: Record<string, string>;
  },
): Promise<{ status: number; json: any }> {
  const res = await app.inject({
    method: opts.method as never,
    url: opts.url,
    payload: opts.body as never,
    headers: {
      ...(opts.body !== undefined ? { 'content-type': 'application/json' } : {}),
      ...(opts.token ? { authorization: `Bearer ${opts.token}` } : {}),
      ...(opts.headers ?? {}),
    },
  });
  if (res.statusCode >= 500) {
    // eslint-disable-next-line no-console
    console.error(`[TEST-INJECT-500] ${opts.method} ${opts.url} (${res.statusCode}):`, res.payload);
  }
  return { status: res.statusCode, json: res.json() };
}

/** taxonomy is required by register/vendor — seed a minimal tree if empty. */
export async function ensureTaxonomy(
  prisma: PrismaClient,
): Promise<{ categoryId: string; regionId: string }> {
  let category = await prisma.category.findFirst({ where: { isActive: true } });
  category ??= await prisma.category.create({
    data: { nameEn: 'Rings', nameAr: 'خواتم', displayOrder: 0 },
  });
  let region = await prisma.region.findFirst({ where: { isActive: true } });
  region ??= await prisma.region.create({
    data: { nameEn: 'Dubai', nameAr: 'دبي', displayOrder: 0 },
  });
  return { categoryId: category.id, regionId: region.id };
}

export async function issueSession(ctx: TestApp, user: User): Promise<string> {
  const tokens = ctx.app.get(TokenService);
  const access = await tokens.signAccess({
    sub: user.id,
    role: user.userType,
    ver: user.tokenVersion,
  });
  return access.token;
}

export async function insertAdmin(prisma: PrismaClient): Promise<User> {
  const suffix = randomUUID().slice(0, 8);
  return prisma.user.create({
    data: {
      mobileNumber: `+97150${suffix.slice(0, 7)}`,
      email: `admin-${suffix}@karathive.test`,
      userType: 'ADMIN',
      accountState: 'ACTIVE',
      preferredLanguage: 'en',
      termsVersion: '1.0',
      privacyVersion: '1.0',
      termsAcceptedAt: new Date(),
      adminProfile: { create: { displayName: 'Test Admin' } },
    },
  });
}

export async function insertVendor(
  prisma: PrismaClient,
  opts: {
    state: 'PENDING' | 'VERIFIED' | 'ACTIVE' | 'REJECTED';
    categoryId?: string;
    regionId?: string;
  },
): Promise<{ user: User; vendorProfileId: string }> {
  const suffix = randomUUID().slice(0, 8);
  const verificationState =
    opts.state === 'PENDING'
      ? 'PENDING_VERIFICATION'
      : opts.state === 'REJECTED'
        ? 'REJECTED'
        : 'VERIFIED';
  const user = await prisma.user.create({
    data: {
      mobileNumber: `+97155${suffix.slice(0, 7)}`,
      email: `vendor-${suffix}@karathive.test`,
      userType: 'VENDOR',
      accountState: 'ACTIVE',
      preferredLanguage: 'en',
      termsVersion: '1.0',
      privacyVersion: '1.0',
      termsAcceptedAt: new Date(),
      vendorProfile: {
        create: {
          legalBusinessName: `Vendor ${suffix} LLC`,
          tradingName: `Vendor ${suffix}`,
          tradeLicenceNumber: `CN-${suffix}`,
          licenceExpiryDate: new Date('2028-01-01'),
          businessAddress: 'Gold Souk',
          contactPersonName: 'Test',
          businessEmail: `vendor-${suffix}@karathive.test`,
          verificationState,
          activatedAt: opts.state === 'ACTIVE' ? new Date() : null,
          verifiedAt: opts.state === 'PENDING' ? null : new Date(),
        },
      },
    },
    include: { vendorProfile: true },
  });
  const vendorProfileId = user.vendorProfile!.id;
  if ((opts.state === 'VERIFIED' || opts.state === 'ACTIVE') && opts.categoryId && opts.regionId) {
    await prisma.vendorCategory.create({ data: { vendorProfileId, categoryId: opts.categoryId } });
    await prisma.vendorRegion.create({ data: { vendorProfileId, regionId: opts.regionId } });
  }
  if (opts.state === 'ACTIVE' && opts.categoryId && opts.regionId) {
    // already set activatedAt
  }
  return { user, vendorProfileId };
}

export async function putKycBytes(
  ctx: TestApp,
  viewerUser: User,
  apiKey: string,
  body: Buffer,
  contentType: string,
): Promise<void> {
  const media = ctx.app.get(MediaService);
  const storage = ctx.app.get(OBJECT_STORAGE) as LocalDiskStorageAdapter;
  const env = ctx.app.get(ENV) as Env;
  const viewer = {
    userId: viewerUser.id,
    role: viewerUser.userType,
    tokenVersion: viewerUser.tokenVersion,
    accountState: viewerUser.accountState,
    preferredLanguage: viewerUser.preferredLanguage,
    vendorProfileId: (await ctx.prisma.vendorProfile.findUnique({ where: { userId: viewerUser.id } }))
      ?.id ?? null,
    vendorVerificationState: null,
    vendorActivatedAt: null,
    customerProfileId: null,
    adminProfileId: null,
  };
  const objectKey = media.objectKeyFor('KYC_DOCUMENT', apiKey, viewer);
  await storage.putForTest(env.SUPABASE_STORAGE_BUCKET_KYC, objectKey, body, contentType);
}

export async function insertCustomer(
  prisma: PrismaClient,
  opts?: {
    mobileNumber?: string;
    email?: string;
    displayName?: string;
    defaultRegionId?: string;
  },
): Promise<{ user: User; customerProfileId: string }> {
  const suffix = randomUUID().slice(0, 8);
  const user = await prisma.user.create({
    data: {
      mobileNumber: opts?.mobileNumber ?? `+97150${suffix.slice(0, 7)}`,
      email: opts?.email ?? `customer-${suffix}@karathive.test`,
      userType: 'CUSTOMER',
      accountState: 'ACTIVE',
      preferredLanguage: 'en',
      termsVersion: '1.0',
      privacyVersion: '1.0',
      termsAcceptedAt: new Date(),
      customerProfile: {
        create: {
          displayName: opts?.displayName ?? `Customer ${suffix}`,
          defaultRegionId: opts?.defaultRegionId ?? null,
        },
      },
    },
    include: { customerProfile: true },
  });
  return { user, customerProfileId: user.customerProfile!.id };
}

export async function insertVendorSubscription(
  prisma: PrismaClient,
  opts: {
    vendorProfileId: string;
    requestType?: 'FIND_ORNAMENT' | 'SELL_OLD_GOLD' | 'GOLD_COIN' | 'GOLD_BULLION';
    state?: 'ACTIVE' | 'GRACE' | 'EXPIRED' | 'CANCELLED';
    periodStart?: Date;
    periodEnd?: Date;
    priceAed?: number;
  },
): Promise<{ id: string }> {
  const sub = await prisma.vendorTypeSubscription.create({
    data: {
      vendorProfileId: opts.vendorProfileId,
      requestType: opts.requestType ?? 'FIND_ORNAMENT',
      state: opts.state ?? 'ACTIVE',
      periodStart: opts.periodStart ?? new Date(),
      periodEnd: opts.periodEnd ?? new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      priceAed: opts.priceAed ?? 500,
    },
  });
  return { id: sub.id };
}

export async function insertPublishedRequest(
  prisma: PrismaClient,
  opts: {
    customerProfileId: string;
    categoryId: string;
    regionId: string;
    requestType?: 'FIND_ORNAMENT' | 'SELL_OLD_GOLD' | 'GOLD_COIN' | 'GOLD_BULLION';
    direction?: 'BUY' | 'SELL';
    notes?: string;
    budgetMin?: number;
    budgetMax?: number;
    purityKarat?: 'K24' | 'K22' | 'K21' | 'K18';
    weightGrams?: number;
  },
): Promise<{ id: string; reference: string }> {
  const suffix = randomUUID().slice(0, 6).toUpperCase();
  const reference = `REQ-2026-${suffix}`;
  const req = await prisma.request.create({
    data: {
      reference,
      customerProfileId: opts.customerProfileId,
      requestType: opts.requestType ?? 'FIND_ORNAMENT',
      direction: opts.direction ?? 'BUY',
      state: 'PUBLISHED',
      categoryId: opts.categoryId,
      regionId: opts.regionId,
      notes: opts.notes ?? 'Test request for matching',
      budgetMin: opts.budgetMin ?? 3000,
      budgetMax: opts.budgetMax ?? 5000,
      purityKarat: opts.purityKarat ?? 'K22',
      weightGrams: opts.weightGrams ?? 15,
      publishedAt: new Date(),
      expiresAt: new Date(Date.now() + 48 * 60 * 60 * 1000),
    },
  });
  return { id: req.id, reference };
}

export async function insertRequestMatch(
  prisma: PrismaClient,
  opts: {
    requestId: string;
    vendorProfileId: string;
    isEligible?: boolean;
    viewedAt?: Date | null;
  },
): Promise<{ id: string }> {
  const match = await prisma.requestMatch.create({
    data: {
      requestId: opts.requestId,
      vendorProfileId: opts.vendorProfileId,
      matchedAt: new Date(),
      isEligible: opts.isEligible ?? true,
      viewedAt: opts.viewedAt ?? null,
    },
  });
  return { id: match.id };
}

