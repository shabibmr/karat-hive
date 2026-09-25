import { describe, expect, it } from 'vitest';
import { signHeaders } from './s3-sigv4';

describe('signHeaders', () => {
  it('includes x-amz-date in SignedHeaders for Oracle compatibility', () => {
    const url = new URL(
      'https://axxa9erb3sgs.compat.objectstorage.ap-hyderabad-1.oraclecloud.com/kyc',
    );
    const headers = signHeaders(
      {
        accessKeyId: 'AKIAEXAMPLE',
        secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
        region: 'ap-hyderabad-1',
        service: 's3',
      },
      {
        method: 'HEAD',
        url,
        headers: { host: url.host },
        body: new Uint8Array(),
        now: new Date('2026-09-25T12:00:00.000Z'),
      },
    );

    expect(headers['x-amz-date']).toBe('20260925T120000Z');
    expect(headers.Authorization).toMatch(
      /^AWS4-HMAC-SHA256 Credential=AKIAEXAMPLE\/20260925\/ap-hyderabad-1\/s3\/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=[0-9a-f]{64}$/,
    );
  });

  it('is stable for a fixed clock (golden vector)', () => {
    const url = new URL(
      'https://axxa9erb3sgs.compat.objectstorage.ap-hyderabad-1.oraclecloud.com/kyc',
    );
    const input = {
      method: 'HEAD',
      url,
      headers: { host: url.host },
      body: new Uint8Array(),
      now: new Date('2026-09-25T12:00:00.000Z'),
    } as const;
    const identity = {
      accessKeyId: 'AKIAEXAMPLE',
      secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
      region: 'ap-hyderabad-1',
      service: 's3',
    };
    const a = signHeaders(identity, input);
    const b = signHeaders(identity, input);
    expect(a.Authorization).toBe(b.Authorization);
  });
});
