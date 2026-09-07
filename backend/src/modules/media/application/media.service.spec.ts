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
    } as unknown as MediaRepository;
    storage = {
      headObject: vi.fn().mockResolvedValue({ exists: true, size: 12, contentType: 'image/jpeg' }),
    } as unknown as ObjectStorage;
    prisma = {
      $transaction: vi.fn(async (fn: (tx: unknown) => Promise<unknown>) =>
        fn({ outboxEvent: { create: outboxCreate } }),
      ),
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
});
