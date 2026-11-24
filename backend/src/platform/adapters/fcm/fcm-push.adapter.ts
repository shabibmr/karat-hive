import { Inject, Injectable, Logger } from '@nestjs/common';
import { importPKCS8, SignJWT } from 'jose';
import { ENV, type Env } from '../../../config/env';
import type { PushDeliveryResult, PushMessage, PushTarget } from '../../ports/push.port';

const FCM_LEGACY_URL = 'https://fcm.googleapis.com/fcm/send';
const GOOGLE_TOKEN_URL = 'https://oauth2.googleapis.com/token';
const FCM_SCOPES = 'https://www.googleapis.com/auth/firebase.messaging';

/**
 * FCM adapter for ANDROID device tokens. Credentials absent → stub SENT (G2-N03).
 * Supports the modern FCM HTTP v1 API with OAuth2 / Service Account authorization,
 * while maintaining backward-compatible fallback to legacy server key.
 * In-app persist is the caller's job (FR-SYS-008.6).
 */
@Injectable()
export class FcmPushAdapter {
  private readonly logger = new Logger(FcmPushAdapter.name);
  private cachedAccessToken: { token: string; expiresAtMs: number } | null = null;

  constructor(@Inject(ENV) private readonly env: Env) {}

  isConfigured(): boolean {
    return Boolean(
      this.env.FCM_BEARER_TOKEN ||
        (this.env.FCM_SERVICE_ACCOUNT_EMAIL && this.env.FCM_SERVICE_ACCOUNT_PRIVATE_KEY) ||
        this.env.FCM_SERVER_KEY,
    );
  }

  isHttpV1(): boolean {
    return Boolean(
      this.env.FCM_BEARER_TOKEN ||
        (this.env.FCM_SERVICE_ACCOUNT_EMAIL && this.env.FCM_SERVICE_ACCOUNT_PRIVATE_KEY),
    );
  }

  async send(target: PushTarget, message: PushMessage): Promise<PushDeliveryResult> {
    if (!this.isConfigured()) {
      this.logger.warn('FCM credentials absent; stubbing push');
      return { status: 'SENT', providerRef: 'stub:fcm' };
    }

    if (this.isHttpV1()) {
      return this.sendHttpV1(target, message);
    }

    return this.sendLegacy(target, message);
  }

  private async getAccessToken(): Promise<string> {
    if (this.env.FCM_BEARER_TOKEN) {
      return this.env.FCM_BEARER_TOKEN;
    }

    const email = this.env.FCM_SERVICE_ACCOUNT_EMAIL;
    const privateKeyPem = this.env.FCM_SERVICE_ACCOUNT_PRIVATE_KEY;
    if (!email || !privateKeyPem) {
      throw new Error('FCM service account credentials not configured');
    }

    const now = Date.now();
    if (this.cachedAccessToken && this.cachedAccessToken.expiresAtMs > now + 60_000) {
      return this.cachedAccessToken.token;
    }

    const formattedKey = privateKeyPem.replace(/\\n/g, '\n');
    const privateKey = await importPKCS8(formattedKey, 'RS256');
    const nowSeconds = Math.floor(now / 1000);

    const assertion = await new SignJWT({
      scope: FCM_SCOPES,
    })
      .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
      .setIssuer(email)
      .setSubject(email)
      .setAudience(GOOGLE_TOKEN_URL)
      .setIssuedAt(nowSeconds)
      .setExpirationTime(nowSeconds + 3600)
      .sign(privateKey);

    const tokenResponse = await fetch(GOOGLE_TOKEN_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion,
      }),
    });

    if (!tokenResponse.ok) {
      const text = await tokenResponse.text().catch(() => '');
      throw new Error(`Google OAuth2 token fetch failed (${tokenResponse.status}): ${text}`.trim());
    }

    const tokenJson = (await tokenResponse.json()) as { access_token: string; expires_in?: number };
    const expiresInMs = (tokenJson.expires_in ?? 3600) * 1000;
    this.cachedAccessToken = {
      token: tokenJson.access_token,
      expiresAtMs: now + expiresInMs,
    };

    return tokenJson.access_token;
  }

  private async sendHttpV1(target: PushTarget, message: PushMessage): Promise<PushDeliveryResult> {
    const projectId = this.env.FIREBASE_PROJECT_ID || 'karat-hive-app';
    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    try {
      const accessToken = await this.getAccessToken();

      const dataPayload: Record<string, string> = {
        deepLink: message.deepLink,
      };
      if (message.data) {
        for (const [k, v] of Object.entries(message.data)) {
          if (v !== undefined && v !== null) {
            dataPayload[k] = String(v);
          }
        }
      }

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: target.token,
            notification: {
              title: message.title,
              body: message.body,
            },
            data: dataPayload,
          },
        }),
      });

      if (!response.ok) {
        const text = await response.text().catch(() => '');
        return { status: 'FAILED', error: `FCM v1 HTTP ${response.status} ${text}`.trim() };
      }

      const body = (await response.json().catch(() => ({}))) as { name?: string };
      return { status: 'SENT', providerRef: body.name ?? 'fcm-v1' };
    } catch (error: unknown) {
      const msg = error instanceof Error ? error.message : String(error);
      return { status: 'FAILED', error: msg };
    }
  }

  private async sendLegacy(target: PushTarget, message: PushMessage): Promise<PushDeliveryResult> {
    try {
      const response = await fetch(FCM_LEGACY_URL, {
        method: 'POST',
        headers: {
          Authorization: `key=${this.env.FCM_SERVER_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          to: target.token,
          notification: { title: message.title, body: message.body },
          data: { deepLink: message.deepLink, ...message.data },
        }),
      });
      if (!response.ok) {
        const text = await response.text().catch(() => '');
        return { status: 'FAILED', error: `FCM HTTP ${response.status} ${text}`.trim() };
      }
      const body = (await response.json().catch(() => ({}))) as { message_id?: number | string };
      return { status: 'SENT', providerRef: String(body.message_id ?? 'fcm') };
    } catch (error: unknown) {
      const msg = error instanceof Error ? error.message : String(error);
      return { status: 'FAILED', error: msg };
    }
  }
}
