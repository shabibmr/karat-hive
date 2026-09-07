import { describe, expect, it, vi } from 'vitest';
import { RoutedPushAdapter } from './routed-push.adapter';
import type { ApnsPushAdapter } from '../apns/apns-push.adapter';
import type { FcmPushAdapter } from '../fcm/fcm-push.adapter';

describe('RoutedPushAdapter (G2-N03)', () => {
  const message = { title: 't', body: 'b', deepLink: '/x' };

  it('routes IOS to APNs and ANDROID to FCM', async () => {
    const fcm = { send: vi.fn().mockResolvedValue({ status: 'SENT', providerRef: 'fcm' }) };
    const apns = { send: vi.fn().mockResolvedValue({ status: 'SENT', providerRef: 'apns' }) };
    const routed = new RoutedPushAdapter(
      fcm as unknown as FcmPushAdapter,
      apns as unknown as ApnsPushAdapter,
    );

    await routed.send({ token: 'ios', platform: 'IOS' }, message);
    await routed.send({ token: 'and', platform: 'ANDROID' }, message);

    expect(apns.send).toHaveBeenCalledOnce();
    expect(fcm.send).toHaveBeenCalledOnce();
  });
});
