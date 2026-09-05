import type { VendorVerificationState } from '@prisma/client';

export type VerificationDecision = 'VERIFY' | 'REJECT' | 'REQUEST_INFO';

/** Legal verification-state transitions (SRS §5.4). */
const TRANSITIONS: Record<VendorVerificationState, VendorVerificationState[]> = {
  REGISTERED: ['PENDING_VERIFICATION'],
  PENDING_VERIFICATION: ['VERIFIED', 'REJECTED', 'PENDING_VERIFICATION'],
  VERIFIED: ['REJECTED'],
  REJECTED: ['PENDING_VERIFICATION'],
};

export function canTransition(from: VendorVerificationState, to: VendorVerificationState): boolean {
  return from === to ? false : (TRANSITIONS[from] ?? []).includes(to);
}

export function targetForDecision(decision: VerificationDecision): VendorVerificationState {
  switch (decision) {
    case 'VERIFY':
      return 'VERIFIED';
    case 'REJECT':
      return 'REJECTED';
    case 'REQUEST_INFO':
      return 'PENDING_VERIFICATION';
  }
}

/** REQUEST_INFO is legal only while already awaiting a decision. */
export function canApplyDecision(
  from: VendorVerificationState,
  decision: VerificationDecision,
): boolean {
  if (decision === 'REQUEST_INFO') return from === 'PENDING_VERIFICATION';
  return canTransition(from, targetForDecision(decision));
}

export const MANDATORY_DOCUMENT_TYPES = ['TRADE_LICENCE', 'EMIRATES_ID'] as const;
