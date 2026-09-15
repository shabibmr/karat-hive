import type { Category, Region } from '@prisma/client';

export type CategorySummary = {
  id: string;
  nameEn: string;
  nameAr: string;
  isActive: boolean;
  displayOrder: number;
  icon?: string | null;
};

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
  icon?: string | null;
};

type Rowish = {
  id: string;
  nameEn: string;
  nameAr: string;
  displayOrder: number;
  isActive: boolean;
  icon?: string | null;
};

function presentFlat(rows: Rowish[]): TaxonomyNode[] {
  return rows
    .map((r) => ({
      id: r.id,
      nameEn: r.nameEn,
      nameAr: r.nameAr,
      displayOrder: r.displayOrder,
      isActive: r.isActive,
      ...(r.icon !== undefined && r.icon !== null ? { icon: r.icon } : {}),
    }))
    .sort((a, b) => a.displayOrder - b.displayOrder || a.nameEn.localeCompare(b.nameEn));
}

export function presentCategorySummary(category: Category): CategorySummary {
  return {
    id: category.id,
    nameEn: category.nameEn,
    nameAr: category.nameAr,
    isActive: category.isActive,
    displayOrder: category.displayOrder,
    ...(category.icon ? { icon: category.icon } : {}),
  };
}

export function presentRegionSummary(region: Region): RegionSummary {
  return {
    id: region.id,
    nameEn: region.nameEn,
    nameAr: region.nameAr,
    isActive: region.isActive,
    displayOrder: region.displayOrder,
  };
}

export function presentCategories(rows: Category[]): TaxonomyNode[] {
  return presentFlat(rows);
}

export function presentRegions(rows: Region[]): TaxonomyNode[] {
  return presentFlat(rows);
}
