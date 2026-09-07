import { describe, expect, it } from 'vitest';
import { isWithinQuietHours } from './quiet-hours';

describe('isWithinQuietHours', () => {
  it('treats 22:00–07:00 GST as wrapping midnight', () => {
    // 18:00 UTC = 22:00 GST
    expect(isWithinQuietHours(new Date('2026-04-01T18:00:00Z'), '22:00', '07:00')).toBe(true);
    // 02:30 UTC = 06:30 GST
    expect(isWithinQuietHours(new Date('2026-04-01T02:30:00Z'), '22:00', '07:00')).toBe(true);
    // 03:00 UTC = 07:00 GST (end exclusive)
    expect(isWithinQuietHours(new Date('2026-04-01T03:00:00Z'), '22:00', '07:00')).toBe(false);
    // 12:00 UTC = 16:00 GST
    expect(isWithinQuietHours(new Date('2026-04-01T12:00:00Z'), '22:00', '07:00')).toBe(false);
  });

  it('handles a same-day window', () => {
    // 10:00 UTC = 14:00 GST
    expect(isWithinQuietHours(new Date('2026-04-01T10:00:00Z'), '13:00', '15:00')).toBe(true);
    expect(isWithinQuietHours(new Date('2026-04-01T12:00:00Z'), '13:00', '15:00')).toBe(false);
  });

  it('returns false for invalid or zero-length windows', () => {
    expect(isWithinQuietHours(new Date(), '22:00', '22:00')).toBe(false);
    expect(isWithinQuietHours(new Date(), 'ab:cd', '07:00')).toBe(false);
  });
});
