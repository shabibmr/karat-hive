import { describe, expect, it } from 'vitest';
import { hashBody, isIdempotencyRequired, isReplayFresh } from './idempotency.policy';

describe('idempotency policy', () => {
  it('requires keys on publish, offer submit, accept, and media intent only', () => {
    expect(isIdempotencyRequired('POST', '/v1/requests/abc/publish')).toBe(true);
    expect(isIdempotencyRequired('POST', '/v1/requests/abc/offers')).toBe(true);
    expect(isIdempotencyRequired('POST', '/v1/offers/abc/accept')).toBe(true);
    expect(isIdempotencyRequired('POST', '/v1/media/upload-intent')).toBe(true);
    expect(isIdempotencyRequired('POST', '/v1/offers/abc/revise')).toBe(false);
    expect(isIdempotencyRequired('POST', '/v1/admin/vendors/abc/suspend')).toBe(false);
    expect(isIdempotencyRequired('POST', '/v1/auth/login')).toBe(false);
  });

  it('hashes bodies stably regardless of key order', () => {
    expect(hashBody({ b: 1, a: 2 })).toBe(hashBody({ a: 2, b: 1 }));
    expect(hashBody({ a: 1 })).not.toBe(hashBody({ a: 2 }));
  });

  it('replays only within 24 hours', () => {
    const created = new Date('2026-09-01T00:00:00.000Z');
    expect(isReplayFresh(created, new Date('2026-09-01T23:59:59.000Z'))).toBe(true);
    expect(isReplayFresh(created, new Date('2026-09-02T00:00:00.000Z'))).toBe(false);
  });
});
