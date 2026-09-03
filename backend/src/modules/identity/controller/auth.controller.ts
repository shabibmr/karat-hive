import { Body, Controller, HttpCode, Post, Req } from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import { z } from 'zod';
import { Public } from '../../../edge/auth/public.decorator';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { LoginService } from '../application/login.service';
import { OtpService } from '../application/otp.service';
import { RegistrationService } from '../application/registration.service';
import { SessionService } from '../application/session.service';
import { clientInfoOf } from './client-info';
import type { SessionBundle } from '../presenter/session.presenter';

const otpRequestSchema = z.object({
  mobileNumber: z
    .string()
    .regex(/^\+[1-9]\d{6,14}$/, 'Enter a valid mobile number in E.164 format.'),
  purpose: z.enum(['REGISTER_VENDOR', 'LOGIN', 'CHANGE_MOBILE']),
});

const otpVerifySchema = z.object({
  challengeId: z.string().uuid(),
  code: z.string().regex(/^\d{4,8}$/),
});

const registerVendorSchema = z.object({
  challengeId: z.string().uuid(),
  legalBusinessName: z.string().min(1).max(200),
  tradingName: z.string().min(1).max(200),
  tradeLicenceNumber: z.string().min(1).max(50),
  licenceExpiryDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  businessAddress: z.string().min(1).max(500),
  contactPersonName: z.string().min(1).max(100),
  businessEmail: z.string().email().max(255),
  regionId: z.string().uuid(),
  categoryIds: z.array(z.string().uuid()).min(1),
  servedRegionIds: z.array(z.string().uuid()).min(1),
  termsVersion: z.string().min(1).max(32),
  privacyVersion: z.string().min(1).max(32),
});

const loginPasswordSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1).max(200),
});

const refreshSchema = z.object({ refreshToken: z.string().min(1) });
const logoutSchema = z.object({
  refreshToken: z.string().min(1).optional(),
  allDevices: z.boolean().optional(),
});

@Controller('v1/auth')
export class AuthController {
  constructor(
    private readonly otp: OtpService,
    private readonly registration: RegistrationService,
    private readonly login: LoginService,
    private readonly session: SessionService,
  ) {}

  @Public()
  @Post('otp/request')
  @HttpCode(201)
  async otpRequest(
    @Body(zodBody(otpRequestSchema)) body: z.infer<typeof otpRequestSchema>,
  ): Promise<{ challengeId: string; expiresAt: string; retryAfterSeconds: number }> {
    const r = await this.otp.issueChallenge(body.mobileNumber, body.purpose);
    return {
      challengeId: r.challengeId,
      expiresAt: r.expiresAt.toISOString(),
      retryAfterSeconds: r.retryAfterSeconds,
    };
  }

  @Public()
  @RevealsIdentity()
  @Post('otp/verify')
  @HttpCode(200)
  async otpVerify(
    @Req() request: FastifyRequest,
    @Body(zodBody(otpVerifySchema)) body: z.infer<typeof otpVerifySchema>,
  ): Promise<SessionBundle | { challengeId: string; mobileVerified: true }> {
    const challenge = await this.otp.verifyChallenge(body.challengeId, body.code);
    if (challenge.purpose === 'LOGIN') {
      return this.login.loginWithVerifiedOtp(challenge, clientInfoOf(request));
    }
    return { challengeId: challenge.id, mobileVerified: true };
  }

  @Public()
  @RevealsIdentity()
  @Post('register/vendor')
  @HttpCode(201)
  registerVendor(
    @Req() request: FastifyRequest,
    @Body(zodBody(registerVendorSchema)) body: z.infer<typeof registerVendorSchema>,
  ): Promise<SessionBundle> {
    return this.registration.registerVendor(body, clientInfoOf(request));
  }

  @Public()
  @RevealsIdentity()
  @Post('login/password')
  @HttpCode(200)
  loginPassword(
    @Req() request: FastifyRequest,
    @Body(zodBody(loginPasswordSchema)) body: z.infer<typeof loginPasswordSchema>,
  ): Promise<SessionBundle> {
    return this.login.loginWithPassword(body.email, body.password, clientInfoOf(request));
  }

  @Public()
  @RevealsIdentity()
  @Post('refresh')
  @HttpCode(200)
  refresh(
    @Req() request: FastifyRequest,
    @Body(zodBody(refreshSchema)) body: z.infer<typeof refreshSchema>,
  ): Promise<SessionBundle> {
    return this.session.refresh(body.refreshToken, clientInfoOf(request));
  }

  @Public()
  @Post('logout')
  @HttpCode(204)
  async logout(@Body(zodBody(logoutSchema)) body: z.infer<typeof logoutSchema>): Promise<void> {
    await this.session.logout(body.refreshToken, body.allDevices ?? false);
  }
}
