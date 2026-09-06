import { describe, expect, it } from 'vitest';
import { findIdentityKey } from './identity-keys';

describe('findIdentityKey', () => {
  it('ignores health payloads and meta', () => {
    expect(findIdentityKey({ status: 'ok' })).toBeNull();
    expect(
      findIdentityKey({ data: { status: 'ok' }, meta: { requestId: 'x', serverTime: 't' } }),
    ).toBeNull();
  });

  it('finds a leaked mobileNumber under data', () => {
    expect(
      findIdentityKey({
        data: { vendor: { label: 'Verified · Deira', mobileNumber: '+971501234567' } },
        meta: { requestId: 'x' },
      }),
    ).toBe('mobileNumber');
  });

  it('does not treat generic name as identity', () => {
    expect(findIdentityKey({ data: { name: 'Gold coin' } })).toBeNull();
  });

  it('detects customerProfileId and vendorProfileId as identity keys', () => {
    expect(findIdentityKey({ customerProfileId: 'cust-123' })).toBe('customerProfileId');
    expect(findIdentityKey({ data: { vendorProfileId: 'vend-123' } })).toBe('vendorProfileId');
    expect(findIdentityKey({ customerId: 'cust-456' })).toBe('customerId');
    expect(findIdentityKey({ customerName: 'Sara Ali' })).toBe('customerName');
    expect(findIdentityKey({ customerEmail: 'sara@example.com' })).toBe('customerEmail');
  });

  it('detects competitor leak keys under findCompetitorLeak and findCompetitorKey', () => {
    expect(findIdentityKey({ competitorPrice: '100' })).toBe('competitorPrice');
    expect(findIdentityKey({ winningPrice: '200' })).toBe('winningPrice');
  });
});

