import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { resolveLanguage } from '../../../edge/errors/error-messages';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { AuditWriter } from '../../audit';
import { TaxonomyQuery } from '../../taxonomy';
import { VendorOnboardingService } from '../../vendor-onboarding';
import { FirebaseTokenService } from './firebase-token.service';
import { OtpService } from './otp.service';
import { SessionService } from './session.service';
import { hashToken } from './token.service';
import { UserRepository } from '../repository/user.repository';
import type { SessionBundle } from '../presenter/session.presenter';

export type RegisterCustomerInput = {
  challengeId?: string;
  firebaseToken?: string;
  displayName: string;
  email?: string;
  preferredLanguage?: 'en' | 'ar';
  defaultRegionId?: string;
  termsVersion: string;
  privacyVersion: string;
};

export type RegisterVendorInput = {
  challengeId?: string;
  firebaseToken?: string;
  legalBusinessName: string;
  tradingName: string;
  tradeLicenceNumber: string;
  licenceExpiryDate: string;
  businessAddress: string;
  contactPersonName: string;
  businessEmail: string;
  regionId: string;
  categoryIds: string[];
  servedRegionIds: string[];
  termsVersion: string;
  privacyVersion: string;
};

@Injectable()
export class RegistrationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
    private readonly otp: OtpService,
    private readonly session: SessionService,
    private readonly users: UserRepository,
    private readonly taxonomy: TaxonomyQuery,
    private readonly vendors: VendorOnboardingService,
    private readonly audit: AuditWriter,
    private readonly firebaseTokens?: FirebaseTokenService,
  ) {}

  async registerVendor(
    input: RegisterVendorInput,
    client: { ip?: string | null; userAgent?: string | null; acceptLanguage?: string },
  ): Promise<SessionBundle> {
    let mobileNumber: string | null = null;
    let firebaseUid: string | null = null;

    if (input.challengeId) {
      const challenge = await this.otp.requireVerified(input.challengeId, 'REGISTER_VENDOR');
      mobileNumber = challenge.mobileNumber;
    }

    if (input.firebaseToken) {
      if (!this.firebaseTokens) {
        throw new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.UNAUTHENTICATED);
      }
      const claims = await this.firebaseTokens.verify(input.firebaseToken);
      firebaseUid = claims.uid;
      if (!mobileNumber && claims.phoneNumber) {
        const phoneRegex = /^\+[1-9]\d{6,14}$/;
        if (!phoneRegex.test(claims.phoneNumber)) {
          throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
            {
              path: 'mobileNumber',
              code: 'INVALID',
              message: 'Google phone must be E.164.',
            },
          ]);
        }
        mobileNumber = claims.phoneNumber;
      }
    }

    if (!mobileNumber) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        { path: 'mobileNumber', code: 'REQUIRED', message: 'Verified mobile number is required.' },
      ]);
    }

    if (await this.users.findByMobile(mobileNumber)) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.MOBILE_ALREADY_REGISTERED);
    }
    if (await this.users.findByEmail(input.businessEmail)) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.EMAIL_ALREADY_REGISTERED);
    }
    if (await this.vendors.licenceExists(input.tradeLicenceNumber)) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.LICENCE_ALREADY_REGISTERED);
    }

    await this.taxonomy.assertActive({
      categoryIds: input.categoryIds,
      regionIds: [input.regionId, ...input.servedRegionIds],
    });

    const now = this.clock.now();
    const language = resolveLanguage(client.acceptLanguage);

    const user = await withTx(this.prisma, async (tx) => {
      const created = await this.users.createVendorUser(tx, {
        mobileNumber: mobileNumber!,
        email: input.businessEmail,
        preferredLanguage: language,
        mobileVerifiedAt: now,
        termsVersion: input.termsVersion,
        privacyVersion: input.privacyVersion,
        termsAcceptedAt: now,
      });
      await this.vendors.createProfile(tx, {
        userId: created.id,
        legalBusinessName: input.legalBusinessName,
        tradingName: input.tradingName,
        tradeLicenceNumber: input.tradeLicenceNumber,
        licenceExpiryDate: new Date(`${input.licenceExpiryDate}T00:00:00Z`),
        businessAddress: input.businessAddress,
        contactPersonName: input.contactPersonName,
        businessEmail: input.businessEmail,
        categoryIds: input.categoryIds,
        servedRegionIds: input.servedRegionIds,
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });

      if (firebaseUid) {
        await tx.oauthBinding.create({
          data: {
            userId: created.id,
            provider: 'GOOGLE',
            subjectHash: hashToken(firebaseUid),
            boundAt: now,
          },
        });
      }

      return created;
    });

    return this.session.issueFor(user, client);
  }

  async registerCustomer(
    input: RegisterCustomerInput,
    client: { ip?: string | null; userAgent?: string | null; acceptLanguage?: string },
  ): Promise<SessionBundle> {
    let mobileNumber: string | null = null;
    let mobileVerifiedAt: Date | null = null;
    let email: string | null = input.email ?? null;
    let emailVerifiedAt: Date | null = null;
    let firebaseUid: string | null = null;

    if (input.challengeId) {
      const challenge = await this.otp.requireVerified(input.challengeId, 'REGISTER_CUSTOMER');
      mobileNumber = challenge.mobileNumber;
      mobileVerifiedAt = this.clock.now();
    }

    if (input.firebaseToken) {
      if (!this.firebaseTokens) {
        throw new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.UNAUTHENTICATED);
      }
      const claims = await this.firebaseTokens.verify(input.firebaseToken);
      firebaseUid = claims.uid;
      if (!email && claims.email) {
        email = claims.email;
        emailVerifiedAt = claims.emailVerified ? this.clock.now() : null;
      }
      if (!mobileNumber && claims.phoneNumber) {
        mobileNumber = claims.phoneNumber;
        mobileVerifiedAt = this.clock.now();
      }
    }

    if (!mobileNumber) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        { path: 'mobileNumber', code: 'REQUIRED', message: 'Verified mobile number is required.' },
      ]);
    }

    if (await this.users.findByMobile(mobileNumber)) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.MOBILE_ALREADY_REGISTERED);
    }
    if (email && (await this.users.findByEmail(email))) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.EMAIL_ALREADY_REGISTERED);
    }

    if (input.defaultRegionId) {
      await this.taxonomy.assertActive({ regionIds: [input.defaultRegionId] });
    }

    const now = this.clock.now();
    const language = input.preferredLanguage ?? resolveLanguage(client.acceptLanguage);

    const user = await withTx(this.prisma, async (tx) => {
      const created = await this.users.createCustomerUser(tx, {
        mobileNumber: mobileNumber!,
        email,
        preferredLanguage: language,
        mobileVerifiedAt,
        emailVerifiedAt,
        termsVersion: input.termsVersion,
        privacyVersion: input.privacyVersion,
        termsAcceptedAt: now,
      });

      await this.users.createCustomerProfile(tx, {
        userId: created.id,
        displayName: input.displayName,
        defaultRegionId: input.defaultRegionId,
      });

      if (firebaseUid) {
        await tx.oauthBinding.create({
          data: {
            userId: created.id,
            provider: 'GOOGLE',
            subjectHash: hashToken(firebaseUid),
            boundAt: now,
          },
        });
      }

      await this.audit.append(tx, {
        actorUserId: created.id,
        action: 'CUSTOMER_REGISTERED',
        entityType: 'user',
        entityId: created.id,
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });

      return created;
    });

    return this.session.issueFor(user, client);
  }
}
