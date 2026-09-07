import { describe, expect, it } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import { ErrorCode } from '../../../edge/errors/error-codes';
import {
  assertNoContactDetails,
  calculateClampedExpiry,
  submitOfferSchema,
} from './offer-validator';

describe('offer-validator', () => {
  it('validates a valid submit offer input', () => {
    const input = {
      offeredPrice: 1500,
      validityHours: 24,
      vendorNote: 'Authentic 22K gold piece',
    };
    const parsed = submitOfferSchema.parse(input);
    expect(parsed.offeredPrice).toBe(1500);
    expect(parsed.validityHours).toBe(24);
  });

  it('rejects invalid validity hours', () => {
    const input = {
      offeredPrice: 1500,
      validityHours: 72,
    };
    expect(() => submitOfferSchema.parse(input)).toThrow();
  });

  it('detects contact details in vendor note', () => {
    expect(() =>
      assertNoContactDetails('Call me at 0501234567 for quick deal'),
    ).toThrowError(
      expect.objectContaining({
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errorCode: ErrorCode.CONTACT_DETAILS_IN_TEXT,
      }),
    );
  });

  it('clamps offer expiry to parent request expiry', () => {
    const now = new Date('2026-09-07T12:00:00Z');
    // Request expires in 10 hours
    const requestExpiresAt = new Date('2026-09-07T22:00:00Z');

    // Vendor asks for 24h validity -> must be clamped to 10h (requestExpiresAt)
    const clamped = calculateClampedExpiry(now, 24, requestExpiresAt);
    expect(clamped.toISOString()).toBe(requestExpiresAt.toISOString());

    // Vendor asks for 12h validity on a request with 48h left -> 12h from now
    const farRequestExpiry = new Date('2026-09-09T12:00:00Z');
    const nominal = calculateClampedExpiry(now, 12, farRequestExpiry);
    expect(nominal.toISOString()).toBe(new Date('2026-09-08T00:00:00Z').toISOString());
  });
});
