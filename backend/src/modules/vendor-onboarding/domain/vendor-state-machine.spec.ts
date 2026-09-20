import { describe, expect, it } from 'vitest';
import { canApplyDecision, canTransition, targetForDecision } from './vendor-state-machine';

describe('vendor-state-machine (VO-06 / BR-004)', () => {
  it('allows VERIFIED → PENDING_VERIFICATION for re-verify', () => {
    expect(canTransition('VERIFIED', 'PENDING_VERIFICATION')).toBe(true);
  });

  it('still allows VERIFIED → REJECTED', () => {
    expect(canTransition('VERIFIED', 'REJECTED')).toBe(true);
  });

  it('rejects same-state transitions', () => {
    expect(canTransition('PENDING_VERIFICATION', 'PENDING_VERIFICATION')).toBe(false);
  });

  it('maps VERIFY / REJECT / REQUEST_INFO targets', () => {
    expect(targetForDecision('VERIFY')).toBe('VERIFIED');
    expect(targetForDecision('REJECT')).toBe('REJECTED');
    expect(targetForDecision('REQUEST_INFO')).toBe('PENDING_VERIFICATION');
  });

  it('allows REQUEST_INFO only from PENDING_VERIFICATION', () => {
    expect(canApplyDecision('PENDING_VERIFICATION', 'REQUEST_INFO')).toBe(true);
    expect(canApplyDecision('VERIFIED', 'REQUEST_INFO')).toBe(false);
  });
});
