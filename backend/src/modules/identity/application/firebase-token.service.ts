import { Inject, Injectable, Optional } from '@nestjs/common';
import { createRemoteJWKSet, errors, jwtVerify, type JWTVerifyGetKey } from 'jose';
import { ENV, type Env } from '../../../config/env';
import { IdentityAuthError } from '../domain/identity-auth-error';

export type FirebaseClaims = {
  uid: string;
  email?: string;
  emailVerified?: boolean;
  phoneNumber?: string;
  name?: string;
  picture?: string;
};

export const FIREBASE_JWKS_URL =
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';

@Injectable()
export class FirebaseTokenService {
  private readonly jwks: JWTVerifyGetKey;

  constructor(
    @Inject(ENV) private readonly env: Env,
    @Optional() customJwks?: JWTVerifyGetKey,
  ) {
    this.jwks = customJwks ?? createRemoteJWKSet(new URL(FIREBASE_JWKS_URL));
  }

  async verify(token: string): Promise<FirebaseClaims> {
    try {
      const projectId = this.env.FIREBASE_PROJECT_ID;
      const { payload } = await jwtVerify(token, this.jwks, {
        issuer: `https://securetoken.google.com/${projectId}`,
        audience: projectId,
        algorithms: ['RS256'],
      });

      const sub = payload.sub;
      if (!sub || typeof sub !== 'string') {
        throw new IdentityAuthError('UNAUTHENTICATED');
      }

      return {
        uid: sub,
        email: typeof payload['email'] === 'string' ? payload['email'] : undefined,
        emailVerified:
          typeof payload['email_verified'] === 'boolean'
            ? payload['email_verified']
            : undefined,
        phoneNumber:
          typeof payload['phone_number'] === 'string'
            ? payload['phone_number']
            : undefined,
        name: typeof payload['name'] === 'string' ? payload['name'] : undefined,
        picture: typeof payload['picture'] === 'string' ? payload['picture'] : undefined,
      };
    } catch (error: unknown) {
      if (error instanceof IdentityAuthError) throw error;
      if (error instanceof errors.JWTExpired) {
        throw new IdentityAuthError('TOKEN_EXPIRED');
      }
      throw new IdentityAuthError('UNAUTHENTICATED');
    }
  }
}
