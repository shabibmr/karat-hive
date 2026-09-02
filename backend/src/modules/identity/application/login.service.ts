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
      const next = registerFailure(
        { failedLoginAttempts: user.failedLoginAttempts, lockedUntil: user.lockedUntil },
        now,
        this.env.LOGIN_MAX_FAILURES,
        this.env.LOGIN_LOCK_MINUTES,
      );
      await this.users.applyLockState(user.id, next);
      if (next.lockedUntil) {
        await withTx(this.prisma, (tx) =>
          this.audit.append(tx, {
            actorUserId: user.id,
            action: 'AUTH_ACCOUNT_LOCKED',
            entityType: 'user',
            entityId: user.id,
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
      throw new ApiException(HttpStatus.NOT_IMPLEMENTED, ErrorCode.INTERNAL);
    }
    if (user.userType === 'VENDOR') {
      if (user.accountState === 'SUSPENDED') {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_SUSPENDED);
      }
      if (user.accountState === 'DEACTIVATED') {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_DEACTIVATED);
      }
      await this.vendors.assertMayAuthenticate(user.id);
    }

    await withTx(this.prisma, (tx) =>
      this.audit.append(tx, {
        actorUserId: user.id,
        action: 'AUTH_PASSWORD_LOGIN',
        entityType: 'user',
        entityId: user.id,
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
