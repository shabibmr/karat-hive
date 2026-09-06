import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { z } from 'zod';

/** Well-known placeholder — refused in every environment (Architecture §18). */
export const BANNED_JWT_SECRET = 'dev-only-access-secret-change';

const roleSchema = z.enum(['api', 'worker', 'all']);

/** Treats an empty env value (`FOO=`) as unset. */
const optionalString = z.preprocess(
  (v) => (typeof v === 'string' && v.trim() === '' ? undefined : v),
  z.string().min(1).optional(),
);

const envSchema = z
  .object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    /** Architecture §6 / AD-BE-07. `APP_ROLE` is a one-release alias. */
    KH_ROLE: roleSchema.default('api'),
    PORT: z.coerce.number().int().positive().default(3000),
    DATABASE_URL: z.string().min(1),
    JWT_ACCESS_SECRET: z.string().min(16),
    JWT_ACCESS_TTL_SECONDS: z.coerce.number().int().positive().default(900),
    JWT_REFRESH_TTL_DAYS: z.coerce.number().int().positive().default(14),
    INSTANCE_ID: z.string().min(1).optional(),
    FIREBASE_PROJECT_ID: z.string().default('karat-hive-app'),

    // --- OTP (vendor onboarding vertical) ---
    OTP_DEV_MODE: z.enum(['console', 'fixed']).default('console'),
    OTP_FIXED_CODE: z
      .string()
      .regex(/^\d{6}$/)
      .default('000000'),
    OTP_TTL_SECONDS: z.coerce.number().int().positive().default(300),
    OTP_MAX_PER_NUMBER_PER_HOUR: z.coerce.number().int().positive().default(5),

    // --- password login lockout (FR-VEN-003) ---
    LOGIN_MAX_FAILURES: z.coerce.number().int().positive().default(5),
    LOGIN_LOCK_MINUTES: z.coerce.number().int().positive().default(15),
    PASSWORD_MIN_LENGTH: z.coerce.number().int().positive().default(10),

    // --- Supabase Storage (KYC documents) ---
    SUPABASE_URL: optionalString,
    SUPABASE_SERVICE_ROLE_KEY: optionalString,
    SUPABASE_STORAGE_BUCKET_KYC: z.string().min(1).default('kyc'),
    SIGNED_UPLOAD_TTL_SECONDS: z.coerce.number().int().positive().default(900),

    // --- dev-only vendor verification shortcut ---
    DEV_VERIFY_ENABLED: z
      .enum(['true', 'false'])
      .default('false')
      .transform((v) => v === 'true'),
    DEV_VERIFY_KEY: optionalString,
  })
  .superRefine((value, ctx) => {
    if (value.JWT_ACCESS_SECRET === BANNED_JWT_SECRET) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['JWT_ACCESS_SECRET'],
        message: 'JWT_ACCESS_SECRET is missing or using a banned default. Set a real secret.',
      });
    }
    if (value.DEV_VERIFY_ENABLED && value.NODE_ENV === 'production') {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['DEV_VERIFY_ENABLED'],
        message: 'DEV_VERIFY_ENABLED must never be true in production.',
      });
    }
    if (value.DEV_VERIFY_ENABLED && !value.DEV_VERIFY_KEY) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['DEV_VERIFY_KEY'],
        message: 'DEV_VERIFY_KEY is required when DEV_VERIFY_ENABLED is true.',
      });
    }
    if (
      value.NODE_ENV === 'production' &&
      (!value.SUPABASE_URL || !value.SUPABASE_SERVICE_ROLE_KEY)
    ) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['SUPABASE_URL'],
        message: 'SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are required in production.',
      });
    }
  });

export type Env = z.infer<typeof envSchema>;
export type AppRole = z.infer<typeof roleSchema>;

export const ENV = Symbol('ENV');

/** Load `backend/.env` into process.env without adding a dotenv dependency. */
export function loadDotenvFile(cwd: string = process.cwd()): void {
  const filePath = resolve(cwd, '.env');
  if (!existsSync(filePath)) return;
  for (const raw of readFileSync(filePath, 'utf8').split(/\r?\n/)) {
    const line = raw.trim();
    if (line.length === 0 || line.startsWith('#')) continue;
    const eq = line.indexOf('=');
    if (eq <= 0) continue;
    const key = line.slice(0, eq).trim();
    let value = line.slice(eq + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (process.env[key] === undefined) process.env[key] = value;
  }
}

export function loadEnv(source: NodeJS.ProcessEnv = process.env): Env {
  const parsed = envSchema.safeParse({
    ...source,
    KH_ROLE: source.KH_ROLE ?? source.APP_ROLE,
  });
  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((issue) => `  ${issue.path.join('.')}: ${issue.message}`)
      .join('\n');
    throw new Error(`Invalid environment:\n${issues}`);
  }
  return parsed.data;
}
