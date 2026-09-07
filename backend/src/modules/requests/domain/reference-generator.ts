import { randomInt } from 'node:crypto';

/**
 * Human-readable reference assigned on publish (FR-CUS-014 AC5, SRS §6.2).
 * Format: KH-RQ-YYYY-NNNNNN (e.g. KH-RQ-2026-004821). Fits inside varchar(24).
 */
export function generateRequestReference(year: number = new Date().getUTCFullYear()): string {
  const sequence = randomInt(0, 1_000_000).toString().padStart(6, '0');
  return `KH-RQ-${year}-${sequence}`;
}
