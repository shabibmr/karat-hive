import type { StorageBucket } from '@prisma/client';
import type { Env } from '../../../config/env';
import { ociS3Configured } from './oci-s3-storage.adapter';

/** Physical object-store bucket names for SRS §7.6 segregation. */
export type PhysicalBucketNames = {
  kyc: string;
  requestMedia: string;
  export: string;
};

/** Prefer OCI bucket env when Oracle S3 is configured (`adr/0013`); else Supabase fallback names. */
export function physicalBucketNamesFromEnv(
  env: Pick<
    Env,
    | 'SUPABASE_STORAGE_BUCKET_KYC'
    | 'OCI_S3_NAMESPACE'
    | 'OCI_S3_ACCESS_KEY_ID'
    | 'OCI_S3_SECRET_ACCESS_KEY'
    | 'OCI_S3_BUCKET_KYC'
    | 'OCI_S3_BUCKET_REQUEST_MEDIA'
    | 'OCI_S3_BUCKET_EXPORT'
  >,
): PhysicalBucketNames {
  if (ociS3Configured(env)) {
    return {
      kyc: env.OCI_S3_BUCKET_KYC,
      requestMedia: env.OCI_S3_BUCKET_REQUEST_MEDIA,
      export: env.OCI_S3_BUCKET_EXPORT,
    };
  }
  return {
    kyc: env.SUPABASE_STORAGE_BUCKET_KYC,
    requestMedia: 'request-media',
    export: 'export',
  };
}

export function physicalBucketName(bucket: StorageBucket, names: PhysicalBucketNames): string {
  switch (bucket) {
    case 'KYC':
      return names.kyc;
    case 'REQUEST_MEDIA':
      return names.requestMedia;
    case 'EXPORT':
      return names.export;
  }
}
