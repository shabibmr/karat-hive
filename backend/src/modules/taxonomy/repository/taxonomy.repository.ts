import { Injectable } from '@nestjs/common';
import type { Category, Region } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';

@Injectable()
export class TaxonomyRepository {
  constructor(private readonly prisma: PrismaService) {}

  listCategories(): Promise<Category[]> {
    return this.prisma.category.findMany({
      where: { isActive: true },
      orderBy: [{ displayOrder: 'asc' }, { nameEn: 'asc' }],
    });
  }

  listRegions(): Promise<Region[]> {
    return this.prisma.region.findMany({
      where: { isActive: true },
      orderBy: [{ displayOrder: 'asc' }, { nameEn: 'asc' }],
    });
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
