import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import type { OtpChallenge } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { ENV, type Env } from '../../../config/env';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { PASSWORD_HASHER, type PasswordHasher } from '../../../platform/ports/password-hasher.port';
import { AuditWriter } from '../../audit';
import { VendorOnboardingService } from '../../vendor-onboarding';
import { isLocked, registerFailure, clearFailures } from '../domain/account-lock';
import { SessionService } from './session.service';
import { UserRepository } from '../repository/user.repository';
import type { SessionBundle } from '../presenter/session.presenter';

@Injectable()
export class LoginService {
  constructor(
    @Inject(ENV) private readonly env: Env,
    @Inject(PASSWORD_HASHER) private readonly hasher: PasswordHasher,
    private readonly clock: Clock,
    private readonly prisma: PrismaService,
    private readonly users: UserRepository,
    private readonly session: SessionService,
    private readonly audit: AuditWriter,
    private readonly vendors: VendorOnboardingService,
  ) {}

  async loginWithPassword(
    email: string,
    password: string,
    client: { ip?: string | null; userAgent?: string | null },
  ): Promise<SessionBundle> {
    const now = this.clock.now();
    const user = await this.users.findByEmail(email);
    if (!user || !user.passwordHash) {
      await withTx(this.prisma, (tx) =>
        this.audit.append(tx, {
          actorUserId: null,
          action: 'ADMIN_LOGIN',
          entityType: 'user',
          entityId: null,
          afterValue: { success: false, reason: 'UNKNOWN_USER' },
          ipAddress: client.ip ?? null,
          userAgent: client.userAgent ?? null,
        }),
      );
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    }
    if (
      isLocked(
        { failedLoginAttempts: user.failedLoginAttempts, lockedUntil: user.lockedUntil },
        now,
      )
    ) {
      throw new ApiException(HttpStatus.LOCKED, ErrorCode.ACCOUNT_LOCKED);
    }

    const ok = await this.hasher.verify(password, user.passwordHash);
    if (!ok) {
      const maxFailures = user.userType === 'ADMIN' ? 3 : this.env.LOGIN_MAX_FAILURES;
      const lockMinutes = user.userType === 'ADMIN' ? 30 : this.env.LOGIN_LOCK_MINUTES;
      const next = registerFailure(
        { failedLoginAttempts: user.failedLoginAttempts, lockedUntil: user.lockedUntil },
        now,
        maxFailures,
        lockMinutes,
      );
      await this.users.applyLockState(user.id, next);
      if (user.userType === 'ADMIN') {
        await withTx(this.prisma, (tx) =>
          this.audit.append(tx, {
            actorUserId: user.id,
            action: 'ADMIN_LOGIN',
            entityType: 'user',
            entityId: user.id,
            afterValue: { success: false, reason: 'BAD_PASSWORD' },
            ipAddress: client.ip ?? null,
            userAgent: client.userAgent ?? null,
          }),
        );
      }
      if (next.lockedUntil) {
        const lockedUntilIso = next.lockedUntil.toISOString();
        await withTx(this.prisma, (tx) =>
          this.audit.append(tx, {
            actorUserId: user.id,
            action: user.userType === 'ADMIN' ? 'ADMIN_ACCOUNT_LOCKED' : 'AUTH_ACCOUNT_LOCKED',
            entityType: 'user',
            entityId: user.id,
            afterValue: { lockedUntil: lockedUntilIso },
            ipAddress: client.ip ?? null,
            userAgent: client.userAgent ?? null,
          }),
        );
        throw new ApiException(HttpStatus.LOCKED, ErrorCode.ACCOUNT_LOCKED);
      }
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    }

    if (user.failedLoginAttempts !== 0 || user.lockedUntil !== null) {
      await this.users.applyLockState(user.id, clearFailures());
    }

    if (user.userType === 'ADMIN') {
      // [DEVIATION AD-API: 2FA deferred — checkpoint-1]
      if (user.accountState === 'SUSPENDED') {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_SUSPENDED);
      }
      if (user.accountState === 'DEACTIVATED') {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_DEACTIVATED);
      }
    } else if (user.userType === 'VENDOR') {
      if (user.accountState === 'SUSPENDED') {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_SUSPENDED);
      }
      if (user.accountState === 'DEACTIVATED') {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_DEACTIVATED);
      }
      await this.vendors.assertMayAuthenticate(user.id);
    } else {
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    }

    await withTx(this.prisma, (tx) =>
      this.audit.append(tx, {
        actorUserId: user.id,
        action: user.userType === 'ADMIN' ? 'ADMIN_LOGIN' : 'AUTH_PASSWORD_LOGIN',
        entityType: 'user',
        entityId: user.id,
        afterValue: user.userType === 'ADMIN' ? { success: true } : null,
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      }),
    );
    return this.session.issueFor(user, client);
  }

  async loginWithVerifiedOtp(
    challenge: OtpChallenge,
    client: { ip?: string | null; userAgent?: string | null },
  ): Promise<SessionBundle> {
    const user = challenge.userId
      ? await this.users.findById(challenge.userId)
      : await this.users.findByMobile(challenge.mobileNumber);
    if (!user || user.deletedAt) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    if (user.accountState === 'SUSPENDED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_SUSPENDED);
    }
    if (user.accountState === 'DEACTIVATED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_DEACTIVATED);
    }
    if (user.userType === 'VENDOR') {
      await this.vendors.assertMayAuthenticate(user.id);
    }
    await withTx(this.prisma, (tx) =>
      this.audit.append(tx, {
        actorUserId: user.id,
        action: 'AUTH_OTP_LOGIN',
        entityType: 'user',
        entityId: user.id,
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      }),
    );
    return this.session.issueFor(user, client);
  }
}
