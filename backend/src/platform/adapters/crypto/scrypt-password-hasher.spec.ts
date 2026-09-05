import { describe, expect, it } from 'vitest';
import { ScryptPasswordHasher } from './scrypt-password-hasher';

describe('ScryptPasswordHasher', () => {
  const hasher = new ScryptPasswordHasher();

  it('hashes and verifies a valid password', async () => {
    const password = 'SuperSecurePassword123!';
    const hash = await hasher.hash(password);

    expect(hash).toMatch(/^scrypt\$/);
    const isValid = await hasher.verify(password, hash);
    expect(isValid).toBe(true);
  });

  it('rejects an incorrect password', async () => {
    const password = 'SuperSecurePassword123!';
    const hash = await hasher.hash(password);

    const isValid = await hasher.verify('WrongPassword', hash);
    expect(isValid).toBe(false);
  });

  it('rejects an invalid hash format', async () => {
    expect(await hasher.verify('password', 'invalid-hash-string')).toBe(false);
    expect(await hasher.verify('password', 'bcrypt$123$456')).toBe(false);
  });
});
