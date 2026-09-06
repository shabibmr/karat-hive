import { Injectable } from '@nestjs/common';
import type { FilterPreset, Prisma } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';

@Injectable()
export class FilterPresetsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async listByVendor(vendorProfileId: string): Promise<FilterPreset[]> {
    return this.prisma.filterPreset.findMany({
      where: { vendorProfileId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findById(id: string, vendorProfileId: string): Promise<FilterPreset | null> {
    return this.prisma.filterPreset.findFirst({
      where: { id, vendorProfileId },
    });
  }

  async create(
    vendorProfileId: string,
    name: string,
    filters: Record<string, unknown>,
  ): Promise<FilterPreset> {
    return this.prisma.filterPreset.create({
      data: {
        vendorProfileId,
        name,
        filters: filters as Prisma.InputJsonValue,
      },
    });
  }

  async update(
    id: string,
    vendorProfileId: string,
    data: { name?: string; filters?: Record<string, unknown> },
  ): Promise<FilterPreset | null> {
    const existing = await this.findById(id, vendorProfileId);
    if (!existing) return null;

    return this.prisma.filterPreset.update({
      where: { id },
      data: {
        ...(data.name !== undefined && { name: data.name }),
        ...(data.filters !== undefined && { filters: data.filters as Prisma.InputJsonValue }),
      },
    });
  }

  async delete(id: string, vendorProfileId: string): Promise<boolean> {
    const existing = await this.findById(id, vendorProfileId);
    if (!existing) return false;

    await this.prisma.filterPreset.delete({
      where: { id },
    });
    return true;
  }
}
