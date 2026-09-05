import { Injectable } from '@nestjs/common';
import { PrismaService } from '../db/prisma.service';

@Injectable()
export class JobLockService {
  constructor(private readonly prisma: PrismaService) {}

  async tryAcquire(
    jobName: string,
    owner: string,
    leaseMs: number,
    now: Date = new Date(),
  ): Promise<boolean> {
    const leasedUntil = new Date(now.getTime() + leaseMs);
    const rows = await this.prisma.$queryRaw<Array<{ job_name: string }>>`
      INSERT INTO job_lock (job_name, owner, leased_until, updated_at)
      VALUES (${jobName}, ${owner}, ${leasedUntil}, ${now})
      ON CONFLICT (job_name) DO UPDATE
      SET owner = EXCLUDED.owner,
          leased_until = EXCLUDED.leased_until,
          updated_at = EXCLUDED.updated_at
      WHERE job_lock.leased_until <= ${now}
      RETURNING job_name
    `;
    return rows.length === 1;
  }

  async renew(
    jobName: string,
    owner: string,
    leaseMs: number,
    now: Date = new Date(),
  ): Promise<boolean> {
    const leasedUntil = new Date(now.getTime() + leaseMs);
    const result = await this.prisma.jobLock.updateMany({
      where: { jobName, owner },
      data: { leasedUntil },
    });
    return result.count === 1;
  }

  async release(jobName: string, owner: string): Promise<void> {
    await this.prisma.jobLock.updateMany({
      where: { jobName, owner },
      data: { leasedUntil: new Date(0) },
    });
  }
}
