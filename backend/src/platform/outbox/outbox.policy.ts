/** Architecture §11.1: 1 m, 5 m, 25 m then FAILED. Attempts increment on failure, not claim. */
export const OUTBOX_MAX_ATTEMPTS = 4;

const BACKOFF_MS = [60_000, 5 * 60_000, 25 * 60_000] as const;

export const OUTBOX_CLAIM_LEASE_MS = 60_000;

export type OutboxBackoff = { outcome: 'retry'; delayMs: number } | { outcome: 'fail' };

/** `attempts` is the count *after* the failure just recorded (1-based). */
export function outboxBackoffAfterFailure(attempts: number): OutboxBackoff {
  if (attempts >= OUTBOX_MAX_ATTEMPTS) return { outcome: 'fail' };
  const delayMs = BACKOFF_MS[attempts - 1] ?? 25 * 60_000;
  return { outcome: 'retry', delayMs };
}

export function isClaimLeaseExpired(
  claimedAt: Date | null,
  now: Date,
  leaseMs = OUTBOX_CLAIM_LEASE_MS,
): boolean {
  if (claimedAt === null) return true;
  return now.getTime() - claimedAt.getTime() >= leaseMs;
}
