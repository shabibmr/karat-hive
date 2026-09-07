import { describe, expect, it, vi } from 'vitest';
import type { Env } from '../../../config/env';
import { ApnsPushAdapter } from './apns-push.adapter';

describe('ApnsPushAdapter (G2-N03)', () => {
  const message = {
    title: 'Your Offer was accepted',
    body: 'The Customer accepted your Offer. You are now connected.',
    deepLink: '/connections/conn-1',
  };

  it('stubs SENT when APNs credentials are absent', async () => {
    const adapter = new ApnsPushAdapter({} as Env);
    const warn = vi.spyOn(adapter['logger'], 'warn');

    const result = await adapter.send({ token: 'ios-token', platform: 'IOS' }, message);

    expect(adapter.isConfigured()).toBe(false);
    expect(result).toEqual({ status: 'SENT', providerRef: 'stub:apns' });
    expect(warn).toHaveBeenCalledWith('APNs credentials absent; stubbing push');
  });

  it('stubs rather than throwing when credentials are present but HTTP/2 is unwired', async () => {
    const adapter = new ApnsPushAdapter({
      APNS_KEY_P8: '-----BEGIN PRIVATE KEY-----',
      APNS_KEY_ID: 'KEYID',
      APNS_TEAM_ID: 'TEAM',
    } as Env);

    const result = await adapter.send({ token: 'ios-token', platform: 'IOS' }, message);

    expect(adapter.isConfigured()).toBe(true);
    expect(result.status).toBe('SENT');
    expect(result.providerRef).toBe('stub:apns-configured');
  });
});
