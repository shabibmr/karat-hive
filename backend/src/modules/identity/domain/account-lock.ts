/** Password-login lockout arithmetic (FR-VEN-003 AC5). Pure. */

export type LockState = { failedLoginAttempts: number; lockedUntil: Date | null };

export function isLocked(state: LockState, now: Date): boolean {
  return state.lockedUntil !== null && state.lockedUntil.getTime() > now.getTime();
}

export function registerFailure(
  state: LockState,
  now: Date,
  maxFailures: number,
  lockMinutes: number,
): LockState {
  const attempts = state.failedLoginAttempts + 1;
  if (attempts >= maxFailures) {
    return { failedLoginAttempts: 0, lockedUntil: new Date(now.getTime() + lockMinutes * 60_000) };
  }
  return { failedLoginAttempts: attempts, lockedUntil: null };
}

export function clearFailures(): LockState {
  return { failedLoginAttempts: 0, lockedUntil: null };
}

export function lockMinutesRemaining(lockedUntil: Date, now: Date): number {
  return Math.max(1, Math.ceil((lockedUntil.getTime() - now.getTime()) / 60_000));
}
