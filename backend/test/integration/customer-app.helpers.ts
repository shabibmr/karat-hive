import { randomUUID } from 'node:crypto';
import { Global, Module } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { PrismaClient } from '@prisma/client';
import { generateKeyPair, SignJWT, type JWTVerifyGetKey } from 'jose';
import { AppModule } from '../../src/app.module';
import { FcmPushAdapter } from '../../src/platform/adapters/fcm/fcm-push.adapter';
import { ApnsPushAdapter } from '../../src/platform/adapters/apns/apns-push.adapter';
import { FirebaseTokenService } from '../../src/modules/identity/application/firebase-token.service';
import { TokenService } from '../../src/modules/identity';

/**
 * The committed tree wires `RoutedPushAdapter` (bound to `PUSH_GATEWAY` in
 * `PlatformModule`) with constructor deps on `FcmPushAdapter` / `ApnsPushAdapter`,
 * but never registers those two as providers — so `AppModule` cannot bootstrap.
 * See the bug note in the Customer-App test-coverage report. This test-only global
 * module supplies them so integration coverage can run; it changes no app code.
 */
@Global()
@Module({
  providers: [FcmPushAdapter, ApnsPushAdapter],
  exports: [FcmPushAdapter, ApnsPushAdapter],
})
class PushAdapterShimModule {}

@Module({ imports: [PushAdapterShimModule, AppModule] })
class CustomerTestRootModule {}

export const TEST_FIREBASE_PROJECT_ID = 'karat-hive-app';

export type CustomerTestApp = {
  app: NestFastifyApplication;
  prisma: PrismaClient;
  /** Mint a Firebase/Google ID token the booted app will actually verify. */
  mintGoogleToken: (claims: {
    uid: string;
    email?: string;
    emailVerified?: boolean;
    phoneNumber?: string;
    name?: string;
    expiresInSeconds?: number;
  }) => Promise<string>;
  close: () => Promise<void>;
};

export async function bootCustomerTestApp(): Promise<CustomerTestApp> {
  process.env.NODE_ENV = 'test';
  process.env.OTP_DEV_MODE = 'fixed';
  process.env.OTP_FIXED_CODE = '000000';
  process.env.DEV_VERIFY_ENABLED = 'true';
  process.env.DEV_VERIFY_KEY = process.env.DEV_VERIFY_KEY ?? 'ci-dev-verify';
  process.env.JWT_ACCESS_SECRET =
    process.env.JWT_ACCESS_SECRET ?? 'integration-test-access-secret';
  process.env.FIREBASE_PROJECT_ID = TEST_FIREBASE_PROJECT_ID;

  const { publicKey, privateKey } = await generateKeyPair('RS256');
  const localJwks: JWTVerifyGetKey = async () => publicKey;

  const debug = process.env.KH_TEST_DEBUG_LOG === '1';
  const app = await NestFactory.create<NestFastifyApplication>(
    CustomerTestRootModule,
    new FastifyAdapter({ logger: false }),
    { logger: debug ? ['error', 'warn', 'log'] : false, abortOnError: false },
  );
  await app.init();
  await app.getHttpAdapter().getInstance().ready();

  // Point the real verifier at a local key pair instead of Google's remote JWKS.
  // `jwks` is `private readonly` in TS only; at runtime it is a plain field.
  const verifier = app.get(FirebaseTokenService);
  (verifier as unknown as { jwks: JWTVerifyGetKey }).jwks = localJwks;

  const prisma = new PrismaClient();
  await prisma.$connect();

  return {
    app,
    prisma,
    mintGoogleToken: async (claims) => {
      const now = Math.floor(Date.now() / 1000);
      const jwt = new SignJWT({
        ...(claims.email ? { email: claims.email } : {}),
        ...(claims.emailVerified !== undefined ? { email_verified: claims.emailVerified } : {}),
        ...(claims.phoneNumber ? { phone_number: claims.phoneNumber } : {}),
        ...(claims.name ? { name: claims.name } : {}),
      })
        .setProtectedHeader({ alg: 'RS256', kid: 'test-key-1' })
        .setSubject(claims.uid)
        .setIssuer(`https://securetoken.google.com/${TEST_FIREBASE_PROJECT_ID}`)
        .setAudience(TEST_FIREBASE_PROJECT_ID)
        .setIssuedAt(now)
        .setExpirationTime(now + (claims.expiresInSeconds ?? 3600));
      return jwt.sign(privateKey);
    },
    close: async () => {
      await prisma.$disconnect();
      await app.close();
    },
  };
}

export async function resetCustomerDb(prisma: PrismaClient): Promise<void> {
  await prisma.$executeRawUnsafe(`
    TRUNCATE TABLE
      audit_log, admin_note, data_subject_request,
      outbox_event, outbox_consumer,
      refresh_token, otp_challenge, oauth_binding, device,
      notification, notification_delivery, notification_preference,
      review, abuse_report, contact_event, filter_preset,
      connection, offer_media, offer_revision, offer,
      request_match, request_media, request,
      vendor_document, vendor_category, vendor_region, vendor_type_subscription,
      media, vendor_profile, customer_profile, admin_profile, "user",
      rate_limit_bucket, idempotency_key
    RESTART IDENTITY CASCADE
  `);
}

export async function injectJson(
  app: NestFastifyApplication,
  opts: {
    method: string;
    url: string;
    body?: unknown;
    token?: string;
    headers?: Record<string, string>;
  },
): Promise<{ status: number; json: any; raw: string }> {
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
  let json: any = undefined;
  try {
    json = res.json();
  } catch {
    json = undefined;
  }
  if (res.statusCode >= 500) {
    // eslint-disable-next-line no-console
    console.error(`[TEST-INJECT-500] ${opts.method} ${opts.url}:`, res.payload);
  }
  return { status: res.statusCode, json, raw: res.payload };
}

export function uniqueSuffix(): string {
  return randomUUID().slice(0, 8);
}

export async function issueAccessToken(
  app: NestFastifyApplication,
  user: { id: string; userType: string; tokenVersion: number },
): Promise<string> {
  const tokens = app.get(TokenService);
  const access = await tokens.signAccess({
    sub: user.id,
    role: user.userType as never,
    ver: user.tokenVersion,
  });
  return access.token;
}

export async function insertCustomer(
  prisma: PrismaClient,
  opts?: { displayName?: string },
): Promise<{ userId: string; customerProfileId: string; user: any }> {
  const suffix = uniqueSuffix();
  const user = await prisma.user.create({
    data: {
      mobileNumber: `+97152${suffix.slice(0, 7)}`,
      email: `customer-${suffix}@karathive.test`,
      userType: 'CUSTOMER',
      accountState: 'ACTIVE',
      preferredLanguage: 'en',
      termsVersion: '1.0',
      privacyVersion: '1.0',
      termsAcceptedAt: new Date(),
      mobileVerifiedAt: new Date(),
      customerProfile: {
        create: { displayName: opts?.displayName ?? `Customer ${suffix}` },
      },
    },
    include: { customerProfile: true },
  });
  return { userId: user.id, customerProfileId: user.customerProfile!.id, user };
}

/** Every JSON key that appears anywhere in `value` (objects + arrays, recursively). */
export function collectKeys(value: unknown, acc = new Set<string>()): Set<string> {
  if (value === null || typeof value !== 'object') return acc;
  if (Array.isArray(value)) {
    for (const item of value) collectKeys(item, acc);
    return acc;
  }
  for (const [key, child] of Object.entries(value as Record<string, unknown>)) {
    acc.add(key);
    collectKeys(child, acc);
  }
  return acc;
}

/** True when `key` is present anywhere in `value` (regardless of the value at that key). */
export function deepHasKey(value: unknown, key: string): boolean {
  return collectKeys(value).has(key);
}
