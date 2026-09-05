import 'reflect-metadata';
import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { AppModule } from './app.module';
import { loadDotenvFile, loadEnv } from './config/env';
import { PrismaService } from './platform/db/prisma.service';
import { OutboxDispatcher } from './platform/outbox/outbox.dispatcher';
import { SchedulerService } from './platform/scheduler/scheduler.service';

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
  scheduler.register({
    name: 'outbox.drain',
    intervalMs: 5_000,
    run: async () => {
      await dispatcher.drain(instanceId);
    },
  });
  scheduler.start(instanceId);
}

bootstrap().catch((error: unknown) => {
  console.error(error);
  process.exit(1);
});
