import { Inject, Injectable, Logger } from '@nestjs/common';
import { ENV, type Env } from '../../../config/env';
import type { PushDeliveryResult, PushMessage, PushTarget } from '../../ports/push.port';

const FCM_LEGACY_URL = 'https://fcm.googleapis.com/fcm/send';

/**
 * FCM adapter for ANDROID device tokens. Credentials absent → stub SENT (G2-N03).
 * In-app persist is the caller's job (FR-SYS-008.6).
 */
@Injectable()
export class FcmPushAdapter {
  private readonly logger = new Logger(FcmPushAdapter.name);

  constructor(@Inject(ENV) private readonly env: Env) {}

  isConfigured(): boolean {
    return Boolean(this.env.FCM_SERVER_KEY);
  }

  async send(target: PushTarget, message: PushMessage): Promise<PushDeliveryResult> {
    if (!this.env.FCM_SERVER_KEY) {
      this.logger.warn('FCM credentials absent; stubbing push');
      return { status: 'SENT', providerRef: 'stub:fcm' };
    }

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
