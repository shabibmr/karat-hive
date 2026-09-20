import { describe, expect, it } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import { ErrorCode } from '../../../edge/errors/error-codes';
import {
  assertNoContactDetails,
  calculateClampedExpiry,
  submitOfferSchema,
} from './offer-validator';

describe('offer-validator', () => {
  it('validates a valid submit offer input with mandatory weight and purity', () => {
    const input = {
      offeredPrice: 1500,
      weightGrams: 10.5,
      purityKarat: '22K',
      vendorNote: 'Authentic 22K gold piece',
    };
    const parsed = submitOfferSchema.parse(input);
    expect(parsed.offeredPrice).toBe(1500);
    expect(parsed.weightGrams).toBe(10.5);
    expect(parsed.purityKarat).toBe('22K');
  });

  it('rejects input when mandatory weight or purity is missing', () => {
    const inputMissingWeight = {
      offeredPrice: 1500,
      purityKarat: '22K',
    };
    expect(() => submitOfferSchema.parse(inputMissingWeight)).toThrow();

    const inputMissingPurity = {
      offeredPrice: 1500,
      weightGrams: 10.5,
    };
    expect(() => submitOfferSchema.parse(inputMissingPurity)).toThrow();
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

  it('sets offer expiry directly to parent request expiry', () => {
    const requestExpiresAt = new Date('2026-09-07T22:00:00Z');
    const clamped = calculateClampedExpiry(requestExpiresAt);
    expect(clamped.toISOString()).toBe(requestExpiresAt.toISOString());
  });
});
