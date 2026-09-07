import { describe, expect, it } from 'vitest';
import { generateKeyPair, SignJWT } from 'jose';
import { hashToken, isFirebaseToken, TokenService } from './token.service';
import type { Env } from '../../../config/env';
import type { PrismaService } from '../../../platform/db/prisma.service';
import { Clock } from '../../../shared/clock';

describe('TokenService & isFirebaseToken', () => {
  const env = {
    JWT_ACCESS_SECRET: 'super-secret-access-key-test-value-must-be-long',
    JWT_ACCESS_TTL_SECONDS: 900,
    FIREBASE_PROJECT_ID: 'karat-hive-app',
  } as Env;
  const prisma = {} as PrismaService;
  const clock = new Clock();
  const service = new TokenService(env, prisma, clock);

  it('correctly identifies RS256 token with Firebase issuer as Firebase token (G2-A05)', async () => {
    const { privateKey } = await generateKeyPair('RS256');
    const token = await new SignJWT({ sub: 'user-1' })
      .setProtectedHeader({ alg: 'RS256' })
      .setIssuer('https://securetoken.google.com/karat-hive-app')
      .sign(privateKey);

    expect(isFirebaseToken(token)).toBe(true);
    expect(service.isFirebaseToken(token)).toBe(true);
  });

  it('rejects RS256 token with foreign issuer as non-Firebase token (G2-A05)', async () => {
    const { privateKey } = await generateKeyPair('RS256');
    const token = await new SignJWT({ sub: 'user-1' })
      .setProtectedHeader({ alg: 'RS256' })
      .setIssuer('https://auth.example.com')
      .sign(privateKey);

    expect(isFirebaseToken(token)).toBe(false);
    expect(service.isFirebaseToken(token)).toBe(false);
  });

  it('correctly identifies HS256 token as non-Firebase token', async () => {
    const access = await service.signAccess({
      sub: 'user-1',
      role: 'VENDOR',
      ver: 1,
    });

    expect(isFirebaseToken(access.token)).toBe(false);
    expect(service.isFirebaseToken(access.token)).toBe(false);
  });

  it('returns false for invalid or garbage tokens', () => {
    expect(isFirebaseToken('not-a-token')).toBe(false);
    expect(isFirebaseToken('')).toBe(false);
    expect(isFirebaseToken('header.payload')).toBe(false);
    expect(service.isFirebaseToken('malformed.token.value')).toBe(false);
  });

  it('hashes token with SHA256', () => {
    const hash = hashToken('sample-token');
    expect(hash).toHaveLength(64);
    expect(hashToken('sample-token')).toBe(hash);
  });
});
