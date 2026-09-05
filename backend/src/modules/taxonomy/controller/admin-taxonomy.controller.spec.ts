import { describe, expect, it, vi, beforeEach } from 'vitest';
import type { FastifyRequest } from 'fastify';
import { AdminTaxonomyController } from './admin-taxonomy.controller';
import type { TaxonomyService } from '../application/taxonomy.service';
import type { ViewerContext } from '../../../edge/auth/viewer-context';

describe('AdminTaxonomyController', () => {
  let controller: AdminTaxonomyController;
  let service: TaxonomyService;

  const mockViewer: ViewerContext = {
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

  const mockRequest = {
    ip: '127.0.0.1',
    headers: { 'user-agent': 'admin-web' },
  } as unknown as FastifyRequest;

  beforeEach(() => {
    service = {
      listTree: vi.fn(),
      createCategory: vi.fn(),
      updateCategory: vi.fn(),
      deactivateCategory: vi.fn(),
      createRegion: vi.fn(),
      updateRegion: vi.fn(),
      deactivateRegion: vi.fn(),
    } as unknown as TaxonomyService;

    controller = new AdminTaxonomyController(service);
  });

  it('getCategories delegates to taxonomyService.listTree with default includeInactive=true', async () => {
    vi.mocked(service.listTree).mockResolvedValue([]);

    await controller.getCategories();

    expect(service.listTree).toHaveBeenCalledWith('category', { includeInactive: true });
  });

  it('getCategories supports includeInactive=false query param', async () => {
    vi.mocked(service.listTree).mockResolvedValue([]);

    await controller.getCategories('false');

    expect(service.listTree).toHaveBeenCalledWith('category', { includeInactive: false });
  });

  it('createCategory delegates to taxonomyService.createCategory', async () => {
    const dto = { nameEn: 'Jewellery', nameAr: 'مجوهرات' };
    vi.mocked(service.createCategory).mockResolvedValue({
      id: 'cat-1',
      nameEn: 'Jewellery',
      nameAr: 'مجوهرات',
      parentId: null,
      isActive: true,
      displayOrder: 0,
    });

    const result = await controller.createCategory(mockViewer, mockRequest, dto);

    expect(result.id).toBe('cat-1');
    expect(service.createCategory).toHaveBeenCalledWith(
      dto,
      mockViewer,
      expect.objectContaining({ ip: '127.0.0.1', userAgent: 'admin-web' }),
    );
  });

  it('updateCategory delegates to taxonomyService.updateCategory', async () => {
    const dto = { nameEn: 'Fine Jewellery' };
    vi.mocked(service.updateCategory).mockResolvedValue({
      id: 'cat-1',
      nameEn: 'Fine Jewellery',
      nameAr: 'مجوهرات',
      parentId: null,
      isActive: true,
      displayOrder: 0,
    });

    const result = await controller.updateCategory('cat-1', mockViewer, mockRequest, dto);

    expect(result.nameEn).toBe('Fine Jewellery');
    expect(service.updateCategory).toHaveBeenCalledWith(
      'cat-1',
      dto,
      mockViewer,
      expect.objectContaining({ ip: '127.0.0.1' }),
    );
  });

  it('deactivateCategory delegates to taxonomyService.deactivateCategory', async () => {
    vi.mocked(service.deactivateCategory).mockResolvedValue({
      id: 'cat-1',
      nameEn: 'Jewellery',
      nameAr: 'مجوهرات',
      parentId: null,
      isActive: false,
      displayOrder: 0,
    });

    const result = await controller.deactivateCategory('cat-1', mockViewer, mockRequest);

    expect(result.isActive).toBe(false);
    expect(service.deactivateCategory).toHaveBeenCalledWith(
      'cat-1',
      mockViewer,
      expect.objectContaining({ ip: '127.0.0.1' }),
    );
  });

  it('getRegions delegates to taxonomyService.listTree with default includeInactive=true', async () => {
    vi.mocked(service.listTree).mockResolvedValue([]);

    await controller.getRegions();

    expect(service.listTree).toHaveBeenCalledWith('region', { includeInactive: true });
  });

  it('createRegion delegates to taxonomyService.createRegion', async () => {
    const dto = { nameEn: 'Dubai', nameAr: 'دبي' };
    vi.mocked(service.createRegion).mockResolvedValue({
      id: 'reg-1',
      nameEn: 'Dubai',
      nameAr: 'دبي',
      parentId: null,
      isActive: true,
      displayOrder: 0,
    });

    const result = await controller.createRegion(mockViewer, mockRequest, dto);

    expect(result.id).toBe('reg-1');
    expect(service.createRegion).toHaveBeenCalledWith(
      dto,
      mockViewer,
      expect.objectContaining({ ip: '127.0.0.1' }),
    );
  });

  it('updateRegion delegates to taxonomyService.updateRegion', async () => {
    const dto = { nameEn: 'Emirate of Dubai' };
    vi.mocked(service.updateRegion).mockResolvedValue({
      id: 'reg-1',
      nameEn: 'Emirate of Dubai',
      nameAr: 'دبي',
      parentId: null,
      isActive: true,
      displayOrder: 0,
    });

    const result = await controller.updateRegion('reg-1', mockViewer, mockRequest, dto);

    expect(result.nameEn).toBe('Emirate of Dubai');
    expect(service.updateRegion).toHaveBeenCalledWith(
      'reg-1',
      dto,
      mockViewer,
      expect.objectContaining({ ip: '127.0.0.1' }),
    );
  });

  it('deactivateRegion delegates to taxonomyService.deactivateRegion', async () => {
    vi.mocked(service.deactivateRegion).mockResolvedValue({
      id: 'reg-1',
      nameEn: 'Dubai',
      nameAr: 'دبي',
      parentId: null,
      isActive: false,
      displayOrder: 0,
    });

    const result = await controller.deactivateRegion('reg-1', mockViewer, mockRequest);

    expect(result.isActive).toBe(false);
    expect(service.deactivateRegion).toHaveBeenCalledWith(
      'reg-1',
      mockViewer,
      expect.objectContaining({ ip: '127.0.0.1' }),
    );
  });
});
