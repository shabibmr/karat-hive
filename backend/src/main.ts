import 'reflect-metadata';
import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { AppModule } from './app.module';
import { loadDotenvFile, loadEnv } from './config/env';
import { PrismaService } from './platform/db/prisma.service';
import { OutboxDispatcher } from './platform/outbox/outbox.dispatcher';
import { SchedulerService } from './platform/scheduler/scheduler.service';
import { OfferService } from './modules/offers';
import { RequestService } from './modules/requests';
import { VendorDocumentsService } from './modules/vendor-onboarding';
import { NotificationService } from './modules/notifications';
import { ReviewService } from './modules/reviews';
import { AdminService } from './modules/admin';
import { GoldRateService } from './modules/gold-rate';

async function bootstrap(): Promise<void> {
  loadDotenvFile();
  const env = loadEnv();
  const logger = new Logger('Bootstrap');
  const instanceId = env.INSTANCE_ID ?? `kh-${process.pid}`;

  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({ logger: false }),
  );
  app.enableShutdownHooks();

  if (env.NODE_ENV === 'production') {
    await app.get(PrismaService).assertReady();
  }

  if (env.KH_ROLE === 'worker' || env.KH_ROLE === 'all') {
    startWorkerJobs(app, instanceId);
    logger.log(`Worker jobs started instance=${instanceId} role=${env.KH_ROLE}`);
  }

  await app.listen(env.PORT, '0.0.0.0');
  logger.log(`Listening on http://127.0.0.1:${env.PORT} role=${env.KH_ROLE}`);
}

function startWorkerJobs(app: NestFastifyApplication, instanceId: string): void {
  const scheduler = app.get(SchedulerService);
  const dispatcher = app.get(OutboxDispatcher);
  const offers = app.get(OfferService);
  const requests = app.get(RequestService);
  const vendorDocs = app.get(VendorDocumentsService);
  const notifications = app.get(NotificationService);
  const reviews = app.get(ReviewService);
  const admin = app.get(AdminService);
  const goldRates = app.get(GoldRateService);

  scheduler.register({
    name: 'outbox.drain',
    intervalMs: 5_000,
    run: async () => {
      await dispatcher.drain(instanceId);
    },
  });

  scheduler.register({
    name: 'offer-expiry-sweep',
    intervalMs: 60_000,
    run: async () => {
      await offers.sweepExpiredOffers();
    },
  });

  scheduler.register({
    name: 'offer-expiry-warning',
    intervalMs: 300_000,
    run: async () => {
      await offers.sweepExpiryWarnings();
    },
  });

  scheduler.register({
    name: 'request-expiry-sweep',
    intervalMs: 60_000,
    run: async () => {
      await requests.sweepExpiredRequests();
    },
  });

  scheduler.register({
    name: 'request-expiry-warning',
    intervalMs: 300_000,
    run: async () => {
      await requests.sweepRequestExpiryWarnings();
    },
  });

  scheduler.register({
    name: 'request-draft-purge',
    intervalMs: 3_600_000,
    run: async () => {
      await requests.purgeExpiredDrafts();
    },
  });

  scheduler.register({
    name: 'vendor-document-expiry',
    intervalMs: 86_400_000,
    run: async () => {
      await vendorDocs.sweepExpiringDocuments();
    },
  });

  scheduler.register({
    name: 'notification-retry',
    intervalMs: 60_000,
    run: async () => {
      await notifications.retryFailedDeliveries();
    },
  });

  scheduler.register({
    name: 'retention-purge',
    intervalMs: 86_400_000,
    run: async () => {
      await notifications.runRetentionPurge();
    },
  });

  scheduler.register({
    name: 'rating-reconcile',
    intervalMs: 300_000,
    run: async () => {
      await reviews.reconcileRatings();
    },
  });

  scheduler.register({
    name: 'announcement-dispatch',
    intervalMs: 60_000,
    run: async () => {
      await admin.sweepAnnouncementDispatch();
    },
  });

  scheduler.register({
    name: 'gold-rate-poll',
    intervalMs: 15 * 60_000,
    run: async () => {
      await goldRates.pollGoldRates();
    },
  });

  scheduler.register({
    name: 'gold-rate-stale-alert',
    intervalMs: 15 * 60_000,
    run: async () => {
      await goldRates.alertIfStale();
    },
  });

  scheduler.start(instanceId);
}

bootstrap().catch((error: unknown) => {
  console.error(error);
  process.exit(1);
});
