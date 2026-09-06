import { describe, expect, it, vi } from 'vitest';
import { SchedulerService, ScheduledJob } from './scheduler.service';
import type { JobLockService } from './job-lock.service';

describe('SchedulerService', () => {
  function createLockMock(): JobLockService {
    return {
      tryAcquire: vi.fn().mockResolvedValue(true),
      renew: vi.fn().mockResolvedValue(true),
      release: vi.fn().mockResolvedValue(undefined),
    } as unknown as JobLockService;
  }

  it('runs an unleased job without acquiring or releasing locks', async () => {
    const locks = createLockMock();
    const scheduler = new SchedulerService(locks);

    let runCount = 0;
    const job: ScheduledJob = {
      name: 'unleased.task',
      intervalMs: 10_000,
      unleased: true,
      run: async () => {
        runCount++;
      },
    };

    const privateScheduler = scheduler as unknown as {
      runOnce: (job: ScheduledJob, owner: string) => Promise<void>;
    };
    await privateScheduler.runOnce(job, 'test-worker');

    expect(runCount).toBe(1);
    expect(locks.tryAcquire).not.toHaveBeenCalled();
    expect(locks.renew).not.toHaveBeenCalled();
    expect(locks.release).not.toHaveBeenCalled();

    await scheduler.onModuleDestroy();
  });

  it('preserves inFlight safety for unleased jobs while running', async () => {
    const locks = createLockMock();
    const scheduler = new SchedulerService(locks);

    let concurrentCount = 0;
    let maxConcurrent = 0;
    let resolveRun: () => void = () => {};

    const job: ScheduledJob = {
      name: 'unleased.slow',
      intervalMs: 10_000,
      unleased: true,
      run: async () => {
        concurrentCount++;
        maxConcurrent = Math.max(maxConcurrent, concurrentCount);
        await new Promise<void>((resolve) => {
          resolveRun = resolve;
        });
        concurrentCount--;
      },
    };

    const privateScheduler = scheduler as unknown as {
      runOnce: (job: ScheduledJob, owner: string) => Promise<void>;
    };

    const run1 = privateScheduler.runOnce(job, 'test-worker');
    const run2 = privateScheduler.runOnce(job, 'test-worker');

    expect(maxConcurrent).toBe(1);
    resolveRun();
    await Promise.all([run1, run2]);
    expect(maxConcurrent).toBe(1);

    await scheduler.onModuleDestroy();
  });

  it('clears inFlight slot even if unleased job throws', async () => {
    const locks = createLockMock();
    const scheduler = new SchedulerService(locks);

    let fail = true;
    let attempts = 0;

    const job: ScheduledJob = {
      name: 'unleased.failing',
      intervalMs: 10_000,
      unleased: true,
      run: async () => {
        attempts++;
        if (fail) {
          throw new Error('Simulated worker crash');
        }
      },
    };

    const privateScheduler = scheduler as unknown as {
      runOnce: (job: ScheduledJob, owner: string) => Promise<void>;
    };

    await privateScheduler.runOnce(job, 'test-worker');
    expect(attempts).toBe(1);

    // Second run should succeed because inFlight was cleaned up in finally
    fail = false;
    await privateScheduler.runOnce(job, 'test-worker');
    expect(attempts).toBe(2);

    await scheduler.onModuleDestroy();
  });

  it('acquires and releases lease for standard (leased) jobs', async () => {
    const locks = createLockMock();
    const scheduler = new SchedulerService(locks);

    let runCount = 0;
    const job: ScheduledJob = {
      name: 'leased.task',
      intervalMs: 10_000,
      run: async () => {
        runCount++;
      },
    };

    const privateScheduler = scheduler as unknown as {
      runOnce: (job: ScheduledJob, owner: string) => Promise<void>;
    };
    await privateScheduler.runOnce(job, 'test-worker');

    expect(runCount).toBe(1);
    expect(locks.tryAcquire).toHaveBeenCalledWith('leased.task', 'test-worker', 20_000);
    expect(locks.release).toHaveBeenCalledWith('leased.task', 'test-worker');

    await scheduler.onModuleDestroy();
  });

  it('skips run if lease acquisition fails', async () => {
    const locks = createLockMock();
    vi.mocked(locks.tryAcquire).mockResolvedValue(false);
    const scheduler = new SchedulerService(locks);

    let runCount = 0;
    const job: ScheduledJob = {
      name: 'leased.contested',
      intervalMs: 10_000,
      run: async () => {
        runCount++;
      },
    };

    const privateScheduler = scheduler as unknown as {
      runOnce: (job: ScheduledJob, owner: string) => Promise<void>;
    };
    await privateScheduler.runOnce(job, 'test-worker');

    expect(runCount).toBe(0);
    expect(locks.tryAcquire).toHaveBeenCalledWith('leased.contested', 'test-worker', 20_000);
    expect(locks.release).not.toHaveBeenCalled();

    await scheduler.onModuleDestroy();
  });
});
