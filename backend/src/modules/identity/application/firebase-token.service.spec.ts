import { describe, expect, it } from 'vitest';
import { generateKeyPair, type JWTVerifyGetKey, SignJWT } from 'jose';
import { FirebaseTokenService } from './firebase-token.service';
import type { Env } from '../../../config/env';

describe('FirebaseTokenService', () => {
  const env = {
    FIREBASE_PROJECT_ID: 'test-project-123',
  } as Env;

  it('successfully verifies a valid RS256 Firebase ID token', async () => {
    const { publicKey, privateKey } = await generateKeyPair('RS256');
    const customJwks: JWTVerifyGetKey = async () => publicKey;

    const service = new FirebaseTokenService(env, customJwks);

    const now = Math.floor(Date.now() / 1000);
    const token = await new SignJWT({
      email: 'vendor@example.com',
      email_verified: true,
      phone_number: '+971501234567',
      name: 'Gold Trader LLC',
      picture: 'https://example.com/pic.jpg',
    })
      .setProtectedHeader({ alg: 'RS256', kid: 'test-key-1' })
      .setSubject('firebase-uid-999')
      .setIssuer('https://securetoken.google.com/test-project-123')
      .setAudience('test-project-123')
      .setIssuedAt(now)
      .setExpirationTime(now + 3600)
      .sign(privateKey);

    const claims = await service.verify(token);
    expect(claims).toEqual({
      uid: 'firebase-uid-999',
      email: 'vendor@example.com',
      emailVerified: true,
      phoneNumber: '+971501234567',
      name: 'Gold Trader LLC',
      picture: 'https://example.com/pic.jpg',
    });
  });

  it('rejects an expired token with TOKEN_EXPIRED', async () => {
    const { publicKey, privateKey } = await generateKeyPair('RS256');
    const customJwks: JWTVerifyGetKey = async () => publicKey;

    const service = new FirebaseTokenService(env, customJwks);

    const past = Math.floor(Date.now() / 1000) - 3600;
    const token = await new SignJWT({})
      .setProtectedHeader({ alg: 'RS256', kid: 'test-key-1' })
      .setSubject('firebase-uid-expired')
      .setIssuer('https://securetoken.google.com/test-project-123')
      .setAudience('test-project-123')
      .setIssuedAt(past - 100)
      .setExpirationTime(past)
      .sign(privateKey);

    await expect(service.verify(token)).rejects.toMatchObject({
      code: 'TOKEN_EXPIRED',
    });
  });

  it('rejects a token signed with wrong audience / project ID', async () => {
    const { publicKey, privateKey } = await generateKeyPair('RS256');
    const customJwks: JWTVerifyGetKey = async () => publicKey;

    const service = new FirebaseTokenService(env, customJwks);

    const now = Math.floor(Date.now() / 1000);
    const token = await new SignJWT({})
      .setProtectedHeader({ alg: 'RS256', kid: 'test-key-1' })
      .setSubject('firebase-uid-wrong-aud')
      .setIssuer('https://securetoken.google.com/wrong-project')
      .setAudience('wrong-project')
      .setIssuedAt(now)
      .setExpirationTime(now + 3600)
      .sign(privateKey);

    await expect(service.verify(token)).rejects.toMatchObject({
      code: 'UNAUTHENTICATED',
    });
  });

  it('rejects a token with invalid signature', async () => {
    const { publicKey } = await generateKeyPair('RS256');
    const otherPair = await generateKeyPair('RS256');
    const customJwks: JWTVerifyGetKey = async () => publicKey;

    const service = new FirebaseTokenService(env, customJwks);

    const now = Math.floor(Date.now() / 1000);
    const token = await new SignJWT({})
      .setProtectedHeader({ alg: 'RS256', kid: 'test-key-1' })
      .setSubject('firebase-uid-bad-sig')
      .setIssuer('https://securetoken.google.com/test-project-123')
      .setAudience('test-project-123')
      .setIssuedAt(now)
      .setExpirationTime(now + 3600)
      .sign(otherPair.privateKey);

    await expect(service.verify(token)).rejects.toMatchObject({
      code: 'UNAUTHENTICATED',
    });
  });

  it('rejects a non-RS256 algorithm token', async () => {
    const { publicKey } = await generateKeyPair('RS256');
    const customJwks: JWTVerifyGetKey = async () => publicKey;
    const service = new FirebaseTokenService(env, customJwks);

    const secret = new TextEncoder().encode('some-super-secret-key-that-is-long-enough');
    const now = Math.floor(Date.now() / 1000);
    const token = await new SignJWT({})
      .setProtectedHeader({ alg: 'HS256' })
      .setSubject('firebase-uid')
      .setIssuer('https://securetoken.google.com/test-project-123')
      .setAudience('test-project-123')
      .setIssuedAt(now)
      .setExpirationTime(now + 3600)
      .sign(secret);

    await expect(service.verify(token)).rejects.toMatchObject({
      code: 'UNAUTHENTICATED',
    });
  });
});
