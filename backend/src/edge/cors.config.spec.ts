import { describe, expect, it } from 'vitest';
import {
  ALLOWED_HEADERS,
  ALLOWED_METHODS,
  EXPOSED_HEADERS,
  corsConfig,
  isOriginAllowed,
} from './cors.config';

describe('CORS Configuration', () => {
  describe('Origin Allowlist', () => {
    it('allows localhost on any port (http and https)', () => {
      expect(isOriginAllowed('http://localhost')).toBe(true);
      expect(isOriginAllowed('http://localhost:3000')).toBe(true);
      expect(isOriginAllowed('http://localhost:5000')).toBe(true);
      expect(isOriginAllowed('http://localhost:8082')).toBe(true);
      expect(isOriginAllowed('https://localhost:443')).toBe(true);
    });

    it('allows 127.0.0.1 on any port (http and https)', () => {
      expect(isOriginAllowed('http://127.0.0.1')).toBe(true);
      expect(isOriginAllowed('http://127.0.0.1:3000')).toBe(true);
      expect(isOriginAllowed('http://127.0.0.1:5000')).toBe(true);
      expect(isOriginAllowed('http://127.0.0.1:8082')).toBe(true);
      expect(isOriginAllowed('https://127.0.0.1:8443')).toBe(true);
    });

    it('allows private LAN IP addresses for physical device and emulator web testing', () => {
      expect(isOriginAllowed('http://192.168.1.100')).toBe(true);
      expect(isOriginAllowed('http://192.168.0.25:5000')).toBe(true);
      expect(isOriginAllowed('http://10.0.2.2:3000')).toBe(true);
      expect(isOriginAllowed('http://172.20.10.2:8082')).toBe(true);
    });

    it('allows production and staging algoray.cloud domains over HTTPS', () => {
      expect(isOriginAllowed('https://algoray.cloud')).toBe(true);
      expect(isOriginAllowed('https://admin.algoray.cloud')).toBe(true);
      expect(isOriginAllowed('https://dev.algoray.cloud')).toBe(true);
      expect(isOriginAllowed('https://staging.algoray.cloud')).toBe(true);
    });

    it('rejects unauthorized or attacker origins', () => {
      expect(isOriginAllowed('https://evil.com')).toBe(false);
      expect(isOriginAllowed('https://fake-algoray.cloud')).toBe(false);
      expect(isOriginAllowed('http://algoray.cloud')).toBe(false); // HTTP rejected for production
      expect(isOriginAllowed('https://algoray.cloud.attacker.com')).toBe(false);
    });
  });

  describe('Methods and Headers', () => {
    it('includes all necessary HTTP methods for admin and client operations', () => {
      expect(ALLOWED_METHODS).toContain('GET');
      expect(ALLOWED_METHODS).toContain('HEAD');
      expect(ALLOWED_METHODS).toContain('POST');
      expect(ALLOWED_METHODS).toContain('PUT');
      expect(ALLOWED_METHODS).toContain('PATCH');
      expect(ALLOWED_METHODS).toContain('DELETE');
      expect(ALLOWED_METHODS).toContain('OPTIONS');
    });

    it('includes Accept-Language alongside custom and auth headers', () => {
      expect(ALLOWED_HEADERS).toContain('Content-Type');
      expect(ALLOWED_HEADERS).toContain('Authorization');
      expect(ALLOWED_HEADERS).toContain('Accept');
      expect(ALLOWED_HEADERS).toContain('Accept-Language');
      expect(ALLOWED_HEADERS).toContain('X-Request-Id');
      expect(ALLOWED_HEADERS).toContain('Idempotency-Key');
    });

    it('exposes trace ID and rate limit headers to client JavaScript', () => {
      expect(EXPOSED_HEADERS).toContain('X-Request-Id');
      expect(EXPOSED_HEADERS).toContain('X-RateLimit-Limit');
      expect(EXPOSED_HEADERS).toContain('X-RateLimit-Remaining');
      expect(EXPOSED_HEADERS).toContain('X-RateLimit-Reset');
    });

    it('maintains stateless configuration with credentials false', () => {
      expect(corsConfig.credentials).toBe(false);
    });
  });
});
