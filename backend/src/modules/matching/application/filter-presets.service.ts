import { HttpStatus, Injectable } from '@nestjs/common';
import type { FilterPreset } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { FilterPresetsRepository } from '../repository/filter-presets.repository';

export type FilterPresetView = {
  id: string;
  name: string;
  filters: unknown;
  createdAt: string;
};

export function presentFilterPreset(preset: FilterPreset): FilterPresetView {
  return {
    id: preset.id,
    name: preset.name,
    filters: preset.filters,
    createdAt: preset.createdAt.toISOString(),
  };
}

@Injectable()
export class FilterPresetsService {
  constructor(private readonly repository: FilterPresetsRepository) {}

  async list(vendorProfileId: string): Promise<FilterPresetView[]> {
    const presets = await this.repository.listByVendor(vendorProfileId);
    return presets.map(presentFilterPreset);
  }

  async get(id: string, vendorProfileId: string): Promise<FilterPresetView> {
    const preset = await this.repository.findById(id, vendorProfileId);
    if (!preset) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return presentFilterPreset(preset);
  }

  async create(
    vendorProfileId: string,
    name: string,
    filters: Record<string, unknown>,
  ): Promise<FilterPresetView> {
    const created = await this.repository.create(vendorProfileId, name.trim(), filters);
    return presentFilterPreset(created);
  }

  async update(
    id: string,
    vendorProfileId: string,
    data: { name?: string; filters?: Record<string, unknown> },
  ): Promise<FilterPresetView> {
    const updated = await this.repository.update(id, vendorProfileId, {
      ...(data.name !== undefined && { name: data.name.trim() }),
      ...(data.filters !== undefined && { filters: data.filters }),
    });

    if (!updated) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return presentFilterPreset(updated);
  }

  async delete(id: string, vendorProfileId: string): Promise<void> {
    const deleted = await this.repository.delete(id, vendorProfileId);
    if (!deleted) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
  }
}
