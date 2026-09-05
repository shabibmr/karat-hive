import { Inject, Injectable, Optional } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../platform/db/prisma.service';
import { Clock } from '../../shared/clock';
import { RATE_LIMIT_SCOPES, TokenBucketConfig } from './rate-limit.policy';

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
    @Optional() @Inject(Clock) private readonly clock: Clock = new Clock(),
  ) {}

  async take(scope: string, subject: string): Promise<RateLimitDecision> {
    const config = RATE_LIMIT_SCOPES[scope];
    if (!config) {
      throw new Error(`Unknown rate-limit scope: ${scope}`);
    }
    const now = this.clock.now();

    let rows = await this.updateBucket(scope, subject, config, now);
    if (rows.length === 0) {
      await this.prisma.$executeRaw`
        INSERT INTO rate_limit_bucket (scope, subject, tokens, window_start, updated_at)
        VALUES (${scope}, ${subject}, ${new Prisma.Decimal(config.capacity)}, ${now}, ${now})
        ON CONFLICT (scope, subject) DO NOTHING
      `;
      rows = await this.updateBucket(scope, subject, config, now);
    }

    const row = rows[0];
    if (!row) {
      throw new Error(`rate_limit_bucket missing after initialization: ${scope}/${subject}`);
    }

    return {
      allowed: row.allowed,
      limit: config.capacity,
      remaining: Math.max(0, Math.floor(Number(row.tokens))),
      resetAt: new Date(now.getTime() + 60_000),
    };
  }

  private async updateBucket(
    scope: string,
    subject: string,
    config: TokenBucketConfig,
    now: Date,
  ): Promise<Array<{ tokens: Prisma.Decimal; allowed: boolean }>> {
    return this.prisma.$queryRaw<Array<{ tokens: Prisma.Decimal; allowed: boolean }>>`
      UPDATE rate_limit_bucket b
      SET
        tokens = CASE WHEN calc.refilled >= 1.0 THEN calc.refilled - 1.0 ELSE calc.refilled END,
        window_start = ${now},
        updated_at = ${now}
      FROM (
        SELECT
          tokens,
          window_start,
          LEAST(${config.capacity}::numeric, tokens + GREATEST(0.0, EXTRACT(EPOCH FROM (${now}::timestamptz - window_start)) / 60.0) * ${config.refillPerMinute}::numeric) AS refilled
        FROM rate_limit_bucket
        WHERE scope = ${scope} AND subject = ${subject}
      ) calc
      WHERE b.scope = ${scope} AND b.subject = ${subject}
      RETURNING
        b.tokens,
        (calc.refilled >= 1.0) AS allowed
    `;
  }
}
