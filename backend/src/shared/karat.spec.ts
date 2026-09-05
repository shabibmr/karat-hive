import { describe, expect, it } from 'vitest';
import { Karat } from './karat';
import { Purity } from './purity';

describe('Karat and Purity', () => {
  it('maps karat codes to fineness', () => {
    expect(Purity.fromKarat(Karat.parse('24K')).fineness).toBe(999);
    expect(Purity.fromKaratCode('22K').fineness).toBe(916);
    expect(Purity.fromKaratCode('21K').fineness).toBe(875);
    expect(Purity.fromKaratCode('18K').fineness).toBe(750);
  });

  it('rejects unknown karat', () => {
    expect(() => Karat.parse('16K')).toThrow(/Invalid karat/);
  });
});
