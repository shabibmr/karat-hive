import type { GoldRate, GoldRateSource, Karat } from '@prisma/client';

export type RateRow = Pick<
  GoldRate,
  | 'id'
  | 'purityKarat'
  | 'ratePerGramAed'
  | 'source'
  | 'feedProvider'
  | 'sourceTimestamp'
  | 'overrideReason'
  | 'overrideExpiresAt'
  | 'createdAt'
>;

function isActiveOverride(row: RateRow, now: Date): boolean {
  if (row.source !== 'MANUAL_OVERRIDE') return false;
  return row.overrideExpiresAt === null || row.overrideExpiresAt > now;
}

function later(a: RateRow, b: RateRow): RateRow {
  const ts = a.sourceTimestamp.getTime() - b.sourceTimestamp.getTime();
  if (ts !== 0) return ts > 0 ? a : b;
  return a.createdAt.getTime() >= b.createdAt.getTime() ? a : b;
}

/**
 * Active override wins; else latest FEED; else last-good of any source
 * (expired override included). Never invents a row.
 */
export function pickEffectiveRate(rows: RateRow[], now: Date): RateRow | null {
  if (rows.length === 0) return null;

  let bestOverride: RateRow | null = null;
  let bestFeed: RateRow | null = null;
  let bestAny: RateRow | null = null;

  for (const row of rows) {
    bestAny = bestAny ? later(bestAny, row) : row;
    if (isActiveOverride(row, now)) {
      bestOverride = bestOverride ? later(bestOverride, row) : row;
    } else if (row.source === 'FEED') {
      bestFeed = bestFeed ? later(bestFeed, row) : row;
    }
  }

  return bestOverride ?? bestFeed ?? bestAny;
}

export function pickEffectiveRates(
  rows: RateRow[],
  karats: Karat[],
  now: Date,
): Map<Karat, RateRow> {
  const byKarat = new Map<Karat, RateRow[]>();
  for (const row of rows) {
    const list = byKarat.get(row.purityKarat) ?? [];
    list.push(row);
    byKarat.set(row.purityKarat, list);
  }
  const result = new Map<Karat, RateRow>();
  for (const karat of karats) {
    const picked = pickEffectiveRate(byKarat.get(karat) ?? [], now);
    if (picked) result.set(karat, picked);
  }
  return result;
}

export function isFeedStale(row: RateRow, now: Date, stalenessThresholdMs: number): boolean {
  if (
    row.source === 'MANUAL_OVERRIDE' &&
    (row.overrideExpiresAt === null || row.overrideExpiresAt > now)
  ) {
    return false;
  }
  return now.getTime() - row.sourceTimestamp.getTime() > stalenessThresholdMs;
}

export function snapshotSource(rows: RateRow[]): GoldRateSource {
  const k24 = rows.find((r) => r.purityKarat === 'K24');
  return (k24 ?? rows[0])?.source ?? 'FEED';
}
