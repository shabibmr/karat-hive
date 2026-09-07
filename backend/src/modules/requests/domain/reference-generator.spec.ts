import { describe, expect, it } from 'vitest';
import { generateRequestReference } from './reference-generator';

describe('reference-generator', () => {
  it('generates references matching the required format KH-RQ-YYYY-NNNNNN', () => {
    const ref = generateRequestReference(2026);
    expect(ref).toMatch(/^KH-RQ-2026-\d{6}$/);
  });

  it('uses current year when year is not provided', () => {
    const currentYear = new Date().getUTCFullYear();
    const ref = generateRequestReference();
    expect(ref).toContain(`KH-RQ-${currentYear}-`);
  });

  it('generates unique sequences across calls', () => {
    const refs = new Set<string>();
    for (let i = 0; i < 50; i++) {
      refs.add(generateRequestReference());
    }
    // High probability of distinct random numbers
    expect(refs.size).toBeGreaterThan(45);
  });
});
