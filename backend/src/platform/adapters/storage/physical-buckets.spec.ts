import { describe, expect, it } from 'vitest';
import type { Env } from '../../../config/env';
import { physicalBucketName, physicalBucketNamesFromEnv } from './physical-buckets';

const base = {
  SUPABASE_STORAGE_BUCKET_KYC: 'supabase-kyc',
  OCI_S3_BUCKET_KYC: 'oci-kyc',
  OCI_S3_BUCKET_REQUEST_MEDIA: 'oci-request-media',
  OCI_S3_BUCKET_EXPORT: 'oci-export',
} as Env;

describe('physicalBucketNamesFromEnv', () => {
  it('uses OCI bucket names when Oracle S3 is configured', () => {
    const names = physicalBucketNamesFromEnv({
      ...base,
      OCI_S3_NAMESPACE: 'ns',
      OCI_S3_ACCESS_KEY_ID: 'ak',
      OCI_S3_SECRET_ACCESS_KEY: 'sk',
    });
    expect(names).toEqual({
      kyc: 'oci-kyc',
      requestMedia: 'oci-request-media',
      export: 'oci-export',
    });
  });

  it('uses Supabase KYC and default media/export names when OCI is unset', () => {
    expect(physicalBucketNamesFromEnv(base)).toEqual({
      kyc: 'supabase-kyc',
      requestMedia: 'request-media',
      export: 'export',
    });
  });
});

describe('physicalBucketName', () => {
  it('maps StorageBucket enums to the resolved names', () => {
    const names = {
      kyc: 'oci-kyc',
      requestMedia: 'oci-request-media',
      export: 'oci-export',
    };
    expect(physicalBucketName('KYC', names)).toBe('oci-kyc');
    expect(physicalBucketName('REQUEST_MEDIA', names)).toBe('oci-request-media');
    expect(physicalBucketName('EXPORT', names)).toBe('oci-export');
  });
});
