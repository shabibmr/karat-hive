import { describe, expect, it } from 'vitest';
import { canAcquireJobLock } from './job-lock.policy';

describe('canAcquireJobLock', () => {
  const now = new Date('2026-09-01T12:00:00.000Z');

  it('acquires when no row exists', () => {
    expect(canAcquireJobLock({ now, requester: 'w1', existing: null })).toBe(true);
  });

  it('refuses a live lease even for the same owner (renew is a separate call)', () => {
    expect(
      canAcquireJobLock({
        now,
        requester: 'w1',
        existing: { owner: 'w1', leasedUntil: new Date('2026-09-01T13:00:00.000Z') },
      }),
    ).toBe(false);
  });

  it('refuses a live lease held by another worker', () => {
    expect(
      canAcquireJobLock({
        now,
        requester: 'w2',
        existing: { owner: 'w1', leasedUntil: new Date('2026-09-01T12:00:01.000Z') },
      }),
    ).toBe(false);
  });

  it('allows another worker after the lease expires', () => {
    expect(
      canAcquireJobLock({
        now,
        requester: 'w2',
        existing: { owner: 'w1', leasedUntil: new Date('2026-09-01T12:00:00.000Z') },
      }),
    ).toBe(true);
  });
});
