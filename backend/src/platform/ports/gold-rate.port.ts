/** Yahoo Finance (or a swap-in provider). Architecture §15.2, FR-SYS-010. */

export type SpotRate = {
  /** 24K / 999, AED per gram. Must be finite and > 0. */
  aedPerGram24k: number;
  sourceTimestamp: Date;
};

export class GoldRateFeedError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'GoldRateFeedError';
  }
}

export interface GoldRateFeed {
  fetchSpotRate(): Promise<SpotRate>;
}

export const GOLD_RATE_FEED = Symbol('GOLD_RATE_FEED');

/** Stored on `gold_rate.feed_provider` (FR-SYS-010 AC1). */
export const YAHOO_FEED_PROVIDER = 'YAHOO_FINANCE';
