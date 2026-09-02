import { createHash } from 'node:crypto';

export const IDEMPOTENCY_TTL_MS = 24 * 60 * 60 * 1000;
export const IDEMPOTENCY_IN_FLIGHT = 0;

const REQUIRED_PATTERNS: RegExp[] = [
  /^\/v1\/requests\/[^/]+\/publish$/,
  /^\/v1\/requests\/[^/]+\/offers$/,
  /^\/v1\/offers\/[^/]+\/accept$/,
  /^\/v1\/media\/upload-intent$/,
];

export function normalizeRoute(method: string, url: string): string {
  const path = url.split('?')[0] ?? url;
  return `${method.toUpperCase()} ${path}`;
}

export function isIdempotencyRequired(method: string, url: string): boolean {
  if (!['POST', 'PATCH', 'PUT', 'DELETE'].includes(method.toUpperCase())) return false;
  const path = url.split('?')[0] ?? url;
  return REQUIRED_PATTERNS.some((re) => re.test(path));
}

export function isMutating(method: string): boolean {
  return ['POST', 'PATCH', 'PUT', 'DELETE'].includes(method.toUpperCase());
}

export function hashBody(body: unknown): string {
  const canonical = body === undefined || body === null ? '' : stableStringify(body);
  return createHash('sha256').update(canonical).digest('hex');
}

function stableStringify(value: unknown): string {
  if (value === null || typeof value !== 'object') return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(stableStringify).join(',')}]`;
  const obj = value as Record<string, unknown>;
  const keys = Object.keys(obj).sort();
  return `{${keys.map((k) => `${JSON.stringify(k)}:${stableStringify(obj[k])}`).join(',')}}`;
}

export function isReplayFresh(createdAt: Date, now: Date, ttlMs = IDEMPOTENCY_TTL_MS): boolean {
  return now.getTime() - createdAt.getTime() < ttlMs;
}
