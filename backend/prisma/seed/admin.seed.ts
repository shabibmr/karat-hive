import type { PrismaClient } from '@prisma/client';
import { ScryptPasswordHasher } from '../../src/platform/adapters/crypto/scrypt-password-hasher';

export async function seedAdmin(prisma: PrismaClient): Promise<void> {
  const email = process.env.SEED_ADMIN_EMAIL || 'admin@karathive.ae';
  const password = process.env.SEED_ADMIN_PASSWORD || 'AdminSecret123!';
  const mobileNumber = process.env.SEED_ADMIN_MOBILE || '+971500000001';
  const displayName = process.env.SEED_ADMIN_NAME || 'Platform Admin';

  const hasher = new ScryptPasswordHasher();
  const passwordHash = await hasher.hash(password);

  const user = await prisma.user.upsert({
    where: { email },
    update: {
      userType: 'ADMIN',
      accountState: 'ACTIVE',
      passwordHash,
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
}
