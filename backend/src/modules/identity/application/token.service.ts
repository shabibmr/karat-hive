import { createHash, randomBytes, randomUUID } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { decodeJwt, decodeProtectedHeader, errors, jwtVerify, SignJWT } from 'jose';
import type { UserType } from '@prisma/client';
import { ENV, type Env } from '../../../config/env';
import { PrismaService } from '../../../platform/db/prisma.service';
import { Clock } from '../../../shared/clock';
import { IdentityAuthError } from '../domain/identity-auth-error';

export type AccessClaims = {
  sub: string;
  role: UserType;
  ver: number;
};

export type IssuedTokens = {
  accessToken: string;
  accessExpiresAt: Date;
  refreshToken: string;
  refreshExpiresAt: Date;
  familyId: string;
};

@Injectable()
export class TokenService {
  constructor(
    @Inject(ENV) private readonly env: Env,
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
  ) {}

  async signAccess(claims: AccessClaims): Promise<{ token: string; expiresAt: Date }> {
    const now = this.clock.now();
    const expiresAt = new Date(now.getTime() + this.env.JWT_ACCESS_TTL_SECONDS * 1000);
    const token = await new SignJWT({ role: claims.role, ver: claims.ver })
      .setProtectedHeader({ alg: 'HS256' })
      .setSubject(claims.sub)
      .setIssuedAt(Math.floor(now.getTime() / 1000))
      .setExpirationTime(Math.floor(expiresAt.getTime() / 1000))
      .sign(this.secret());
    return { token, expiresAt };
  }

  async verifyAccess(token: string): Promise<AccessClaims> {
    try {
      const { payload } = await jwtVerify(token, this.secret(), { algorithms: ['HS256'] });
      const sub = payload.sub;
      const role = payload['role'];
      const ver = payload['ver'];
      if (typeof sub !== 'string' || typeof role !== 'string' || typeof ver !== 'number') {
        throw new IdentityAuthError('UNAUTHENTICATED');
      }
      return { sub, role: role as UserType, ver };
    } catch (error: unknown) {
      if (error instanceof IdentityAuthError) throw error;
      if (error instanceof errors.JWTExpired) {
        throw new IdentityAuthError('TOKEN_EXPIRED');
      }
      throw new IdentityAuthError('UNAUTHENTICATED');
    }
  }

  async issueRefresh(args: {
    userId: string;
    familyId?: string;
    ip?: string | null;
    userAgent?: string | null;
    ttlMs: number;
  }): Promise<{ refreshToken: string; refreshExpiresAt: Date; familyId: string }> {
    const familyId = args.familyId ?? randomUUID();
    const refreshToken = randomBytes(32).toString('base64url');
    const refreshExpiresAt = new Date(this.clock.now().getTime() + args.ttlMs);
    await this.prisma.refreshToken.create({
      data: {
        userId: args.userId,
        familyId,
        tokenHash: hashToken(refreshToken),
        expiresAt: refreshExpiresAt,
        ip: args.ip ?? null,
        userAgent: args.userAgent ?? null,
      },
    });
    return { refreshToken, refreshExpiresAt, familyId };
  }

  async rotateRefresh(
    presented: string,
    ttlMs: number,
    ip?: string | null,
    userAgent?: string | null,
  ): Promise<IssuedTokens> {
    const now = this.clock.now();
    const existing = await this.prisma.refreshToken.findUnique({
      where: { tokenHash: hashToken(presented) },
    });
    if (!existing) {
      throw new IdentityAuthError('UNAUTHENTICATED');
    }
    if (existing.rotatedAt !== null || existing.reuseDetectedAt !== null) {
      await this.revokeFamily(existing.familyId, now);
      throw new IdentityAuthError('REFRESH_REUSE_DETECTED');
    }
    if (existing.revokedAt !== null || existing.expiresAt.getTime() <= now.getTime()) {
      throw new IdentityAuthError('UNAUTHENTICATED');
    }

    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: existing.userId } });
    if (user.deletedAt !== null || user.accountState !== 'ACTIVE') {
      await this.revokeFamily(existing.familyId, now);
      throw new IdentityAuthError('UNAUTHENTICATED');
    }
    await this.prisma.refreshToken.update({
      where: { id: existing.id },
      data: { rotatedAt: now },
    });
    const next = await this.issueRefresh({
      userId: existing.userId,
      familyId: existing.familyId,
      ip,
      userAgent,
      ttlMs,
    });
    const access = await this.signAccess({
      sub: user.id,
      role: user.userType,
      ver: user.tokenVersion,
    });
    return {
      accessToken: access.token,
      accessExpiresAt: access.expiresAt,
      refreshToken: next.refreshToken,
      refreshExpiresAt: next.refreshExpiresAt,
      familyId: next.familyId,
    };
  }

  async revokePresented(refreshToken: string, now: Date = this.clock.now()): Promise<void> {
    const existing = await this.prisma.refreshToken.findUnique({
      where: { tokenHash: hashToken(refreshToken) },
    });
    if (!existing) return;
    await this.prisma.refreshToken.update({
      where: { id: existing.id },
      data: { revokedAt: now },
    });
  }

  async revokeFamilyForPresented(
    refreshToken: string,
    now: Date = this.clock.now(),
  ): Promise<void> {
    const existing = await this.prisma.refreshToken.findUnique({
      where: { tokenHash: hashToken(refreshToken) },
    });
    if (!existing) return;
    await this.prisma.refreshToken.updateMany({
      where: { familyId: existing.familyId, revokedAt: null },
      data: { revokedAt: now },
    });
  }

  async revokeFamily(familyId: string, now: Date = this.clock.now()): Promise<void> {
    await this.prisma.refreshToken.updateMany({
      where: { familyId, revokedAt: null },
      data: { revokedAt: now, reuseDetectedAt: now },
    });
  }

  /** One row per active family: the current (unrotated) refresh tip. */
  async listActiveFamilies(
    userId: string,
    now: Date = this.clock.now(),
  ): Promise<
    Array<{
      familyId: string;
      ip: string | null;
      userAgent: string | null;
      createdAt: Date;
      familyCreatedAt: Date;
    }>
  > {
    const tips = await this.prisma.refreshToken.findMany({
      where: {
        userId,
        revokedAt: null,
        rotatedAt: null,
        reuseDetectedAt: null,
        expiresAt: { gt: now },
      },
      orderBy: { createdAt: 'desc' },
    });
    const seen = new Set<string>();
    const out: Array<{
      familyId: string;
      ip: string | null;
      userAgent: string | null;
      createdAt: Date;
      familyCreatedAt: Date;
    }> = [];
    for (const tip of tips) {
      if (seen.has(tip.familyId)) continue;
      seen.add(tip.familyId);
      const oldest = await this.prisma.refreshToken.findFirst({
        where: { familyId: tip.familyId },
        orderBy: { createdAt: 'asc' },
        select: { createdAt: true },
      });
      out.push({
        familyId: tip.familyId,
        ip: tip.ip,
        userAgent: tip.userAgent,
        createdAt: tip.createdAt,
        familyCreatedAt: oldest?.createdAt ?? tip.createdAt,
      });
    }
    return out;
  }

  async familyOwnedBy(userId: string, familyId: string): Promise<boolean> {
    const row = await this.prisma.refreshToken.findFirst({
      where: { userId, familyId },
      select: { id: true },
    });
    return row !== null;
  }

  private secret(): Uint8Array {
    return new TextEncoder().encode(this.env.JWT_ACCESS_SECRET);
  }

  isFirebaseToken(token: string): boolean {
    return isFirebaseToken(token, this.env.FIREBASE_PROJECT_ID);
  }
}

export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

export function isFirebaseToken(token: string, expectedProjectId?: string): boolean {
  try {
    const header = decodeProtectedHeader(token);
    if (header.alg !== 'RS256') return false;
    const claims = decodeJwt(token);
    if (expectedProjectId) {
      return claims.iss === `https://securetoken.google.com/${expectedProjectId}`;
    }
    return (
      typeof claims.iss === 'string' &&
      claims.iss.startsWith('https://securetoken.google.com/')
    );
  } catch {
    return false;
  }
}
