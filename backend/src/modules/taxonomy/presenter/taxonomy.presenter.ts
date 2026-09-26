import type { Region } from '@prisma/client';

export type RegionSummary = {
  id: string;
  nameEn: string;
  nameAr: string;
  isActive: boolean;
  displayOrder: number;
};

export type TaxonomyNode = {
  id: string;
  nameEn: string;
  nameAr: string;
  displayOrder: number;
  isActive: boolean;
};

export function presentRegionSummary(region: Region): RegionSummary {
  return {
    id: region.id,
    nameEn: region.nameEn,
    nameAr: region.nameAr,
    isActive: region.isActive,
    displayOrder: region.displayOrder,
  };
}

export function presentRegions(rows: Region[]): TaxonomyNode[] {
  return rows
    .map((r) => ({
      id: r.id,
      nameEn: r.nameEn,
      nameAr: r.nameAr,
      displayOrder: r.displayOrder,
      isActive: r.isActive,
    }))
    .sort((a, b) => a.displayOrder - b.displayOrder || a.nameEn.localeCompare(b.nameEn));
}
