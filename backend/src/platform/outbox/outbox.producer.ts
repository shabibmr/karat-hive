import { Prisma } from '@prisma/client';
import type { DbTx } from '../db/tx';
import type { OutboxEventType } from './outbox.events';

export type OutboxEnqueueInput = {
  eventType: OutboxEventType;
  aggregateType: string;
  aggregateId: string;
  payload: Prisma.InputJsonValue;
  availableAt?: Date;
};

/** Insert in the same transaction as the domain write (AD-BE-06). */
export async function enqueueOutbox(tx: DbTx, input: OutboxEnqueueInput): Promise<void> {
  await tx.outboxEvent.create({
    data: {
      eventType: input.eventType,
      aggregateType: input.aggregateType,
      aggregateId: input.aggregateId,
      payload: input.payload,
      availableAt: input.availableAt,
      state: 'PENDING',
    },
  });
}
