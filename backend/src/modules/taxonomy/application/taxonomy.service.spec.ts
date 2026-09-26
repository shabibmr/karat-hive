import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import type { Region } from '@prisma/client';
import { TaxonomyService } from './taxonomy.service';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { TaxonomyRepository } from '../repository/taxonomy.repository';
import type { AuditWriter } from '../../audit';

describe('TaxonomyService', () => {
  let service: TaxonomyService;
  let prisma: PrismaService;
  let repo: TaxonomyRepository;
  let audit: AuditWriter;

  const mockAdminViewer: ViewerContext = {
    userId: 'admin-1',
    role: 'ADMIN',
    tokenVersion: 1,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    vendorProfileId: null,
    vendorVerificationState: null,
    vendorActivatedAt: null,
    customerProfileId: null,
    adminProfileId: 'ap-1',
  };

  const clientInfo = { ip: '127.0.0.1', userAgent: 'vitest-agent' };

  const mockRegion: Region = {
    id: 'reg-1',
    nameEn: 'Deira',
    nameAr: 'ديرة',
    displayOrder: 0,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(() => {
    prisma = {
      $transaction: vi.fn().mockImplementation(async (cb) => cb({})),
    } as unknown as PrismaService;

    repo = {
      listRegions: vi.fn(),
      findRegionById: vi.fn(),
      countReferences: vi.fn(),
      createRegion: vi.fn(),
      updateRegion: vi.fn(),
      deactivateRegion: vi.fn(),
      deleteRegion: vi.fn(),
      countActiveRegions: vi.fn(),
    } as unknown as TaxonomyRepository;

    audit = {
      append: vi.fn().mockResolvedValue(undefined),
    } as unknown as AuditWriter;

    service = new TaxonomyService(prisma, repo, audit);
  });

  describe('createRegion', () => {
    it('creates a region and records audit row', async () => {
      vi.mocked(repo.createRegion).mockResolvedValue(mockRegion);

      const result = await service.createRegion(
        { nameEn: 'Deira', nameAr: 'ديرة' },
        mockAdminViewer,
        clientInfo,
      );

      expect(result.id).toBe('reg-1');
      expect(result.nameEn).toBe('Deira');
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'REGION_CREATE',
          entityType: 'region',
          actorUserId: 'admin-1',
          beforeValue: null,
          afterValue: expect.objectContaining({ nameEn: 'Deira' }),
        }),
      );
    });

    it('rejects blank nameEn or nameAr with 422 VALIDATION_FAILED', async () => {
      await expect(
        service.createRegion({ nameEn: '   ', nameAr: 'ديرة' }, mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errorCode: ErrorCode.VALIDATION_FAILED,
      });

      await expect(
        service.createRegion({ nameEn: 'Deira', nameAr: '   ' }, mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errorCode: ErrorCode.VALIDATION_FAILED,
      });
    });
  });

  describe('updateRegion', () => {
    it('updates a region name and records audit row with before and after', async () => {
      vi.mocked(repo.findRegionById).mockResolvedValue(mockRegion);
      vi.mocked(repo.updateRegion).mockResolvedValue({
        ...mockRegion,
        nameEn: 'Al Rigga',
      });

      const result = await service.updateRegion(
        'reg-1',
        { nameEn: 'Al Rigga' },
        mockAdminViewer,
        clientInfo,
      );

      expect(result.nameEn).toBe('Al Rigga');
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'REGION_UPDATE',
          entityType: 'region',
          actorUserId: 'admin-1',
          beforeValue: expect.objectContaining({ nameEn: 'Deira' }),
          afterValue: expect.objectContaining({ nameEn: 'Al Rigga' }),
        }),
      );
    });

    it('rejects blank nameEn on patch with 422 VALIDATION_FAILED', async () => {
      vi.mocked(repo.findRegionById).mockResolvedValue(mockRegion);

      await expect(
        service.updateRegion('reg-1', { nameEn: '   ' }, mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errorCode: ErrorCode.VALIDATION_FAILED,
      });
    });
  });

  describe('deactivateRegion', () => {
    it('deactivates region even when in-use, preserving associations, and audits action', async () => {
      vi.mocked(repo.findRegionById).mockResolvedValue(mockRegion);
      vi.mocked(repo.deactivateRegion).mockResolvedValue({
        ...mockRegion,
        isActive: false,
      });

      const result = await service.deactivateRegion('reg-1', mockAdminViewer, clientInfo);

      expect(result.isActive).toBe(false);
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'REGION_DEACTIVATE',
          entityType: 'region',
          actorUserId: 'admin-1',
          beforeValue: { isActive: true },
          afterValue: { isActive: false },
        }),
      );
    });

    it('throws 404 NOT_FOUND when deactivating a non-existent region', async () => {
      vi.mocked(repo.findRegionById).mockResolvedValue(null);

      await expect(
        service.deactivateRegion('non-existent', mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.NOT_FOUND,
        errorCode: ErrorCode.NOT_FOUND,
      });
    });
  });

  describe('deleteRegion & TAXONOMY_IN_USE', () => {
    it('throws 409 TAXONOMY_IN_USE when attempting to delete a region referenced by requests or vendors', async () => {
      vi.mocked(repo.findRegionById).mockResolvedValue(mockRegion);
      vi.mocked(repo.countReferences).mockResolvedValue(5); // 5 active references!

      await expect(
        service.deleteRegion('reg-1', mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.CONFLICT,
        errorCode: ErrorCode.TAXONOMY_IN_USE,
      });
    });

    it('deletes region and emits audit entry when reference count is 0', async () => {
      vi.mocked(repo.findRegionById).mockResolvedValue(mockRegion);
      vi.mocked(repo.countReferences).mockResolvedValue(0);
      vi.mocked(repo.deleteRegion).mockResolvedValue(mockRegion);

      await service.deleteRegion('reg-1', mockAdminViewer, clientInfo);

      expect(repo.deleteRegion).toHaveBeenCalledWith('reg-1', expect.anything());
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'REGION_DELETE',
          entityType: 'region',
          entityId: 'reg-1',
        }),
      );
    });
  });
});
