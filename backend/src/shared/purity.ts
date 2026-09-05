import { Karat, type KaratCode } from './karat';

/** Fineness in parts per thousand corresponding to karat (SRS glossary). */
const FINENESS: Record<KaratCode, number> = {
  '24K': 999,
  '22K': 916,
  '21K': 875,
  '18K': 750,
};

export class Purity {
  private constructor(
    readonly karat: Karat,
    readonly fineness: number,
  ) {}

  static fromKarat(karat: Karat): Purity {
    return new Purity(karat, FINENESS[karat.code]);
  }

  static fromKaratCode(code: string): Purity {
    return Purity.fromKarat(Karat.parse(code));
  }

  toString(): string {
    return String(this.fineness);
  }
}
