import { generateKeyPairSync } from 'node:crypto';
import { describe, expect, it, vi } from 'vitest';
import type { Env } from '../../../config/env';
import { FcmPushAdapter } from './fcm-push.adapter';

describe('FcmPushAdapter (G2-N03 & HTTP v1 Modernization)', () => {
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

  it('POSTs to FCM legacy endpoint when only a server key is configured', async () => {
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

  it('POSTs to FCM HTTP v1 when a bearer token is configured', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ name: 'projects/test-project/messages/msg-123' }),
    });
    vi.stubGlobal('fetch', fetchMock);

    const adapter = new FcmPushAdapter({
      FIREBASE_PROJECT_ID: 'test-project',
      FCM_BEARER_TOKEN: 'test-bearer-token',
    } as Env);

    expect(adapter.isConfigured()).toBe(true);
    expect(adapter.isHttpV1()).toBe(true);

    const result = await adapter.send(
      { token: 'android-token-123', platform: 'ANDROID' },
      { ...message, data: { type: 'REQUEST_NEW' } },
    );

    expect(result).toEqual({
      status: 'SENT',
      providerRef: 'projects/test-project/messages/msg-123',
    });

    expect(fetchMock).toHaveBeenCalledWith(
      'https://fcm.googleapis.com/v1/projects/test-project/messages:send',
      expect.objectContaining({
        method: 'POST',
        headers: {
          Authorization: 'Bearer test-bearer-token',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: 'android-token-123',
            notification: {
              title: message.title,
              body: message.body,
            },
            data: {
              deepLink: '/requests/req-1',
              type: 'REQUEST_NEW',
            },
          },
        }),
      }),
    );

    vi.unstubAllGlobals();
  });

  it('handles FCM HTTP v1 failure response cleanly', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: false,
      status: 400,
      text: async () => '{"error": {"message": "Invalid registration token"}}',
    });
    vi.stubGlobal('fetch', fetchMock);

    const adapter = new FcmPushAdapter({
      FIREBASE_PROJECT_ID: 'test-project',
      FCM_BEARER_TOKEN: 'test-bearer-token',
    } as Env);

    const result = await adapter.send({ token: 'bad-token', platform: 'ANDROID' }, message);

    expect(result).toEqual({
      status: 'FAILED',
      error: 'FCM v1 HTTP 400 {"error": {"message": "Invalid registration token"}}',
    });

    vi.unstubAllGlobals();
  });

  it('exchanges service account credentials for Google OAuth2 token and caches it', async () => {
    const { privateKey } = generateKeyPairSync('rsa', {
      modulusLength: 2048,
      publicKeyEncoding: { type: 'spki', format: 'pem' },
      privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
    });

    const fetchMock = vi.fn().mockImplementation(async (url: string) => {
      if (url === 'https://oauth2.googleapis.com/token') {
        return {
          ok: true,
          json: async () => ({ access_token: 'minted-oauth-token', expires_in: 3600 }),
        };
      }
      if (url.includes('/messages:send')) {
        return {
          ok: true,
          json: async () => ({ name: 'projects/test-project/messages/oauth-msg' }),
        };
      }
      throw new Error(`Unexpected url: ${url}`);
    });
    vi.stubGlobal('fetch', fetchMock);

    const adapter = new FcmPushAdapter({
      FIREBASE_PROJECT_ID: 'test-project',
      FCM_SERVICE_ACCOUNT_EMAIL: 'sa@test-project.iam.gserviceaccount.com',
      FCM_SERVICE_ACCOUNT_PRIVATE_KEY: privateKey,
    } as Env);

    // First send exchanges OAuth2 token
    const result1 = await adapter.send({ token: 'android-token-1', platform: 'ANDROID' }, message);
    expect(result1).toEqual({
      status: 'SENT',
      providerRef: 'projects/test-project/messages/oauth-msg',
    });

    // Second send reuses cached token (oauth token endpoint not called again)
    const result2 = await adapter.send({ token: 'android-token-2', platform: 'ANDROID' }, message);
    expect(result2).toEqual({
      status: 'SENT',
      providerRef: 'projects/test-project/messages/oauth-msg',
    });

    expect(fetchMock).toHaveBeenCalledTimes(3); // 1 token exchange + 2 sends
    const calls = fetchMock.mock.calls;
    expect(calls[0]?.[0]).toBe('https://oauth2.googleapis.com/token');
    expect(calls[1]?.[0]).toBe('https://fcm.googleapis.com/v1/projects/test-project/messages:send');
    expect(calls[2]?.[0]).toBe('https://fcm.googleapis.com/v1/projects/test-project/messages:send');

    vi.unstubAllGlobals();
  });
});
