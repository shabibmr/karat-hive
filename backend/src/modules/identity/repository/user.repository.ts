import { Injectable } from '@nestjs/common';
import type { PreferredLanguage, User } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';
import type { LockState } from '../domain/account-lock';

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

  async touchLogin(id: string, now: Date): Promise<void> {
    await this.prisma.user.update({ where: { id }, data: { lastLoginAt: now } });
  }

  async setPreferredLanguage(id: string, language: PreferredLanguage): Promise<void> {
    await this.prisma.user.update({ where: { id }, data: { preferredLanguage: language } });
  }
}
