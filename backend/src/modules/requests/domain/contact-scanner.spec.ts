import { describe, expect, it } from 'vitest';
import { scanForContactDetails } from './contact-scanner';

describe('contact-scanner', () => {
  it('returns clean when no contact details are present', () => {
    const res = scanForContactDetails('Looking for an 18K gold ring with modern design, weight around 10 grams.');
    expect(res.hasContactInfo).toBe(false);
    expect(res.warnings).toHaveLength(0);
  });

  it('handles null, undefined, or empty string gracefully', () => {
    expect(scanForContactDetails(null).hasContactInfo).toBe(false);
    expect(scanForContactDetails(undefined).hasContactInfo).toBe(false);
    expect(scanForContactDetails('').hasContactInfo).toBe(false);
    expect(scanForContactDetails('   ').hasContactInfo).toBe(false);
  });

  it('detects email addresses', () => {
    const res = scanForContactDetails('Please email me at buyer@example.com for details');
    expect(res.hasContactInfo).toBe(true);
    expect(res.warnings[0]).toContain('Potential contact details detected');
  });

  it('detects phone numbers with 7+ digits', () => {
    const tests = [
      'Call me at 0501234567',
      'Contact +971 50 123 4567',
      'My number is 04-123-4567',
      'Reach me at (050) 9876543',
    ];

    for (const text of tests) {
      const res = scanForContactDetails(text);
      expect(res.hasContactInfo).toBe(true);
    }
  });

  it('does not flag normal specification numbers like weight or year', () => {
    const cleanTexts = [
      'Budget is 2500 AED, year 2026 design, 18K purity, 22g weight',
      'Looking for 2 pieces of 50 gram bars',
      'Gold coin 10g 24K',
    ];

    for (const text of cleanTexts) {
      const res = scanForContactDetails(text);
      expect(res.hasContactInfo).toBe(false);
    }
  });

  it('detects URLs and website domains', () => {
    expect(scanForContactDetails('Check out https://myjewellery.com').hasContactInfo).toBe(true);
    expect(scanForContactDetails('Visit www.shop.ae').hasContactInfo).toBe(true);
    expect(scanForContactDetails('See example.com/photos').hasContactInfo).toBe(true);
  });

  it('detects WhatsApp and chat handles', () => {
    expect(scanForContactDetails('WhatsApp wa.me/971501234567').hasContactInfo).toBe(true);
    expect(scanForContactDetails('Contact on insta @goldbuyer_dxb').hasContactInfo).toBe(true);
  });
});
