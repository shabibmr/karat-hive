import type { PrismaClient } from '@prisma/client';

type Node = { key: string; nameEn: string; nameAr: string; children?: Node[] };

const REGIONS: Node[] = [
  {
    key: 'abu-dhabi',
    nameEn: 'Abu Dhabi',
    nameAr: 'أبوظبي',
    children: [
      { key: 'ad-city', nameEn: 'Abu Dhabi City', nameAr: 'مدينة أبوظبي' },
      { key: 'al-ain', nameEn: 'Al Ain', nameAr: 'العين' },
    ],
  },
  {
    key: 'dubai',
    nameEn: 'Dubai',
    nameAr: 'دبي',
    children: [
      { key: 'deira', nameEn: 'Deira', nameAr: 'ديرة' },
      { key: 'bur-dubai', nameEn: 'Bur Dubai', nameAr: 'بر دبي' },
      { key: 'dubai-marina', nameEn: 'Dubai Marina', nameAr: 'مرسى دبي' },
    ],
  },
  { key: 'sharjah', nameEn: 'Sharjah', nameAr: 'الشارقة' },
  { key: 'ajman', nameEn: 'Ajman', nameAr: 'عجمان' },
  { key: 'umm-al-quwain', nameEn: 'Umm Al Quwain', nameAr: 'أم القيوين' },
  { key: 'ras-al-khaimah', nameEn: 'Ras Al Khaimah', nameAr: 'رأس الخيمة' },
  { key: 'fujairah', nameEn: 'Fujairah', nameAr: 'الفجيرة' },
];

const CATEGORIES: Node[] = [
  {
    key: 'ornaments',
    nameEn: 'Gold Ornaments',
    nameAr: 'مصوغات ذهبية',
    children: [
      { key: 'rings', nameEn: 'Rings', nameAr: 'خواتم' },
      { key: 'chains', nameEn: 'Chains & Necklaces', nameAr: 'سلاسل وقلائد' },
      { key: 'bangles', nameEn: 'Bangles & Bracelets', nameAr: 'أساور' },
      { key: 'earrings', nameEn: 'Earrings', nameAr: 'أقراط' },
    ],
  },
  {
    key: 'coins',
    nameEn: 'Gold Coins',
    nameAr: 'عملات ذهبية',
    children: [
      { key: 'coins-investment', nameEn: 'Investment Coins', nameAr: 'عملات استثمارية' },
      { key: 'coins-collectible', nameEn: 'Collectible Coins', nameAr: 'عملات نادرة' },
    ],
  },
  {
    key: 'bullion',
    nameEn: 'Gold Bullion',
    nameAr: 'سبائك ذهبية',
    children: [
      { key: 'bars-small', nameEn: 'Small Bars (1–50g)', nameAr: 'سبائك صغيرة' },
      { key: 'bars-large', nameEn: 'Large Bars (100g+)', nameAr: 'سبائك كبيرة' },
    ],
  },
  { key: 'old-gold', nameEn: 'Old / Scrap Gold', nameAr: 'ذهب قديم' },
];

async function seedTree(
  prisma: PrismaClient,
  kind: 'category' | 'region',
  nodes: Node[],
): Promise<void> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const model: any = kind === 'category' ? prisma.category : prisma.region;
  let order = 0;
  for (const root of nodes) {
    const parent = await model.upsert({
      where: { id: await idFor(prisma, kind, root.key) },
      update: { nameEn: root.nameEn, nameAr: root.nameAr, displayOrder: order, isActive: true },
      create: {
        id: await idFor(prisma, kind, root.key),
        nameEn: root.nameEn,
        nameAr: root.nameAr,
        displayOrder: order,
        isActive: true,
      },
    });
    order += 1;
    let childOrder = 0;
    for (const child of root.children ?? []) {
      await model.upsert({
        where: { id: await idFor(prisma, kind, child.key) },
        update: {
          nameEn: child.nameEn,
          nameAr: child.nameAr,
          displayOrder: childOrder,
          isActive: true,
          parentId: parent.id,
        },
        create: {
          id: await idFor(prisma, kind, child.key),
          nameEn: child.nameEn,
          nameAr: child.nameAr,
          displayOrder: childOrder,
          isActive: true,
          parentId: parent.id,
        },
      });
      childOrder += 1;
    }
  }
}

/** Deterministic UUID v5-style from a stable slug so re-seeding is idempotent. */
const NAMESPACE = '6f9619ff-8b86-d011-b42d-00cf4fc964ff';
async function idFor(_p: PrismaClient, kind: string, key: string): Promise<string> {
  const { createHash } = await import('node:crypto');
  const h = createHash('sha1').update(`${NAMESPACE}:${kind}:${key}`).digest('hex');
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-5${h.slice(13, 16)}-8${h.slice(17, 20)}-${h.slice(20, 32)}`;
}

export async function seedTaxonomy(prisma: PrismaClient): Promise<void> {
  await seedTree(prisma, 'region', REGIONS);
  await seedTree(prisma, 'category', CATEGORIES);
}
