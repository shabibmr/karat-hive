import { PrismaClient } from '@prisma/client';
import { seedAdmin } from './admin.seed';
import { seedPlatformSettings } from './platform-settings.seed';
import { seedTaxonomy } from './taxonomy.seed';
import { seedVendor, type SeedVendorState } from './vendor-dev.seed';

function parseSeedVendorState(raw: string | undefined): SeedVendorState {
  const value = (raw ?? 'ACTIVE').trim().toUpperCase();
  if (value === 'PENDING' || value === 'VERIFIED' || value === 'ACTIVE') {
    return value;
  }
  throw new Error(
    `SEED_VENDOR_STATE must be PENDING, VERIFIED, or ACTIVE (got ${JSON.stringify(raw)}).`,
  );
}

async function main(): Promise<void> {
  const prisma = new PrismaClient();
  try {
    await seedAdmin(prisma);
    await seedTaxonomy(prisma);
    await seedPlatformSettings(prisma);
    const vendorState = parseSeedVendorState(process.env.SEED_VENDOR_STATE);
    const vendor = await seedVendor(prisma, {
      state: vendorState,
      mobileNumber: process.env.SEED_VENDOR_MOBILE,
      email: process.env.SEED_VENDOR_EMAIL,
    });
    const admins = await prisma.user.count({ where: { userType: 'ADMIN' } });
    const vendors = await prisma.user.count({ where: { userType: 'VENDOR' } });
    const categories = await prisma.category.count();
    const regions = await prisma.region.count();
    const settings = await prisma.platformSetting.count();
    // eslint-disable-next-line no-console
    console.log(
      `Seed complete: ${admins} admin user(s), ${vendors} vendor user(s) (${vendorState} ${vendor.email}), ${categories} categories, ${regions} regions, ${settings} settings.`,
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
