/** AED amount as a decimal string on the wire (AD-API-05). Stored numeric(12,2). */
export class Money {
  private constructor(readonly aed: string) {}

  static fromDecimalString(value: string): Money {
    if (!/^-?\d+\.\d{2}$/.test(value)) {
      throw new Error(`Invalid money: ${value}`);
    }
    return new Money(value);
  }

  toString(): string {
    return this.aed;
  }
}
