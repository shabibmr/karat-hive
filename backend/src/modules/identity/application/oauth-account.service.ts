import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { AuditWriter } from '../../audit';
import { FirebaseTokenService } from './firebase-token.service';
import { SessionService } from './session.service';
import { hashToken } from './token.service';
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

  async createSessionFromFirebase(
    token: string,
    client: { ip?: string | null; userAgent?: string | null; acceptLanguage?: string },
  ): Promise<SessionBundle> {
    const claims = await this.firebaseTokens.verify(token);
    const subjectHash = hashToken(claims.uid);
    const now = this.clock.now();

    // 1. Look up existing OauthBinding
    const existingBinding = await this.prisma.oauthBinding.findUnique({
      where: { subjectHash },
      include: { user: true },
    });

    if (existingBinding && existingBinding.user) {
      if (existingBinding.user.deletedAt !== null) {
        throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
      }
      return this.sessionService.issueFor(existingBinding.user, client);
    }

    // 2. If not bound, match by verified email (G2-A02: require claims.emailVerified === true)
    if (claims.email && claims.emailVerified === true) {
      const email = claims.email.trim();
      const matchedUser = await this.prisma.user.findUnique({
        where: { email },
      });

      if (matchedUser && matchedUser.deletedAt === null) {
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

        return this.sessionService.issueFor(matchedUser, client);
      }
    }

    // 3. Match by verified E.164 phone if available
    const phoneRegex = /^\+[1-9]\d{6,14}$/;
    if (claims.phoneNumber && phoneRegex.test(claims.phoneNumber)) {
      const matchedUser = await this.prisma.user.findUnique({
        where: { mobileNumber: claims.phoneNumber },
      });

      if (matchedUser && matchedUser.deletedAt === null) {
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

        return this.sessionService.issueFor(matchedUser, client);
      }
    }

    // 4. Unbound token and no existing user to bind -> 401 UNAUTHENTICATED
    throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
  }
}
