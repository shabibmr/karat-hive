import { Injectable } from '@nestjs/common';
import type {
  DataSubjectRequest,
  DataSubjectRequestState,
  PreferredLanguage,
  User,
  UserAccountState,
} from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';
import type { LockState } from '../domain/account-lock';

/** Marker on `data_subject_request.reason` until OTP confirm (G2-I09). */
export const DELETION_AWAITING_CONFIRMATION = 'AWAITING_CONFIRMATION';

@Injectable()
export class UserRepository {
  constructor(private readonly prisma: PrismaService) {}

  findByMobile(mobileNumber: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { mobileNumber } });
  }

  findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { email } });
  }

  findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  findAdminProfile(userId: string) {
    return this.prisma.adminProfile.findUnique({ where: { userId } });
  }

  findCustomerProfile(userId: string) {
    return this.prisma.customerProfile.findUnique({
      where: { userId },
      include: {
        defaultRegion: { select: { id: true, nameEn: true, nameAr: true } },
        photoMedia: { select: { id: true, key: true } },
      },
    });
  }

  createCustomerUser(
    tx: DbTx,
    input: {
      mobileNumber: string;
      email?: string | null;
      preferredLanguage: PreferredLanguage;
      mobileVerifiedAt?: Date | null;
      emailVerifiedAt?: Date | null;
      termsVersion: string;
      privacyVersion: string;
      termsAcceptedAt: Date;
    },
  ): Promise<User> {
    return tx.user.create({
      data: {
        mobileNumber: input.mobileNumber,
        email: input.email ?? null,
        userType: 'CUSTOMER',
        accountState: 'ACTIVE',
        preferredLanguage: input.preferredLanguage,
        mobileVerifiedAt: input.mobileVerifiedAt ?? null,
        emailVerifiedAt: input.emailVerifiedAt ?? null,
        termsVersion: input.termsVersion,
        privacyVersion: input.privacyVersion,
        termsAcceptedAt: input.termsAcceptedAt,
      },
    });
  }

  createCustomerProfile(
    tx: DbTx,
    input: {
      userId: string;
      displayName: string;
      defaultRegionId?: string | null;
      photoMediaId?: string | null;
    },
  ) {
    return tx.customerProfile.create({
      data: {
        userId: input.userId,
        displayName: input.displayName,
        defaultRegionId: input.defaultRegionId ?? null,
        photoMediaId: input.photoMediaId ?? null,
      },
    });
  }

  updateCustomerProfile(
    userId: string,
    input: {
      displayName?: string;
      defaultRegionId?: string | null;
      photoMediaId?: string | null;
    },
  ) {
    return this.prisma.customerProfile.update({
      where: { userId },
      data: {
        ...(input.displayName !== undefined ? { displayName: input.displayName } : {}),
        ...(input.defaultRegionId !== undefined ? { defaultRegionId: input.defaultRegionId } : {}),
        ...(input.photoMediaId !== undefined ? { photoMediaId: input.photoMediaId } : {}),
      },
    });
  }

  createVendorUser(
    tx: DbTx,
    input: {
      mobileNumber: string;
      email: string;
      preferredLanguage: PreferredLanguage;
      mobileVerifiedAt: Date;
      termsVersion: string;
      privacyVersion: string;
      termsAcceptedAt: Date;
    },
  ): Promise<User> {
    return tx.user.create({
      data: {
        mobileNumber: input.mobileNumber,
        email: input.email,
        userType: 'VENDOR',
        accountState: 'ACTIVE',
        preferredLanguage: input.preferredLanguage,
        mobileVerifiedAt: input.mobileVerifiedAt,
        termsVersion: input.termsVersion,
        privacyVersion: input.privacyVersion,
        termsAcceptedAt: input.termsAcceptedAt,
      },
    });
  }

  async applyLockState(id: string, state: LockState): Promise<void> {
    await this.prisma.user.update({
      where: { id },
      data: { failedLoginAttempts: state.failedLoginAttempts, lockedUntil: state.lockedUntil },
    });
  }

  async setPasswordHash(id: string, passwordHash: string): Promise<void> {
    await this.prisma.user.update({
      where: { id },
      data: { passwordHash, failedLoginAttempts: 0 },
    });
  }

  async touchLogin(id: string, now: Date): Promise<void> {
    await this.prisma.user.update({ where: { id }, data: { lastLoginAt: now } });
  }

  async setPreferredLanguage(id: string, language: PreferredLanguage): Promise<void> {
    await this.prisma.user.update({ where: { id }, data: { preferredLanguage: language } });
  }

  async hasOauthBinding(userId: string): Promise<boolean> {
    const binding = await this.prisma.oauthBinding.findFirst({
      where: { userId },
      select: { id: true },
    });
    return Boolean(binding);
  }

  async countLiveRequestsForCustomer(
    customerProfileId: string,
    now: Date = new Date(),
  ): Promise<number> {
    return this.prisma.request.count({
      where: {
        customerProfileId,
        state: 'PUBLISHED',
        expiresAt: { gt: now },
      },
    });
  }

  updateMobile(
    tx: DbTx,
    id: string,
    mobileNumber: string,
    mobileVerifiedAt: Date,
  ): Promise<User> {
    return tx.user.update({
      where: { id },
      data: { mobileNumber, mobileVerifiedAt },
    });
  }

  setAccountState(tx: DbTx, id: string, accountState: UserAccountState): Promise<User> {
    return tx.user.update({
      where: { id },
      data: { accountState },
    });
  }

  async countActiveConnectionsForVendor(vendorProfileId: string): Promise<number> {
    return this.prisma.connection.count({
      where: { vendorProfileId, state: 'ACTIVE' },
    });
  }

  async hasConnectionCreatedSince(customerProfileId: string, since: Date): Promise<boolean> {
    const found = await this.prisma.connection.findFirst({
      where: { customerProfileId, createdAt: { gte: since } },
      select: { id: true },
    });
    return Boolean(found);
  }

  async closeLiveRequestsForCustomer(customerProfileId: string, tx: DbTx): Promise<void> {
    const live = await tx.request.findMany({
      where: {
        customerProfileId,
        state: { in: ['PUBLISHED', 'OFFERS_RECEIVED'] },
      },
      select: { id: true },
    });
    if (live.length === 0) return;
    const ids = live.map((row) => row.id);
    await tx.offer.updateMany({
      where: { requestId: { in: ids }, state: 'PENDING' },
      data: { state: 'WITHDRAWN_BY_SYSTEM' },
    });
    await tx.request.updateMany({
      where: { id: { in: ids } },
      data: { state: 'CANCELLED', cancellationReason: 'ACCOUNT_DEACTIVATED' },
    });
  }

  createDataSubjectRequest(
    tx: DbTx,
    input: {
      userId: string;
      state: DataSubjectRequestState;
      reason?: string | null;
    },
  ): Promise<DataSubjectRequest> {
    return tx.dataSubjectRequest.create({
      data: {
        userId: input.userId,
        state: input.state,
        reason: input.reason ?? null,
      },
    });
  }

  findDataSubjectRequest(id: string): Promise<DataSubjectRequest | null> {
    return this.prisma.dataSubjectRequest.findUnique({ where: { id } });
  }

  findPendingDeletionRequest(userId: string): Promise<DataSubjectRequest | null> {
    return this.prisma.dataSubjectRequest.findFirst({
      where: { userId, state: 'QUEUED', reason: DELETION_AWAITING_CONFIRMATION },
      orderBy: { createdAt: 'desc' },
    });
  }

  confirmDataSubjectRequest(tx: DbTx, id: string): Promise<DataSubjectRequest> {
    return tx.dataSubjectRequest.update({
      where: { id },
      data: { reason: null, state: 'QUEUED' },
    });
  }
}

