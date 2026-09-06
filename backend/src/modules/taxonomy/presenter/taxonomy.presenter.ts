import type { Category, Region } from '@prisma/client';

export type CategorySummary = {
  id: string;
  nameEn: string;
  nameAr: string;
  parentId?: string | null;
  isActive: boolean;
  displayOrder: number;
  icon?: string | null;
};

export type RegionSummary = {
  id: string;
  nameEn: string;
  nameAr: string;
  parentId?: string | null;
  isActive: boolean;
  displayOrder: number;
};

export type TaxonomyNode = {
  id: string;
  parentId?: string | null;
  nameEn: string;
  nameAr: string;
  displayOrder: number;
  isActive: boolean;
  icon?: string | null;
  children: TaxonomyNode[];
};

type Rowish = {
  id: string;
  parentId: string | null;
  nameEn: string;
  nameAr: string;
  displayOrder: number;
  isActive: boolean;
  icon?: string | null;
};

function toTree(rows: Rowish[]): TaxonomyNode[] {
  const byId = new Map<string, TaxonomyNode>();
  for (const r of rows) {
    byId.set(r.id, {
      id: r.id,
      parentId: r.parentId,
      nameEn: r.nameEn,
      nameAr: r.nameAr,
      displayOrder: r.displayOrder,
      isActive: r.isActive,
      ...(r.icon !== undefined && r.icon !== null ? { icon: r.icon } : {}),
      children: [],
    });
  }
  const roots: TaxonomyNode[] = [];
  for (const r of rows) {
    const node = byId.get(r.id)!;
    const parent = r.parentId ? byId.get(r.parentId) : undefined;
    if (parent) {
      parent.children.push(node);
    } else {
      roots.push(node);
    }
  }
  const sort = (nodes: TaxonomyNode[]): void => {
    nodes.sort((a, b) => a.displayOrder - b.displayOrder || a.nameEn.localeCompare(b.nameEn));
    nodes.forEach((n) => sort(n.children));
  };
  sort(roots);
  return roots;
}

export function presentCategorySummary(category: Category): CategorySummary {
  return {
    id: category.id,
    nameEn: category.nameEn,
    nameAr: category.nameAr,
    parentId: category.parentId,
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
    parentId: region.parentId,
    isActive: region.isActive,
    displayOrder: region.displayOrder,
  };
}

export function presentCategories(rows: Category[]): TaxonomyNode[] {
  return toTree(rows);
}

export function presentRegions(rows: Region[]): TaxonomyNode[] {
  return toTree(rows);
}
