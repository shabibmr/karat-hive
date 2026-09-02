import { randomBytes, scrypt, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import { Injectable } from '@nestjs/common';
import type { PasswordHasher } from '../../ports/password-hasher.port';

const scryptAsync = promisify(scrypt);
const KEYLEN = 64;
const SCHEME = 'scrypt';

@Injectable()
export class ScryptPasswordHasher implements PasswordHasher {
  async hash(plain: string): Promise<string> {
    const salt = randomBytes(16);
    const derived = (await scryptAsync(plain, salt, KEYLEN)) as Buffer;
    return `${SCHEME}$${salt.toString('base64')}$${derived.toString('base64')}`;
  }

  async verify(plain: string, stored: string): Promise<boolean> {
    const [scheme, saltB64, hashB64] = stored.split('$');
    if (scheme !== SCHEME || !saltB64 || !hashB64) return false;
    const salt = Buffer.from(saltB64, 'base64');
    const expected = Buffer.from(hashB64, 'base64');
    const derived = (await scryptAsync(plain, salt, expected.length)) as Buffer;
    return derived.length === expected.length && timingSafeEqual(derived, expected);
  }
}
