import type { PrismaClient } from '@prisma/client';

type Node = { key: string; nameEn: string; nameAr: string; icon?: string };

const REGIONS: Node[] = [
  { key: 'abu-dhabi', nameEn: 'Abu Dhabi', nameAr: 'أبوظبي' },
  { key: 'dubai', nameEn: 'Dubai', nameAr: 'دبي' },
  { key: 'sharjah', nameEn: 'Sharjah', nameAr: 'الشارقة' },
  { key: 'ajman', nameEn: 'Ajman', nameAr: 'عجمان' },
  { key: 'umm-al-quwain', nameEn: 'Umm Al Quwain', nameAr: 'أم القيوين' },
  { key: 'ras-al-khaimah', nameEn: 'Ras Al Khaimah', nameAr: 'رأس الخيمة' },
  { key: 'fujairah', nameEn: 'Fujairah', nameAr: 'الفجيرة' },
];

const CATEGORIES: Node[] = [
  { key: 'rings', nameEn: 'Rings', nameAr: 'خواتم' },
  { key: 'necklaces', nameEn: 'Chains & Necklaces', nameAr: 'سلاسل وقلائد' },
  { key: 'bangles', nameEn: 'Bangles & Bracelets', nameAr: 'أساور وغوايش' },
  { key: 'earrings', nameEn: 'Earrings', nameAr: 'أقراط وحلق' },
  { key: 'pendants', nameEn: 'Pendants', nameAr: 'تعليقات وميداليات' },
  { key: 'sets', nameEn: 'Jewellery Sets', nameAr: 'أطقم مجوهرات' },
  { key: 'bullion', nameEn: 'Gold Bars / Bullion', nameAr: 'سبائك ذهبية' },
  { key: 'coins', nameEn: 'Gold Coins', nameAr: 'عملات ومسكوكات ذهبية' },
  { key: 'old-gold', nameEn: 'Scrap & Old Gold', nameAr: 'ذهب قديم وكسر صهر' },
  { key: 'watches', nameEn: 'Luxury Gold Watches', nameAr: 'ساعات ذهبية فاخرة' },
];

async function seedFlat(prisma: PrismaClient, kind: 'category' | 'region', nodes: Node[]): Promise<void> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const model: any = kind === 'category' ? prisma.category : prisma.region;
  const seededIds: string[] = [];
  let order = 0;
  for (const node of nodes) {
    const id = await idFor(prisma, kind, node.key);
    seededIds.push(id);
    await model.upsert({
      where: { id },
      update: {
        nameEn: node.nameEn,
        nameAr: node.nameAr,
        displayOrder: order,
        isActive: true,
        ...(node.icon ? { icon: node.icon } : {}),
      },
      create: {
        id,
        nameEn: node.nameEn,
        nameAr: node.nameAr,
        displayOrder: order,
        isActive: true,
        ...(node.icon ? { icon: node.icon } : {}),
      },
    });
    order += 1;
  }
  // Retire pre-flattening rows (e.g. old subcategory/area leaves) that are no
  // longer part of the flat taxonomy, without deleting them — requests and
  // vendor selections may still reference them (onDelete: Restrict).
  await model.updateMany({
    where: { id: { notIn: seededIds }, isActive: true },
    data: { isActive: false },
  });
}

/** Deterministic UUID v5-style from a stable slug so re-seeding is idempotent. */
const NAMESPACE = '6f9619ff-8b86-d011-b42d-00cf4fc964ff';
async function idFor(_p: PrismaClient, kind: string, key: string): Promise<string> {
  const { createHash } = await import('node:crypto');
  const h = createHash('sha1').update(`${NAMESPACE}:${kind}:${key}`).digest('hex');
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-5${h.slice(13, 16)}-8${h.slice(17, 20)}-${h.slice(20, 32)}`;
}

export async function seedTaxonomy(prisma: PrismaClient): Promise<void> {
  await seedFlat(prisma, 'region', REGIONS);
  await seedFlat(prisma, 'category', CATEGORIES);
}
