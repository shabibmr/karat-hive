import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../platform/db/prisma.service';
import { Clock } from '../../shared/clock';
import { RATE_LIMIT_SCOPES, refillBucket } from './rate-limit.policy';

export type RateLimitDecision = {
  allowed: boolean;
  limit: number;
  remaining: number;
  resetAt: Date;
};

@Injectable()
export class RateLimitService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
  ) {}

  async take(scope: string, subject: string): Promise<RateLimitDecision> {
    const config = RATE_LIMIT_SCOPES[scope];
    if (!config) {
      throw new Error(`Unknown rate-limit scope: ${scope}`);
    }
    const now = this.clock.now();
    return this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw`
        INSERT INTO rate_limit_bucket (scope, subject, tokens, window_start, updated_at)
        VALUES (${scope}, ${subject}, ${new Prisma.Decimal(config.capacity)}, ${now}, ${now})
        ON CONFLICT (scope, subject) DO NOTHING
      `;
      const rows = await tx.$queryRaw<Array<{ tokens: Prisma.Decimal; window_start: Date }>>`
        SELECT tokens, window_start
        FROM rate_limit_bucket
        WHERE scope = ${scope} AND subject = ${subject}
        FOR UPDATE
      `;
      const row = rows[0];
      if (!row) {
        throw new Error(`rate_limit_bucket missing after insert: ${scope}/${subject}`);
      }
      const next = refillBucket({
        tokens: Number(row.tokens),
        windowStart: row.window_start,
        now,
        config,
      });
      await tx.rateLimitBucket.update({
        where: { scope_subject: { scope, subject } },
        data: {
          tokens: new Prisma.Decimal(next.tokens),
          windowStart: next.windowStart,
        },
      });
      return {
        allowed: next.allowed,
        limit: config.capacity,
        remaining: next.remaining,
        resetAt: new Date(now.getTime() + 60_000),
      };
    });
  }
}
