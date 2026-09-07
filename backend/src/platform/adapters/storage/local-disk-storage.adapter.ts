import { createHash } from 'node:crypto';
import { mkdir, readFile, rm, stat, writeFile } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { Injectable } from '@nestjs/common';
import type {
  CreateSignedUploadInput,
  ObjectHead,
  ObjectStorage,
  SignedDownload,
  SignedUpload,
} from '../../ports/storage.port';

/**
 * Filesystem-backed ObjectStorage for tests / CI (no Supabase). "Signed URLs" are
 * file:// paths carrying an HMAC-free token; a matching sidecar records size + type.
 */
@Injectable()
export class LocalDiskStorageAdapter implements ObjectStorage {
  private readonly root = resolve(process.cwd(), '.tmp', 'uploads');

  private objectPath(bucket: string, key: string): string {
    const segments = key.split('/').filter((s) => s.length > 0);
    return join(this.root, bucket, ...segments);
  }

  async createSignedUploadUrl(input: CreateSignedUploadInput): Promise<SignedUpload> {
    const token = createHash('sha256').update(`${input.bucket}/${input.key}`).digest('hex');
    return {
      uploadUrl: `local://${input.bucket}/${input.key}?token=${token}&ct=${encodeURIComponent(input.contentType)}`,
      requiredHeaders: { 'Content-Type': input.contentType },
      expiresAt: new Date(Date.now() + input.ttlSeconds * 1000),
    };
  }

  async createSignedDownloadUrl(
    bucket: string,
    key: string,
    ttlSeconds: number,
  ): Promise<SignedDownload> {
    return {
      url: `local://${bucket}/${key}`,
      expiresAt: new Date(Date.now() + ttlSeconds * 1000),
    };
  }

  async headObject(bucket: string, key: string): Promise<ObjectHead | null> {
    try {
      const path = this.objectPath(bucket, key);
      const info = await stat(path);
      let contentType: string | null = null;
      try {
        const meta = JSON.parse(await readFile(`${path}.meta.json`, 'utf8')) as {
          contentType?: string;
        };
        contentType = meta.contentType ?? null;
      } catch {
        contentType = null;
      }
      return { exists: true, size: info.size, contentType };
    } catch {
      return null;
    }
  }

  async getObject(bucket: string, key: string): Promise<Buffer | null> {
    try {
      return await readFile(this.objectPath(bucket, key));
    } catch {
      return null;
    }
  }

  async putObject(bucket: string, key: string, body: Buffer, contentType: string): Promise<void> {
    const path = this.objectPath(bucket, key);
    await mkdir(dirname(path), { recursive: true });
    await writeFile(path, body);
    await writeFile(`${path}.meta.json`, JSON.stringify({ contentType, size: body.length }));
  }

  async deleteObject(bucket: string, key: string): Promise<void> {
    const path = this.objectPath(bucket, key);
    await rm(path, { force: true });
    await rm(`${path}.meta.json`, { force: true });
  }

  /** Test helper — simulate a client PUT to the signed URL. */
  async putForTest(bucket: string, key: string, body: Buffer, contentType: string): Promise<void> {
    await this.putObject(bucket, key, body, contentType);
  }
}
