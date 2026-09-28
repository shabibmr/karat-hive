import { BeforeApplicationShutdown, Injectable, Logger } from '@nestjs/common';
import { OutboxClaimer, type ClaimedOutboxEvent } from './outbox.claimer';
import type { OutboxEventType } from './outbox.events';
import { PerfTimer, perfLogEnabled } from '../perf/perf-timer';

export type OutboxHandler = (event: ClaimedOutboxEvent) => Promise<void>;

type RegisteredConsumer = { consumer: string; handler: OutboxHandler };

const DRAIN_TIMEOUT_MS = 30_000;

@Injectable()
export class OutboxDispatcher implements BeforeApplicationShutdown {
  private readonly logger = new Logger(OutboxDispatcher.name);
  private readonly handlers = new Map<OutboxEventType, RegisteredConsumer[]>();
  private claiming = true;
  private inflight: Promise<unknown> | null = null;

  constructor(private readonly claimer: OutboxClaimer) {}

  register(eventType: OutboxEventType, consumer: string, handler: OutboxHandler): void {
    const list = this.handlers.get(eventType) ?? [];
    list.push({ consumer, handler });
    this.handlers.set(eventType, list);
  }

  stopClaiming(): void {
    this.claiming = false;
  }

  async beforeApplicationShutdown(): Promise<void> {
    this.claiming = false;
    if (this.inflight === null) return;
    await Promise.race([this.inflight, sleep(DRAIN_TIMEOUT_MS)]);
  }

  async drain(workerId: string, batchSize = 20): Promise<number> {
    if (!this.claiming) return 0;
    const run = this.drainBatch(workerId, batchSize);
    this.inflight = run;
    try {
      return await run;
    } finally {
      if (this.inflight === run) this.inflight = null;
    }
  }

  private async drainBatch(workerId: string, batchSize: number): Promise<number> {
    const batch = await this.claimer.claimBatch(workerId, batchSize);
    if (perfLogEnabled && batch.length > 0) {
      this.logger.log(`[Perf] outbox.drain batchSize=${batch.length}`);
    }
    for (const event of batch) {
      // Queue wait = how long the event sat PENDING before this worker claimed it —
      // directly measures the outbox.drain poll interval's contribution to latency.
      const queueWaitMs = Date.now() - event.createdAt.getTime();
      const perf = new PerfTimer(`[Perf] outbox.event ${event.eventType}`, {
        eventId: event.id,
        queueWaitMs,
      });
      const consumers = this.handlers.get(event.eventType as OutboxEventType) ?? [];
      try {
        if (consumers.length === 0) {
          this.logger.warn(`No consumers for ${event.eventType}; marking done.`);
          await this.claimer.markDone(event.id);
          continue;
        }
        for (const { consumer, handler } of consumers) {
          if (await this.claimer.hasConsumed(event.id, consumer)) continue;
          await handler(event);
          perf.lap(consumer);
          await this.claimer.markConsumed(event.id, consumer);
        }
        await this.claimer.markDone(event.id);
        perf.done({ outcome: 'done' });
      } catch (error: unknown) {
        const message = error instanceof Error ? error.message : String(error);
        this.logger.warn(`Outbox event ${event.id} failed: ${message}`);
        await this.claimer.markFailure(event.id, message);
        perf.done({ outcome: 'failed' });
      }
    }
    return batch.length;
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
