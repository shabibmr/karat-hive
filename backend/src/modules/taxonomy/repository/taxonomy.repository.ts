import { Injectable } from '@nestjs/common';
import type { Category, Region } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';

export type TaxonomyKind = 'category' | 'region';

export type CreateTaxonomyInput = {
  nameEn: string;
  nameAr: string;
  parentId?: string | null;
  displayOrder?: number;
  isActive?: boolean;
};

export type UpdateTaxonomyInput = {
  nameEn?: string;
  nameAr?: string;
  parentId?: string | null;
  displayOrder?: number;
  isActive?: boolean;
};

@Injectable()
export class TaxonomyRepository {
  constructor(private readonly prisma: PrismaService) {}

  listCategories(options?: { includeInactive?: boolean }): Promise<Category[]> {
    const where = options?.includeInactive ? {} : { isActive: true };
    return this.prisma.category.findMany({
      where,
      orderBy: [{ displayOrder: 'asc' }, { nameEn: 'asc' }],
    });
  }

  listRegions(options?: { includeInactive?: boolean }): Promise<Region[]> {
    const where = options?.includeInactive ? {} : { isActive: true };
    return this.prisma.region.findMany({
      where,
      orderBy: [{ displayOrder: 'asc' }, { nameEn: 'asc' }],
    });
  }

  list(
    kind: TaxonomyKind,
    options?: { includeInactive?: boolean },
  ): Promise<(Category | Region)[]> {
    return kind === 'category' ? this.listCategories(options) : this.listRegions(options);
  }

  findById(kind: TaxonomyKind, id: string, tx?: DbTx): Promise<(Category | Region) | null> {
    const client = tx ?? this.prisma;
    return kind === 'category'
      ? client.category.findUnique({ where: { id } })
      : client.region.findUnique({ where: { id } });
  }

  findCategoryById(id: string, tx?: DbTx): Promise<Category | null> {
    const client = tx ?? this.prisma;
    return client.category.findUnique({ where: { id } });
  }

  findRegionById(id: string, tx?: DbTx): Promise<Region | null> {
    const client = tx ?? this.prisma;
    return client.region.findUnique({ where: { id } });
  }

  countChildren(kind: TaxonomyKind, id: string, tx?: DbTx): Promise<number> {
    const client = tx ?? this.prisma;
    return kind === 'category'
      ? client.category.count({ where: { parentId: id } })
      : client.region.count({ where: { parentId: id } });
  }

  async countReferences(kind: TaxonomyKind, id: string, tx?: DbTx): Promise<number> {
    const client = tx ?? this.prisma;
    if (kind === 'category') {
      const [requests, vendors, children] = await Promise.all([
        client.request.count({ where: { categoryId: id } }),
        client.vendorCategory.count({ where: { categoryId: id } }),
        client.category.count({ where: { parentId: id } }),
      ]);
      return requests + vendors + children;
    }
    const [requests, vendors, customers, children] = await Promise.all([
      client.request.count({ where: { regionId: id } }),
      client.vendorRegion.count({ where: { regionId: id } }),
      client.customerProfile.count({ where: { defaultRegionId: id } }),
      client.region.count({ where: { parentId: id } }),
    ]);
    return requests + vendors + customers + children;
  }

  async createCategory(input: CreateTaxonomyInput, tx?: DbTx): Promise<Category> {
    const client = tx ?? this.prisma;
    const maxOrder =
      input.displayOrder ??
      ((
        await client.category.aggregate({
          where: { parentId: input.parentId ?? null },
          _max: { displayOrder: true },
        })
      )._max.displayOrder ?? -1) + 1;

    return client.category.create({
      data: {
        nameEn: input.nameEn,
        nameAr: input.nameAr,
        parentId: input.parentId ?? null,
        displayOrder: maxOrder,
        isActive: input.isActive ?? true,
      },
    });
  }

  async createRegion(input: CreateTaxonomyInput, tx?: DbTx): Promise<Region> {
    const client = tx ?? this.prisma;
    const maxOrder =
      input.displayOrder ??
      ((
        await client.region.aggregate({
          where: { parentId: input.parentId ?? null },
          _max: { displayOrder: true },
        })
      )._max.displayOrder ?? -1) + 1;

    return client.region.create({
      data: {
        nameEn: input.nameEn,
        nameAr: input.nameAr,
        parentId: input.parentId ?? null,
        displayOrder: maxOrder,
        isActive: input.isActive ?? true,
      },
    });
  }

  create(kind: TaxonomyKind, input: CreateTaxonomyInput, tx?: DbTx): Promise<Category | Region> {
    return kind === 'category' ? this.createCategory(input, tx) : this.createRegion(input, tx);
  }

  updateCategory(id: string, input: UpdateTaxonomyInput, tx?: DbTx): Promise<Category> {
    const client = tx ?? this.prisma;
    return client.category.update({
      where: { id },
      data: {
        ...(input.nameEn !== undefined ? { nameEn: input.nameEn } : {}),
        ...(input.nameAr !== undefined ? { nameAr: input.nameAr } : {}),
        ...(input.parentId !== undefined ? { parentId: input.parentId } : {}),
        ...(input.displayOrder !== undefined ? { displayOrder: input.displayOrder } : {}),
        ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
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
        ...(input.parentId !== undefined ? { parentId: input.parentId } : {}),
        ...(input.displayOrder !== undefined ? { displayOrder: input.displayOrder } : {}),
        ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
      },
    });
  }

  update(
    kind: TaxonomyKind,
    id: string,
    input: UpdateTaxonomyInput,
    tx?: DbTx,
  ): Promise<Category | Region> {
    return kind === 'category'
      ? this.updateCategory(id, input, tx)
      : this.updateRegion(id, input, tx);
  }

  deactivateCategory(id: string, tx?: DbTx): Promise<Category> {
    const client = tx ?? this.prisma;
    return client.category.update({
      where: { id },
      data: { isActive: false },
    });
  }

  deactivateRegion(id: string, tx?: DbTx): Promise<Region> {
    const client = tx ?? this.prisma;
    return client.region.update({
      where: { id },
      data: { isActive: false },
    });
  }

  deactivate(kind: TaxonomyKind, id: string, tx?: DbTx): Promise<Category | Region> {
    return kind === 'category' ? this.deactivateCategory(id, tx) : this.deactivateRegion(id, tx);
  }

  delete(kind: TaxonomyKind, id: string, tx?: DbTx): Promise<Category | Region> {
    const client = tx ?? this.prisma;
    return kind === 'category'
      ? client.category.delete({ where: { id } })
      : client.region.delete({ where: { id } });
  }

  async countActiveCategories(ids: string[]): Promise<number> {
    if (ids.length === 0) return 0;
    return this.prisma.category.count({ where: { id: { in: ids }, isActive: true } });
  }

  async countActiveRegions(ids: string[]): Promise<number> {
    if (ids.length === 0) return 0;
    return this.prisma.region.count({ where: { id: { in: ids }, isActive: true } });
  }
}
