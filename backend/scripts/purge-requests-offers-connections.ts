/**
 * Purge all Requests, Offers, Connections, and related dependent entities from the database.
 *
 * Entities targeted:
 * - Reviews (linked to connections)
 * - ContactEvents (linked to connections)
 * - Connections
 * - Request.acceptedOfferId (cleared to break circular FK)
 * - OfferMedia & OfferRevisions
 * - Offers
 * - RequestMedia & RequestMatches
 * - Requests
 * - Media (REQUEST_IMAGE & OFFER_IMAGE purposes)
 * - Notifications & Deliveries (related to requests, offers, connections, reviews)
 * - OutboxEvents & Consumers (related to requests, offers, connections, media uploads)
 * - AuditLogs (entityType in request, offer, connection, review)
 *
 * Usage:
 *   cd backend && npx ts-node --transpile-only scripts/purge-requests-offers-connections.ts --dry-run
 *   cd backend && npx ts-node --transpile-only scripts/purge-requests-offers-connections.ts --apply
 */
import { PrismaClient } from '@prisma/client';

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

  try {
    console.log(`[purge] Mode: ${flags.dryRun ? 'DRY RUN (no changes)' : 'APPLY (deleting data)'}`);

    // 1. Collect IDs and counts
    const requestCount = await prisma.request.count();
    const offerCount = await prisma.offer.count();
    const connectionCount = await prisma.connection.count();
    const reviewCount = await prisma.review.count();
    const contactEventCount = await prisma.contactEvent.count();
    const requestMediaCount = await prisma.requestMedia.count();
    const requestMatchCount = await prisma.requestMatch.count();
    const offerMediaCount = await prisma.offerMedia.count();
    const offerRevisionCount = await prisma.offerRevision.count();

    const mediaTargetCount = await prisma.media.count({
      where: { purpose: { in: ['REQUEST_IMAGE', 'OFFER_IMAGE'] } }
    });

    const notifs = await prisma.notification.findMany({
      where: {
        OR: [
          { type: { startsWith: 'request.' } },
          { type: { startsWith: 'offer.' } },
          { type: { startsWith: 'connection.' } },
          { type: { startsWith: 'review.' } },
          { deepLink: { startsWith: '/requests' } },
          { deepLink: { startsWith: '/offers' } },
          { deepLink: { startsWith: '/connections' } }
        ]
      },
      select: { id: true }
    });
    const notifIds = notifs.map(n => n.id);
    const notifDeliveryCount = await prisma.notificationDelivery.count({
      where: { notificationId: { in: notifIds } }
    });

    const outboxEvents = await prisma.outboxEvent.findMany({
      where: {
        OR: [
          { aggregateType: { in: ['request', 'offer', 'connection'] } },
          { eventType: { startsWith: 'request.' } },
          { eventType: { startsWith: 'offer.' } },
          { eventType: { startsWith: 'connection.' } },
          {
            AND: [
              { aggregateType: 'media' },
              {
                OR: [
                  { payload: { path: ['purpose'], equals: 'REQUEST_IMAGE' } },
                  { payload: { path: ['purpose'], equals: 'OFFER_IMAGE' } }
                ]
              }
            ]
          }
        ]
      },
      select: { id: true }
    });
    const outboxEventIds = outboxEvents.map(e => e.id);
    const outboxConsumerCount = await prisma.outboxConsumer.count({
      where: { eventId: { in: outboxEventIds } }
    });

    const auditLogCount = await prisma.auditLog.count({
      where: { entityType: { in: ['request', 'offer', 'connection', 'review'] } }
    });

    console.log('\n--- Records Identified for Deletion ---');
    console.log(`- Requests:              ${requestCount}`);
    console.log(`- Offers:                ${offerCount}`);
    console.log(`- Connections:           ${connectionCount}`);
    console.log(`- Reviews:               ${reviewCount}`);
    console.log(`- Contact Events:        ${contactEventCount}`);
    console.log(`- Request Media links:   ${requestMediaCount}`);
    console.log(`- Request Matches:       ${requestMatchCount}`);
    console.log(`- Offer Media links:     ${offerMediaCount}`);
    console.log(`- Offer Revisions:       ${offerRevisionCount}`);
    console.log(`- Request/Offer Media:   ${mediaTargetCount}`);
    console.log(`- Notifications:         ${notifIds.length}`);
    console.log(`- Notif Deliveries:      ${notifDeliveryCount}`);
    console.log(`- Outbox Events:         ${outboxEventIds.length}`);
    console.log(`- Outbox Consumers:      ${outboxConsumerCount}`);
    console.log(`- Audit Logs:            ${auditLogCount}`);

    if (flags.dryRun) {
      console.log('\n[purge] Dry-run complete. Re-run with --apply to execute deletion.');
      return;
    }

    console.log('\n[purge] Executing database transaction...');
    await prisma.$transaction(async (tx) => {
      // Step 1: Delete reviews
      const delReviews = await tx.review.deleteMany({});
      console.log(`Deleted ${delReviews.count} reviews.`);

      // Step 2: Delete contact events
      const delContactEvents = await tx.contactEvent.deleteMany({});
      console.log(`Deleted ${delContactEvents.count} contact events.`);

      // Step 3: Delete connections
      const delConnections = await tx.connection.deleteMany({});
      console.log(`Deleted ${delConnections.count} connections.`);

      // Step 4: Clear circular FK on request.accepted_offer_id
      const clearedAcceptedOffers = await tx.request.updateMany({
        where: { acceptedOfferId: { not: null } },
        data: { acceptedOfferId: null }
      });
      console.log(`Cleared acceptedOfferId on ${clearedAcceptedOffers.count} requests.`);

      // Step 5: Delete offer media and revisions
      const delOfferMedia = await tx.offerMedia.deleteMany({});
      console.log(`Deleted ${delOfferMedia.count} offer media links.`);

      const delOfferRevisions = await tx.offerRevision.deleteMany({});
      console.log(`Deleted ${delOfferRevisions.count} offer revisions.`);

      // Step 6: Delete offers
      const delOffers = await tx.offer.deleteMany({});
      console.log(`Deleted ${delOffers.count} offers.`);

      // Step 7: Delete request media and request matches
      const delRequestMedia = await tx.requestMedia.deleteMany({});
      console.log(`Deleted ${delRequestMedia.count} request media links.`);

      const delRequestMatches = await tx.requestMatch.deleteMany({});
      console.log(`Deleted ${delRequestMatches.count} request matches.`);

      // Step 8: Delete requests
      const delRequests = await tx.request.deleteMany({});
      console.log(`Deleted ${delRequests.count} requests.`);

      // Step 9: Delete request & offer media files
      const delMedia = await tx.media.deleteMany({
        where: { purpose: { in: ['REQUEST_IMAGE', 'OFFER_IMAGE'] } }
      });
      console.log(`Deleted ${delMedia.count} media records (REQUEST_IMAGE / OFFER_IMAGE).`);

      // Step 10: Delete notifications & deliveries
      if (notifIds.length > 0) {
        const delDeliveries = await tx.notificationDelivery.deleteMany({
          where: { notificationId: { in: notifIds } }
        });
        console.log(`Deleted ${delDeliveries.count} notification deliveries.`);

        const delNotifs = await tx.notification.deleteMany({
          where: { id: { in: notifIds } }
        });
        console.log(`Deleted ${delNotifs.count} notifications.`);
      }

      // Step 11: Delete outbox events & consumers
      if (outboxEventIds.length > 0) {
        const delConsumers = await tx.outboxConsumer.deleteMany({
          where: { eventId: { in: outboxEventIds } }
        });
        console.log(`Deleted ${delConsumers.count} outbox consumers.`);

        const delEvents = await tx.outboxEvent.deleteMany({
          where: { id: { in: outboxEventIds } }
        });
        console.log(`Deleted ${delEvents.count} outbox events.`);
      }

      // Step 12: Delete audit logs
      const delAudit = await tx.auditLog.deleteMany({
        where: { entityType: { in: ['request', 'offer', 'connection', 'review'] } }
      });
      console.log(`Deleted ${delAudit.count} audit logs.`);
    }, { timeout: 60000 });

    console.log('\n[purge] Database purge successfully completed!');
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((err) => {
  console.error('[purge] Error during purge:', err);
  process.exit(1);
});
