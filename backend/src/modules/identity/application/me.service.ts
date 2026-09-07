import { HttpStatus, Injectable } from '@nestjs/common';
import type { PreferredLanguage, User } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { AuditWriter } from '../../audit';
import { VendorOnboardingService } from '../../vendor-onboarding';
import { presentMe, type DeletionRequestView, type Me } from '../presenter/me.presenter';
import {
  DELETION_AWAITING_CONFIRMATION,
  UserRepository,
} from '../repository/user.repository';
import { OtpService } from './otp.service';

const E164 = /^\+[1-9]\d{6,14}$/;
const DELETION_CONNECTION_WINDOW_MS = 30 * 24 * 60 * 60 * 1000;

@Injectable()
export class MeService {
  constructor(
    private readonly users: UserRepository,
    private readonly vendors: VendorOnboardingService,
    private readonly otp: OtpService,
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
    private readonly audit: AuditWriter,
  ) {}

  async forUser(user: User): Promise<Me> {
    const vendor =
      user.userType === 'VENDOR'
        ? await this.vendors.vendorMeForUser(user.id, user.accountState)
        : null;
    const admin = user.userType === 'ADMIN' ? await this.users.findAdminProfile(user.id) : null;
    const customer =
      user.userType === 'CUSTOMER' ? await this.users.findCustomerProfile(user.id) : null;

    let oauthBound: boolean | undefined = undefined;
    let liveRequestCount: number | undefined = undefined;
    let canCreateRequest: boolean | undefined = undefined;

    if (user.userType === 'CUSTOMER') {
      oauthBound = await this.users.hasOauthBinding(user.id);
      if (customer) {
        liveRequestCount = await this.users.countLiveRequestsForCustomer(customer.id);
        canCreateRequest = liveRequestCount < 3;
      }
    }

    const customerMe = customer
      ? {
          displayName: customer.displayName,
          photoUrl: customer.photoMedia ? `/v1/media/${customer.photoMedia.key}` : null,
          defaultRegion: customer.defaultRegion
            ? {
                id: customer.defaultRegion.id,
                nameEn: customer.defaultRegion.nameEn,
                nameAr: customer.defaultRegion.nameAr,
              }
            : null,
          rating: customer.aggregateRating
            ? {
                average: Number(customer.aggregateRating),
                count: customer.reviewCount,
              }
            : null,
          reviewCount: customer.reviewCount,
          connectionCount: customer.connectionCount,
          liveRequestCount,
          canCreateRequest,
        }
      : null;

    return presentMe(
      user,
      vendor,
      admin ? { displayName: admin.displayName } : null,
      customerMe,
      oauthBound,
    );
  }

  async get(viewer: ViewerContext): Promise<Me> {
    const user = await this.users.findById(viewer.userId);
    if (!user) throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    return this.forUser(user);
  }

  async patch(
    viewer: ViewerContext,
    dto: {
      preferredLanguage?: PreferredLanguage;
      displayName?: string;
      defaultRegionId?: string | null;
    },
  ): Promise<Me> {
    if (dto.preferredLanguage) {
      await this.users.setPreferredLanguage(viewer.userId, dto.preferredLanguage);
    }
    if (viewer.role === 'CUSTOMER' && (dto.displayName || dto.defaultRegionId !== undefined)) {
      await this.users.updateCustomerProfile(viewer.userId, {
        displayName: dto.displayName,
        defaultRegionId: dto.defaultRegionId,
      });
    }
    return this.get(viewer);
  }

  /** G2-I07: apply a verified CHANGE_MOBILE OTP to the caller's number. */
  async changeMobile(viewer: ViewerContext, challengeId: string): Promise<Me> {
    if (viewer.role !== 'CUSTOMER' && viewer.role !== 'VENDOR') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    const challenge = await this.otp.requireVerified(challengeId, 'CHANGE_MOBILE');
    const newNumber = challenge.mobileNumber;
    if (!E164.test(newNumber)) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        { path: 'mobileNumber', code: 'INVALID', message: 'New mobile must be E.164.' },
      ]);
    }

    const user = await this.requireUser(viewer.userId);
    if (user.mobileNumber === newNumber) {
      return this.forUser(user);
    }

    const occupant = await this.users.findByMobile(newNumber);
    if (occupant && occupant.id !== user.id) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.MOBILE_ALREADY_REGISTERED);
    }

    const now = this.clock.now();
    const updated = await withTx(this.prisma, async (tx) => {
      const next = await this.users.updateMobile(tx, user.id, newNumber, now);
      await this.audit.append(tx, {
        actorUserId: user.id,
        action: 'MOBILE_CHANGED',
        entityType: 'user',
        entityId: user.id,
        afterValue: { mobileNumber: newNumber },
      });
      return next;
    });

    return this.forUser(updated);
  }

  /** G2-I08: self-deactivate. Customer closes live Requests; Vendor refused if an ACTIVE Connection exists. */
  async deactivate(viewer: ViewerContext): Promise<Me> {
    if (viewer.role !== 'CUSTOMER' && viewer.role !== 'VENDOR') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    const user = await this.requireUser(viewer.userId);
    if (user.accountState === 'DEACTIVATED') {
      return this.forUser(user);
    }

    if (viewer.role === 'VENDOR') {
      if (!viewer.vendorProfileId) {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
      }
      const active = await this.users.countActiveConnectionsForVendor(viewer.vendorProfileId);
      if (active > 0) {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
      }
    }

    const updated = await withTx(this.prisma, async (tx) => {
      if (viewer.role === 'CUSTOMER' && viewer.customerProfileId) {
        await this.users.closeLiveRequestsForCustomer(viewer.customerProfileId, tx);
      }
      const next = await this.users.setAccountState(tx, user.id, 'DEACTIVATED');
      await this.audit.append(tx, {
        actorUserId: user.id,
        action: 'ACCOUNT_DEACTIVATED',
        entityType: 'user',
        entityId: user.id,
        afterValue: { accountState: 'DEACTIVATED' },
      });
      return next;
    });

    return this.forUser(updated);
  }

  /** G2-I09 step 1: pending data-subject request + OTP on the current number. */
  async createDeletionRequest(viewer: ViewerContext): Promise<DeletionRequestView> {
    if (viewer.role !== 'CUSTOMER') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    const user = await this.requireUser(viewer.userId);
    await this.assertNoRecentConnection(viewer);

    const issued = await this.otp.issueChallenge(user.mobileNumber, 'CHANGE_MOBILE');
    const pending = await this.users.findPendingDeletionRequest(user.id);
    const row =
      pending ??
      (await withTx(this.prisma, async (tx) => {
        const created = await this.users.createDataSubjectRequest(tx, {
          userId: user.id,
          state: 'QUEUED',
          reason: DELETION_AWAITING_CONFIRMATION,
        });
        await this.audit.append(tx, {
          actorUserId: user.id,
          action: 'DELETION_REQUESTED',
          entityType: 'data_subject_request',
          entityId: created.id,
        });
        return created;
      }));

    return {
      id: row.id,
      state: row.state,
      createdAt: row.createdAt.toISOString(),
      challengeId: issued.challengeId,
      expiresAt: issued.expiresAt.toISOString(),
      retryAfterSeconds: issued.retryAfterSeconds,
    };
  }

  /** G2-I09 step 2: verified OTP commits the request as QUEUED for the worker. */
  async confirmDeletionRequest(
    viewer: ViewerContext,
    id: string,
    challengeId: string,
  ): Promise<DeletionRequestView> {
    if (viewer.role !== 'CUSTOMER') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    const user = await this.requireUser(viewer.userId);
    const row = await this.users.findDataSubjectRequest(id);
    if (!row || row.userId !== user.id) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    if (row.reason !== DELETION_AWAITING_CONFIRMATION) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT);
    }

    await this.assertNoRecentConnection(viewer);

    const challenge = await this.otp.requireVerified(challengeId, 'CHANGE_MOBILE');
    if (challenge.mobileNumber !== user.mobileNumber) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        {
          path: 'challengeId',
          code: 'NOT_VERIFIED',
          message: 'Verify the mobile number on this account.',
        },
      ]);
    }

    const confirmed = await withTx(this.prisma, async (tx) => {
      const next = await this.users.confirmDataSubjectRequest(tx, row.id);
      await this.audit.append(tx, {
        actorUserId: user.id,
        action: 'DELETION_REQUEST_CONFIRMED',
        entityType: 'data_subject_request',
        entityId: next.id,
        afterValue: { state: 'QUEUED' },
      });
      return next;
    });

    return {
      id: confirmed.id,
      state: confirmed.state,
      createdAt: confirmed.createdAt.toISOString(),
    };
  }

  private async requireUser(userId: string): Promise<User> {
    const user = await this.users.findById(userId);
    if (!user) throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    return user;
  }

  private async assertNoRecentConnection(viewer: ViewerContext): Promise<void> {
    if (!viewer.customerProfileId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
    const since = new Date(this.clock.now().getTime() - DELETION_CONNECTION_WINDOW_MS);
    if (await this.users.hasConnectionCreatedSince(viewer.customerProfileId, since)) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
  }
}
