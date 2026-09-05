import { Inject, Injectable, Logger } from '@nestjs/common';
import type { OtpPurpose } from '@prisma/client';
import { ENV, type Env } from '../../../config/env';
import type { OtpSender } from '../../ports/otp-sender.port';

/**
 * Dev OTP delivery. `console` mode logs the code; `fixed` mode is a no-op because
 * the code is always `OTP_FIXED_CODE`. A real SMS provider slots in behind OtpSender.
 */
@Injectable()
export class ConsoleOtpSender implements OtpSender {
  private readonly logger = new Logger('OtpSender');

  constructor(@Inject(ENV) private readonly env: Env) {}

  async send(input: { mobileNumber: string; code: string; purpose: OtpPurpose }): Promise<void> {
    if (this.env.OTP_DEV_MODE === 'fixed') {
      this.logger.warn(
        `[OTP] ${input.mobileNumber} -> fixed code ${this.env.OTP_FIXED_CODE} (${input.purpose})`,
      );
      return;
    }
    this.logger.log(`[OTP] ${input.mobileNumber} -> ${input.code} (${input.purpose})`);
  }
}
