import { Prisma } from '@prisma/client';
import { describe, expect, it } from 'vitest';
import { isFeedStale, pickEffectiveRate, type RateRow } from './effective-rate';

const now = new Date('2026-09-07T12:00:00Z');

function row(partial: Partial<RateRow> & Pick<RateRow, 'id' | 'source'>): RateRow {
  return {
    purityKarat: 'K24',
    ratePerGramAed: new Prisma.Decimal('300.00'),
    feedProvider: partial.source === 'FEED' ? 'YAHOO_FINANCE' : null,
    sourceTimestamp: new Date('2026-09-07T10:00:00Z'),
    overrideReason: null,
    overrideExpiresAt: null,
    createdAt: new Date('2026-09-07T10:00:01Z'),
    ...partial,
  };
}

describe('pickEffectiveRate', () => {
  it('prefers an unexpired manual override over a newer feed', () => {
    const feed = row({
      id: 'feed',
      source: 'FEED',
      sourceTimestamp: new Date('2026-09-07T11:50:00Z'),
    });
    const override = row({
      id: 'ov',
      source: 'MANUAL_OVERRIDE',
      ratePerGramAed: new Prisma.Decimal('310.00'),
      overrideReason: 'feed down',
      overrideExpiresAt: new Date('2026-09-07T18:00:00Z'),
      sourceTimestamp: new Date('2026-09-07T11:00:00Z'),
    });
    expect(pickEffectiveRate([feed, override], now)?.id).toBe('ov');
  });

  it('falls back to feed after override expiry (last-good feed retained)', () => {
    const feed = row({ id: 'feed', source: 'FEED' });
    const expired = row({
      id: 'ov',
      source: 'MANUAL_OVERRIDE',
      overrideExpiresAt: new Date('2026-09-07T11:00:00Z'),
      sourceTimestamp: new Date('2026-09-07T11:00:00Z'),
    });
    expect(pickEffectiveRate([expired, feed], now)?.id).toBe('feed');
  });

  it('keeps an expired override as last-good when no feed exists', () => {
    const expired = row({
      id: 'ov',
      source: 'MANUAL_OVERRIDE',
      overrideExpiresAt: new Date('2026-09-07T11:00:00Z'),
    });
    expect(pickEffectiveRate([expired], now)?.id).toBe('ov');
  });

  it('returns null when there are no rows', () => {
    expect(pickEffectiveRate([], now)).toBeNull();
  });
});

describe('isFeedStale', () => {
  it('marks a feed older than the threshold stale and leaves an active override fresh', () => {
    const hour = 60 * 60 * 1000;
    const oldFeed = row({
      id: 'feed',
      source: 'FEED',
      sourceTimestamp: new Date('2026-09-07T10:00:00Z'),
    });
    const override = row({
      id: 'ov',
      source: 'MANUAL_OVERRIDE',
      overrideExpiresAt: new Date('2026-09-08T00:00:00Z'),
      sourceTimestamp: new Date('2026-09-07T10:00:00Z'),
    });
    expect(isFeedStale(oldFeed, now, hour)).toBe(true);
    expect(isFeedStale(override, now, hour)).toBe(false);
  });
});
