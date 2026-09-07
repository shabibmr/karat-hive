import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import type { OtpChallenge, OtpPurpose } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { ENV, type Env } from '../../../config/env';
import { Clock } from '../../../shared/clock';
import { OTP_SENDER, type OtpSender } from '../../../platform/ports/otp-sender.port';
import {
  generateOtpCode,
  hashOtpCode,
  isOtpExpired,
  otpCodeMatches,
  OTP_MAX_ATTEMPTS,
} from '../domain/otp-challenge';
import { OtpRepository } from '../repository/otp.repository';
import { UserRepository } from '../repository/user.repository';

export type IssueResult = { challengeId: string; expiresAt: Date; retryAfterSeconds: number };

@Injectable()
export class OtpService {
  constructor(
    @Inject(ENV) private readonly env: Env,
    @Inject(OTP_SENDER) private readonly sender: OtpSender,
    private readonly clock: Clock,
    private readonly repo: OtpRepository,
    private readonly users: UserRepository,
  ) {}

  async issueChallenge(mobileNumber: string, purpose: OtpPurpose): Promise<IssueResult> {
    const now = this.clock.now();
    const windowStart = new Date(now.getTime() - 60 * 60 * 1000);
    const recent = await this.repo.countSince(mobileNumber, purpose, windowStart);
    if (recent >= this.env.OTP_MAX_PER_NUMBER_PER_HOUR) {
      throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, ErrorCode.OTP_RATE_LIMITED);
    }

    const existingUser = await this.users.findByMobile(mobileNumber);
    if (purpose === 'REGISTER_VENDOR' || purpose === 'REGISTER_CUSTOMER') {
      if (existingUser) {
        throw new ApiException(HttpStatus.CONFLICT, ErrorCode.MOBILE_ALREADY_REGISTERED);
      }
    }

    const code = this.env.OTP_DEV_MODE === 'fixed' ? this.env.OTP_FIXED_CODE : generateOtpCode();
    const expiresAt = new Date(now.getTime() + this.env.OTP_TTL_SECONDS * 1000);
    const challenge = await this.repo.create({
      mobileNumber,
      purpose,
      codeHash: hashOtpCode(code),
      expiresAt,
      userId: existingUser?.id ?? null,
    });

    await this.sender.send({ mobileNumber, code, purpose });

    return { challengeId: challenge.id, expiresAt, retryAfterSeconds: 60 };
  }

  async verifyChallenge(challengeId: string, code: string): Promise<OtpChallenge> {
    const now = this.clock.now();
    const challenge = await this.repo.findById(challengeId);
    if (!challenge) throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.OTP_INVALID);
    if (challenge.consumedAt)
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.OTP_EXPIRED);
    if (isOtpExpired(challenge.expiresAt, now)) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.OTP_EXPIRED);
    }
    if (challenge.attempts >= OTP_MAX_ATTEMPTS) {
      throw new ApiException(HttpStatus.LOCKED, ErrorCode.ACCOUNT_LOCKED);
    }
    if (!otpCodeMatches(code, challenge.codeHash)) {
      await this.repo.incrementAttempts(challenge.id);
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.OTP_INVALID);
    }
    await this.repo.consume(challenge.id, now);
    return challenge;
  }

  /** For register/vendor: assert an OTP was verified for this number + purpose. */
  async requireVerified(challengeId: string, purpose: OtpPurpose): Promise<OtpChallenge> {
    const challenge = await this.repo.findById(challengeId);
    if (!challenge || challenge.purpose !== purpose || !challenge.consumedAt) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        { path: 'challengeId', code: 'NOT_VERIFIED', message: 'Verify your mobile number first.' },
      ]);
    }
    return challenge;
  }
}
