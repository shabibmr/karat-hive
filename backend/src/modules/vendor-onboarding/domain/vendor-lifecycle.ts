import type { UserAccountState, VendorVerificationState } from '@prisma/client';

/** Composed marketplace state returned as `vendorLifecycle` on Vendor-facing Me (AD-API §5). */
export type VendorAccountState =
  | 'REGISTERED'
  | 'PENDING_VERIFICATION'
  | 'VERIFIED'
  | 'ACTIVE'
  | 'SUSPENDED'
  | 'REJECTED'
  | 'DEACTIVATED';

export type AwaitingApprovalReason =
  'PENDING_DOCUMENTS' | 'PENDING_ADMIN' | 'ACTIVATION_PENDING' | 'REJECTED';

export type VendorLifecycleInput = {
  accountState: UserAccountState;
  verificationState: VendorVerificationState;
  activatedAt: Date | null;
  hasMandatoryDocuments: boolean;
};

export function composeVendorLifecycle(input: VendorLifecycleInput): VendorAccountState {
  if (input.accountState === 'SUSPENDED') return 'SUSPENDED';
  if (input.accountState === 'DEACTIVATED') return 'DEACTIVATED';
  if (input.verificationState === 'REJECTED') return 'REJECTED';
  if (input.verificationState === 'VERIFIED') {
    return input.activatedAt !== null ? 'ACTIVE' : 'VERIFIED';
  }
  return input.verificationState; // REGISTERED | PENDING_VERIFICATION
}

export function isMarketplaceActive(input: VendorLifecycleInput): boolean {
  return composeVendorLifecycle(input) === 'ACTIVE';
}

export function awaitingApprovalReason(
  input: VendorLifecycleInput,
): AwaitingApprovalReason | undefined {
  const lifecycle = composeVendorLifecycle(input);
  switch (lifecycle) {
    case 'ACTIVE':
      return undefined;
    case 'REJECTED':
      return 'REJECTED';
    case 'VERIFIED':
      // Defensive/transient only: activation is unconditional on verification
      // (see VendorVerificationService), so this composed state should not persist.
      return 'ACTIVATION_PENDING';
    case 'PENDING_VERIFICATION':
      return input.hasMandatoryDocuments ? 'PENDING_ADMIN' : 'PENDING_DOCUMENTS';
    default:
      return 'PENDING_DOCUMENTS';
  }
}

/** Vendor marketplace access now gates on VERIFIED + a Type Subscription (BR-002), not taxonomy declarations. */
export function shouldActivate(input: {
  verificationState: VendorVerificationState;
  activatedAt: Date | null;
}): boolean {
  return input.verificationState === 'VERIFIED' && input.activatedAt === null;
}
