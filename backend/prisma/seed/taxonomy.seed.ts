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
      { key: 'al-dhafra', nameEn: 'Al Dhafra', nameAr: 'الظفرة' },
      { key: 'khalifa-city', nameEn: 'Khalifa City', nameAr: 'مدينة خليفة' },
      { key: 'yas-island', nameEn: 'Yas Island', nameAr: 'جزيرة ياس' },
    ],
  },
  {
    key: 'dubai',
    nameEn: 'Dubai',
    nameAr: 'دبي',
    children: [
      { key: 'deira', nameEn: 'Deira (Gold Souk)', nameAr: 'ديرة (سوق الذهب)' },
      { key: 'bur-dubai', nameEn: 'Bur Dubai', nameAr: 'بر دبي' },
      { key: 'dubai-marina', nameEn: 'Dubai Marina', nameAr: 'مرسى دبي' },
      { key: 'downtown-dubai', nameEn: 'Downtown Dubai', nameAr: 'وسط مدينة دبي' },
      { key: 'jumeirah', nameEn: 'Jumeirah', nameAr: 'جميرا' },
      { key: 'al-barsha', nameEn: 'Al Barsha', nameAr: 'البرشاء' },
    ],
  },
  {
    key: 'sharjah',
    nameEn: 'Sharjah',
    nameAr: 'الشارقة',
    children: [
      { key: 'al-majaz', nameEn: 'Al Majaz', nameAr: 'المجاز' },
      { key: 'al-nahda-shj', nameEn: 'Al Nahda', nameAr: 'النهدة' },
      { key: 'muwailih', nameEn: 'Muwailih', nameAr: 'مويلح' },
      { key: 'al-qasimia', nameEn: 'Al Qasimia', nameAr: 'القاسمية' },
    ],
  },
  {
    key: 'ajman',
    nameEn: 'Ajman',
    nameAr: 'عجمان',
    children: [
      { key: 'al-nuaimiya', nameEn: 'Al Nuaimiya', nameAr: 'النعيمية' },
      { key: 'al-rashidiya-ajm', nameEn: 'Al Rashidiya', nameAr: 'الراشدية' },
      { key: 'al-jurf', nameEn: 'Al Jurf', nameAr: 'الجرف' },
    ],
  },
  {
    key: 'umm-al-quwain',
    nameEn: 'Umm Al Quwain',
    nameAr: 'أم القيوين',
    children: [
      { key: 'al-raudah', nameEn: 'Al Raudah', nameAr: 'الروضة' },
      { key: 'al-salamah', nameEn: 'Al Salamah', nameAr: 'السلمة' },
      { key: 'uaq-old-town', nameEn: 'Old Town Area', nameAr: 'البلدة القديمة' },
    ],
  },
  {
    key: 'ras-al-khaimah',
    nameEn: 'Ras Al Khaimah',
    nameAr: 'رأس الخيمة',
    children: [
      { key: 'al-nakheel', nameEn: 'Al Nakheel', nameAr: 'النخيل' },
      { key: 'al-hamra', nameEn: 'Al Hamra Village', nameAr: 'قرية الحمراء' },
      { key: 'al-dhait', nameEn: 'Al Dhait', nameAr: 'الظيت' },
    ],
  },
  {
    key: 'fujairah',
    nameEn: 'Fujairah',
    nameAr: 'الفجيرة',
    children: [
      { key: 'al-faseel', nameEn: 'Al Faseel', nameAr: 'الفصيل' },
      { key: 'mirbah', nameEn: 'Mirbah', nameAr: 'مربح' },
      { key: 'dibba-fujairah', nameEn: 'Dibba Al Fujairah', nameAr: 'دبا الفجيرة' },
    ],
  },
];

const CATEGORIES: Node[] = [
  {
    key: 'jewellery',
    nameEn: 'Jewellery',
    nameAr: 'مجوهرات وحلي ذهبية',
    children: [
      { key: 'rings', nameEn: 'Rings', nameAr: 'خواتم' },
      { key: 'necklaces', nameEn: 'Chains & Necklaces', nameAr: 'سلاسل وقلائد' },
      { key: 'bangles', nameEn: 'Bangles & Bracelets', nameAr: 'أساور وغوايش' },
      { key: 'earrings', nameEn: 'Earrings', nameAr: 'أقراط وحلق' },
      { key: 'pendants', nameEn: 'Pendants & Medallions', nameAr: 'تعليقات وميداليات' },
      { key: 'sets', nameEn: 'Full Jewellery Sets', nameAr: 'أطقم مجوهرات كاملة' },
    ],
  },
  {
    key: 'bullion',
    nameEn: 'Bullion & Bars',
    nameAr: 'سبائك ذهبية',
    children: [
      { key: 'bars-small', nameEn: 'Small Bars (1g – 20g)', nameAr: 'سبائك صغيرة (1 - 20 غرام)' },
      {
        key: 'bars-medium',
        nameEn: 'Medium Bars (31.1g – 100g)',
        nameAr: 'سبائك أونصة ومتوسطة (31.1 - 100 غرام)',
      },
      {
        key: 'bars-large',
        nameEn: 'Large Bars (250g – 500g)',
        nameAr: 'سبائك كبيرة (250 - 500 غرام)',
      },
      { key: 'bars-kilo', nameEn: 'Kilobar (1kg / 1000g)', nameAr: 'سبائك كيلو (1000 غرام)' },
    ],
  },
  {
    key: 'coins',
    nameEn: 'Gold Coins',
    nameAr: 'عملات ومسكوكات ذهبية',
    children: [
      {
        key: 'coins-investment',
        nameEn: 'Investment Coins (Sovereigns, Krugerrand)',
        nameAr: 'عملات استثمارية وسيادية',
      },
      {
        key: 'coins-commemorative',
        nameEn: 'Commemorative & Collectible Coins',
        nameAr: 'عملات تذكارية ونادرة',
      },
    ],
  },
  {
    key: 'old-gold',
    nameEn: 'Scrap & Old Gold',
    nameAr: 'ذهب قديم وكسر صهر',
    children: [
      {
        key: 'broken-jewellery',
        nameEn: 'Broken & Used Jewellery',
        nameAr: 'حلي ومجوهرات مستعملة ومكسورة',
      },
      { key: 'melt-scrap', nameEn: 'Melt Scrap & Dental Gold', nameAr: 'كسر صهر وسبك' },
    ],
  },
  {
    key: 'watches',
    nameEn: 'Luxury Gold Watches',
    nameAr: 'ساعات ذهبية فاخرة',
    children: [
      { key: 'watches-mens', nameEn: "Men's Gold Watches", nameAr: 'ساعات ذهبية رجالية' },
      { key: 'watches-womens', nameEn: "Women's Gold Watches", nameAr: 'ساعات ذهبية نسائية' },
    ],
  },
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
    const rootId = await idFor(prisma, kind, root.key);
    const parent = await model.upsert({
      where: { id: rootId },
      update: { nameEn: root.nameEn, nameAr: root.nameAr, displayOrder: order, isActive: true },
      create: {
        id: rootId,
        nameEn: root.nameEn,
        nameAr: root.nameAr,
        displayOrder: order,
        isActive: true,
      },
    });
    order += 1;
    let childOrder = 0;
    for (const child of root.children ?? []) {
      const childId = await idFor(prisma, kind, child.key);
      await model.upsert({
        where: { id: childId },
        update: {
          nameEn: child.nameEn,
          nameAr: child.nameAr,
          displayOrder: childOrder,
          isActive: true,
          parentId: parent.id,
        },
        create: {
          id: childId,
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
