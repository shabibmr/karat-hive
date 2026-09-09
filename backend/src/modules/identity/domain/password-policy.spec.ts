import { describe, expect, it } from 'vitest';
import { meetsPasswordPolicy, passwordPolicyFailure } from './password-policy';

describe('passwordPolicy (NFR-012)', () => {
  it('accepts a long mixed-class password', () => {
    expect(meetsPasswordPolicy('Str0ngEnough!x')).toBe(true);
    expect(passwordPolicyFailure('Str0ngEnough!x')).toBeNull();
  });

  it('rejects short passwords', () => {
    expect(passwordPolicyFailure('Ab1!short')).toBe('TOO_SHORT');
  });

  it('requires lower, upper, and digit', () => {
    expect(passwordPolicyFailure('ALLUPPERCASE1!')).toBe('MISSING_LOWER');
    expect(passwordPolicyFailure('alllowercase1!')).toBe('MISSING_UPPER');
    expect(passwordPolicyFailure('NoDigitsHere!!')).toBe('MISSING_DIGIT');
  });

  it('rejects known-breached candidates that otherwise pass structure', () => {
    expect(passwordPolicyFailure('Password123!')).toBe('BREACHED');
  });
});
