import { Injectable, Logger } from '@nestjs/common';
import { GoldRateFeedError, type GoldRateFeed, type SpotRate } from '../../ports/gold-rate.port';

/** COMEX gold futures, USD per troy ounce. */
export const YAHOO_GOLD_SYMBOL = 'GC=F';
export const YAHOO_CHART_URL = `https://query1.finance.yahoo.com/v8/finance/chart/${YAHOO_GOLD_SYMBOL}`;

/** UAE dirham is pegged; conversion lives in the adapter, not the domain. */
export const AED_PER_USD = 3.6725;
export const TROY_OUNCE_GRAMS = 31.1034768;

type YahooChartMeta = {
  regularMarketPrice?: number;
  regularMarketTime?: number;
  previousClose?: number;
  currency?: string;
};

type YahooChartResponse = {
  chart?: {
    result?: Array<{ meta?: YahooChartMeta }>;
    error?: { code?: string; description?: string } | null;
  };
};

/**
 * Yahoo Finance chart adapter. Converts USD/oz → AED/g 24K.
 * Never returns 0 or a fabricated fallback (FR-SYS-010 AC2).
 */
@Injectable()
export class YahooGoldRateAdapter implements GoldRateFeed {
  private readonly logger = new Logger(YahooGoldRateAdapter.name);

  async fetchSpotRate(): Promise<SpotRate> {
    const response = await fetch(YAHOO_CHART_URL, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
        'User-Agent': 'KaratHive/1.0 (gold-rate-ingest)',
      },
      signal: AbortSignal.timeout(10_000),
    });

    if (!response.ok) {
      throw new GoldRateFeedError(`Yahoo Finance HTTP ${response.status}`);
    }

    let body: YahooChartResponse;
    try {
      body = (await response.json()) as YahooChartResponse;
    } catch {
      throw new GoldRateFeedError('Yahoo Finance returned non-JSON');
    }

    const chartError = body.chart?.error;
    if (chartError) {
      throw new GoldRateFeedError(
        `Yahoo Finance chart error: ${chartError.code ?? ''} ${chartError.description ?? ''}`.trim(),
      );
    }

    const meta = body.chart?.result?.[0]?.meta;
    const usdPerOz = meta?.regularMarketPrice ?? meta?.previousClose;
    if (typeof usdPerOz !== 'number' || !Number.isFinite(usdPerOz) || usdPerOz <= 0) {
      throw new GoldRateFeedError('Yahoo Finance returned a missing or non-positive gold price');
    }

    const aedPerGram24k = (usdPerOz * AED_PER_USD) / TROY_OUNCE_GRAMS;
    if (!Number.isFinite(aedPerGram24k) || aedPerGram24k <= 0) {
      throw new GoldRateFeedError('Converted AED/g rate is not a positive finite number');
    }

    const sourceTimestamp =
      typeof meta?.regularMarketTime === 'number' && meta.regularMarketTime > 0
        ? new Date(meta.regularMarketTime * 1000)
        : new Date();

    this.logger.debug(
      `Yahoo spot usdPerOz=${usdPerOz} aedPerGram24k=${aedPerGram24k.toFixed(4)} ts=${sourceTimestamp.toISOString()}`,
    );

    return { aedPerGram24k, sourceTimestamp };
  }
}
