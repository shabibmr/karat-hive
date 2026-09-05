import type { OtpPurpose } from '@prisma/client';

/** Delivery channel for one-time passcodes. Console/fixed stub in dev; SMS provider later. */
export interface OtpSender {
  send(input: { mobileNumber: string; code: string; purpose: OtpPurpose }): Promise<void>;
}

export const OTP_SENDER = Symbol('OTP_SENDER');
