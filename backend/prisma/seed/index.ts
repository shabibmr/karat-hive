import { PrismaClient } from '@prisma/client';
import { seedAdmin } from './admin.seed';
import { seedPlatformSettings } from './platform-settings.seed';
import { seedTaxonomy } from './taxonomy.seed';

async function main(): Promise<void> {
  const prisma = new PrismaClient();
  try {
    await seedAdmin(prisma);
    await seedTaxonomy(prisma);
    await seedPlatformSettings(prisma);
    const admins = await prisma.user.count({ where: { userType: 'ADMIN' } });
    const categories = await prisma.category.count();
    const regions = await prisma.region.count();
    const settings = await prisma.platformSetting.count();
    // eslint-disable-next-line no-console
    console.log(
      `Seed complete: ${admins} admin user(s), ${categories} categories, ${regions} regions, ${settings} settings.`,
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
