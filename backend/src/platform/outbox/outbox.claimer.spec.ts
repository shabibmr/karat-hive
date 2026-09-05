import { describe, expect, it, vi } from 'vitest';
import { Prisma } from '@prisma/client';
import { OutboxClaimer } from './outbox.claimer';
import { OUTBOX_MAX_ERROR_LENGTH } from './outbox.policy';
import type { PrismaService } from '../db/prisma.service';

function createMockPrisma() {
  return {
    $queryRaw: vi.fn(),
    $executeRaw: vi.fn(),
    outboxConsumer: {
      findUnique: vi.fn(),
      create: vi.fn(),
    },
    outboxEvent: {
      update: vi.fn(),
    },
  } as unknown as PrismaService;
}

describe('OutboxClaimer', () => {
  describe('markFailure', () => {
    it('consolidates attempt increment and backoff update into a single query', async () => {
      const prisma = createMockPrisma();
      vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([{ id: 'evt-1', attempts: 1 }]);

      const claimer = new OutboxClaimer(prisma);
      const fixedNow = new Date('2026-09-03T00:00:00.000Z');

      await claimer.markFailure(
        'e0000000-0000-0000-0000-000000000001',
        'network timeout',
        fixedNow,
      );

      // Exactly one query roundtrip executed
      expect(prisma.$queryRaw).toHaveBeenCalledTimes(1);
      expect(prisma.outboxEvent.update).not.toHaveBeenCalled();
    });

    it('truncates error message exceeding safe maximum length', async () => {
      const prisma = createMockPrisma();
      vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([{ id: 'evt-1', attempts: 1 }]);

      const claimer = new OutboxClaimer(prisma);
      const longError = 'x'.repeat(2500);

      await claimer.markFailure('e0000000-0000-0000-0000-000000000001', longError);

      expect(prisma.$queryRaw).toHaveBeenCalledTimes(1);
      const queryCall = vi.mocked(prisma.$queryRaw).mock.calls[0];
      const passedError = queryCall?.find(
        (arg) => typeof arg === 'string' && arg.startsWith('xxx'),
      ) as string;

      expect(passedError).toBeDefined();
      expect(passedError.length).toBe(OUTBOX_MAX_ERROR_LENGTH);
    });

    it('throws when the target outbox event does not exist', async () => {
      const prisma = createMockPrisma();
      vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([]);

      const claimer = new OutboxClaimer(prisma);

      await expect(
        claimer.markFailure('e0000000-0000-0000-0000-000000000001', 'not found err'),
      ).rejects.toThrow(
        'outbox_event e0000000-0000-0000-0000-000000000001 missing after failure increment',
      );
    });
  });

  describe('markDone', () => {
    it('updates state to DONE and clears lastError', async () => {
      const prisma = createMockPrisma();
      vi.mocked(prisma.outboxEvent.update).mockResolvedValueOnce({} as never);

      const claimer = new OutboxClaimer(prisma);
      await claimer.markDone('evt-1');

      expect(prisma.outboxEvent.update).toHaveBeenCalledWith({
        where: { id: 'evt-1' },
        data: { state: 'DONE', lastError: null },
      });
    });
  });

  describe('hasConsumed and markConsumed', () => {
    it('returns false when consumer record does not exist', async () => {
      const prisma = createMockPrisma();
      vi.mocked(prisma.outboxConsumer.findUnique).mockResolvedValueOnce(null);

      const claimer = new OutboxClaimer(prisma);
      const result = await claimer.hasConsumed('evt-1', 'consumer-a');

      expect(result).toBe(false);
      expect(prisma.outboxConsumer.findUnique).toHaveBeenCalledWith({
        where: { eventId_consumer: { eventId: 'evt-1', consumer: 'consumer-a' } },
      });
    });

    it('handles duplicate consumer marker gracefully (P2002)', async () => {
      const prisma = createMockPrisma();
      const p2002 = new Prisma.PrismaClientKnownRequestError('Unique violation', {
        code: 'P2002',
        clientVersion: '5.x',
      });
      vi.mocked(prisma.outboxConsumer.create).mockRejectedValueOnce(p2002);

      const claimer = new OutboxClaimer(prisma);
      const result = await claimer.markConsumed('evt-1', 'consumer-a');

      expect(result).toBe(false);
    });
  });
});
