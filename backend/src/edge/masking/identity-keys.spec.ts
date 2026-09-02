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
});
