import type { Karat } from '@prisma/client';

export const ALL_KARATS: Karat[] = ['K24', 'K22', 'K21', 'K18'];

export const WIRE_KARAT: Record<Karat, '24K' | '22K' | '21K' | '18K'> = {
  K24: '24K',
  K22: '22K',
  K21: '21K',
  K18: '18K',
};

export type WireKarat = (typeof WIRE_KARAT)[Karat];

/** 24K base; 22/21/18K derived by fineness (FR-SYS-010 AC3). */
export const DEFAULT_PURITY_FACTORS: Record<Karat, number> = {
  K24: 1,
  K22: 22 / 24,
  K21: 21 / 24,
  K18: 18 / 24,
};

export type DerivedRate = {
  purityKarat: Karat;
  ratePerGramAed: number;
};

export class InvalidSpotRateError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'InvalidSpotRateError';
  }
}

/** Round half-up to fils (AED 2 dp). */
export function roundAed(value: number): number {
  return Math.round(value * 100) / 100;
}

/**
 * Derive per-purity AED/g from a 24K spot. Throws if the base is not a
 * positive finite number so a caller cannot persist `0` (FR-SYS-010 AC2).
 */
export function derivePurityRates(
  aedPerGram24k: number,
  factors: Record<Karat, number> = DEFAULT_PURITY_FACTORS,
): DerivedRate[] {
  if (!Number.isFinite(aedPerGram24k) || aedPerGram24k <= 0) {
    throw new InvalidSpotRateError('24K spot must be a positive finite AED/g value');
  }

  const derived: DerivedRate[] = [];
  for (const karat of ALL_KARATS) {
    const factor = factors[karat];
    if (!Number.isFinite(factor) || factor <= 0) {
      throw new InvalidSpotRateError(`Purity factor for ${karat} must be positive`);
    }
    const rate = roundAed(aedPerGram24k * factor);
    if (rate <= 0) {
      throw new InvalidSpotRateError(`Derived ${karat} rate rounded to zero; refusing to persist`);
    }
    derived.push({ purityKarat: karat, ratePerGramAed: rate });
  }
  return derived;
}

export function toWireKarat(karat: Karat): WireKarat {
  return WIRE_KARAT[karat];
}

export function fromWireKarat(value: string): Karat | null {
  switch (value) {
    case '24K':
    case 'K24':
      return 'K24';
    case '22K':
    case 'K22':
      return 'K22';
    case '21K':
    case 'K21':
      return 'K21';
    case '18K':
    case 'K18':
      return 'K18';
    default:
      return null;
  }
}

export function money2(value: { toFixed?: (dp: number) => string } | number | string): string {
  if (typeof value === 'number') return value.toFixed(2);
  if (typeof value === 'string') {
    const n = Number(value);
    if (!Number.isFinite(n)) return value;
    return n.toFixed(2);
  }
  if (value && typeof value.toFixed === 'function') return value.toFixed(2);
  return String(value);
}
