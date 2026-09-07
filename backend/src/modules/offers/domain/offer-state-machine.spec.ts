import { describe, expect, it } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import type { OfferState } from '@prisma/client';
import { ErrorCode } from '../../../edge/errors/error-codes';
import {
  isOfferTerminal,
  TERMINAL_OFFER_STATES,
  transitionOfferState,
} from './offer-state-machine';

describe('offer-state-machine', () => {
  it('allows valid transitions from PENDING', () => {
    const validTargets: OfferState[] = [
      'ACCEPTED',
      'REJECTED',
      'EXPIRED',
      'WITHDRAWN',
      'WITHDRAWN_BY_SYSTEM',
    ];

    for (const target of validTargets) {
      expect(transitionOfferState('PENDING', target)).toBe(target);
    }
  });

  it('no-op when transitioning to self', () => {
    expect(transitionOfferState('PENDING', 'PENDING')).toBe('PENDING');
    expect(transitionOfferState('ACCEPTED', 'ACCEPTED')).toBe('ACCEPTED');
  });

  it('disallows transitions out of terminal states', () => {
    for (const terminal of TERMINAL_OFFER_STATES) {
      if (terminal === 'EXPIRED') {
        expect(() => transitionOfferState('EXPIRED', 'PENDING')).toThrowError(
          expect.objectContaining({
            status: HttpStatus.CONFLICT,
            errorCode: ErrorCode.OFFER_EXPIRED,
          }),
        );
      } else {
        expect(() => transitionOfferState(terminal, 'PENDING')).toThrowError(
          expect.objectContaining({
            status: HttpStatus.CONFLICT,
            errorCode: ErrorCode.OFFER_NOT_PENDING,
          }),
        );
      }
    }
  });

  it('correctly identifies terminal states', () => {
    expect(isOfferTerminal('PENDING')).toBe(false);
    expect(isOfferTerminal('ACCEPTED')).toBe(true);
    expect(isOfferTerminal('REJECTED')).toBe(true);
    expect(isOfferTerminal('EXPIRED')).toBe(true);
    expect(isOfferTerminal('WITHDRAWN')).toBe(true);
    expect(isOfferTerminal('WITHDRAWN_BY_SYSTEM')).toBe(true);
  });
});
