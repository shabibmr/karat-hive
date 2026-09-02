import { describe, expect, it } from 'vitest';
import { BANNED_JWT_SECRET, loadEnv } from './env';

const BASE = {
  DATABASE_URL: 'postgresql://karat:karat@localhost:5432/karat_hive',
  JWT_ACCESS_SECRET: 'unit-test-access-secret',
};

describe('loadEnv', () => {
  it('refuses a missing JWT_ACCESS_SECRET', () => {
    expect(() => loadEnv({ DATABASE_URL: BASE.DATABASE_URL })).toThrow(/JWT_ACCESS_SECRET/);
  });

  it('refuses the banned default secret in every NODE_ENV', () => {
    expect(() =>
      loadEnv({
        ...BASE,
        NODE_ENV: 'development',
        JWT_ACCESS_SECRET: BANNED_JWT_SECRET,
      }),
    ).toThrow(/banned default/);
  });

  it('prefers KH_ROLE over APP_ROLE', () => {
    const env = loadEnv({
      ...BASE,
      KH_ROLE: 'worker',
      APP_ROLE: 'api',
    });
    expect(env.KH_ROLE).toBe('worker');
  });

  it('accepts APP_ROLE as a one-release alias', () => {
    const env = loadEnv({
      ...BASE,
      APP_ROLE: 'all',
    });
    expect(env.KH_ROLE).toBe('all');
  });
});
