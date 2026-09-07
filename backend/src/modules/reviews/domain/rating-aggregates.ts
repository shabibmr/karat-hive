/** SAM-GAP-8 / Physical-Data-Model: vendor_profile.rating_trend jsonb shape. */
export type RatingTrendPoint = {
  period: string;
  average: number;
  count: number;
};

export function averageRating(reviews: { rating: number }[]): number | null {
  if (reviews.length === 0) return null;
  return Number(
    (reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length).toFixed(1),
  );
}

/** Six calendar months ending at `now`, oldest first (`FR-SYS-012`, SAM-GAP-8). */
export function buildSixMonthRatingTrend(
  reviews: { rating: number; createdAt: Date }[],
  now: Date,
): RatingTrendPoint[] {
  const trend: RatingTrendPoint[] = [];
  for (let i = 5; i >= 0; i--) {
    const start = new Date(now.getFullYear(), now.getMonth() - i, 1);
    const end = new Date(now.getFullYear(), now.getMonth() - i + 1, 1);
    const period = `${start.getFullYear()}-${String(start.getMonth() + 1).padStart(2, '0')}`;
    const monthReviews = reviews.filter(
      (r) => r.createdAt >= start && r.createdAt < end,
    );
    trend.push({
      period,
      average: averageRating(monthReviews) ?? 0,
      count: monthReviews.length,
    });
  }
  return trend;
}
