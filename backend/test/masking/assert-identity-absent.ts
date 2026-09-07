import { expect } from 'vitest';
import { findIdentityKey } from '../../src/edge/masking/identity-keys';

/**
 * Masked identity fields must be omitted from JSON (NFR-013 / BR-006).
 * A present key with `null` or `""` is a leak — the interceptor treats the key name as the hit.
 */
export function assertIdentityKeysAbsent(value: unknown, label = 'payload'): void {
  const hit = findIdentityKey(value);
  expect(hit, `${label} must not contain identity key ${hit ?? ''}`).toBeNull();
}
