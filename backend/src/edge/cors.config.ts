export const ALLOWED_ORIGIN_PATTERNS: RegExp[] = [
  /^https?:\/\/localhost(:\d+)?$/,
  /^https?:\/\/127\.0\.0\.1(:\d+)?$/,
  // Local network / LAN private IP ranges for physical device & emulator web testing:
  // - 10.0.0.0/8
  // - 172.16.0.0/12
  // - 192.168.0.0/16
  /^https?:\/\/(10(\.\d{1,3}){3}|172\.(1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3})(:\d+)?$/,
  // Production / staging domains and subdomains:
  /^https:\/\/([a-z0-9-]+\.)?algoray\.cloud$/,
];

export const ALLOWED_METHODS = [
  'GET',
  'HEAD',
  'POST',
  'PUT',
  'PATCH',
  'DELETE',
  'OPTIONS',
];

export const ALLOWED_HEADERS = [
  'Content-Type',
  'Authorization',
  'Accept',
  'Accept-Language',
  'X-Request-Id',
  'Idempotency-Key',
];

export const EXPOSED_HEADERS = [
  'X-Request-Id',
  'X-RateLimit-Limit',
  'X-RateLimit-Remaining',
  'X-RateLimit-Reset',
];

export function isOriginAllowed(origin: string): boolean {
  return ALLOWED_ORIGIN_PATTERNS.some((pattern) => pattern.test(origin));
}

export const corsConfig = {
  origin: ALLOWED_ORIGIN_PATTERNS,
  methods: ALLOWED_METHODS,
  allowedHeaders: ALLOWED_HEADERS,
  exposedHeaders: EXPOSED_HEADERS,
  credentials: false,
  maxAge: 86_400,
};
