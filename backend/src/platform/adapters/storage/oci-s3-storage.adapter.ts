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

function requestId(res: Response): string {
  return res.headers.get('opc-request-id') ?? res.headers.get('x-amz-request-id') ?? 'n/a';
}

/**
 * Oracle Object Storage via the S3 Compatibility API (`adr/0013`).
 * Endpoint region places the bucket; no R2-style LocationConstraint body.
 */
@Injectable()
export class OciS3StorageAdapter implements ObjectStorage {
  private readonly logger = new Logger(OciS3StorageAdapter.name);
  /** Per-bucket ensure so a 403 on `kyc` cannot block `request-media` uploads. */
  private readonly bucketReady = new Map<string, Promise<void>>();

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

  /** Ensure every configured bucket exists (admin / boot probes). */
  ensureBuckets(): Promise<void> {
    return Promise.all(ociS3BucketNames(this.env).map((b) => this.ensureBucket(b))).then(() => undefined);
  }

  /** Ensure only the bucket needed for the current object operation. */
  ensureBucket(bucket: string): Promise<void> {
    let pending = this.bucketReady.get(bucket);
    if (!pending) {
      pending = this.createBucketIfMissing(bucket).catch((error: unknown) => {
        this.bucketReady.delete(bucket);
        throw error;
      });
      this.bucketReady.set(bucket, pending);
    }
    return pending;
  }

  private async createBucketIfMissing(bucket: string): Promise<void> {
    const url = new URL(`${this.endpoint()}/${bucket}`);
    const headHeaders = signHeaders(this.identity(), {
      method: 'HEAD',
      url,
      headers: { host: url.host },
      body: new Uint8Array(),
      now: new Date(),
    });
    const head = await fetch(url, { method: 'HEAD', headers: headHeaders });
    if (head.ok) return;
    if (head.status === 403 && (await this.listProbeOk(bucket))) return;
    if (head.status !== 404) {
      // HEAD has no body; the request id is what Oracle support needs.
      throw new Error(
        `OCI S3 head bucket ${bucket} failed: ${head.status} (opc-request-id=${requestId(head)})`,
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
    if (res.ok || res.status === 409) return;
    const text = await res.text();
    throw new Error(`OCI S3 create bucket ${bucket} failed: ${res.status} ${text}`);
  }

  /**
   * Oracle can 403 `HEAD bucket` while the same key may list it, so a 403 HEAD
   * alone does not prove the bucket is unusable. Object ops are the real test.
   */
  private async listProbeOk(bucket: string): Promise<boolean> {
    const url = new URL(`${this.endpoint()}/${bucket}?max-keys=1`);
    const res = await fetch(url, {
      method: 'GET',
      headers: signHeaders(this.identity(), {
        method: 'GET',
        url,
        headers: { host: url.host },
        body: new Uint8Array(),
        now: new Date(),
      }),
    });
    if (!res.ok) {
      this.logger.warn(
        `OCI S3 list probe ${bucket} failed: ${res.status} (opc-request-id=${requestId(res)})`,
      );
    }
    return res.ok;
  }

  async createSignedUploadUrl(input: CreateSignedUploadInput): Promise<SignedUpload> {
    await this.ensureBucket(input.bucket);
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
    await this.ensureBucket(bucket);
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
    await this.ensureBucket(bucket);
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
    await this.ensureBucket(bucket);
    const url = this.objectUrl(bucket, key);
    const res = await this.signed('GET', url, {}, new Uint8Array());
    if (res.status === 404) return null;
    if (!res.ok) throw new Error(`OCI S3 get failed: ${res.status} ${await res.text()}`);
    return Buffer.from(await res.arrayBuffer());
  }

  async putObject(bucket: string, key: string, body: Buffer, contentType: string): Promise<void> {
    await this.ensureBucket(bucket);
    const url = this.objectUrl(bucket, key);
    const res = await this.signed('PUT', url, { 'content-type': contentType }, body);
    if (!res.ok) throw new Error(`OCI S3 put failed: ${res.status} ${await res.text()}`);
  }

  async deleteObject(bucket: string, key: string): Promise<void> {
    await this.ensureBucket(bucket);
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
