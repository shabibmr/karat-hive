import { describe, expect, it } from 'vitest';
import {
  outboxBackoffAfterFailure,
  isClaimLeaseExpired,
  OUTBOX_CLAIM_LEASE_MS,
} from './outbox.policy';

describe('outboxBackoffAfterFailure', () => {
  it('retries with 1m then 5m then 25m, then fails on the fourth attempt', () => {
    expect(outboxBackoffAfterFailure(1)).toEqual({ outcome: 'retry', delayMs: 60_000 });
    expect(outboxBackoffAfterFailure(2)).toEqual({ outcome: 'retry', delayMs: 5 * 60_000 });
    expect(outboxBackoffAfterFailure(3)).toEqual({ outcome: 'retry', delayMs: 25 * 60_000 });
    expect(outboxBackoffAfterFailure(4)).toEqual({ outcome: 'fail' });
  });
});

describe('outbox claim lease', () => {
  it('treats a claim older than the lease as reclaimable', () => {
    const now = new Date('2026-09-01T12:00:00.000Z');
    const fresh = new Date(now.getTime() - OUTBOX_CLAIM_LEASE_MS + 1);
    const stale = new Date(now.getTime() - OUTBOX_CLAIM_LEASE_MS);
    expect(isClaimLeaseExpired(fresh, now)).toBe(false);
    expect(isClaimLeaseExpired(stale, now)).toBe(true);
    expect(isClaimLeaseExpired(null, now)).toBe(true);
  });

  it('selects a disjoint pending batch in available_at order (SKIP LOCKED analogue)', () => {
    const now = new Date('2026-09-01T12:00:00.000Z');
    const rows = [
      { id: 'later', state: 'PENDING', availableAt: new Date('2026-09-01T11:59:30.000Z') },
      { id: 'due', state: 'PENDING', availableAt: new Date('2026-09-01T11:59:00.000Z') },
      { id: 'claimed', state: 'CLAIMED', availableAt: new Date('2026-09-01T11:00:00.000Z') },
      { id: 'future', state: 'PENDING', availableAt: new Date('2026-09-01T13:00:00.000Z') },
    ];
    const claimedByA = claimPending(rows, now, 10);
    expect(claimedByA.map((r) => r.id)).toEqual(['due', 'later']);
    const remaining = rows.filter((r) => !claimedByA.includes(r));
    expect(claimPending(remaining, now, 10).map((r) => r.id)).toEqual([]);
  });
});

function claimPending<T extends { state: string; availableAt: Date }>(
  rows: T[],
  now: Date,
  limit: number,
): T[] {
  return rows
    .filter((row) => row.state === 'PENDING' && row.availableAt.getTime() <= now.getTime())
    .sort((a, b) => a.availableAt.getTime() - b.availableAt.getTime())
    .slice(0, limit);
}
