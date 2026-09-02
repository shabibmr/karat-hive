/** Grams as a decimal string on the wire. Stored numeric(10,2). */
export class Weight {
  private constructor(readonly grams: string) {}

  static fromDecimalString(value: string): Weight {
    if (!/^\d+\.\d{2}$/.test(value)) {
      throw new Error(`Invalid weight: ${value}`);
    }
    return new Weight(value);
  }

  toString(): string {
    return this.grams;
  }
}
