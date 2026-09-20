import { HttpStatus } from '@nestjs/common';
import { z } from 'zod';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { scanForContactDetails } from '../../requests/domain/contact-scanner';

export const submitOfferSchema = z.object({
  offeredPrice: z.union([z.number().positive(), z.string().regex(/^\d+(\.\d{1,2})?$/)]),
  weightGrams: z.union([z.number().positive(), z.string().regex(/^\d+(\.\d{1,2})?$/)]),
  purityKarat: z.enum(['18K', '21K', '22K', '24K']),
  makingCharges: z.union([z.number().nonnegative(), z.string().regex(/^\d+(\.\d{1,2})?$/)]).optional(),
  ratePerGram: z.union([z.number().positive(), z.string().regex(/^\d+(\.\d{1,2})?$/)]).optional(),
  deliveryTimeframe: z.string().max(100).optional(),
  warrantyTerms: z.string().max(1000).optional(),
  vendorNote: z.string().max(2000).optional(),
  mediaKeys: z.array(z.string().min(1)).max(3).optional(),
});

export type SubmitOfferInput = z.infer<typeof submitOfferSchema>;

export const reviseOfferSchema = z.object({
  offeredPrice: z.union([z.number().positive(), z.string().regex(/^\d+(\.\d{1,2})?$/)]),
  weightGrams: z.union([z.number().positive(), z.string().regex(/^\d+(\.\d{1,2})?$/)]),
  purityKarat: z.enum(['18K', '21K', '22K', '24K']),
  makingCharges: z.union([z.number().nonnegative(), z.string().regex(/^\d+(\.\d{1,2})?$/)]).optional(),
  ratePerGram: z.union([z.number().positive(), z.string().regex(/^\d+(\.\d{1,2})?$/)]).optional(),
  deliveryTimeframe: z.string().max(100).optional(),
  warrantyTerms: z.string().max(1000).optional(),
  vendorNote: z.string().max(2000).optional(),
});

export type ReviseOfferInput = z.infer<typeof reviseOfferSchema>;

export const declineOfferSchema = z.object({
  reason: z.enum(['PRICE_TOO_HIGH', 'TERMS_UNSUITABLE', 'NO_LONGER_REQUIRED', 'OTHER']).optional(),
  note: z.string().max(500).optional(),
});

export type DeclineOfferInput = z.infer<typeof declineOfferSchema>;

export const acceptOfferSchema = z.object({
  confirmation: z.literal('REVEAL_AND_CONNECT'),
});

export type AcceptOfferInput = z.infer<typeof acceptOfferSchema>;

/**
 * Validates vendor note for prohibited contact details (BR-022).
 */
export function assertNoContactDetails(vendorNote?: string | null): void {
  if (!vendorNote) return;
  const result = scanForContactDetails(vendorNote);
  if (result.hasContactInfo) {
    throw new ApiException(
      HttpStatus.UNPROCESSABLE_ENTITY,
      ErrorCode.CONTACT_DETAILS_IN_TEXT,
    );
  }
}

/**
 * Calculates offer expiry timestamp: strictly aligned to parent request's expiry.
 */
export function calculateClampedExpiry(
  requestExpiresAt: Date,
): Date {
  return requestExpiresAt;
}
