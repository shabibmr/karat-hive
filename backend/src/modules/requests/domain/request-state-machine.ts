import type { Direction, RequestState, RequestType } from '@prisma/client';

export const TERMINAL_REQUEST_STATES: readonly RequestState[] = [
  'CLOSED',
  'EXPIRED',
  'CANCELLED',
  'REMOVED',
] as const;

export const LIVE_REQUEST_STATES: readonly RequestState[] = [
  'PUBLISHED',
  'OFFERS_RECEIVED',
] as const;

export const ALLOWED_TRANSITIONS: Readonly<Record<RequestState, readonly RequestState[]>> = {
  DRAFT: ['PUBLISHED', 'CANCELLED', 'REMOVED'],
  PUBLISHED: ['OFFERS_RECEIVED', 'CANCELLED', 'EXPIRED', 'REMOVED'],
  OFFERS_RECEIVED: ['ACCEPTED', 'CANCELLED', 'EXPIRED', 'REMOVED'],
  ACCEPTED: ['CLOSED', 'REMOVED'],
  CLOSED: [],
  EXPIRED: ['REMOVED'],
  CANCELLED: ['REMOVED'],
  REMOVED: [],
};

export function canTransitionRequest(from: RequestState, to: RequestState): boolean {
  return ALLOWED_TRANSITIONS[from].includes(to);
}

export function isTerminalRequestState(state: RequestState): boolean {
  return (TERMINAL_REQUEST_STATES as readonly string[]).includes(state);
}

export function isLiveRequestState(state: RequestState): boolean {
  return (LIVE_REQUEST_STATES as readonly string[]).includes(state);
}

/**
 * Direction is fixed by type: FIND_ORNAMENT -> BUY; SELL_OLD_GOLD -> SELL;
 * coins and bullion are caller-selected (FR-CUS-005).
 */
export function resolveRequestDirection(
  type: RequestType,
  callerDirection?: Direction,
): Direction {
  if (type === 'FIND_ORNAMENT') return 'BUY';
  if (type === 'SELL_OLD_GOLD') return 'SELL';
  if (callerDirection === 'BUY' || callerDirection === 'SELL') return callerDirection;
  return 'BUY';
}
