import type { PrismaClient } from '@prisma/client';
import { ScryptPasswordHasher } from '../../src/platform/adapters/crypto/scrypt-password-hasher';

type GoogleAdminConfig = {
  email: string;
  mobileNumber: string;
  displayName: string;
};

// Google-only admins: no password, first Google sign-in with a verified matching
// email auto-binds via OAuthAccountService (backend/src/modules/identity/application/oauth-account.service.ts).
const GOOGLE_ADMINS: GoogleAdminConfig[] = [
  {
    email: 'algoraytechnologies@gmail.com',
    mobileNumber: '+971500000098',
    displayName: 'Algoray Technologies',
  },
];

async function seedGoogleAdmin(prisma: PrismaClient, config: GoogleAdminConfig): Promise<void> {
  const user = await prisma.user.upsert({
    where: { email: config.email },
    update: {
      userType: 'ADMIN',
      accountState: 'ACTIVE',
    },
    create: {
      email: config.email,
      mobileNumber: config.mobileNumber,
      emailVerifiedAt: new Date(),
      userType: 'ADMIN',
      accountState: 'ACTIVE',
      preferredLanguage: 'en',
      termsVersion: '1.0',
      privacyVersion: '1.0',
      termsAcceptedAt: new Date(),
    },
  });

  await prisma.adminProfile.upsert({
    where: { userId: user.id },
    update: { displayName: config.displayName },
    create: { userId: user.id, displayName: config.displayName },
  });

  // eslint-disable-next-line no-console
  console.log(`Seeded Google Admin user: ${config.email} (displayName: "${config.displayName}")`);
}

export async function seedAdmin(prisma: PrismaClient): Promise<void> {
  const email = process.env.SEED_ADMIN_EMAIL || 'admin@karathive.ae';
  const password = process.env.SEED_ADMIN_PASSWORD || 'AdminSecret123!';
  // [PROPOSED] Default is not +971500000001 so CP1-V01 REGISTER_VENDOR can use that number after seed.
  const mobileNumber = process.env.SEED_ADMIN_MOBILE || '+971500000099';
  const displayName = process.env.SEED_ADMIN_NAME || 'Platform Admin';

  const hasher = new ScryptPasswordHasher();
  const passwordHash = await hasher.hash(password);

  const user = await prisma.user.upsert({
    where: { email },
    update: {
      userType: 'ADMIN',
      accountState: 'ACTIVE',
      passwordHash,
      mobileNumber,
    },
    create: {
      email,
      mobileNumber,
      mobileVerifiedAt: new Date(),
      emailVerifiedAt: new Date(),
      passwordHash,
      userType: 'ADMIN',
      accountState: 'ACTIVE',
      preferredLanguage: 'en',
      termsVersion: '1.0',
      privacyVersion: '1.0',
      termsAcceptedAt: new Date(),
    },
  });

  await prisma.adminProfile.upsert({
    where: { userId: user.id },
    update: {
      displayName,
    },
    create: {
      userId: user.id,
      displayName,
    },
  });

  // eslint-disable-next-line no-console
  console.log(`Seeded Admin user: ${email} (password: ${password}, displayName: "${displayName}")`);

  for (const config of GOOGLE_ADMINS) {
    await seedGoogleAdmin(prisma, config);
  }
}
