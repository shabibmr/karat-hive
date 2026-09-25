import { describe, expect, it } from 'vitest';
import type { Env } from '../../../config/env';
import { selectObjectStorage } from '../../platform.module';
import { ociS3Configured } from './oci-s3-storage.adapter';

describe('selectObjectStorage', () => {
  it('uses local disk in test', () => {
    const store = selectObjectStorage({ NODE_ENV: 'test' } as Env);
    expect(store.constructor.name).toBe('LocalDiskStorageAdapter');
  });

  it('uses Oracle S3 when credentials are set', () => {
    const env = {
      NODE_ENV: 'development',
      OCI_S3_NAMESPACE: 'axxa9erb3sgs',
      OCI_S3_REGION: 'ap-hyderabad-1',
      OCI_S3_ACCESS_KEY_ID: 'key',
      OCI_S3_SECRET_ACCESS_KEY: 'secret',
      OCI_S3_BUCKET_KYC: 'kyc',
      OCI_S3_BUCKET_REQUEST_MEDIA: 'request-media',
      OCI_S3_BUCKET_EXPORT: 'export',
    } as Env;
    expect(ociS3Configured(env)).toBe(true);
    expect(selectObjectStorage(env).constructor.name).toBe('OciS3StorageAdapter');
  });

  it('falls back to Supabase when OCI credentials are unset', () => {
    const env = {
      NODE_ENV: 'development',
      SUPABASE_URL: 'https://example.supabase.co',
      SUPABASE_SERVICE_ROLE_KEY: 'service-role',
      SUPABASE_STORAGE_BUCKET_KYC: 'kyc',
    } as Env;
    expect(ociS3Configured(env)).toBe(false);
    expect(selectObjectStorage(env).constructor.name).toBe('SupabaseStorageAdapter');
  });
});
