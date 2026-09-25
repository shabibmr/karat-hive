import { afterEach, describe, expect, it, vi } from 'vitest';
import type { Env } from '../../../config/env';
import { OciS3StorageAdapter, ociS3Configured } from './oci-s3-storage.adapter';

const env = {
  OCI_S3_NAMESPACE: 'axxa9erb3sgs',
  OCI_S3_REGION: 'ap-hyderabad-1',
  OCI_S3_ACCESS_KEY_ID: 'access',
  OCI_S3_SECRET_ACCESS_KEY: 'secret',
  OCI_S3_BUCKET_KYC: 'kyc',
  OCI_S3_BUCKET_REQUEST_MEDIA: 'request-media',
  OCI_S3_BUCKET_EXPORT: 'export',
} as Env;

afterEach(() => {
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

describe('ociS3Configured', () => {
  it('is true when namespace and both keys are set', () => {
    expect(ociS3Configured(env)).toBe(true);
  });

  it('is false when any identity field is missing', () => {
    expect(ociS3Configured({ ...env, OCI_S3_NAMESPACE: undefined })).toBe(false);
  });
});

describe('OciS3StorageAdapter', () => {
  it('HEADs each configured bucket once against the Oracle S3 endpoint', async () => {
    const fetchMock = vi.fn(async () => new Response(null, { status: 200 }));
    vi.stubGlobal('fetch', fetchMock);

    const adapter = new OciS3StorageAdapter(env);
    await adapter.ensureBuckets();
    await adapter.ensureBuckets();

    expect(fetchMock).toHaveBeenCalledTimes(3);
    expect(fetchMock.mock.calls.every((call) => call[1]?.method === 'HEAD')).toBe(true);
    const urls = fetchMock.mock.calls.map((call) => String(call[0]));
    expect(urls).toEqual([
      'https://axxa9erb3sgs.compat.objectstorage.ap-hyderabad-1.oraclecloud.com/kyc',
      'https://axxa9erb3sgs.compat.objectstorage.ap-hyderabad-1.oraclecloud.com/request-media',
      'https://axxa9erb3sgs.compat.objectstorage.ap-hyderabad-1.oraclecloud.com/export',
    ]);
    const firstHeaders = fetchMock.mock.calls[0]![1]?.headers as Record<string, string>;
    expect(firstHeaders.Authorization).toMatch(/^AWS4-HMAC-SHA256/);
    expect(firstHeaders['x-amz-date']).toBeTruthy();
  });

  it('presigns uploads on the Oracle host with Content-Type required', async () => {
    const fetchMock = vi.fn(async () => new Response(null, { status: 200 }));
    vi.stubGlobal('fetch', fetchMock);

    const adapter = new OciS3StorageAdapter(env);
    const signed = await adapter.createSignedUploadUrl({
      bucket: 'kyc',
      key: 'vendor/doc.pdf',
      contentType: 'application/pdf',
      ttlSeconds: 900,
    });

    expect(signed.uploadUrl).toContain(
      'https://axxa9erb3sgs.compat.objectstorage.ap-hyderabad-1.oraclecloud.com/kyc/vendor/doc.pdf',
    );
    expect(signed.uploadUrl).toContain('X-Amz-Signature=');
    expect(signed.uploadUrl).not.toContain('.r2.');
    expect(signed.requiredHeaders).toEqual({ 'Content-Type': 'application/pdf' });
  });

  it('PUTs a bucket when HEAD returns 404', async () => {
    const fetchMock = vi.fn(async (_url: unknown, init?: RequestInit) => {
      if (init?.method === 'HEAD') return new Response(null, { status: 404 });
      if (init?.method === 'PUT') return new Response(null, { status: 200 });
      return new Response(null, { status: 500 });
    });
    vi.stubGlobal('fetch', fetchMock);

    await new OciS3StorageAdapter(env).ensureBuckets();

    const methods = fetchMock.mock.calls.map((call) => call[1]?.method);
    expect(methods.filter((m) => m === 'HEAD')).toHaveLength(3);
    expect(methods.filter((m) => m === 'PUT')).toHaveLength(3);
  });

  it('fails when HEAD returns a non-404 error', async () => {
    const fetchMock = vi.fn(async () => new Response('nope', { status: 403 }));
    vi.stubGlobal('fetch', fetchMock);

    await expect(new OciS3StorageAdapter(env).ensureBuckets()).rejects.toThrow(
      /OCI S3 head bucket kyc failed: 403/,
    );
  });
});
