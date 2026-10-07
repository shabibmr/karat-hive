import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { AuditWriter } from '../../audit';
import { FirebaseTokenService } from './firebase-token.service';
import { SessionService } from './session.service';
import { hashToken } from './token.service';
import { AuthAudience, audienceMatchesRole } from '../domain/auth-audience';
import type { User, UserType } from '@prisma/client';
import type { SessionBundle } from '../presenter/session.presenter';

@Injectable()
export class OAuthAccountService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseTokens: FirebaseTokenService,
    private readonly sessionService: SessionService,
    private readonly clock: Clock,
    private readonly audit: AuditWriter,
  ) {}

  private assertUserCanLogin(
    user: User,
    audience: AuthAudience,
    expectedRole?: UserType,
  ): void {
    if (user.deletedAt !== null) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    }
    if (expectedRole !== undefined && user.userType !== expectedRole) {
      throw new ApiException(
        HttpStatus.FORBIDDEN,
        ErrorCode.ACCOUNT_ROLE_MISMATCH,
        [{ code: 'actualRole', message: user.userType }],
      );
    }
    if (!audienceMatchesRole(audience, user.userType)) {
      throw new ApiException(
        HttpStatus.FORBIDDEN,
        ErrorCode.ACCOUNT_ROLE_MISMATCH,
        [{ code: 'actualRole', message: user.userType }],
      );
    }
    if (user.accountState !== 'ACTIVE') {
      if (user.accountState === 'SUSPENDED') {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_SUSPENDED);
      }
      if (user.accountState === 'DEACTIVATED') {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_DEACTIVATED);
      }
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
  }

  async createSessionFromFirebase(
    token: string,
    client: { ip?: string | null; userAgent?: string | null; acceptLanguage?: string } = {},
    audienceOrRole?: AuthAudience | UserType,
    expectedRole?: UserType,
  ): Promise<SessionBundle> {
    let audience: AuthAudience = AuthAudience.MOBILE_RESTORE;
    let targetRole = expectedRole;

    if (audienceOrRole) {
      if (
        audienceOrRole === 'CUSTOMER' ||
        audienceOrRole === 'VENDOR' ||
        audienceOrRole === 'ADMIN'
      ) {
        targetRole = audienceOrRole;
        audience =
          targetRole === 'ADMIN'
            ? AuthAudience.ADMIN_PORTAL
            : AuthAudience.MOBILE_RESTORE;
      } else {
        audience = audienceOrRole as AuthAudience;
      }
    }

    const claims = await this.firebaseTokens.verify(token);
    const subjectHash = hashToken(claims.uid);
    const now = this.clock.now();

    // 1. Look up existing OauthBinding
    const existingBinding = await this.prisma.oauthBinding.findUnique({
      where: { subjectHash },
      include: { user: true },
    });

    if (existingBinding && existingBinding.user) {
      this.assertUserCanLogin(existingBinding.user, audience, targetRole);
      return audienceOrRole === undefined
        ? this.sessionService.issueFor(existingBinding.user, client)
        : this.sessionService.issueFor(existingBinding.user, client, audience);
    }

    // 2. If not bound, match by verified email (G2-A02: require claims.emailVerified === true)
    if (claims.email && claims.emailVerified === true) {
      const email = claims.email.trim();
      const matchedUser = await this.prisma.user.findUnique({
        where: { email },
      });

      if (matchedUser) {
        this.assertUserCanLogin(matchedUser, audience, targetRole);

        await this.prisma.oauthBinding.upsert({
          where: {
            userId_provider: {
              userId: matchedUser.id,
              provider: 'GOOGLE',
            },
          },
          create: {
            userId: matchedUser.id,
            provider: 'GOOGLE',
            subjectHash,
            boundAt: now,
          },
          update: {
            subjectHash,
            boundAt: now,
          },
        });

        await this.audit.append(this.prisma, {
          actorUserId: matchedUser.id,
          action: 'OAUTH_BOUND',
          entityType: 'oauth_binding',
          entityId: matchedUser.id,
          ipAddress: client.ip ?? null,
          userAgent: client.userAgent ?? null,
        });

        return audienceOrRole === undefined
          ? this.sessionService.issueFor(matchedUser, client)
          : this.sessionService.issueFor(matchedUser, client, audience);
      }
    }

    // 3. Match by verified E.164 phone if available
    const phoneRegex = /^\+[1-9]\d{6,14}$/;
    if (claims.phoneNumber && phoneRegex.test(claims.phoneNumber)) {
      const matchedUser = await this.prisma.user.findUnique({
        where: { mobileNumber: claims.phoneNumber },
      });

      if (matchedUser) {
        this.assertUserCanLogin(matchedUser, audience, targetRole);

        await this.prisma.oauthBinding.upsert({
          where: {
            userId_provider: {
              userId: matchedUser.id,
              provider: 'GOOGLE',
            },
          },
          create: {
            userId: matchedUser.id,
            provider: 'GOOGLE',
            subjectHash,
            boundAt: now,
          },
          update: {
            subjectHash,
            boundAt: now,
          },
        });

        await this.audit.append(this.prisma, {
          actorUserId: matchedUser.id,
          action: 'OAUTH_BOUND',
          entityType: 'oauth_binding',
          entityId: matchedUser.id,
          ipAddress: client.ip ?? null,
          userAgent: client.userAgent ?? null,
        });

        return audienceOrRole === undefined
          ? this.sessionService.issueFor(matchedUser, client)
          : this.sessionService.issueFor(matchedUser, client, audience);
      }
    }

    // 4. Unbound token and no existing user to bind -> 401 UNAUTHENTICATED
    throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
  }
}
