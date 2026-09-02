import type { Category, Region } from '@prisma/client';

export type TaxonomyNode = {
  id: string;
  nameEn: string;
  nameAr: string;
  displayOrder: number;
  children: TaxonomyNode[];
};

type Rowish = {
  id: string;
  parentId: string | null;
  nameEn: string;
  nameAr: string;
  displayOrder: number;
};

function toTree(rows: Rowish[]): TaxonomyNode[] {
  const byId = new Map<string, TaxonomyNode>();
  for (const r of rows) {
    byId.set(r.id, {
      id: r.id,
      nameEn: r.nameEn,
      nameAr: r.nameAr,
      displayOrder: r.displayOrder,
      children: [],
    });
  }
  const roots: TaxonomyNode[] = [];
  for (const r of rows) {
    const node = byId.get(r.id)!;
    const parent = r.parentId ? byId.get(r.parentId) : undefined;
    if (parent) parent.children.push(node);
    else roots.push(node);
  }
  const sort = (nodes: TaxonomyNode[]): void => {
    nodes.sort((a, b) => a.displayOrder - b.displayOrder || a.nameEn.localeCompare(b.nameEn));
    nodes.forEach((n) => sort(n.children));
  };
  sort(roots);
  return roots;
}

export function presentCategories(rows: Category[]): TaxonomyNode[] {
  return toTree(rows);
}

export function presentRegions(rows: Region[]): TaxonomyNode[] {
  return toTree(rows);
}
