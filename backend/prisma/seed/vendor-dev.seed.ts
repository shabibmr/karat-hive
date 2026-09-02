import { createHash, randomUUID } from 'node:crypto';
import type { PrismaClient, VendorVerificationState } from '@prisma/client';

export type SeedVendorState = 'PENDING' | 'VERIFIED' | 'ACTIVE';

function scryptHashSync(plain: string): string {
  // Matches ScryptPasswordHasher format: scrypt$<saltB64>$<hashB64>
  const { scryptSync, randomBytes } = require('node:crypto') as typeof import('node:crypto');
  const salt = randomBytes(16);
  const derived = scryptSync(plain, salt, 64);
  return `scrypt$${salt.toString('base64')}$${derived.toString('base64')}`;
}

/**
 * Creates (or resets) a dev Vendor at a chosen lifecycle. Idempotent per mobile number.
 * Password is `Passw0rd!dev` for the VERIFIED/ACTIVE fixtures.
 */
export async function seedVendor(
  prisma: PrismaClient,
  opts: { state: SeedVendorState; mobileNumber?: string; email?: string },
): Promise<{ userId: string; vendorProfileId: string; email: string; mobileNumber: string }> {
  const mobileNumber = opts.mobileNumber ?? '+971500000090';
  const email = opts.email ?? 'dev.vendor@karathive.test';

  await prisma.user.deleteMany({ where: { mobileNumber } });

  const verificationState: VendorVerificationState =
    opts.state === 'PENDING' ? 'PENDING_VERIFICATION' : 'VERIFIED';
  const activated = opts.state === 'ACTIVE';

  const user = await prisma.user.create({
    data: {
      mobileNumber,
      email,
      userType: 'VENDOR',
      accountState: 'ACTIVE',
      preferredLanguage: 'en',
      mobileVerifiedAt: new Date(),
      passwordHash: scryptHashSync('Passw0rd!dev'),
      termsVersion: '1.0',
      privacyVersion: '1.0',
      termsAcceptedAt: new Date(),
    },
  });

  const categories = await prisma.category.findMany({
    where: { parentId: { not: null } },
    take: 2,
  });
  const regions = await prisma.region.findMany({ where: { parentId: { not: null } }, take: 1 });

  const profile = await prisma.vendorProfile.create({
    data: {
      userId: user.id,
      legalBusinessName: 'Dev Gold Trading LLC',
      tradingName: 'Dev Gold',
      tradeLicenceNumber: `DEV-${createHash('sha1').update(mobileNumber).digest('hex').slice(0, 10)}`,
      licenceExpiryDate: new Date('2028-01-01'),
      businessAddress: 'Gold Souk, Deira, Dubai',
      contactPersonName: 'Dev Contact',
      businessEmail: email,
      verificationState,
      verifiedAt: opts.state === 'PENDING' ? null : new Date(),
      activatedAt: activated ? new Date() : null,
    },
  });

  if (opts.state !== 'PENDING' && (categories.length === 0 || regions.length === 0)) {
    throw new Error('Seed taxonomy before seeding a VERIFIED/ACTIVE vendor.');
  }
  if (opts.state !== 'PENDING') {
    await prisma.vendorCategory.createMany({
      data: categories.map((c) => ({ vendorProfileId: profile.id, categoryId: c.id })),
      skipDuplicates: true,
    });
    await prisma.vendorRegion.createMany({
      data: regions.map((r) => ({ vendorProfileId: profile.id, regionId: r.id })),
      skipDuplicates: true,
    });
  }

  // Mandatory KYC docs for non-PENDING fixtures.
  if (opts.state !== 'PENDING') {
    for (const documentType of ['TRADE_LICENCE', 'EMIRATES_ID'] as const) {
      const media = await prisma.media.create({
        data: {
          key: randomUUID(),
          purpose: 'KYC_DOCUMENT',
          state: 'READY',
          bucket: 'KYC',
          contentType: 'application/pdf',
          byteSize: 1024,
          exifStripped: true,
          malwareScanState: 'CLEAN',
          uploadedByUserId: user.id,
        },
      });
      await prisma.vendorDocument.create({
        data: {
          vendorProfileId: profile.id,
          documentType,
          mediaId: media.id,
          verified: true,
          uploadedAt: new Date(),
        },
      });
    }
  }

  return { userId: user.id, vendorProfileId: profile.id, email, mobileNumber };
}
