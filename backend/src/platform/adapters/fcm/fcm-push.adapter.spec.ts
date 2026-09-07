import { describe, expect, it, vi } from 'vitest';
import type { Env } from '../../../config/env';
import { FcmPushAdapter } from './fcm-push.adapter';

describe('FcmPushAdapter (G2-N03)', () => {
  const message = {
    title: 'New matched Request',
    body: 'A new Request matches your categories and region.',
    deepLink: '/requests/req-1',
  };

  it('stubs SENT when FCM credentials are absent', async () => {
    const adapter = new FcmPushAdapter({} as Env);
    const warn = vi.spyOn(adapter['logger'], 'warn');

    const result = await adapter.send({ token: 'android-token', platform: 'ANDROID' }, message);

    expect(adapter.isConfigured()).toBe(false);
    expect(result).toEqual({ status: 'SENT', providerRef: 'stub:fcm' });
    expect(warn).toHaveBeenCalledWith('FCM credentials absent; stubbing push');
  });

  it('POSTs to FCM when a server key is configured', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ message_id: 42 }),
    });
    vi.stubGlobal('fetch', fetchMock);

    const adapter = new FcmPushAdapter({ FCM_SERVER_KEY: 'server-key' } as Env);
    const result = await adapter.send({ token: 'android-token', platform: 'ANDROID' }, message);

    expect(result).toEqual({ status: 'SENT', providerRef: '42' });
    expect(fetchMock).toHaveBeenCalledWith(
      'https://fcm.googleapis.com/fcm/send',
      expect.objectContaining({
        method: 'POST',
        headers: expect.objectContaining({ Authorization: 'key=server-key' }),
      }),
    );

    vi.unstubAllGlobals();
  });
});
