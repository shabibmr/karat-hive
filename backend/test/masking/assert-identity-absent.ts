import { expect } from 'vitest';
import { findCompetitorLeak, findIdentityKey } from '../../src/edge/masking/identity-keys';

/**
 * Masked identity fields must be omitted from JSON (NFR-013 / BR-006).
 * A present key with `null` or `""` is a leak — the interceptor treats the key name as the hit.
 */
export function assertIdentityKeysAbsent(value: unknown, label = 'payload'): void {
  const hit = findIdentityKey(value);
  expect(hit, `${label} must not contain identity key ${hit ?? ''}`).toBeNull();
}

/**
 * Competitor Blindness (BR-008).
 * Asserts that competitor prices, competitor terms, and competitor vendor identities are ABSENT.
 * Only aggregate offer counts (e.g. offerCount, offersReceivedCount) or the vendor's own offer (myOffer) are permitted.
 */
export function assertCompetitorBlindness(value: unknown, label = 'vendor payload'): void {
  const hit = findCompetitorLeak(value);
  expect(hit, `${label} must not contain competitor leak "${hit ?? ''}" (BR-008)`).toBeNull();
}

/**
 * Combined verification for vendor-presented payloads (RequestForVendor, /v1/matches, /v1/me/dashboard).
 * Asserts both Customer Identity Masking (BR-006 / NFR-013) and Competitor Blindness (BR-008).
 */
export function assertVendorPresenterMasking(value: unknown, label = 'RequestForVendor'): void {
  assertIdentityKeysAbsent(value, label);
  assertCompetitorBlindness(value, label);
}
