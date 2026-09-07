import { describe, expect, it } from 'vitest';
import { buildVendorPerformanceCsv } from './vendor-performance-csv';

describe('buildVendorPerformanceCsv', () => {
  it('emits header-only CSV when there are no rows (empty-safe)', () => {
    const csv = buildVendorPerformanceCsv([]);
    expect(csv).toBe(
      'offerId,requestReference,requestType,category,region,state,offeredPriceAed,submittedAt,expiresAt,decidedAt,declineReason,responseMinutes\n',
    );
  });

  it('escapes commas and quotes in cell values', () => {
    const csv = buildVendorPerformanceCsv([
      {
        offerId: 'off-1',
        requestReference: 'KH-2026-001',
        requestType: 'FIND_ORNAMENT',
        categoryNameEn: 'Rings, Gold',
        regionNameEn: 'Deira',
        state: 'REJECTED',
        offeredPriceAed: '1200.00',
        submittedAt: '2026-09-01T00:00:00.000Z',
        expiresAt: '2026-09-02T00:00:00.000Z',
        decidedAt: '2026-09-01T12:00:00.000Z',
        declineReason: 'Said "too high"',
        responseMinutes: '45',
      },
    ]);
    expect(csv).toContain('"Rings, Gold"');
    expect(csv).toContain('"Said ""too high"""');
    expect(csv).toContain('off-1,KH-2026-001,FIND_ORNAMENT');
  });
});
