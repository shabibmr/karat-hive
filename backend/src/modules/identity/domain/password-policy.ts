/** NFR-012 structural checks for Vendor/Admin passwords. */

const MIN_LENGTH = 12;

/** Common passwords that pass length/class checks but are known-breached. */
const BREACHED = new Set(
  [
    'Password123!',
    'Password1234',
    'Qwerty123456',
    'Welcome1234!',
    'Admin123456!',
    'ChangeMe123!',
    'Passw0rd1234',
    'P@ssw0rd1234',
  ].map((p) => p.toLowerCase()),
);

export type PasswordPolicyFailure =
  | 'TOO_SHORT'
  | 'MISSING_LOWER'
  | 'MISSING_UPPER'
  | 'MISSING_DIGIT'
  | 'BREACHED';

/** Returns null when the password meets NFR-012; otherwise a failure reason. */
export function passwordPolicyFailure(plain: string): PasswordPolicyFailure | null {
  if (plain.length < MIN_LENGTH) return 'TOO_SHORT';
  if (!/[a-z]/.test(plain)) return 'MISSING_LOWER';
  if (!/[A-Z]/.test(plain)) return 'MISSING_UPPER';
  if (!/\d/.test(plain)) return 'MISSING_DIGIT';
  if (BREACHED.has(plain.toLowerCase())) return 'BREACHED';
  return null;
}

export function meetsPasswordPolicy(plain: string): boolean {
  return passwordPolicyFailure(plain) === null;
}
