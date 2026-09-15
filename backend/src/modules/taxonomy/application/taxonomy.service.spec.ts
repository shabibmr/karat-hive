import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import type { Category } from '@prisma/client';
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

  const mockCategory: Category = {
    id: 'cat-1',
    nameEn: 'Gold Jewellery',
    nameAr: 'مجوهرات ذهبية',
    icon: null,
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
      list: vi.fn(),
      listCategories: vi.fn(),
      listRegions: vi.fn(),
      findById: vi.fn(),
      findCategoryById: vi.fn(),
      findRegionById: vi.fn(),
      countReferences: vi.fn(),
      create: vi.fn(),
      createCategory: vi.fn(),
      createRegion: vi.fn(),
      update: vi.fn(),
      updateCategory: vi.fn(),
      updateRegion: vi.fn(),
      deactivate: vi.fn(),
      deactivateCategory: vi.fn(),
      deactivateRegion: vi.fn(),
      delete: vi.fn(),
      countActiveCategories: vi.fn(),
      countActiveRegions: vi.fn(),
    } as unknown as TaxonomyRepository;

    audit = {
      append: vi.fn().mockResolvedValue(undefined),
    } as unknown as AuditWriter;

    service = new TaxonomyService(prisma, repo, audit);
  });

  describe('create', () => {
    it('creates a category and records audit row', async () => {
      vi.mocked(repo.create).mockResolvedValue(mockCategory);

      const result = await service.createCategory(
        { nameEn: 'Gold Jewellery', nameAr: 'مجوهرات ذهبية' },
        mockAdminViewer,
        clientInfo,
      );

      expect(result.id).toBe('cat-1');
      expect(result.nameEn).toBe('Gold Jewellery');
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'CATEGORY_CREATE',
          entityType: 'category',
          actorUserId: 'admin-1',
          beforeValue: null,
          afterValue: expect.objectContaining({ nameEn: 'Gold Jewellery' }),
        }),
      );
    });

    it('rejects blank nameEn or nameAr with 422 VALIDATION_FAILED', async () => {
      await expect(
        service.createCategory({ nameEn: '   ', nameAr: 'مجوهرات' }, mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errorCode: ErrorCode.VALIDATION_FAILED,
      });

      await expect(
        service.createCategory({ nameEn: 'Jewellery', nameAr: '   ' }, mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errorCode: ErrorCode.VALIDATION_FAILED,
      });
    });
  });

  describe('update', () => {
    it('updates a category name and records audit row with before and after', async () => {
      vi.mocked(repo.findById).mockResolvedValue(mockCategory);
      vi.mocked(repo.update).mockResolvedValue({
        ...mockCategory,
        nameEn: 'Fine Jewellery',
      });

      const result = await service.updateCategory(
        'cat-1',
        { nameEn: 'Fine Jewellery' },
        mockAdminViewer,
        clientInfo,
      );

      expect(result.nameEn).toBe('Fine Jewellery');
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'CATEGORY_UPDATE',
          entityType: 'category',
          actorUserId: 'admin-1',
          beforeValue: expect.objectContaining({ nameEn: 'Gold Jewellery' }),
          afterValue: expect.objectContaining({ nameEn: 'Fine Jewellery' }),
        }),
      );
    });

    it('rejects blank nameEn on patch with 422 VALIDATION_FAILED', async () => {
      vi.mocked(repo.findById).mockResolvedValue(mockCategory);

      await expect(
        service.updateCategory('cat-1', { nameEn: '   ' }, mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errorCode: ErrorCode.VALIDATION_FAILED,
      });
    });
  });

  describe('deactivate', () => {
    it('deactivates category even when in-use, preserving associations, and audits action', async () => {
      vi.mocked(repo.findById).mockResolvedValue(mockCategory);
      vi.mocked(repo.deactivate).mockResolvedValue({
        ...mockCategory,
        isActive: false,
      });

      const result = await service.deactivateCategory('cat-1', mockAdminViewer, clientInfo);

      expect(result.isActive).toBe(false);
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'CATEGORY_DEACTIVATE',
          entityType: 'category',
          actorUserId: 'admin-1',
          beforeValue: { isActive: true },
          afterValue: { isActive: false },
        }),
      );
    });

    it('throws 404 NOT_FOUND when deactivating a non-existent category', async () => {
      vi.mocked(repo.findById).mockResolvedValue(null);

      await expect(
        service.deactivateCategory('non-existent', mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.NOT_FOUND,
        errorCode: ErrorCode.NOT_FOUND,
      });
    });
  });

  describe('delete & TAXONOMY_IN_USE', () => {
    it('throws 409 TAXONOMY_IN_USE when attempting to delete a category referenced by requests or vendors', async () => {
      vi.mocked(repo.findById).mockResolvedValue(mockCategory);
      vi.mocked(repo.countReferences).mockResolvedValue(5); // 5 active references!

      await expect(
        service.delete('category', 'cat-1', mockAdminViewer, clientInfo),
      ).rejects.toMatchObject({
        status: HttpStatus.CONFLICT,
        errorCode: ErrorCode.TAXONOMY_IN_USE,
      });
    });

    it('deletes category and emits audit entry when reference count is 0', async () => {
      vi.mocked(repo.findById).mockResolvedValue(mockCategory);
      vi.mocked(repo.countReferences).mockResolvedValue(0);
      vi.mocked(repo.delete).mockResolvedValue(mockCategory);

      await service.delete('category', 'cat-1', mockAdminViewer, clientInfo);

      expect(repo.delete).toHaveBeenCalledWith('category', 'cat-1', expect.anything());
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          action: 'CATEGORY_DELETE',
          entityType: 'category',
          entityId: 'cat-1',
        }),
      );
    });
  });
});
