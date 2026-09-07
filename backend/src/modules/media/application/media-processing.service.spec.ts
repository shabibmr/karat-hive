import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { Media } from '@prisma/client';
import type { Env } from '../../../config/env';
import type { ObjectStorage } from '../../../platform/ports/storage.port';
import type { OutboxDispatcher } from '../../../platform/outbox/outbox.dispatcher';
import { EICAR_SIGNATURE } from '../domain/media-pipeline';
import { thumbnailStorageKey } from '../domain/media-rules';
import type { MediaRepository } from '../repository/media.repository';
import { MediaConsumer } from './media.consumer';
import { MediaProcessingService } from './media-processing.service';

function jpegWithGpsExif(): Buffer {
  const exifPayload = Buffer.from('Exif\0\0GPS\0home');
  const app1Len = 2 + exifPayload.length;
  return Buffer.concat([
    Buffer.from([0xff, 0xd8]),
    Buffer.from([0xff, 0xe1, (app1Len >> 8) & 0xff, app1Len & 0xff]),
    exifPayload,
    Buffer.from([0xff, 0xd9]),
  ]);
}

function mediaRow(overrides: Partial<Media> = {}): Media {
  return {
    id: 'media-1',
    key: '11111111-1111-1111-1111-111111111111',
    purpose: 'REQUEST_IMAGE',
    state: 'PENDING_PROCESSING',
    bucket: 'REQUEST_MEDIA',
    contentType: 'image/jpeg',
    byteSize: 32,
    exifStripped: false,
    malwareScanState: 'PENDING',
    thumbnailKey: null,
    uploadedByUserId: 'user-1',
    createdAt: new Date('2026-09-07T00:00:00Z'),
    updatedAt: new Date('2026-09-07T00:00:00Z'),
    ...overrides,
  };
}

describe('MediaProcessingService (G2-P02)', () => {
  const env = { NODE_ENV: 'test', SUPABASE_STORAGE_BUCKET_KYC: 'kyc' } as Env;
  const objectKey = 'user/user-1/REQUEST_IMAGE/11111111-1111-1111-1111-111111111111';

  let repo: MediaRepository;
  let storage: ObjectStorage;
  let service: MediaProcessingService;

  beforeEach(() => {
    repo = {
      findById: vi.fn(),
      findByKey: vi.fn(),
      updateByKey: vi.fn().mockImplementation(async (key: string, data: Partial<Media>) => ({
        ...mediaRow(),
        key,
        ...data,
      })),
    } as unknown as MediaRepository;

    storage = {
      getObject: vi.fn(),
      putObject: vi.fn().mockResolvedValue(undefined),
    } as unknown as ObjectStorage;

    service = new MediaProcessingService(env, storage, repo);
  });

  function event(payload: Record<string, unknown> = {}) {
    return {
      id: 'evt-1',
      aggregateId: 'media-1',
      payload: {
        mediaId: 'media-1',
        key: '11111111-1111-1111-1111-111111111111',
        objectKey,
        purpose: 'REQUEST_IMAGE',
        bucket: 'REQUEST_MEDIA',
        ...payload,
      },
    };
  }

  it('no-ops when the row is already READY (idempotent)', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(mediaRow({ state: 'READY' }));
    await service.processUploaded(event());
    expect(storage.getObject).not.toHaveBeenCalled();
    expect(repo.updateByKey).not.toHaveBeenCalled();
  });

  it('no-ops when the row is already QUARANTINED', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(mediaRow({ state: 'QUARANTINED' }));
    await service.processUploaded(event());
    expect(storage.getObject).not.toHaveBeenCalled();
  });

  it('returns without throwing when the media row is gone', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(null);
    vi.mocked(repo.findByKey).mockResolvedValueOnce(null);
    await service.processUploaded(event());
    expect(storage.getObject).not.toHaveBeenCalled();
  });

  it('strips EXIF, writes a thumbnail, and marks READY', async () => {
    const raw = jpegWithGpsExif();
    vi.mocked(repo.findById).mockResolvedValueOnce(mediaRow({ byteSize: raw.length }));
    vi.mocked(storage.getObject).mockResolvedValueOnce(raw);

    await service.processUploaded(event());

    expect(storage.putObject).toHaveBeenCalledTimes(2);
    const originalPut = vi.mocked(storage.putObject).mock.calls[0];
    expect(originalPut?.[1]).toBe(objectKey);
    expect(originalPut?.[2]?.includes('Exif')).toBe(false);
    expect(originalPut?.[2]?.includes('GPS')).toBe(false);

    const thumbKey = thumbnailStorageKey('11111111-1111-1111-1111-111111111111');
    expect(storage.putObject).toHaveBeenCalledWith(
      'request-media',
      thumbKey,
      expect.any(Buffer),
      'image/jpeg',
    );
    expect(repo.updateByKey).toHaveBeenCalledWith(
      '11111111-1111-1111-1111-111111111111',
      expect.objectContaining({
        state: 'READY',
        malwareScanState: 'CLEAN',
        exifStripped: true,
        thumbnailKey: thumbKey,
      }),
    );
  });

  it('quarantines type-mismatch (PDF posing as jpeg)', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(mediaRow());
    vi.mocked(storage.getObject).mockResolvedValueOnce(Buffer.from('%PDF-1.4\n'));

    await service.processUploaded(event());

    expect(repo.updateByKey).toHaveBeenCalledWith(
      '11111111-1111-1111-1111-111111111111',
      expect.objectContaining({
        state: 'QUARANTINED',
        malwareScanState: 'QUARANTINED',
      }),
    );
    expect(storage.putObject).not.toHaveBeenCalled();
  });

  it('quarantines the EICAR malware stub', async () => {
    const infected = Buffer.concat([
      Buffer.from([0xff, 0xd8, 0xff, 0xd9]),
      Buffer.from(EICAR_SIGNATURE),
    ]);
    vi.mocked(repo.findById).mockResolvedValueOnce(mediaRow({ byteSize: infected.length }));
    vi.mocked(storage.getObject).mockResolvedValueOnce(infected);

    await service.processUploaded(event());

    expect(repo.updateByKey).toHaveBeenCalledWith(
      '11111111-1111-1111-1111-111111111111',
      expect.objectContaining({ state: 'QUARANTINED', malwareScanState: 'QUARANTINED' }),
    );
  });

  it('marks a clean PDF READY without a thumbnail', async () => {
    const pdf = Buffer.from('%PDF-1.4\n1 0 obj\nendobj\n%%EOF\n');
    vi.mocked(repo.findById).mockResolvedValueOnce(
      mediaRow({
        purpose: 'KYC_DOCUMENT',
        bucket: 'KYC',
        contentType: 'application/pdf',
        byteSize: pdf.length,
      }),
    );
    vi.mocked(storage.getObject).mockResolvedValueOnce(pdf);

    await service.processUploaded(
      event({ purpose: 'KYC_DOCUMENT', bucket: 'KYC', objectKey: 'vendor/vp-1/KYC_DOCUMENT/k' }),
    );

    expect(storage.putObject).toHaveBeenCalledTimes(1);
    expect(repo.updateByKey).toHaveBeenCalledWith(
      '11111111-1111-1111-1111-111111111111',
      expect.objectContaining({
        state: 'READY',
        malwareScanState: 'CLEAN',
        exifStripped: true,
        thumbnailKey: null,
      }),
    );
  });

  it('throws when the object is missing so the outbox can retry', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(mediaRow());
    vi.mocked(storage.getObject).mockResolvedValueOnce(null);

    await expect(service.processUploaded(event())).rejects.toThrow(/media object missing/);
    expect(repo.updateByKey).not.toHaveBeenCalled();
  });
});

describe('MediaConsumer', () => {
  it('registers media:process on media.uploaded', () => {
    const register = vi.fn();
    const processing = { processUploaded: vi.fn() };
    const consumer = new MediaConsumer(
      { register } as unknown as OutboxDispatcher,
      processing as unknown as MediaProcessingService,
    );
    consumer.onModuleInit();
    expect(register).toHaveBeenCalledWith('media.uploaded', 'media:process', expect.any(Function));
  });
});
