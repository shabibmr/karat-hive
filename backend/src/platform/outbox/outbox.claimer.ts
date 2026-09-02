import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../db/prisma.service';
import { OUTBOX_CLAIM_LEASE_MS, outboxBackoffAfterFailure } from './outbox.policy';

export type ClaimedOutboxEvent = {
  id: string;
  eventType: string;
  aggregateType: string;
  aggregateId: string;
  payload: Prisma.JsonValue;
  attempts: number;
};

@Injectable()
export class OutboxClaimer {
  constructor(private readonly prisma: PrismaService) {}

  async reclaimExpired(now: Date = new Date()): Promise<number> {
    const cutoff = new Date(now.getTime() - OUTBOX_CLAIM_LEASE_MS);
    const result = await this.prisma.$executeRaw`
      UPDATE outbox_event
      SET state = 'PENDING'::"OutboxState",
          claimed_at = NULL,
          claimed_by = NULL
      WHERE state = 'CLAIMED'::"OutboxState"
        AND claimed_at IS NOT NULL
        AND claimed_at <= ${cutoff}
    `;
    return Number(result);
  }

  async claimBatch(workerId: string, limit: number): Promise<ClaimedOutboxEvent[]> {
    await this.reclaimExpired();
    const rows = await this.prisma.$queryRaw<ClaimedOutboxEvent[]>`
      UPDATE outbox_event
      SET state = 'CLAIMED'::"OutboxState",
          claimed_at = now(),
          claimed_by = ${workerId}
      WHERE id IN (
        SELECT id FROM outbox_event
        WHERE state = 'PENDING'::"OutboxState"
          AND available_at <= now()
        ORDER BY available_at
        FOR UPDATE SKIP LOCKED
        LIMIT ${limit}
      )
      RETURNING id, event_type AS "eventType", aggregate_type AS "aggregateType",
                aggregate_id AS "aggregateId", payload, attempts
    `;
    return rows;
  }

  async hasConsumed(eventId: string, consumer: string): Promise<boolean> {
    const row = await this.prisma.outboxConsumer.findUnique({
      where: { eventId_consumer: { eventId, consumer } },
    });
    return row !== null;
  }

  async markConsumed(eventId: string, consumer: string): Promise<boolean> {
    try {
      await this.prisma.outboxConsumer.create({
        data: { eventId, consumer, consumedAt: new Date() },
      });
      return true;
    } catch (error: unknown) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        return false;
      }
      throw error;
    }
  }

  async markDone(eventId: string): Promise<void> {
    await this.prisma.outboxEvent.update({
      where: { id: eventId },
      data: { state: 'DONE', lastError: null },
    });
  }

  async markFailure(eventId: string, lastError: string, now: Date = new Date()): Promise<void> {
    const rows = await this.prisma.$queryRaw<Array<{ attempts: number }>>`
      UPDATE outbox_event
      SET attempts = attempts + 1
      WHERE id = ${eventId}::uuid
      RETURNING attempts
    `;
    const attempts = rows[0]?.attempts;
    if (attempts === undefined) {
      throw new Error(`outbox_event ${eventId} missing after failure increment`);
    }
    const backoff = outboxBackoffAfterFailure(attempts);
    if (backoff.outcome === 'fail') {
      await this.prisma.outboxEvent.update({
        where: { id: eventId },
        data: { state: 'FAILED', lastError, claimedAt: null, claimedBy: null },
      });
      return;
    }
    await this.prisma.outboxEvent.update({
      where: { id: eventId },
      data: {
        state: 'PENDING',
        availableAt: new Date(now.getTime() + backoff.delayMs),
        claimedAt: null,
        claimedBy: null,
        lastError,
      },
    });
  }
}
