/** Own-records CSV for FR-VEN-023 AC3. Never includes competing Vendor identity or prices (BR-008). */

export type VendorPerformanceCsvRow = {
  offerId: string;
  requestReference: string;
  requestType: string;
  categoryNameEn: string;
  regionNameEn: string;
  state: string;
  offeredPriceAed: string;
  submittedAt: string;
  expiresAt: string;
  decidedAt: string;
  declineReason: string;
  responseMinutes: string;
};

const HEADER = [
  'offerId',
  'requestReference',
  'requestType',
  'category',
  'region',
  'state',
  'offeredPriceAed',
  'submittedAt',
  'expiresAt',
  'decidedAt',
  'declineReason',
  'responseMinutes',
] as const;

export function buildVendorPerformanceCsv(rows: VendorPerformanceCsvRow[]): string {
  const lines = [HEADER.join(',')];
  for (const row of rows) {
    lines.push(
      [
        csvCell(row.offerId),
        csvCell(row.requestReference),
        csvCell(row.requestType),
        csvCell(row.categoryNameEn),
        csvCell(row.regionNameEn),
        csvCell(row.state),
        csvCell(row.offeredPriceAed),
        csvCell(row.submittedAt),
        csvCell(row.expiresAt),
        csvCell(row.decidedAt),
        csvCell(row.declineReason),
        csvCell(row.responseMinutes),
      ].join(','),
    );
  }
  return `${lines.join('\n')}\n`;
}

function csvCell(value: string): string {
  if (/[",\n\r]/.test(value)) {
    return `"${value.replace(/"/g, '""')}"`;
  }
  return value;
}
