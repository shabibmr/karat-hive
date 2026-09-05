import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import { PrismaService } from '../../platform/db/prisma.service';
import { ReadinessGate } from '../../platform/lifecycle/readiness.gate';
import { Public } from '../auth/public.decorator';
import { ErrorCode } from '../errors/error-codes';

@Public()
@Controller()
export class HealthController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly readiness: ReadinessGate,
  ) {}

  /** Liveness. No database. API-Route-Inventory §7. */
  @Get('health')
  health(): { status: 'ok' } {
    return { status: 'ok' };
  }

  /** Readiness. PostgreSQL ping + applied migrations. Fails immediately on SIGTERM. */
  @Get('ready')
  async ready(): Promise<{ status: 'ok'; migrationsCurrent: boolean }> {
    if (!this.readiness.isAccepting()) {
      throw new ServiceUnavailableException({
        code: ErrorCode.INTERNAL,
        message: 'Shutting down.',
      });
    }
    try {
      await this.prisma.ping();
      const migrationsCurrent = await this.prisma.migrationsAreCurrent();
      if (!migrationsCurrent) {
        throw new ServiceUnavailableException({
          code: ErrorCode.INTERNAL,
          message: 'Database migrations are not current.',
        });
      }
      return { status: 'ok', migrationsCurrent: true };
    } catch (error) {
      if (error instanceof ServiceUnavailableException) throw error;
      throw new ServiceUnavailableException({
        code: ErrorCode.INTERNAL,
        message: 'Database is not ready.',
      });
    }
  }
}
