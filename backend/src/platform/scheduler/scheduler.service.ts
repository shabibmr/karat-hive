import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { JobLockService } from './job-lock.service';

export type ScheduledJob = {
  name: string;
  intervalMs: number;
  leaseMs?: number;
  unleased?: boolean;
  run: () => Promise<void>;
};

@Injectable()
export class SchedulerService implements OnModuleDestroy {
  private readonly logger = new Logger(SchedulerService.name);
  private readonly jobs: ScheduledJob[] = [];
  private readonly timers: NodeJS.Timeout[] = [];
  private readonly inFlight = new Set<string>();
  private running = false;

  constructor(private readonly locks: JobLockService) {}

  register(job: ScheduledJob): void {
    this.jobs.push(job);
  }

  start(owner: string): void {
    if (this.running) return;
    this.running = true;
    for (const job of this.jobs) {
      const tick = (): void => {
        void this.runOnce(job, owner);
      };
      tick();
      this.timers.push(setInterval(tick, job.intervalMs));
    }
    this.logger.log(`Scheduler started with ${this.jobs.length} job(s) owner=${owner}`);
  }

  async onModuleDestroy(): Promise<void> {
    this.running = false;
    for (const timer of this.timers) clearInterval(timer);
    this.timers.length = 0;
  }

  private async runOnce(job: ScheduledJob, owner: string): Promise<void> {
    if (this.inFlight.has(job.name)) return;
    this.inFlight.add(job.name);

    if (job.unleased) {
      try {
        await job.run();
      } catch (error: unknown) {
        const message = error instanceof Error ? error.message : String(error);
        this.logger.error(`Job ${job.name} failed: ${message}`);
      } finally {
        this.inFlight.delete(job.name);
      }
      return;
    }

    const leaseMs = job.leaseMs ?? Math.max(job.intervalMs * 2, 15_000);
    let acquired: boolean;
    try {
      acquired = await this.locks.tryAcquire(job.name, owner, leaseMs);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.error(`Job ${job.name} lock acquisition failed: ${message}`);
      this.inFlight.delete(job.name);
      return;
    }
    if (!acquired) {
      this.inFlight.delete(job.name);
      return;
    }
    const heartbeat = setInterval(
      () => {
        this.locks.renew(job.name, owner, leaseMs).catch((error: unknown) => {
          const message = error instanceof Error ? error.message : String(error);
          this.logger.error(`Job ${job.name} lock renewal failed: ${message}`);
        });
      },
      Math.max(1_000, Math.floor(leaseMs / 3)),
    );
    try {
      await job.run();
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.error(`Job ${job.name} failed: ${message}`);
    } finally {
      clearInterval(heartbeat);
      try {
        await this.locks.release(job.name, owner);
      } catch (error: unknown) {
        const message = error instanceof Error ? error.message : String(error);
        this.logger.error(`Job ${job.name} lock release failed: ${message}`);
      }
      this.inFlight.delete(job.name);
    }
  }
}
