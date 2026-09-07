import { describe, expect, it } from 'vitest';
import {
  derivePurityRates,
  fromWireKarat,
  InvalidSpotRateError,
  money2,
  roundAed,
  toWireKarat,
} from './purity';

describe('derivePurityRates', () => {
  it('derives 22K/21K/18K from a 24K base using fineness factors', () => {
    const rows = derivePurityRates(240);
    expect(rows).toEqual([
      { purityKarat: 'K24', ratePerGramAed: 240 },
      { purityKarat: 'K22', ratePerGramAed: 220 },
      { purityKarat: 'K21', ratePerGramAed: 210 },
      { purityKarat: 'K18', ratePerGramAed: 180 },
    ]);
  });

  it('refuses a non-positive 24K spot (never fabricate 0)', () => {
    expect(() => derivePurityRates(0)).toThrow(InvalidSpotRateError);
    expect(() => derivePurityRates(-1)).toThrow(InvalidSpotRateError);
    expect(() => derivePurityRates(Number.NaN)).toThrow(InvalidSpotRateError);
  });

  it('refuses a derived rate that rounds to zero', () => {
    expect(() => derivePurityRates(0.001)).toThrow(/rounded to zero/);
  });
});

describe('karat wire mapping', () => {
  it('maps Prisma enums to inventory 24K-style strings', () => {
    expect(toWireKarat('K24')).toBe('24K');
    expect(fromWireKarat('24K')).toBe('K24');
    expect(fromWireKarat('K18')).toBe('K18');
    expect(fromWireKarat('9K')).toBeNull();
  });

  it('formats money to 2 dp', () => {
    expect(money2(312.3)).toBe('312.30');
    expect(roundAed(312.345)).toBe(312.35);
  });
});
