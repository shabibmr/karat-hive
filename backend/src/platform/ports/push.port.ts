/** Push gateway (Architecture-Backend §15.1). APNs / FCM behind this port (G2-N03). */

export type PushPlatform = 'IOS' | 'ANDROID';

export type PushTarget = {
  token: string;
  platform: PushPlatform;
};

export type PushMessage = {
  title: string;
  body: string;
  deepLink: string;
  data?: Record<string, string>;
};

export type PushDeliveryResult = {
  status: 'SENT' | 'FAILED' | 'BOUNCED';
  providerRef?: string;
  error?: string;
};

export interface PushGateway {
  send(target: PushTarget, message: PushMessage): Promise<PushDeliveryResult>;
}

export const PUSH_GATEWAY = Symbol('PUSH_GATEWAY');
