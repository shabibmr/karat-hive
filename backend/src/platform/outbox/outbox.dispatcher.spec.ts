import { describe, expect, it, vi } from 'vitest';
import { OutboxDispatcher } from './outbox.dispatcher';
import type { OutboxClaimer, ClaimedOutboxEvent } from './outbox.claimer';

function event(overrides: Partial<ClaimedOutboxEvent> = {}): ClaimedOutboxEvent {
  return {
    id: 'evt-1',
    eventType: 'offer.submitted',
    aggregateType: 'offer',
    aggregateId: 'agg-1',
    payload: {},
    attempts: 0,
    ...overrides,
  };
}

describe('OutboxDispatcher', () => {
  it('writes the consumer marker only after the handler succeeds', async () => {
    const order: string[] = [];
    const claimer = {
      claimBatch: vi.fn(async () => [event()]),
      hasConsumed: vi.fn(async () => false),
      markConsumed: vi.fn(async () => {
        order.push('consumed');
        return true;
      }),
      markDone: vi.fn(async () => {
        order.push('done');
      }),
      markFailure: vi.fn(async () => {
        order.push('failed');
      }),
    };
    const dispatcher = new OutboxDispatcher(claimer as unknown as OutboxClaimer);
    dispatcher.register('offer.submitted', 'notifications:dispatch', async () => {
      order.push('handler');
    });
    await dispatcher.drain('w1');
    expect(order).toEqual(['handler', 'consumed', 'done']);
  });

  it('does not mark consumed when the handler throws, and records failure', async () => {
    const claimer = {
      claimBatch: vi.fn(async () => [event()]),
      hasConsumed: vi.fn(async () => false),
      markConsumed: vi.fn(async () => true),
      markDone: vi.fn(async () => undefined),
      markFailure: vi.fn(async () => undefined),
    };
    const dispatcher = new OutboxDispatcher(claimer as unknown as OutboxClaimer);
    dispatcher.register('offer.submitted', 'notifications:dispatch', async () => {
      throw new Error('boom');
    });
    await dispatcher.drain('w1');
    expect(claimer.markConsumed).not.toHaveBeenCalled();
    expect(claimer.markDone).not.toHaveBeenCalled();
    expect(claimer.markFailure).toHaveBeenCalledOnce();
  });

  it('logs a warning and marks event done when no consumers are registered', async () => {
    const claimer = {
      claimBatch: vi.fn(async () => [event({ eventType: 'unknown.event' })]),
      hasConsumed: vi.fn(async () => false),
      markConsumed: vi.fn(async () => true),
      markDone: vi.fn(async () => undefined),
      markFailure: vi.fn(async () => undefined),
    };
    const dispatcher = new OutboxDispatcher(claimer as unknown as OutboxClaimer);
    const warnSpy = vi.spyOn(dispatcher['logger'], 'warn');
    await dispatcher.drain('w1');
    expect(warnSpy).toHaveBeenCalledWith('No consumers for unknown.event; marking done.');
    expect(claimer.markDone).toHaveBeenCalledWith('evt-1');
    expect(claimer.markConsumed).not.toHaveBeenCalled();
  });
});
