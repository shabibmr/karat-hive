import { afterEach, describe, expect, it, vi } from 'vitest';
import { GoldRateFeedError } from '../../ports/gold-rate.port';
import { AED_PER_USD, TROY_OUNCE_GRAMS, YahooGoldRateAdapter } from './yahoo-gold-rate.adapter';

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

describe('YahooGoldRateAdapter', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it('converts a positive GC=F quote to AED/g 24K', async () => {
    const usdPerOz = 3103.4768;
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(
        jsonResponse({
          chart: {
            result: [
              {
                meta: {
                  regularMarketPrice: usdPerOz,
                  regularMarketTime: 1_725_000_000,
                  currency: 'USD',
                },
              },
            ],
            error: null,
          },
        }),
      ),
    );

    const adapter = new YahooGoldRateAdapter();
    const spot = await adapter.fetchSpotRate();
    expect(spot.aedPerGram24k).toBeCloseTo((usdPerOz * AED_PER_USD) / TROY_OUNCE_GRAMS, 6);
    expect(spot.aedPerGram24k).toBeGreaterThan(0);
    expect(spot.sourceTimestamp.getTime()).toBe(1_725_000_000 * 1000);
  });

  it('refuses a zero or missing Yahoo price (never fabricate 0)', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(
        jsonResponse({
          chart: { result: [{ meta: { regularMarketPrice: 0 } }], error: null },
        }),
      ),
    );
    await expect(new YahooGoldRateAdapter().fetchSpotRate()).rejects.toBeInstanceOf(
      GoldRateFeedError,
    );

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(jsonResponse({ chart: { result: [{ meta: {} }] } })),
    );
    await expect(new YahooGoldRateAdapter().fetchSpotRate()).rejects.toBeInstanceOf(
      GoldRateFeedError,
    );
  });

  it('throws on HTTP failure', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(jsonResponse({ error: 'nope' }, 503)));
    await expect(new YahooGoldRateAdapter().fetchSpotRate()).rejects.toThrow(/HTTP 503/);
  });
});
