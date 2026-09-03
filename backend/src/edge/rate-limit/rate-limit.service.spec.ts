import { describe, expect, it, vi } from 'vitest';
import { Prisma } from '@prisma/client';
import { RateLimitService } from './rate-limit.service';
import type { PrismaService } from '../../platform/db/prisma.service';
import type { Clock } from '../../shared/clock';

function createMockPrisma() {
  return {
    $queryRaw: vi.fn(),
    $executeRaw: vi.fn(),
  } as unknown as PrismaService;
}

function createMockClock(now: Date): Clock {
  return {
    now: vi.fn().mockReturnValue(now),
    nowIso: vi.fn().mockReturnValue(now.toISOString()),
  };
}

describe('RateLimitService', () => {
  const t0 = new Date('2026-09-01T12:00:00.000Z');

  it('throws for unknown rate-limit scope', async () => {
    const prisma = createMockPrisma();
    const clock = createMockClock(t0);
    const service = new RateLimitService(prisma, clock);

    await expect(service.take('nonexistent_scope', 'user_1')).rejects.toThrow(
      'Unknown rate-limit scope: nonexistent_scope',
    );
  });

  it('executes atomic update query and returns decision without multi-step interactive transaction', async () => {
    const prisma = createMockPrisma();
    const clock = createMockClock(t0);
    vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([
      { tokens: new Prisma.Decimal(4), allowed: true },
    ]);

    const service = new RateLimitService(prisma, clock);
    const decision = await service.take('otp', 'user_1');

    // Exactly 1 atomic query executed, no interactive transaction
    expect(prisma.$queryRaw).toHaveBeenCalledTimes(1);
    expect(prisma.$executeRaw).not.toHaveBeenCalled();
    expect(decision).toEqual({
      allowed: true,
      limit: 5, // OTP capacity is 5
      remaining: 4,
      resetAt: new Date(t0.getTime() + 60_000),
    });
  });

  it('initializes bucket on cold start when first query returns no rows', async () => {
    const prisma = createMockPrisma();
    const clock = createMockClock(t0);

    // First update finds no row (cold start)
    vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([]);
    // Insert succeeds
    vi.mocked(prisma.$executeRaw).mockResolvedValueOnce(1);
    // Retry update succeeds
    vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([
      { tokens: new Prisma.Decimal(4), allowed: true },
    ]);

    const service = new RateLimitService(prisma, clock);
    const decision = await service.take('otp', 'user_new');

    expect(prisma.$queryRaw).toHaveBeenCalledTimes(2);
    expect(prisma.$executeRaw).toHaveBeenCalledTimes(1);
    expect(decision.allowed).toBe(true);
    expect(decision.remaining).toBe(4);
  });

  it('returns rate limited decision when bucket capacity is exhausted', async () => {
    const prisma = createMockPrisma();
    const clock = createMockClock(t0);
    vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([
      { tokens: new Prisma.Decimal(0), allowed: false },
    ]);

    const service = new RateLimitService(prisma, clock);
    const decision = await service.take('otp', 'user_1');

    expect(decision).toEqual({
      allowed: false,
      limit: 5,
      remaining: 0,
      resetAt: new Date(t0.getTime() + 60_000),
    });
  });

  it('throws when bucket is still missing after initialization', async () => {
    const prisma = createMockPrisma();
    const clock = createMockClock(t0);

    vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([]);
    vi.mocked(prisma.$executeRaw).mockResolvedValueOnce(1);
    vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([]);

    const service = new RateLimitService(prisma, clock);
    await expect(service.take('otp', 'user_1')).rejects.toThrow(
      'rate_limit_bucket missing after initialization: otp/user_1',
    );
  });
});
