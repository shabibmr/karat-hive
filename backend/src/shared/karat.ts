/** Wire karat (`AD-API` / SRS `FR-ADM-030`). Matches Prisma `Karat` enum maps. */
export const KARAT_VALUES = ['24K', '22K', '21K', '18K'] as const;

export type KaratCode = (typeof KARAT_VALUES)[number];

export class Karat {
  private constructor(readonly code: KaratCode) {}

  static parse(value: string): Karat {
    if (!KARAT_VALUES.includes(value as KaratCode)) {
      throw new Error(`Invalid karat: ${value}`);
    }
    return new Karat(value as KaratCode);
  }

  toString(): string {
    return this.code;
  }
}
