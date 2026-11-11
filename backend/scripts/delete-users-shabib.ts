/**
 * Delete specified users and all their associated records from PostgreSQL and Firebase Auth.
 *
 * Targets:
 * - shabibmr@gmail.com
 * - personalshabib@gmail.com
 *
 * Usage:
 *   cd backend && npx ts-node --transpile-only scripts/delete-users-shabib.ts --dry-run
 *   cd backend && npx ts-node --transpile-only scripts/delete-users-shabib.ts --apply
 */
import { PrismaClient } from '@prisma/client';
import fs from 'fs';
import path from 'path';

type Flags = { dryRun: boolean; apply: boolean };

function parseArgs(argv: string[]): Flags {
  const dryRun = argv.includes('--dry-run') || !argv.includes('--apply');
  const apply = argv.includes('--apply');
  if (apply && argv.includes('--dry-run')) {
    throw new Error('Pass either --dry-run or --apply, not both.');
  }
  return { dryRun: !apply, apply };
}

async function getFirebaseToken(): Promise<string> {
  const p = path.join(process.env.HOME || '/root', '.config/configstore/firebase-tools.json');
  if (!fs.existsSync(p)) {
    throw new Error(`Firebase config not found at ${p}`);
  }
  const config = JSON.parse(fs.readFileSync(p, 'utf8'));
  const token = config.tokens?.access_token;
  if (!token) {
    throw new Error('Firebase access token missing from configstore.');
  }
  return token;
}

async function deleteFirebaseUsers(uids: string[], token: string): Promise<void> {
  for (const uid of uids) {
    const res = await fetch('https://identitytoolkit.googleapis.com/v1/projects/karat-hive-app/accounts:delete', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ localId: uid }),
    });
    if (!res.ok) {
      const errorText = await res.text();
      throw new Error(`Failed to delete Firebase Auth user ${uid}: ${res.status} ${errorText}`);
    }
  }
}

async function main(): Promise<void> {
  const flags = parseArgs(process.argv.slice(2));
  const prisma = new PrismaClient();
  const targetEmails = ['shabibmr@gmail.com', 'personalshabib@gmail.com'];

  try {
    console.log(`[delete-users] Mode: ${flags.dryRun ? 'DRY RUN (no changes)' : 'APPLY (executing deletion)'}`);

    // 1. Identify Postgres Users
    const users = await prisma.user.findMany({
      where: {
        OR: [
          { email: { in: targetEmails, mode: 'insensitive' } },
          { vendorProfile: { businessEmail: { in: targetEmails, mode: 'insensitive' } } },
        ],
      },
      include: {
        customerProfile: true,
        vendorProfile: true,
        oauthBindings: true,
      },
    });

    const userIds = users.map((u) => u.id);
    const customerProfileIds = users.map((u) => u.customerProfile?.id).filter((id): id is string => !!id);
    const vendorProfileIds = users.map((u) => u.vendorProfile?.id).filter((id): id is string => !!id);
    const allEntityIds = [...userIds, ...customerProfileIds, ...vendorProfileIds];

    console.log(`\nIdentified ${users.length} PostgreSQL user(s):`);
    for (const u of users) {
      console.log(`- ID: ${u.id} | Email: ${u.email} | Type: ${u.userType} | Mobile: ${u.mobileNumber}`);
    }

    // 2. Identify Firebase Users
    let fbUsers: { localId: string; email: string }[] = [];
    let fbToken: string | null = null;
    try {
      fbToken = await getFirebaseToken();
      const fbRes = await fetch('https://identitytoolkit.googleapis.com/v1/projects/karat-hive-app/accounts:lookup', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${fbToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          // check by email or uid
        }),
      });
      // We can look up by UIDs or check the ones we discovered earlier
      const checkUids = ['57PAjeYfF5fhrzM5hE4NkDPj5nh2', 'eU0BdfrE6IYJ99xoCwLrfAM6A3U2'];
      const lookupRes = await fetch('https://identitytoolkit.googleapis.com/v1/projects/karat-hive-app/accounts:lookup', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${fbToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ localId: checkUids }),
      });
      if (lookupRes.ok) {
        const data = (await lookupRes.json()) as { users?: { localId: string; email: string }[] };
        fbUsers = data.users || [];
      }
    } catch (err) {
      console.warn('[delete-users] Warning checking Firebase Auth:', err);
    }

    console.log(`\nIdentified ${fbUsers.length} Firebase Auth user(s):`);
    for (const fb of fbUsers) {
      console.log(`- UID: ${fb.localId} | Email: ${fb.email}`);
    }

    // Counts of records in Postgres
    const [
      subCount,
      regCount,
      custCount,
      vendCount,
      oauthCount,
      tokenCount,
      idempCount,
      mediaCount,
      auditCount,
    ] = await Promise.all([
      prisma.vendorTypeSubscription.count({ where: { vendorProfileId: { in: vendorProfileIds } } }),
      prisma.vendorRegion.count({ where: { vendorProfileId: { in: vendorProfileIds } } }),
      prisma.customerProfile.count({ where: { id: { in: customerProfileIds } } }),
      prisma.vendorProfile.count({ where: { id: { in: vendorProfileIds } } }),
      prisma.oauthBinding.count({ where: { userId: { in: userIds } } }),
      prisma.refreshToken.count({ where: { userId: { in: userIds } } }),
      prisma.idempotencyKey.count({ where: { callerUserId: { in: userIds } } }),
      prisma.media.count({ where: { uploadedByUserId: { in: userIds } } }),
      prisma.auditLog.count({
        where: {
          OR: [
            { actorUserId: { in: userIds } },
            { entityId: { in: allEntityIds } },
          ],
        },
      }),
    ]);

    console.log('\n--- PostgreSQL Records Scheduled for Deletion ---');
    console.log(`- Vendor Subscriptions:   ${subCount}`);
    console.log(`- Vendor Regions:         ${regCount}`);
    console.log(`- Vendor Profiles:        ${vendCount}`);
    console.log(`- Customer Profiles:      ${custCount}`);
    console.log(`- OAuth Bindings:         ${oauthCount}`);
    console.log(`- Refresh Tokens:         ${tokenCount}`);
    console.log(`- Idempotency Keys:       ${idempCount}`);
    console.log(`- Uploaded Media:         ${mediaCount}`);
    console.log(`- Audit Logs:             ${auditCount}`);
    console.log(`- Users:                  ${userIds.length}`);

    if (flags.dryRun) {
      console.log('\n[delete-users] Dry-run complete. Re-run with --apply to execute.');
      return;
    }

    console.log('\n[delete-users] Executing database transaction...');
    await prisma.$transaction(async (tx) => {
      // 1. Vendor subscriptions
      if (vendorProfileIds.length > 0) {
        const delSubs = await tx.vendorTypeSubscription.deleteMany({
          where: { vendorProfileId: { in: vendorProfileIds } },
        });
        console.log(`Deleted ${delSubs.count} vendor subscriptions.`);

        // 2. Vendor regions
        const delRegs = await tx.vendorRegion.deleteMany({
          where: { vendorProfileId: { in: vendorProfileIds } },
        });
        console.log(`Deleted ${delRegs.count} vendor regions.`);

        // 3. Vendor profiles
        const delVend = await tx.vendorProfile.deleteMany({
          where: { id: { in: vendorProfileIds } },
        });
        console.log(`Deleted ${delVend.count} vendor profiles.`);
      }

      // 4. Customer profiles
      if (customerProfileIds.length > 0) {
        const delCust = await tx.customerProfile.deleteMany({
          where: { id: { in: customerProfileIds } },
        });
        console.log(`Deleted ${delCust.count} customer profiles.`);
      }

      // 5. OAuth bindings
      if (userIds.length > 0) {
        const delOauth = await tx.oauthBinding.deleteMany({
          where: { userId: { in: userIds } },
        });
        console.log(`Deleted ${delOauth.count} oauth bindings.`);

        // 6. Refresh tokens
        const delTokens = await tx.refreshToken.deleteMany({
          where: { userId: { in: userIds } },
        });
        console.log(`Deleted ${delTokens.count} refresh tokens.`);

        // 7. Idempotency keys
        const delIdemp = await tx.idempotencyKey.deleteMany({
          where: { callerUserId: { in: userIds } },
        });
        console.log(`Deleted ${delIdemp.count} idempotency keys.`);

        // 8. Uploaded media
        const delMedia = await tx.media.deleteMany({
          where: { uploadedByUserId: { in: userIds } },
        });
        console.log(`Deleted ${delMedia.count} media records.`);

        // 9. Audit logs
        const delAudit = await tx.auditLog.deleteMany({
          where: {
            OR: [
              { actorUserId: { in: userIds } },
              { entityId: { in: allEntityIds } },
            ],
          },
        });
        console.log(`Deleted ${delAudit.count} audit logs.`);

        // 10. Users
        const delUsers = await tx.user.deleteMany({
          where: { id: { in: userIds } },
        });
        console.log(`Deleted ${delUsers.count} users.`);
      }
    });

    console.log('[delete-users] PostgreSQL transaction committed successfully!');

    // 11. Delete from Firebase Auth
    if (fbUsers.length > 0 && fbToken) {
      console.log('\n[delete-users] Deleting users from Firebase Auth...');
      const uidsToDelete = fbUsers.map((u) => u.localId);
      await deleteFirebaseUsers(uidsToDelete, fbToken);
      console.log(`Successfully deleted ${uidsToDelete.length} users from Firebase Auth!`);
    }

    console.log('\n[delete-users] All operations successfully completed!');
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((err) => {
  console.error('[delete-users] Error:', err);
  process.exit(1);
});
