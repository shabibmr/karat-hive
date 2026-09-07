import { Inject, Injectable } from '@nestjs/common';
import { ENV, type Env } from '../../../config/env';
import type {
  CreateSignedUploadInput,
  ObjectHead,
  ObjectStorage,
  SignedDownload,
  SignedUpload,
} from '../../ports/storage.port';

/**
 * Supabase Storage over its REST API (Node 20 global fetch, no SDK).
 * Auth is the service-role key, which bypasses Storage RLS — never exposed to clients.
 */
@Injectable()
export class SupabaseStorageAdapter implements ObjectStorage {
  constructor(@Inject(ENV) private readonly env: Env) {}

  private base(): string {
    const url = this.env.SUPABASE_URL;
    const key = this.env.SUPABASE_SERVICE_ROLE_KEY;
    if (!url || !key) {
      throw new Error(
        'SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are required for object storage.',
      );
    }
    return `${url.replace(/\/$/, '')}/storage/v1`;
  }

  private headers(): Record<string, string> {
    const key = this.env.SUPABASE_SERVICE_ROLE_KEY as string;
    return { Authorization: `Bearer ${key}`, apikey: key, 'Content-Type': 'application/json' };
  }

  async createSignedUploadUrl(input: CreateSignedUploadInput): Promise<SignedUpload> {
    const path = encodePath(input.key);
    const res = await fetch(`${this.base()}/object/upload/sign/${input.bucket}/${path}`, {
      method: 'POST',
      headers: this.headers(),
      body: JSON.stringify({}),
    });
    if (!res.ok) throw new Error(`Supabase sign upload failed: ${res.status} ${await res.text()}`);
    const body = (await res.json()) as { url: string };
    return {
      uploadUrl: `${this.base()}${body.url}`,
      requiredHeaders: { 'Content-Type': input.contentType, 'x-upsert': 'true' },
      expiresAt: new Date(Date.now() + input.ttlSeconds * 1000),
    };
  }

  async createSignedDownloadUrl(
    bucket: string,
    key: string,
    ttlSeconds: number,
  ): Promise<SignedDownload> {
    const path = encodePath(key);
    const res = await fetch(`${this.base()}/object/sign/${bucket}/${path}`, {
      method: 'POST',
      headers: this.headers(),
      body: JSON.stringify({ expiresIn: ttlSeconds }),
    });
    if (!res.ok)
      throw new Error(`Supabase sign download failed: ${res.status} ${await res.text()}`);
    const body = (await res.json()) as { signedURL: string };
    return {
      url: `${this.base()}${body.signedURL}`,
      expiresAt: new Date(Date.now() + ttlSeconds * 1000),
    };
  }

  async headObject(bucket: string, key: string): Promise<ObjectHead | null> {
    const signed = await this.createSignedDownloadUrl(bucket, key, 60);
    const res = await fetch(signed.url, { method: 'HEAD' });
    if (res.status === 404 || res.status === 400) return null;
    if (!res.ok) throw new Error(`Supabase head failed: ${res.status}`);
    const len = res.headers.get('content-length');
    return {
      exists: true,
      size: len ? Number(len) : 0,
      contentType: res.headers.get('content-type'),
    };
  }

  async getObject(bucket: string, key: string): Promise<Buffer | null> {
    const path = encodePath(key);
    const auth = this.authHeaders();
    const res = await fetch(`${this.base()}/object/${bucket}/${path}`, { headers: auth });
    if (res.status === 404 || res.status === 400) return null;
    if (!res.ok) throw new Error(`Supabase get failed: ${res.status} ${await res.text()}`);
    return Buffer.from(await res.arrayBuffer());
  }

  async putObject(bucket: string, key: string, body: Buffer, contentType: string): Promise<void> {
    const path = encodePath(key);
    const res = await fetch(`${this.base()}/object/${bucket}/${path}`, {
      method: 'POST',
      headers: {
        ...this.authHeaders(),
        'Content-Type': contentType,
        'x-upsert': 'true',
      },
      body: new Uint8Array(body),
    });
    if (!res.ok) throw new Error(`Supabase put failed: ${res.status} ${await res.text()}`);
  }

  async deleteObject(bucket: string, key: string): Promise<void> {
    const path = encodePath(key);
    const res = await fetch(`${this.base()}/object/${bucket}/${path}`, {
      method: 'DELETE',
      headers: this.headers(),
    });
    if (res.status === 404) return;
    if (!res.ok) throw new Error(`Supabase delete failed: ${res.status} ${await res.text()}`);
  }

  private authHeaders(): Record<string, string> {
    const key = this.env.SUPABASE_SERVICE_ROLE_KEY as string;
    return { Authorization: `Bearer ${key}`, apikey: key };
  }
}

function encodePath(key: string): string {
  return key
    .split('/')
    .map((seg) => encodeURIComponent(seg))
    .join('/');
}
