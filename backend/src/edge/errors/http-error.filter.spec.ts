import { describe, expect, it, vi } from 'vitest';
import { ArgumentsHost, HttpException, HttpStatus, Logger } from '@nestjs/common';
import type { FastifyReply, FastifyRequest } from 'fastify';
import { HttpErrorFilter, isErrorCode } from './http-error.filter';
import { ErrorCode } from './error-codes';
import { ApiException } from './api-exception';
import type { Clock } from '../../shared/clock';
import { VIEWER_CONTEXT_KEY, type ViewerContext } from '../auth/viewer-context';

function createMockHost(options?: {
  headers?: Record<string, string | string[] | undefined>;
  viewer?: Partial<ViewerContext>;
}) {
  const statusSpy = vi.fn().mockReturnThis();
  const sendSpy = vi.fn().mockReturnThis();

  const reply = {
    status: statusSpy,
    send: sendSpy,
  } as unknown as FastifyReply;

  const request = {
    headers: options?.headers ?? {},
    ...(options?.viewer ? { [VIEWER_CONTEXT_KEY]: options.viewer as ViewerContext } : {}),
  } as unknown as FastifyRequest;

  const host = {
    switchToHttp: () => ({
      getResponse: () => reply,
      getRequest: () => request,
    }),
  } as unknown as ArgumentsHost;

  return { host, request, reply, statusSpy, sendSpy };
}

const mockClock: Clock = {
  now: () => new Date('2026-09-03T12:00:00.000Z'),
  nowIso: () => '2026-09-03T12:00:00.000Z',
};

describe('HttpErrorFilter', () => {
  describe('isErrorCode', () => {
    it('returns true for valid ErrorCode enum values', () => {
      expect(isErrorCode(ErrorCode.VALIDATION_FAILED)).toBe(true);
      expect(isErrorCode(ErrorCode.UNAUTHENTICATED)).toBe(true);
      expect(isErrorCode(ErrorCode.FORBIDDEN)).toBe(true);
      expect(isErrorCode(ErrorCode.NOT_FOUND)).toBe(true);
      expect(isErrorCode(ErrorCode.CONFLICT)).toBe(true);
      expect(isErrorCode(ErrorCode.RATE_LIMITED)).toBe(true);
      expect(isErrorCode(ErrorCode.INTERNAL)).toBe(true);
      expect(isErrorCode(ErrorCode.ACCOUNT_SUSPENDED)).toBe(true);
      expect(isErrorCode(ErrorCode.ACCOUNT_LOCKED)).toBe(true);
      expect(isErrorCode(ErrorCode.OTP_INVALID)).toBe(true);
      expect(isErrorCode(ErrorCode.MEDIA_NOT_READY)).toBe(true);
    });

    it('returns false for prototype property names', () => {
      expect(isErrorCode('toString')).toBe(false);
      expect(isErrorCode('valueOf')).toBe(false);
      expect(isErrorCode('constructor')).toBe(false);
      expect(isErrorCode('__proto__')).toBe(false);
      expect(isErrorCode('hasOwnProperty')).toBe(false);
      expect(isErrorCode('isPrototypeOf')).toBe(false);
      expect(isErrorCode('propertyIsEnumerable')).toBe(false);
      expect(isErrorCode('toLocaleString')).toBe(false);
    });

    it('returns false for non-string or unknown values', () => {
      expect(isErrorCode(null)).toBe(false);
      expect(isErrorCode(undefined)).toBe(false);
      expect(isErrorCode(123)).toBe(false);
      expect(isErrorCode(true)).toBe(false);
      expect(isErrorCode({})).toBe(false);
      expect(isErrorCode([])).toBe(false);
      expect(isErrorCode(Symbol('ERR'))).toBe(false);
      expect(isErrorCode('')).toBe(false);
      expect(isErrorCode('UNKNOWN_ERROR_CODE')).toBe(false);
    });
  });

  describe('catch - prototype property leakage handling', () => {
    const filter = new HttpErrorFilter(mockClock);

    it.each([
      { code: 'toString', status: HttpStatus.BAD_REQUEST, expectedCode: ErrorCode.VALIDATION_FAILED },
      { code: 'valueOf', status: HttpStatus.UNAUTHORIZED, expectedCode: ErrorCode.UNAUTHENTICATED },
      { code: 'constructor', status: HttpStatus.FORBIDDEN, expectedCode: ErrorCode.FORBIDDEN },
      { code: '__proto__', status: HttpStatus.NOT_FOUND, expectedCode: ErrorCode.NOT_FOUND },
      { code: 'hasOwnProperty', status: HttpStatus.CONFLICT, expectedCode: ErrorCode.CONFLICT },
      { code: 'isPrototypeOf', status: 423, expectedCode: ErrorCode.ACCOUNT_LOCKED },
      { code: 'propertyIsEnumerable', status: HttpStatus.TOO_MANY_REQUESTS, expectedCode: ErrorCode.RATE_LIMITED },
      { code: 'toLocaleString', status: HttpStatus.BAD_GATEWAY, expectedCode: ErrorCode.INTERNAL },
    ])(
      'handles code: "$code" at status $status without throwing and falls back to $expectedCode',
      ({ code, status, expectedCode }) => {
        const { host, statusSpy, sendSpy } = createMockHost();
        const exception = new HttpException({ code }, status);

        expect(() => filter.catch(exception, host)).not.toThrow();
        expect(statusSpy).toHaveBeenCalledWith(status);
        expect(sendSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            error: expect.objectContaining({
              code: expectedCode,
              message: expect.any(String),
            }),
          }),
        );
      },
    );
  });

  describe('catch - valid ErrorCode formatting and localization', () => {
    const filter = new HttpErrorFilter(mockClock);

    it('formats structured JSON envelope with valid ErrorCode and English message by default', () => {
      const { host, statusSpy, sendSpy } = createMockHost({
        headers: { 'x-request-id': 'req-test-123' },
      });
      const exception = new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_SUSPENDED);

      filter.catch(exception, host);

      expect(statusSpy).toHaveBeenCalledWith(HttpStatus.FORBIDDEN);
      expect(sendSpy).toHaveBeenCalledWith({
        error: {
          code: ErrorCode.ACCOUNT_SUSPENDED,
          message: 'This account is suspended. Contact support.',
          details: [],
        },
        meta: {
          requestId: 'req-test-123',
          serverTime: '2026-09-03T12:00:00.000Z',
        },
      });
    });

    it('formats Arabic message when accept-language header specifies Arabic', () => {
      const { host, sendSpy } = createMockHost({
        headers: {
          'accept-language': 'ar-AE,ar;q=0.9',
          'x-request-id': 'req-ar-456',
        },
      });
      const exception = new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);

      filter.catch(exception, host);

      expect(sendSpy).toHaveBeenCalledWith({
        error: {
          code: ErrorCode.UNAUTHENTICATED,
          message: 'يرجى تسجيل الدخول للمتابعة.',
          details: [],
        },
        meta: {
          requestId: 'req-ar-456',
          serverTime: '2026-09-03T12:00:00.000Z',
        },
      });
    });

    it('prefers viewer preferredLanguage over accept-language header', () => {
      const { host, sendSpy } = createMockHost({
        headers: {
          'accept-language': 'en-US,en;q=0.9',
          'x-request-id': 'req-lang-pref',
        },
        viewer: { preferredLanguage: 'ar' },
      });
      const exception = new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.OTP_INVALID);

      filter.catch(exception, host);

      expect(sendSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          error: expect.objectContaining({
            code: ErrorCode.OTP_INVALID,
            message: 'الرمز غير صحيح. تحقق منه وحاول مرة أخرى.',
          }),
        }),
      );
    });

    it('preserves error details array from exception payload', () => {
      const { host, sendSpy } = createMockHost({
        headers: { 'x-request-id': 'req-details' },
      });
      const details = [
        { path: 'phone', code: 'invalid_phone', message: 'Must be UAE mobile' },
        { path: 'email', code: 'invalid_email', message: 'Must be valid email' },
      ];
      const exception = new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.VALIDATION_FAILED, details);

      filter.catch(exception, host);

      expect(sendSpy).toHaveBeenCalledWith({
        error: {
          code: ErrorCode.VALIDATION_FAILED,
          message: 'Please check the highlighted fields and try again.',
          details,
        },
        meta: {
          requestId: 'req-details',
          serverTime: '2026-09-03T12:00:00.000Z',
        },
      });
    });

    it('generates a requestId when x-request-id header is missing', () => {
      const { host, sendSpy } = createMockHost();
      const exception = new HttpException('Not Found', HttpStatus.NOT_FOUND);

      filter.catch(exception, host);

      expect(sendSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          error: expect.objectContaining({
            code: ErrorCode.NOT_FOUND,
          }),
          meta: expect.objectContaining({
            requestId: expect.any(String),
            serverTime: '2026-09-03T12:00:00.000Z',
          }),
        }),
      );
    });
  });

  describe('catch - non-HttpException handling', () => {
    const filter = new HttpErrorFilter(mockClock);

    it('handles generic Error by returning 500 INTERNAL with localized message', () => {
      const loggerSpy = vi.spyOn(Logger.prototype, 'error').mockImplementation(() => {});
      const { host, statusSpy, sendSpy } = createMockHost({
        headers: { 'x-request-id': 'req-500' },
      });
      const genericError = new Error('Database connection pool exhausted');

      expect(() => filter.catch(genericError, host)).not.toThrow();

      expect(loggerSpy).toHaveBeenCalledWith(genericError);
      expect(statusSpy).toHaveBeenCalledWith(HttpStatus.INTERNAL_SERVER_ERROR);
      expect(sendSpy).toHaveBeenCalledWith({
        error: {
          code: ErrorCode.INTERNAL,
          message: 'Something went wrong. Please try again.',
          details: [],
        },
        meta: {
          requestId: 'req-500',
          serverTime: '2026-09-03T12:00:00.000Z',
        },
      });
      loggerSpy.mockRestore();
    });

    it('handles string payload in HttpException cleanly', () => {
      const { host, statusSpy, sendSpy } = createMockHost();
      const exception = new HttpException('Simple error string', HttpStatus.BAD_REQUEST);

      filter.catch(exception, host);

      expect(statusSpy).toHaveBeenCalledWith(HttpStatus.BAD_REQUEST);
      expect(sendSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          error: expect.objectContaining({
            code: ErrorCode.VALIDATION_FAILED,
            details: [],
          }),
        }),
      );
    });

    it('handles accept-language passed as an array of strings', () => {
      const { host, sendSpy } = createMockHost({
        headers: {
          'accept-language': ['ar-SA', 'en'],
        },
      });
      const exception = new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

      filter.catch(exception, host);

      expect(sendSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          error: expect.objectContaining({
            code: ErrorCode.NOT_FOUND,
            message: 'تعذر العثور على العنصر المطلوب.',
          }),
        }),
      );
    });
  });
});
