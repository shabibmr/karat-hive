import { Injectable } from '@nestjs/common';
import type { Region } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';

export type CreateTaxonomyInput = {
  nameEn: string;
  nameAr: string;
  displayOrder?: number;
  isActive?: boolean;
};

export type UpdateTaxonomyInput = {
  nameEn?: string;
  nameAr?: string;
  displayOrder?: number;
  isActive?: boolean;
};

@Injectable()
export class TaxonomyRepository {
  constructor(private readonly prisma: PrismaService) {}

  listRegions(options?: { includeInactive?: boolean }): Promise<Region[]> {
    const where = options?.includeInactive ? {} : { isActive: true };
    return this.prisma.region.findMany({
      where,
      orderBy: [{ displayOrder: 'asc' }, { nameEn: 'asc' }],
    });
  }

  findRegionById(id: string, tx?: DbTx): Promise<Region | null> {
    const client = tx ?? this.prisma;
    return client.region.findUnique({ where: { id } });
  }

  async countReferences(id: string, tx?: DbTx): Promise<number> {
    const client = tx ?? this.prisma;
    const [requests, vendors, customers] = await Promise.all([
      client.request.count({ where: { regionId: id } }),
      client.vendorRegion.count({ where: { regionId: id } }),
      client.customerProfile.count({ where: { defaultRegionId: id } }),
    ]);
    return requests + vendors + customers;
  }

  async createRegion(input: CreateTaxonomyInput, tx?: DbTx): Promise<Region> {
    const client = tx ?? this.prisma;
    const maxOrder =
      input.displayOrder ??
      ((await client.region.aggregate({ _max: { displayOrder: true } }))._max.displayOrder ??
        -1) + 1;

    return client.region.create({
      data: {
        nameEn: input.nameEn,
        nameAr: input.nameAr,
        displayOrder: maxOrder,
        isActive: input.isActive ?? true,
      },
    });
  }

  updateRegion(id: string, input: UpdateTaxonomyInput, tx?: DbTx): Promise<Region> {
    const client = tx ?? this.prisma;
    return client.region.update({
      where: { id },
      data: {
        ...(input.nameEn !== undefined ? { nameEn: input.nameEn } : {}),
        ...(input.nameAr !== undefined ? { nameAr: input.nameAr } : {}),
        ...(input.displayOrder !== undefined ? { displayOrder: input.displayOrder } : {}),
        ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
      },
    });
  }

  deactivateRegion(id: string, tx?: DbTx): Promise<Region> {
    const client = tx ?? this.prisma;
    return client.region.update({
      where: { id },
      data: { isActive: false },
    });
  }

  deleteRegion(id: string, tx?: DbTx): Promise<Region> {
    const client = tx ?? this.prisma;
    return client.region.delete({ where: { id } });
  }

  async countActiveRegions(ids: string[]): Promise<number> {
    if (ids.length === 0) return 0;
    return this.prisma.region.count({ where: { id: { in: ids }, isActive: true } });
  }
}
