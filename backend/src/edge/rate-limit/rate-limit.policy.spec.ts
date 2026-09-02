import { describe, expect, it } from 'vitest';
import { RATE_LIMIT_SCOPES, refillBucket } from './rate-limit.policy';

describe('refillBucket', () => {
  const config = { capacity: 5, refillPerMinute: 5 };
  const t0 = new Date('2026-09-01T12:00:00.000Z');

  it('allows and consumes one token', () => {
    const next = refillBucket({ tokens: 5, windowStart: t0, now: t0, config });
    expect(next.allowed).toBe(true);
    expect(next.tokens).toBe(4);
  });

  it('rejects when empty before refill', () => {
    const next = refillBucket({ tokens: 0, windowStart: t0, now: t0, config });
    expect(next.allowed).toBe(false);
    expect(next.tokens).toBe(0);
  });

  it('does not define an unknown scope (guard must not fail-open)', () => {
    expect(RATE_LIMIT_SCOPES['not-a-scope']).toBeUndefined();
  });

  it('refills by elapsed minutes without exceeding capacity', () => {
    const later = new Date(t0.getTime() + 60_000);
    const next = refillBucket({ tokens: 0, windowStart: t0, now: later, config });
    expect(next.allowed).toBe(true);
    expect(next.tokens).toBe(4);
  });
});
