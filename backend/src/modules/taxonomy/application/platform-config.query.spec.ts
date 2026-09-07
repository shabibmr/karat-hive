import { describe, expect, it, vi } from 'vitest';
import { PlatformConfigQuery } from './platform-config.query';
import type { PrismaService } from '../../../platform/db/prisma.service';

describe('PlatformConfigQuery', () => {
  it('throws 500 INTERNAL when platformSetting table is empty (G2-P01)', async () => {
    const prisma = {
      platformSetting: {
        findMany: vi.fn().mockResolvedValue([]),
      },
    } as unknown as PrismaService;

    const query = new PlatformConfigQuery(prisma);
    await expect(query.getPlatformConfig()).rejects.toMatchObject({
      errorCode: 'INTERNAL',
      status: 500,
    });
  });

  it('overrides defaults with database rows when present', async () => {
    const prisma = {
      platformSetting: {
        findMany: vi.fn().mockResolvedValue([
          { key: 'request.lifetime_hours', value: 72 },
          { key: 'bullion.minimum_value_aed', value: '1000.00' },
          { key: 'request.max_concurrent_live', value: 5 },
          { key: 'legal.terms_url', value: 'https://custom.terms' },
        ]),
      },
    } as unknown as PrismaService;

    const query = new PlatformConfigQuery(prisma);
    const config = await query.getPlatformConfig();

    expect(config.requestLifetimeHours).toBe(72);
    expect(config.bullionMinimumAed).toBe('1000.00');
    expect(config.maxConcurrentLiveRequests).toBe(5);
    expect(config.termsUrl).toBe('https://custom.terms');
    // non-overridden remains default
    expect(config.defaultOfferValidityHours).toBe(24);
    expect(config.offerValidityHours).toEqual([12, 24, 48]);
  });
});
