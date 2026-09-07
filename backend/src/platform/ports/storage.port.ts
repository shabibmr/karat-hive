/** Object storage abstraction (C-13). Supabase Storage in dev/prod; local disk in tests. */

export interface SignedUpload {
  uploadUrl: string;
  requiredHeaders: Record<string, string>;
  expiresAt: Date;
}

export interface ObjectHead {
  exists: boolean;
  size: number;
  contentType: string | null;
}

export interface SignedDownload {
  url: string;
  expiresAt: Date;
}

export interface CreateSignedUploadInput {
  bucket: string;
  key: string;
  contentType: string;
  maxBytes: number;
  ttlSeconds: number;
}

export interface ObjectStorage {
  createSignedUploadUrl(input: CreateSignedUploadInput): Promise<SignedUpload>;
  headObject(bucket: string, key: string): Promise<ObjectHead | null>;
  createSignedDownloadUrl(bucket: string, key: string, ttlSeconds: number): Promise<SignedDownload>;
  getObject(bucket: string, key: string): Promise<Buffer | null>;
  putObject(bucket: string, key: string, body: Buffer, contentType: string): Promise<void>;
  deleteObject(bucket: string, key: string): Promise<void>;
}

export const OBJECT_STORAGE = Symbol('OBJECT_STORAGE');
