import { Body, Controller, Delete, Get, HttpCode, HttpStatus, Param, Post, Req } from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import { z } from 'zod';
import { Public } from '../../../edge/auth/public.decorator';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { OAuthAccountService } from '../application/oauth-account.service';
import { OtpService } from '../application/otp.service';
import { RegistrationService } from '../application/registration.service';
import { SessionService, type SessionFamilyView } from '../application/session.service';
import { clientInfoOf } from './client-info';
import type { SessionBundle } from '../presenter/session.presenter';

const otpRequestSchema = z.object({
  mobileNumber: z
    .string()
    .regex(/^\+[1-9]\d{6,14}$/, 'Enter a valid mobile number in E.164 format.'),
  // LOGIN removed (adr/0010 / G2-A15). OTP proves a number only.
  purpose: z.enum(['REGISTER_CUSTOMER', 'REGISTER_VENDOR', 'CHANGE_MOBILE']),
});

const otpVerifySchema = z.object({
  challengeId: z.string().uuid(),
  code: z.string().regex(/^\d{4,8}$/),
});

const registerCustomerSchema = z
  .object({
    challengeId: z.string().uuid().optional(),
    firebaseToken: z.string().min(1).optional(),
    displayName: z.string().min(1).max(100),
    email: z.string().email().max(255).optional(),
    preferredLanguage: z.enum(['en', 'ar']).optional(),
    defaultRegionId: z.string().uuid().optional(),
    termsVersion: z.string().min(1).max(32),
    privacyVersion: z.string().min(1).max(32),
  })
  .refine((v) => v.challengeId !== undefined || v.firebaseToken !== undefined, {
    message: 'Either challengeId or firebaseToken is required.',
  });

const registerVendorSchema = z
  .object({
    challengeId: z.string().uuid().optional(),
    firebaseToken: z.string().min(1).optional(),
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
  })
  .refine((v) => v.challengeId !== undefined || v.firebaseToken !== undefined, {
    message: 'Either challengeId or firebaseToken is required.',
  });

const refreshSchema = z.object({ refreshToken: z.string().min(1) });
const logoutSchema = z.object({
  refreshToken: z.string().min(1).optional(),
  allDevices: z.boolean().optional(),
});

const firebaseSessionSchema = z
  .object({
    idToken: z.string().min(1).optional(),
    token: z.string().min(1).optional(),
    firebaseToken: z.string().min(1).optional(),
  })
  .refine((v) => Boolean(v.idToken || v.token || v.firebaseToken), {
    message: 'idToken, token, or firebaseToken is required.',
  });

@Controller('v1/auth')
export class AuthController {
  constructor(
    private readonly otp: OtpService,
    private readonly registration: RegistrationService,
    private readonly session: SessionService,
    private readonly oauthAccount: OAuthAccountService,
  ) {}

  @Public()
  @RevealsIdentity()
  @Post('firebase/session')
  @HttpCode(200)
  createFirebaseSession(
    @Req() request: FastifyRequest,
    @Body(zodBody(firebaseSessionSchema)) body: z.infer<typeof firebaseSessionSchema>,
  ): Promise<SessionBundle> {
    const token = (body.idToken || body.token || body.firebaseToken)!;
    return this.oauthAccount.createSessionFromFirebase(token, clientInfoOf(request));
  }

  @Public()
  @RevealsIdentity()
  @Post('google/session')
  @HttpCode(200)
  createGoogleSession(
    @Req() request: FastifyRequest,
    @Body(zodBody(firebaseSessionSchema)) body: z.infer<typeof firebaseSessionSchema>,
  ): Promise<SessionBundle> {
    const token = (body.idToken || body.token || body.firebaseToken)!;
    return this.oauthAccount.createSessionFromFirebase(token, clientInfoOf(request));
  }

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
    @Body(zodBody(otpVerifySchema)) body: z.infer<typeof otpVerifySchema>,
  ): Promise<{ challengeId: string; mobileVerified: true }> {
    const challenge = await this.otp.verifyChallenge(body.challengeId, body.code);
    return { challengeId: challenge.id, mobileVerified: true };
  }

  @Public()
  @RevealsIdentity()
  @Post('register/customer')
  @HttpCode(201)
  registerCustomer(
    @Req() request: FastifyRequest,
    @Body(zodBody(registerCustomerSchema)) body: z.infer<typeof registerCustomerSchema>,
  ): Promise<SessionBundle> {
    return this.registration.registerCustomer(body, clientInfoOf(request));
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
  @Post('register/admin')
  @HttpCode(404)
  registerAdmin(): never {
    throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.ADMIN_SELF_REGISTRATION_FORBIDDEN);
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

  @Get('sessions')
  @RevealsIdentity()
  listSessions(@Viewer() viewer: ViewerContext): Promise<SessionFamilyView[]> {
    return this.session.listSessions(viewer.userId);
  }

  @Delete('sessions/:id')
  @HttpCode(204)
  async revokeSession(
    @Viewer() viewer: ViewerContext,
    @Param('id') familyId: string,
  ): Promise<void> {
    if (!z.string().uuid().safeParse(familyId).success) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    await this.session.revokeSession(viewer.userId, familyId);
  }
}
