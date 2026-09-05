import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../db/prisma.service';
import {
  BACKOFF_MS,
  OUTBOX_CLAIM_LEASE_MS,
  OUTBOX_MAX_ATTEMPTS,
  OUTBOX_MAX_ERROR_LENGTH,
} from './outbox.policy';

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
    const safeError =
      typeof lastError === 'string'
        ? lastError.slice(0, OUTBOX_MAX_ERROR_LENGTH)
        : String(lastError ?? '').slice(0, OUTBOX_MAX_ERROR_LENGTH);

    const delay1 = new Date(now.getTime() + BACKOFF_MS[0]);
    const delay2 = new Date(now.getTime() + BACKOFF_MS[1]);
    const delay3 = new Date(now.getTime() + BACKOFF_MS[2]);

    const rows = await this.prisma.$queryRaw<Array<{ id: string; attempts: number }>>`
      UPDATE outbox_event
      SET attempts = attempts + 1,
          claimed_at = NULL,
          claimed_by = NULL,
          last_error = ${safeError},
          state = CASE
            WHEN attempts + 1 >= ${OUTBOX_MAX_ATTEMPTS} THEN 'FAILED'::"OutboxState"
            ELSE 'PENDING'::"OutboxState"
          END,
          available_at = CASE
            WHEN attempts + 1 >= ${OUTBOX_MAX_ATTEMPTS} THEN available_at
            WHEN attempts + 1 = 1 THEN ${delay1}
            WHEN attempts + 1 = 2 THEN ${delay2}
            ELSE ${delay3}
          END
      WHERE id = ${eventId}::uuid
      RETURNING id, attempts
    `;
    if (rows.length === 0) {
      throw new Error(`outbox_event ${eventId} missing after failure increment`);
    }
  }
}
