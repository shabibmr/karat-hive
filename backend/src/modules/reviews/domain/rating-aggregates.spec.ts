import { describe, expect, it } from 'vitest';
import { averageRating, buildSixMonthRatingTrend } from './rating-aggregates';

describe('rating-aggregates', () => {
  it('returns null average for an empty set', () => {
    expect(averageRating([])).toBeNull();
  });

  it('averages published ratings to one decimal', () => {
    expect(averageRating([{ rating: 5 }, { rating: 4 }, { rating: 4 }])).toBe(4.3);
  });

  it('builds a 6-month ratingTrend with period/average/count (SAM-GAP-8)', () => {
    const now = new Date('2026-09-15T12:00:00Z');
    const reviews = [
      { rating: 5, createdAt: new Date('2026-09-01T10:00:00Z') },
      { rating: 4, createdAt: new Date('2026-09-10T10:00:00Z') },
      { rating: 3, createdAt: new Date('2026-07-20T10:00:00Z') },
    ];

    const trend = buildSixMonthRatingTrend(reviews, now);

    expect(trend).toHaveLength(6);
    expect(trend[0]).toEqual({ period: '2026-04', average: 0, count: 0 });
    expect(trend[3]).toEqual({ period: '2026-07', average: 3, count: 1 });
    expect(trend[5]).toEqual({ period: '2026-09', average: 4.5, count: 2 });
  });

  it('is idempotent for the same inputs', () => {
    const now = new Date('2026-03-01T00:00:00Z');
    const reviews = [{ rating: 5, createdAt: new Date('2026-01-15T00:00:00Z') }];
    expect(buildSixMonthRatingTrend(reviews, now)).toEqual(
      buildSixMonthRatingTrend(reviews, now),
    );
  });
});
