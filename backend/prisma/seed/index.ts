import { PrismaClient } from '@prisma/client';
import { seedPlatformSettings } from './platform-settings.seed';
import { seedTaxonomy } from './taxonomy.seed';

async function main(): Promise<void> {
  const prisma = new PrismaClient();
  try {
    await seedTaxonomy(prisma);
    await seedPlatformSettings(prisma);
    const categories = await prisma.category.count();
    const regions = await prisma.region.count();
    const settings = await prisma.platformSetting.count();
    // eslint-disable-next-line no-console
    console.log(
      `Seed complete: ${categories} categories, ${regions} regions, ${settings} settings.`,
    );
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
