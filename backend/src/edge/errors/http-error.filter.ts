import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { FastifyReply, FastifyRequest } from 'fastify';
import { Clock } from '../../shared/clock';
import { viewerOf } from '../auth/viewer-context';
import { requestIdOf } from '../request-id';
import { ErrorCode } from './error-codes';
import { messageFor, resolveLanguage, type UiLanguage } from './error-messages';

type ErrorBody = {
  error: {
    code: ErrorCode;
    message: string;
    details: Array<{ path?: string; code: string; message: string }>;
  };
  meta: { requestId: string; serverTime: string };
};

@Catch()
export class HttpErrorFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpErrorFilter.name);

  constructor(private readonly clock: Clock) {}

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const reply = ctx.getResponse<FastifyReply>();
    const request = ctx.getRequest<FastifyRequest>();
    const requestId = requestIdOf(request);
    const serverTime = this.clock.nowIso();
    const language = resolveLanguage(
      headerString(request.headers['accept-language']),
      viewerOf(request)?.preferredLanguage,
    );

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code: ErrorCode = ErrorCode.INTERNAL;
    let details: ErrorBody['error']['details'] = [];

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const payload = exception.getResponse();
      if (payload && typeof payload === 'object') {
        const body = payload as Record<string, unknown>;
        if (isErrorCode(body['code'])) code = body['code'];
        if (Array.isArray(body['details'])) {
          details = body['details'] as ErrorBody['error']['details'];
        }
      }
      code = codeForStatus(status, code);
    } else {
      this.logger.error(exception);
      if (process.env.NODE_ENV === 'test') {
        console.error('[UNHANDLED-EXCEPTION in HttpErrorFilter]:', exception);
      }
    }

    const body: ErrorBody = {
      error: { code, message: messageFor(code, language), details },
      meta: { requestId, serverTime },
    };
    void reply.status(status).send(body);
  }
}

function headerString(value: string | string[] | undefined): string | undefined {
  if (typeof value === 'string') return value;
  if (Array.isArray(value)) return value[0];
  return undefined;
}

export function isErrorCode(value: unknown): value is ErrorCode {
  return typeof value === 'string' && Object.hasOwn(ErrorCode, value);
}

function codeForStatus(status: number, explicit: ErrorCode): ErrorCode {
  if (explicit !== ErrorCode.INTERNAL) return explicit;
  if (status === 400) return ErrorCode.VALIDATION_FAILED;
  if (status === 401) return ErrorCode.UNAUTHENTICATED;
  if (status === 403) return ErrorCode.FORBIDDEN;
  if (status === 404) return ErrorCode.NOT_FOUND;
  if (status === 409) return ErrorCode.CONFLICT;
  if (status === 423) return ErrorCode.ACCOUNT_LOCKED;
  if (status === 429) return ErrorCode.RATE_LIMITED;
  return ErrorCode.INTERNAL;
}

export type { UiLanguage };
