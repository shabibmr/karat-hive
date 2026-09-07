import { HttpStatus } from '@nestjs/common';
import type { OfferState } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';

export const TERMINAL_OFFER_STATES: ReadonlySet<OfferState> = new Set<OfferState>([
  'ACCEPTED',
  'REJECTED',
  'EXPIRED',
  'WITHDRAWN',
  'WITHDRAWN_BY_SYSTEM',
]);

export function isOfferTerminal(state: OfferState): boolean {
  return TERMINAL_OFFER_STATES.has(state);
}

const ALLOWED_TRANSITIONS: Record<OfferState, ReadonlySet<OfferState>> = {
  PENDING: new Set<OfferState>([
    'ACCEPTED',
    'REJECTED',
    'EXPIRED',
    'WITHDRAWN',
    'WITHDRAWN_BY_SYSTEM',
  ]),
  ACCEPTED: new Set(),
  REJECTED: new Set(),
  EXPIRED: new Set(),
  WITHDRAWN: new Set(),
  WITHDRAWN_BY_SYSTEM: new Set(),
};

/**
 * Pure state machine transition function (SRS §5.3 / NFR-029).
 * Throws 409 CONFLICT if the transition is illegal.
 */
export function transitionOfferState(current: OfferState, next: OfferState): OfferState {
  if (current === next) return current;

  const allowed = ALLOWED_TRANSITIONS[current];
  if (!allowed || !allowed.has(next)) {
    if (current === 'EXPIRED') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_EXPIRED);
    }
    if (isOfferTerminal(current)) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_NOT_PENDING);
    }
    throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT);
  }

  return next;
}
