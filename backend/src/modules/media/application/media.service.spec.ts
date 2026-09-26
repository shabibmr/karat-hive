import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { Media } from '@prisma/client';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import type { Env } from '../../../config/env';
import type { ObjectStorage } from '../../../platform/ports/storage.port';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';
import type { MediaRepository } from '../repository/media.repository';
import { MediaService } from './media.service';

function mediaRow(overrides: Partial<Media> = {}): Media {
  return {
    id: 'media-1',
    key: '22222222-2222-2222-2222-222222222222',
    purpose: 'REQUEST_IMAGE',
    state: 'PENDING_UPLOAD',
    bucket: 'REQUEST_MEDIA',
    contentType: 'image/jpeg',
    byteSize: 12,
    exifStripped: false,
    malwareScanState: 'PENDING',
    thumbnailKey: null,
    uploadedByUserId: 'user-1',
    createdAt: new Date('2026-09-07T00:00:00Z'),
    updatedAt: new Date('2026-09-07T00:00:00Z'),
    ...overrides,
  };
}

const customerViewer: ViewerContext = {
  userId: 'user-1',
  role: 'CUSTOMER',
  tokenVersion: 1,
  accountState: 'ACTIVE',
  preferredLanguage: 'en',
  vendorProfileId: null,
  vendorVerificationState: null,
  vendorActivatedAt: null,
  customerProfileId: 'cust-1',
  adminProfileId: null,
};

const vendorViewer: ViewerContext = {
  ...customerViewer,
  role: 'VENDOR',
  customerProfileId: null,
  vendorProfileId: 'vp-1',
  vendorVerificationState: 'PENDING_VERIFICATION',
};

describe('MediaService.complete (G2-P02)', () => {
  let repo: MediaRepository;
  let storage: ObjectStorage;
  let prisma: PrismaService;
  let audit: AuditWriter;
  let outboxCreate: ReturnType<typeof vi.fn>;

  function build(env: Partial<Env>): MediaService {
    return new MediaService(
      {
        NODE_ENV: 'test',
        SUPABASE_STORAGE_BUCKET_KYC: 'kyc',
        SIGNED_UPLOAD_TTL_SECONDS: 900,
        ...env,
      } as Env,
      storage,
      prisma,
      repo,
      audit,
    );
  }

  beforeEach(() => {
    outboxCreate = vi.fn().mockResolvedValue({ id: 'ob-1' });
    repo = {
      findByKey: vi.fn(),
      markState: vi.fn(),
      create: vi.fn(),
    } as unknown as MediaRepository;
    storage = {
      headObject: vi.fn().mockResolvedValue({ exists: true, size: 12, contentType: 'image/jpeg' }),
      createSignedUploadUrl: vi.fn().mockResolvedValue({
        uploadUrl: 'https://storage.example/upload',
        requiredHeaders: {},
        expiresAt: new Date('2026-09-07T01:00:00Z'),
      }),
      createSignedDownloadUrl: vi.fn(),
      getObject: vi.fn(),
    } as unknown as ObjectStorage;
    prisma = {
      $transaction: vi.fn(async (fn: (tx: unknown) => Promise<unknown>) =>
        fn({ outboxEvent: { create: outboxCreate } }),
      ),
      media: { findFirst: vi.fn().mockResolvedValue(null) },
      vendorProfile: { findUnique: vi.fn().mockResolvedValue(null) },
    } as unknown as PrismaService;
    audit = { append: vi.fn() } as unknown as AuditWriter;
  });

  it('keeps non-prod KYC READY (dev shortcut) and still enqueues media.uploaded', async () => {
    const kyc = mediaRow({
      purpose: 'KYC_DOCUMENT',
      bucket: 'KYC',
      contentType: 'application/pdf',
    });
    vi.mocked(repo.findByKey).mockResolvedValueOnce(kyc);
    vi.mocked(storage.headObject).mockResolvedValueOnce({
      exists: true,
      size: 12,
      contentType: 'application/pdf',
    });
    const ready = {
      ...kyc,
      state: 'READY' as const,
      malwareScanState: 'CLEAN' as const,
      exifStripped: true,
    };
    vi.mocked(repo.markState).mockResolvedValueOnce(ready);

    const result = await build({ NODE_ENV: 'test' }).complete(vendorViewer, kyc.key);

    expect(result.state).toBe('READY');
    expect(repo.markState).toHaveBeenCalledWith(
      expect.anything(),
      kyc.key,
      'READY',
      expect.objectContaining({ malwareScanState: 'CLEAN', exifStripped: true }),
    );
    expect(outboxCreate).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          eventType: 'media.uploaded',
          aggregateType: 'media',
          aggregateId: kyc.id,
        }),
      }),
    );
  });

  it('leaves Request images PENDING_PROCESSING even when NODE_ENV!=production', async () => {
    const row = mediaRow();
    vi.mocked(repo.findByKey).mockResolvedValueOnce(row);
    const pending = { ...row, state: 'PENDING_PROCESSING' as const };
    vi.mocked(repo.markState).mockResolvedValueOnce(pending);

    const result = await build({ NODE_ENV: 'development' }).complete(customerViewer, row.key);

    expect(result.state).toBe('PENDING_PROCESSING');
    expect(repo.markState).toHaveBeenCalledWith(
      expect.anything(),
      row.key,
      'PENDING_PROCESSING',
      expect.objectContaining({ malwareScanState: 'PENDING', exifStripped: false }),
    );
    const payload = vi.mocked(outboxCreate).mock.calls[0]?.[0]?.data?.payload as {
      objectKey?: string;
    };
    expect(payload.objectKey).toContain(row.key);
  });

  it('never short-circuits KYC in production', async () => {
    const kyc = mediaRow({
      purpose: 'KYC_DOCUMENT',
      bucket: 'KYC',
      contentType: 'application/pdf',
    });
    vi.mocked(repo.findByKey).mockResolvedValueOnce(kyc);
    vi.mocked(storage.headObject).mockResolvedValueOnce({
      exists: true,
      size: 12,
      contentType: 'application/pdf',
    });
    vi.mocked(repo.markState).mockResolvedValueOnce({
      ...kyc,
      state: 'PENDING_PROCESSING',
    });

    const result = await build({ NODE_ENV: 'production' }).complete(vendorViewer, kyc.key);

    expect(result.state).toBe('PENDING_PROCESSING');
    expect(repo.markState).toHaveBeenCalledWith(
      expect.anything(),
      kyc.key,
      'PENDING_PROCESSING',
      expect.anything(),
    );
  });

  it('is idempotent once PENDING_PROCESSING or READY', async () => {
    vi.mocked(repo.findByKey).mockResolvedValueOnce(mediaRow({ state: 'PENDING_PROCESSING' }));
    const result = await build({}).complete(customerViewer, '22222222-2222-2222-2222-222222222222');
    expect(result.state).toBe('PENDING_PROCESSING');
    expect(repo.markState).not.toHaveBeenCalled();
    expect(outboxCreate).not.toHaveBeenCalled();
  });

  it('throws UPLOAD_NOT_COMPLETED when the object is missing', async () => {
    vi.mocked(repo.findByKey).mockResolvedValueOnce(mediaRow());
    vi.mocked(storage.headObject).mockResolvedValueOnce(null);

    await expect(
      build({}).complete(customerViewer, '22222222-2222-2222-2222-222222222222'),
    ).rejects.toMatchObject({ errorCode: ErrorCode.UPLOAD_NOT_COMPLETED });
  });

  it('accepts an upload smaller than the declared byteSize (prefetched-intent placeholder) and persists the real size', async () => {
    const row = mediaRow({ byteSize: 5 * 1024 * 1024, contentType: 'image/avif' });
    vi.mocked(repo.findByKey).mockResolvedValueOnce(row);
    vi.mocked(storage.headObject).mockResolvedValueOnce({
      exists: true,
      size: 812_000,
      contentType: 'image/avif',
    });
    const pending = { ...row, state: 'PENDING_PROCESSING' as const, byteSize: 812_000 };
    vi.mocked(repo.markState).mockResolvedValueOnce(pending);

    const result = await build({}).complete(customerViewer, row.key);

    expect(result.state).toBe('PENDING_PROCESSING');
    expect(repo.markState).toHaveBeenCalledWith(
      expect.anything(),
      row.key,
      'PENDING_PROCESSING',
      expect.objectContaining({ byteSize: 812_000 }),
    );
  });

  it('rejects an upload larger than the declared byteSize', async () => {
    const row = mediaRow({ byteSize: 1000 });
    vi.mocked(repo.findByKey).mockResolvedValueOnce(row);
    vi.mocked(storage.headObject).mockResolvedValueOnce({
      exists: true,
      size: 1001,
      contentType: 'image/jpeg',
    });

    await expect(build({}).complete(customerViewer, row.key)).rejects.toMatchObject({
      errorCode: ErrorCode.UPLOAD_NOT_COMPLETED,
    });
    expect(repo.markState).not.toHaveBeenCalled();
  });

  describe('createIntent — image/avif allow-list', () => {
    it('accepts image/avif for REQUEST_IMAGE', async () => {
      vi.mocked(repo.create).mockResolvedValueOnce(
        mediaRow({ contentType: 'image/avif', byteSize: 5 * 1024 * 1024 }),
      );

      const intent = await build({}).createIntent(customerViewer, {
        purpose: 'REQUEST_IMAGE',
        contentType: 'image/avif',
        byteSize: 5 * 1024 * 1024,
      });

      expect(intent.uploadUrl).toBe('https://storage.example/upload');
    });

    it('accepts image/avif for OFFER_IMAGE and KYC_DOCUMENT', async () => {
      vi.mocked(repo.create).mockResolvedValue(mediaRow({ contentType: 'image/avif' }));

      await expect(
        build({}).createIntent(vendorViewer, {
          purpose: 'OFFER_IMAGE',
          contentType: 'image/avif',
          byteSize: 1000,
        }),
      ).resolves.toBeDefined();
      await expect(
        build({}).createIntent(vendorViewer, {
          purpose: 'KYC_DOCUMENT',
          contentType: 'image/avif',
          byteSize: 1000,
        }),
      ).resolves.toBeDefined();
    });

    it('still rejects image/avif for purposes not in scope (e.g. PROFILE_PHOTO)', async () => {
      await expect(
        build({}).createIntent(customerViewer, {
          purpose: 'PROFILE_PHOTO',
          contentType: 'image/avif',
          byteSize: 1000,
        }),
      ).rejects.toMatchObject({ errorCode: ErrorCode.MEDIA_TYPE_REJECTED });
      expect(repo.create).not.toHaveBeenCalled();
    });
  });

  describe('resolveMediaUrlOrStream (ADM-API-GAP-04)', () => {
    it('returns redirect when signed download url is an http/https url', async () => {
      vi.mocked(repo.findByKey).mockResolvedValue(
        mediaRow({ key: 'img-1', state: 'READY', purpose: 'REQUEST_IMAGE', uploadedByUserId: 'user-1' }),
      );
      vi.mocked(storage.createSignedDownloadUrl).mockResolvedValue({
        url: 'https://storage.supabase.co/object/sign/req.jpg',
        expiresAt: new Date(),
      });

      const svc = build({});
      const result = await svc.resolveMediaUrlOrStream('img-1');
      expect(result).toEqual({
        type: 'redirect',
        url: 'https://storage.supabase.co/object/sign/req.jpg',
      });
    });

    it('returns stream buffer when signed download url is local disk storage', async () => {
      vi.mocked(repo.findByKey).mockResolvedValue(
        mediaRow({ key: 'img-2', state: 'READY', purpose: 'REQUEST_IMAGE', uploadedByUserId: 'user-1' }),
      );
      vi.mocked(storage.createSignedDownloadUrl).mockResolvedValue({
        url: 'local://request-media/req.jpg',
        expiresAt: new Date(),
      });
      vi.mocked(storage.getObject).mockResolvedValue(Buffer.from('fake-image-bytes'));

      const svc = build({});
      const result = await svc.resolveMediaUrlOrStream('img-2');
      expect(result).toEqual({
        type: 'stream',
        buffer: Buffer.from('fake-image-bytes'),
        contentType: 'image/jpeg',
      });
    });

    describe('thumbnail keys', () => {
      const thumbRow = mediaRow({
        key: 'img-3',
        state: 'READY',
        purpose: 'REQUEST_IMAGE',
        uploadedByUserId: 'user-1',
        thumbnailKey: 'img-3.thumb',
      });

      beforeEach(() => {
        vi.mocked(repo.findByKey).mockResolvedValue(null);
        vi.mocked(prisma.media.findFirst).mockResolvedValue(thumbRow);
        vi.mocked(storage.createSignedDownloadUrl).mockImplementation(async (_b, key) => ({
          url: `https://storage.example/${key}`,
          expiresAt: new Date(),
        }));
      });

      it('signs the thumbnail stored beside the original object', async () => {
        const result = await build({}).resolveMediaUrlOrStream('img-3.thumb');
        expect(result).toEqual({
          type: 'redirect',
          url: 'https://storage.example/user/user-1/REQUEST_IMAGE/img-3.thumb',
        });
      });

      it('falls back to a legacy bucket-root thumbnail', async () => {
        vi.mocked(storage.headObject)
          .mockResolvedValueOnce(null)
          .mockResolvedValueOnce({ exists: true, size: 12, contentType: 'image/jpeg' });
        const result = await build({}).resolveMediaUrlOrStream('img-3.thumb');
        expect(result).toEqual({ type: 'redirect', url: 'https://storage.example/img-3.thumb' });
      });

      it('falls back to the original when no thumbnail object exists', async () => {
        vi.mocked(storage.headObject).mockResolvedValue(null);
        const result = await build({}).resolveMediaUrlOrStream('img-3.thumb');
        expect(result).toEqual({
          type: 'redirect',
          url: 'https://storage.example/user/user-1/REQUEST_IMAGE/img-3',
        });
      });
    });

    it('throws 404 if media is missing', async () => {
      vi.mocked(repo.findByKey).mockResolvedValue(null);
      const svc = build({});
      await expect(svc.resolveMediaUrlOrStream('non-existent')).rejects.toMatchObject({
        errorCode: ErrorCode.NOT_FOUND,
      });
    });

    it('throws FORBIDDEN if media is quarantined', async () => {
      vi.mocked(repo.findByKey).mockResolvedValue(
        mediaRow({ key: 'img-q', state: 'QUARANTINED' }),
      );
      const svc = build({});
      await expect(svc.resolveMediaUrlOrStream('img-q')).rejects.toMatchObject({
        errorCode: ErrorCode.MEDIA_QUARANTINED,
      });
    });
  });
});
