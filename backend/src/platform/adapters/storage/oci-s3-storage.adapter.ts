import { Inject, Injectable, Logger } from '@nestjs/common';
import { ENV, type Env } from '../../../config/env';
import type {
  CreateSignedUploadInput,
  ObjectHead,
  ObjectStorage,
  SignedDownload,
  SignedUpload,
} from '../../ports/storage.port';
import { presign, signHeaders, type SigV4Identity } from './s3-sigv4';

export function ociS3Configured(
  env: Pick<Env, 'OCI_S3_NAMESPACE' | 'OCI_S3_ACCESS_KEY_ID' | 'OCI_S3_SECRET_ACCESS_KEY'>,
): boolean {
  return Boolean(env.OCI_S3_NAMESPACE && env.OCI_S3_ACCESS_KEY_ID && env.OCI_S3_SECRET_ACCESS_KEY);
}

/** Physical bucket names used when Oracle S3 is the active store (`adr/0013`). */
export function ociS3BucketNames(env: Env): string[] {
  return [env.OCI_S3_BUCKET_KYC, env.OCI_S3_BUCKET_REQUEST_MEDIA, env.OCI_S3_BUCKET_EXPORT];
}

/**
 * Oracle Object Storage via the S3 Compatibility API (`adr/0013`).
 * Endpoint region places the bucket; no R2-style LocationConstraint body.
 */
@Injectable()
export class OciS3StorageAdapter implements ObjectStorage {
  private readonly logger = new Logger(OciS3StorageAdapter.name);
  private bucketsReady: Promise<void> | null = null;

  constructor(@Inject(ENV) private readonly env: Env) {}

  private endpoint(): string {
    return `https://${this.env.OCI_S3_NAMESPACE}.compat.objectstorage.${this.env.OCI_S3_REGION}.oraclecloud.com`;
  }

  private identity(): SigV4Identity {
    return {
      accessKeyId: this.env.OCI_S3_ACCESS_KEY_ID as string,
      secretAccessKey: this.env.OCI_S3_SECRET_ACCESS_KEY as string,
      region: this.env.OCI_S3_REGION,
      service: 's3',
    };
  }

  private objectUrl(bucket: string, key: string): URL {
    const encoded = key.split('/').map(encodeURIComponent).join('/');
    return new URL(`${this.endpoint()}/${bucket}/${encoded}`);
  }

  ensureBuckets(): Promise<void> {
    this.bucketsReady ??= this.createBuckets().catch((error: unknown) => {
      this.bucketsReady = null;
      throw error;
    });
    return this.bucketsReady;
  }

  private async createBuckets(): Promise<void> {
    for (const bucket of ociS3BucketNames(this.env)) {
      const url = new URL(`${this.endpoint()}/${bucket}`);
      const headHeaders = signHeaders(this.identity(), {
        method: 'HEAD',
        url,
        headers: { host: url.host },
        body: new Uint8Array(),
        now: new Date(),
      });
      const head = await fetch(url, { method: 'HEAD', headers: headHeaders });
      if (head.ok) continue;
      if (head.status !== 404) {
        throw new Error(
          `OCI S3 head bucket ${bucket} failed: ${head.status} ${await head.text()}`,
        );
      }
      const putHeaders = signHeaders(this.identity(), {
        method: 'PUT',
        url,
        headers: { host: url.host },
        body: '',
        now: new Date(),
      });
      const res = await fetch(url, { method: 'PUT', headers: putHeaders });
      if (res.ok || res.status === 409) continue;
      const text = await res.text();
      throw new Error(`OCI S3 create bucket ${bucket} failed: ${res.status} ${text}`);
    }
  }

  async createSignedUploadUrl(input: CreateSignedUploadInput): Promise<SignedUpload> {
    await this.ensureBuckets();
    const url = this.objectUrl(input.bucket, input.key);
    const uploadUrl = presign(this.identity(), {
      method: 'PUT',
      url,
      signedHeaderNames: ['host', 'content-type'],
      headers: { host: url.host, 'content-type': input.contentType },
      expiresSeconds: input.ttlSeconds,
      now: new Date(),
    });
    return {
      uploadUrl,
      requiredHeaders: { 'Content-Type': input.contentType },
      expiresAt: new Date(Date.now() + input.ttlSeconds * 1000),
    };
  }

  async createSignedDownloadUrl(
    bucket: string,
    key: string,
    ttlSeconds: number,
  ): Promise<SignedDownload> {
    await this.ensureBuckets();
    const url = this.objectUrl(bucket, key);
    return {
      url: presign(this.identity(), {
        method: 'GET',
        url,
        signedHeaderNames: ['host'],
        headers: { host: url.host },
        expiresSeconds: ttlSeconds,
        now: new Date(),
      }),
      expiresAt: new Date(Date.now() + ttlSeconds * 1000),
    };
  }

  async headObject(bucket: string, key: string): Promise<ObjectHead | null> {
    await this.ensureBuckets();
    const url = this.objectUrl(bucket, key);
    const res = await this.signed('HEAD', url, {}, new Uint8Array());
    if (res.status === 404) return null;
    if (!res.ok) throw new Error(`OCI S3 head failed: ${res.status} ${await res.text()}`);
    const len = res.headers.get('content-length');
    return {
      exists: true,
      size: len ? Number(len) : 0,
      contentType: res.headers.get('content-type'),
    };
  }

  async getObject(bucket: string, key: string): Promise<Buffer | null> {
    await this.ensureBuckets();
    const url = this.objectUrl(bucket, key);
    const res = await this.signed('GET', url, {}, new Uint8Array());
    if (res.status === 404) return null;
    if (!res.ok) throw new Error(`OCI S3 get failed: ${res.status} ${await res.text()}`);
    return Buffer.from(await res.arrayBuffer());
  }

  async putObject(bucket: string, key: string, body: Buffer, contentType: string): Promise<void> {
    await this.ensureBuckets();
    const url = this.objectUrl(bucket, key);
    const res = await this.signed('PUT', url, { 'content-type': contentType }, body);
    if (!res.ok) throw new Error(`OCI S3 put failed: ${res.status} ${await res.text()}`);
  }

  async deleteObject(bucket: string, key: string): Promise<void> {
    await this.ensureBuckets();
    const url = this.objectUrl(bucket, key);
    const res = await this.signed('DELETE', url, {}, new Uint8Array());
    if (res.status === 404) return;
    if (!res.ok) throw new Error(`OCI S3 delete failed: ${res.status} ${await res.text()}`);
  }

  private signed(
    method: string,
    url: URL,
    extra: Record<string, string>,
    body: Uint8Array | Buffer,
  ): Promise<Response> {
    const headers = signHeaders(this.identity(), {
      method,
      url,
      headers: { host: url.host, ...extra },
      body,
      now: new Date(),
    });
    this.logger.debug(`${method} ${url.pathname}`);
    return fetch(url, {
      method,
      headers,
      body: method === 'GET' || method === 'HEAD' ? undefined : (body as BodyInit),
    });
  }
}
