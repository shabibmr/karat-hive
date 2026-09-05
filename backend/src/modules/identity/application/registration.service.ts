import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { resolveLanguage } from '../../../edge/errors/error-messages';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { TaxonomyQuery } from '../../taxonomy';
import { VendorOnboardingService } from '../../vendor-onboarding';
import { OtpService } from './otp.service';
import { SessionService } from './session.service';
import { UserRepository } from '../repository/user.repository';
import type { SessionBundle } from '../presenter/session.presenter';

export type RegisterVendorInput = {
  challengeId: string;
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
  ) {}

  async registerVendor(
    input: RegisterVendorInput,
    client: { ip?: string | null; userAgent?: string | null; acceptLanguage?: string },
  ): Promise<SessionBundle> {
    const challenge = await this.otp.requireVerified(input.challengeId, 'REGISTER_VENDOR');
    const mobileNumber = challenge.mobileNumber;

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
        mobileNumber,
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
      return created;
    });

    return this.session.issueFor(user, client);
  }
}
