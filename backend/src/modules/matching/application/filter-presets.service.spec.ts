import { describe, expect, it, vi } from 'vitest';
import type { FilterPreset } from '@prisma/client';
import { FilterPresetsService } from './filter-presets.service';
import type { FilterPresetsRepository } from '../repository/filter-presets.repository';

describe('FilterPresetsService', () => {
  const fakeRepo = {
    listByVendor: vi.fn(),
    findById: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  } as unknown as FilterPresetsRepository;

  const service = new FilterPresetsService(fakeRepo);

  it('lists presets for a vendor', async () => {
    const fakePreset: FilterPreset = {
      id: 'preset-1',
      vendorProfileId: 'vendor-1',
      name: 'High Value Bullion',
      filters: { requestType: 'BULLION', budgetMin: 10000 },
      createdAt: new Date('2026-09-07T00:00:00.000Z'),
      updatedAt: new Date('2026-09-07T00:00:00.000Z'),
    };

    vi.mocked(fakeRepo.listByVendor).mockResolvedValue([fakePreset]);

    const result = await service.list('vendor-1');
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('preset-1');
    expect(result[0].name).toBe('High Value Bullion');
  });

  it('creates preset with trimmed name', async () => {
    const fakePreset: FilterPreset = {
      id: 'preset-2',
      vendorProfileId: 'vendor-1',
      name: 'Dubai Gold',
      filters: { regionId: 'reg-dxb' },
      createdAt: new Date('2026-09-07T00:00:00.000Z'),
      updatedAt: new Date('2026-09-07T00:00:00.000Z'),
    };

    vi.mocked(fakeRepo.create).mockResolvedValue(fakePreset);

    const result = await service.create('vendor-1', '  Dubai Gold  ', { regionId: 'reg-dxb' });
    expect(fakeRepo.create).toHaveBeenCalledWith('vendor-1', 'Dubai Gold', { regionId: 'reg-dxb' });
    expect(result.id).toBe('preset-2');
  });

  it('throws 404 when updating non-existent preset', async () => {
    vi.mocked(fakeRepo.update).mockResolvedValue(null);

    await expect(service.update('preset-999', 'vendor-1', { name: 'Updated' })).rejects.toMatchObject({
      status: 404,
    });
  });

  it('throws 404 when deleting non-existent preset', async () => {
    vi.mocked(fakeRepo.delete).mockResolvedValue(false);

    await expect(service.delete('preset-999', 'vendor-1')).rejects.toMatchObject({
      status: 404,
    });
  });
});
