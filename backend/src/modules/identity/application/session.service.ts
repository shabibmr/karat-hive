import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import type { User } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { ENV, type Env } from '../../../config/env';
import { Clock } from '../../../shared/clock';
import { IdentityAuthError } from '../domain/identity-auth-error';
import { MeService } from './me.service';
import { TokenService, type IssuedTokens } from './token.service';
import { UserRepository } from '../repository/user.repository';
import { presentSession, type SessionBundle } from '../presenter/session.presenter';

type ClientInfo = { ip?: string | null; userAgent?: string | null };

@Injectable()
export class SessionService {
  constructor(
    @Inject(ENV) private readonly env: Env,
    private readonly clock: Clock,
    private readonly tokens: TokenService,
    private readonly users: UserRepository,
    private readonly me: MeService,
  ) {}

  private refreshTtlMs(): number {
    return this.env.JWT_REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000;
  }

  async issueFor(user: User, client: ClientInfo = {}): Promise<SessionBundle> {
    const access = await this.tokens.signAccess({
      sub: user.id,
      role: user.userType,
      ver: user.tokenVersion,
    });
    const refresh = await this.tokens.issueRefresh({
      userId: user.id,
      ip: client.ip ?? null,
      userAgent: client.userAgent ?? null,
      ttlMs: this.refreshTtlMs(),
    });
    const bundle: IssuedTokens = {
      accessToken: access.token,
      accessExpiresAt: access.expiresAt,
      refreshToken: refresh.refreshToken,
      refreshExpiresAt: refresh.refreshExpiresAt,
      familyId: refresh.familyId,
    };
    await this.users.touchLogin(user.id, this.clock.now());
    return presentSession(bundle, await this.me.forUser(user));
  }

  async refresh(presented: string, client: ClientInfo = {}): Promise<SessionBundle> {
    let issued: IssuedTokens;
    try {
      issued = await this.tokens.rotateRefresh(
        presented,
        this.refreshTtlMs(),
        client.ip ?? null,
        client.userAgent ?? null,
      );
    } catch (error: unknown) {
      if (error instanceof IdentityAuthError) {
        const code =
          error.code === 'REFRESH_REUSE_DETECTED'
            ? ErrorCode.REFRESH_REUSE_DETECTED
            : ErrorCode.UNAUTHENTICATED;
        throw new ApiException(HttpStatus.UNAUTHORIZED, code);
      }
      throw error;
    }
    const claims = await this.tokens.verifyAccess(issued.accessToken);
    const user = await this.users.findById(claims.sub);
    if (!user || user.deletedAt) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    }
    return presentSession(issued, await this.me.forUser(user));
  }

  async logout(presented: string | undefined, allDevices: boolean): Promise<void> {
    if (!presented) return;
    if (allDevices) {
      await this.tokens.revokeFamilyForPresented(presented);
      return;
    }
    await this.tokens.revokePresented(presented);
  }
}
