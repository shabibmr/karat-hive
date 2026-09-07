import type { GoldRateSource } from '@prisma/client';
import { isFeedStale, snapshotSource, type RateRow } from '../domain/effective-rate';
import { money2, toWireKarat } from '../domain/purity';
import type { GoldRateIngestState } from '../domain/settings-keys';

export const DISPLAY_NOT_LICENSED = 'DISPLAY_NOT_LICENSED' as const;

export type DisplayNotLicensedPayload = {
  available: false;
  reason: typeof DISPLAY_NOT_LICENSED;
};

export type GoldRateSnapshot = {
  available: boolean;
  stale: boolean;
  source: GoldRateSource;
  sourceTimestamp: string;
  ingestedAt: string;
  staleAfter: string;
  rates: { karat: string; ratePerGramAed: string }[];
  disclaimer: string;
};

export type GoldRateFeedHealth = {
  provider: 'YAHOO_FINANCE';
  lastSuccessAt: string | null;
  lastAttemptAt: string | null;
  consecutiveFailures: number;
  lastError: string | null;
  failingSinceAt: string | null;
  staleAlertSentAt: string | null;
};

export type AdminGoldRatePayload = GoldRateSnapshot & {
  feedHealth: GoldRateFeedHealth;
  pollIntervalMinutes: number;
  stalenessThresholdMinutes: number;
};

export type GoldRateHistoryRow = {
  id: string;
  karat: string;
  ratePerGramAed: string;
  source: GoldRateSource;
  feedProvider: string | null;
  sourceTimestamp: string;
  ingestedAt: string;
  overrideReason: string | null;
  overrideExpiresAt: string | null;
};

export function disclaimerFor(lang: 'en' | 'ar'): string {
  return lang === 'ar'
    ? 'للإيضاح فقط — ليست عرض سعر ولا إيجاباً.'
    : 'Indicative only — not a quotation or an offer.';
}

export function presentDisplayNotLicensed(): DisplayNotLicensedPayload {
  return { available: false, reason: DISPLAY_NOT_LICENSED };
}

export function presentSnapshot(
  rows: RateRow[],
  now: Date,
  stalenessThresholdMs: number,
  lang: 'en' | 'ar',
): GoldRateSnapshot {
  if (rows.length === 0) {
    return {
      available: false,
      stale: true,
      source: 'FEED',
      sourceTimestamp: now.toISOString(),
      ingestedAt: now.toISOString(),
      staleAfter: new Date(now.getTime() + stalenessThresholdMs).toISOString(),
      rates: [],
      disclaimer: disclaimerFor(lang),
    };
  }

  const newest = rows.reduce((a, b) =>
    a.sourceTimestamp.getTime() >= b.sourceTimestamp.getTime() ? a : b,
  );
  const stale = rows.some((row) => isFeedStale(row, now, stalenessThresholdMs));

  return {
    available: true,
    stale,
    source: snapshotSource(rows),
    sourceTimestamp: newest.sourceTimestamp.toISOString(),
    ingestedAt: newest.createdAt.toISOString(),
    staleAfter: new Date(newest.sourceTimestamp.getTime() + stalenessThresholdMs).toISOString(),
    rates: rows.map((row) => ({
      karat: toWireKarat(row.purityKarat),
      ratePerGramAed: money2(row.ratePerGramAed),
    })),
    disclaimer: disclaimerFor(lang),
  };
}

export function presentFeedHealth(state: GoldRateIngestState): GoldRateFeedHealth {
  return {
    provider: 'YAHOO_FINANCE',
    lastSuccessAt: state.lastSuccessAt,
    lastAttemptAt: state.lastAttemptAt,
    consecutiveFailures: state.consecutiveFailures,
    lastError: state.lastError,
    failingSinceAt: state.failingSinceAt,
    staleAlertSentAt: state.staleAlertSentAt,
  };
}

export function presentHistoryRow(row: RateRow): GoldRateHistoryRow {
  return {
    id: row.id,
    karat: toWireKarat(row.purityKarat),
    ratePerGramAed: money2(row.ratePerGramAed),
    source: row.source,
    feedProvider: row.feedProvider,
    sourceTimestamp: row.sourceTimestamp.toISOString(),
    ingestedAt: row.createdAt.toISOString(),
    overrideReason: row.overrideReason,
    overrideExpiresAt: row.overrideExpiresAt?.toISOString() ?? null,
  };
}
