/**
 * G2-A07 — one-off repair for rows written by the pre-fix AuthGuard auto-provision path.
 *
 * Detects:
 * - Vendor users whose mobile is not E.164 (legacy `+fb_<uid>` pattern)
 * - Vendor profiles with synthetic trade licences (`PENDING_<…>`)
 * - Users missing terms/privacy stamps
 *
 * Does **not** invent a replacement phone. Soft-deletes the User (sets `deletedAt`)
 * and bumps `tokenVersion` so existing sessions die. Product decides whether those
 * people re-register via Google + register routes.
 *
 * Usage:
 *   cd backend && npx ts-node --transpile-only scripts/repair-auto-provision.ts --dry-run
 *   cd backend && npx ts-node --transpile-only scripts/repair-auto-provision.ts --apply
 */
import { PrismaClient } from '@prisma/client';

const E164 = /^\+[1-9]\d{6,14}$/;
const SYNTHETIC_LICENCE = /^PENDING_/i;

type Flags = { dryRun: boolean; apply: boolean };

function parseArgs(argv: string[]): Flags {
  const dryRun = argv.includes('--dry-run') || !argv.includes('--apply');
  const apply = argv.includes('--apply');
  if (apply && argv.includes('--dry-run')) {
    throw new Error('Pass either --dry-run or --apply, not both.');
  }
  return { dryRun: !apply, apply };
}

async function main(): Promise<void> {
  const flags = parseArgs(process.argv.slice(2));
  const prisma = new PrismaClient();
  const now = new Date();

  try {
    const candidates = await prisma.user.findMany({
      where: {
        deletedAt: null,
        OR: [
          { mobileNumber: { startsWith: '+fb_' } },
          { termsVersion: null },
          { privacyVersion: null },
          { termsAcceptedAt: null },
          {
            vendorProfile: {
              is: { tradeLicenceNumber: { startsWith: 'PENDING_' } },
            },
          },
        ],
      },
      include: { vendorProfile: true },
      orderBy: { createdAt: 'asc' },
    });

    const report: Array<{
      userId: string;
      mobileNumber: string;
      userType: string;
      reasons: string[];
    }> = [];

    for (const user of candidates) {
      const reasons: string[] = [];
      if (!E164.test(user.mobileNumber)) {
        reasons.push(`invalid_mobile:${user.mobileNumber}`);
      }
      if (!user.termsVersion || !user.privacyVersion || !user.termsAcceptedAt) {
        reasons.push('missing_terms');
      }
      const licence = user.vendorProfile?.tradeLicenceNumber;
      if (licence && SYNTHETIC_LICENCE.test(licence)) {
        reasons.push(`synthetic_licence:${licence}`);
      }
      if (reasons.length === 0) continue;
      report.push({
        userId: user.id,
        mobileNumber: user.mobileNumber,
        userType: user.userType,
        reasons,
      });
    }

    console.log(
      JSON.stringify(
        {
          mode: flags.apply ? 'apply' : 'dry-run',
          matched: report.length,
          rows: report,
        },
        null,
        2,
      ),
    );

    if (!flags.apply || report.length === 0) {
      return;
    }

    for (const row of report) {
      // Soft-delete only. Never UPDATE mobile_number to another invalid value.
      await prisma.user.update({
        where: { id: row.userId },
        data: {
          deletedAt: now,
          tokenVersion: { increment: 1 },
        },
      });
    }

    console.error(`Applied soft-delete to ${report.length} user(s).`);
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
