import { Inject, Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { ENV, type Env } from '../../config/env';

/**
 * PostgreSQL is required for /ready and every domain path.
 * In development/test, boot and /health must not depend on it (P0, no Docker).
 * In production, Architecture §6: connect and verify migrations before traffic.
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor(@Inject(ENV) private readonly env: Env) {
    super({
      datasources: {
        db: {
          url: env.DATABASE_URL,
        },
      },
    });
  }

  async onModuleInit(): Promise<void> {
    if (this.env.NODE_ENV === 'production') {
      await this.assertReady();
      return;
    }
    try {
      await this.$connect();
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.warn(`PostgreSQL not reachable at boot: ${message}`);
    }
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }

  async assertReady(): Promise<void> {
    await this.$connect();
    const current = await this.migrationsAreCurrent();
    if (!current) {
      throw new Error('Database migrations are not current.');
    }
  }

  async ping(): Promise<boolean> {
    await this.$connect();
    await this.$queryRaw`SELECT 1`;
    return true;
  }

  async migrationsAreCurrent(): Promise<boolean> {
    try {
      const rows = await this.$queryRaw<Array<{ pending: bigint }>>`
        SELECT COUNT(*)::bigint AS pending
        FROM _prisma_migrations
        WHERE finished_at IS NULL OR rolled_back_at IS NOT NULL
      `;
      const pending = rows[0]?.pending ?? 1n;
      if (pending !== 0n) return false;
      const applied = await this.$queryRaw<Array<{ n: bigint }>>`
        SELECT COUNT(*)::bigint AS n FROM _prisma_migrations WHERE finished_at IS NOT NULL
      `;
      return (applied[0]?.n ?? 0n) > 0n;
    } catch {
      return false;
    }
  }
}
