import { Injectable, Logger } from '@nestjs/common';
import { ApnsPushAdapter } from '../apns/apns-push.adapter';
import { FcmPushAdapter } from '../fcm/fcm-push.adapter';
import type {
  PushDeliveryResult,
  PushGateway,
  PushMessage,
  PushTarget,
} from '../../ports/push.port';

/** Routes IOS → APNs and ANDROID → FCM. No new datastore (C-12). */
@Injectable()
export class RoutedPushAdapter implements PushGateway {
  private readonly logger = new Logger(RoutedPushAdapter.name);

  constructor(
    private readonly fcm: FcmPushAdapter,
    private readonly apns: ApnsPushAdapter,
  ) {}

  async send(target: PushTarget, message: PushMessage): Promise<PushDeliveryResult> {
    if (!target.token) {
      return { status: 'FAILED', error: 'missing push token' };
    }
    if (target.platform === 'IOS') {
      return this.apns.send(target, message);
    }
    if (target.platform === 'ANDROID') {
      return this.fcm.send(target, message);
    }
    this.logger.warn(`Unknown push platform ${(target as PushTarget).platform}`);
    return { status: 'FAILED', error: `unknown platform ${(target as PushTarget).platform}` };
  }
}
