import { Inject, Injectable, Logger } from '@nestjs/common';
import { ENV, type Env } from '../../../config/env';
import type { PushDeliveryResult, PushMessage, PushTarget } from '../../ports/push.port';

/**
 * APNs adapter for IOS device tokens. Credentials absent → stub SENT (G2-N03).
 * HTTP/2 provider send is not wired this slice; configured credentials still stub
 * rather than fail closed, so in-app persist is never blocked (FR-SYS-008.6).
 */
@Injectable()
export class ApnsPushAdapter {
  private readonly logger = new Logger(ApnsPushAdapter.name);

  constructor(@Inject(ENV) private readonly env: Env) {}

  isConfigured(): boolean {
    return Boolean(this.env.APNS_KEY_P8 && this.env.APNS_KEY_ID && this.env.APNS_TEAM_ID);
  }

  async send(target: PushTarget, message: PushMessage): Promise<PushDeliveryResult> {
    if (!this.isConfigured()) {
      this.logger.warn('APNs credentials absent; stubbing push');
      return { status: 'SENT', providerRef: 'stub:apns' };
    }

    this.logger.warn(
      `APNs credentials present but HTTP/2 send is not wired; stubbing token=${target.token.slice(0, 8)}… deepLink=${message.deepLink}`,
    );
    return { status: 'SENT', providerRef: 'stub:apns-configured' };
  }
}
