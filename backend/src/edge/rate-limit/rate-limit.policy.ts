export type TokenBucketConfig = {
  capacity: number;
  refillPerMinute: number;
};

export const RATE_LIMIT_SCOPES: Record<string, TokenBucketConfig> = {
  default_mutating: { capacity: 60, refillPerMinute: 60 },
  auth: { capacity: 20, refillPerMinute: 10 },
  otp: { capacity: 5, refillPerMinute: 5 },
  search: { capacity: 30, refillPerMinute: 30 },
};

export function scopeFor(method: string, url: string): string | null {
  const path = url.split('?')[0] ?? url;
  if (path === '/health' || path === '/ready') return null;
  if (path.startsWith('/v1/auth/otp')) return 'otp';
  if (path.startsWith('/v1/auth/')) return 'auth';
  if (path.includes('/search') || path.endsWith('/matches')) return 'search';
  if (['POST', 'PATCH', 'PUT', 'DELETE'].includes(method.toUpperCase())) return 'default_mutating';
  return null;
}

export function refillBucket(args: {
  tokens: number;
  windowStart: Date;
  now: Date;
  config: TokenBucketConfig;
}): { tokens: number; windowStart: Date; allowed: boolean; remaining: number } {
  const elapsedMin = Math.max(0, (args.now.getTime() - args.windowStart.getTime()) / 60_000);
  const refilled = Math.min(
    args.config.capacity,
    args.tokens + elapsedMin * args.config.refillPerMinute,
  );
  const allowed = refilled >= 1;
  const tokens = allowed ? refilled - 1 : refilled;
  return {
    tokens,
    windowStart: args.now,
    allowed,
    remaining: Math.floor(tokens),
  };
}
