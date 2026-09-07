export const GOLD_RATE_SETTING = {
  endUserDisplay: 'goldRates.endUserDisplay',
  pollIntervalMinutes: 'goldRates.pollIntervalMinutes',
  stalenessThresholdMinutes: 'goldRates.stalenessThresholdMinutes',
  purityFactors: 'goldRates.purityFactors',
  ingestState: 'goldRates.ingestState',
} as const;

export const DEFAULT_POLL_INTERVAL_MINUTES = 15;
export const DEFAULT_STALENESS_THRESHOLD_MINUTES = 60;
/** FR-SYS-010.5 — Admin alert after 2 h of ingestion failure. */
export const INGESTION_FAILURE_ALERT_MS = 2 * 60 * 60 * 1000;

export type GoldRateIngestState = {
  lastAttemptAt: string | null;
  lastSuccessAt: string | null;
  consecutiveFailures: number;
  lastError: string | null;
  failingSinceAt: string | null;
  staleAlertSentAt: string | null;
};

export const EMPTY_INGEST_STATE: GoldRateIngestState = {
  lastAttemptAt: null,
  lastSuccessAt: null,
  consecutiveFailures: 0,
  lastError: null,
  failingSinceAt: null,
  staleAlertSentAt: null,
};

export function parseIngestState(value: unknown): GoldRateIngestState {
  if (!value || typeof value !== 'object') return { ...EMPTY_INGEST_STATE };
  const v = value as Record<string, unknown>;
  return {
    lastAttemptAt: typeof v.lastAttemptAt === 'string' ? v.lastAttemptAt : null,
    lastSuccessAt: typeof v.lastSuccessAt === 'string' ? v.lastSuccessAt : null,
    consecutiveFailures:
      typeof v.consecutiveFailures === 'number' && Number.isFinite(v.consecutiveFailures)
        ? v.consecutiveFailures
        : 0,
    lastError: typeof v.lastError === 'string' ? v.lastError : null,
    failingSinceAt: typeof v.failingSinceAt === 'string' ? v.failingSinceAt : null,
    staleAlertSentAt: typeof v.staleAlertSentAt === 'string' ? v.staleAlertSentAt : null,
  };
}

export function isEndUserDisplayEnabled(value: unknown): boolean {
  return value === true || value === 'true';
}
