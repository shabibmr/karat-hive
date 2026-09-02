import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { PrismaClient } from '@prisma/client';
import { AppModule } from '../../src/app.module';

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
  process.env.JWT_ACCESS_SECRET =
    process.env.JWT_ACCESS_SECRET ?? 'integration-test-access-secret';

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
      media, vendor_profile, customer_profile, admin_profile, "user"
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
      'content-type': 'application/json',
      ...(opts.token ? { authorization: `Bearer ${opts.token}` } : {}),
      ...(opts.headers ?? {}),
    },
  });
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
