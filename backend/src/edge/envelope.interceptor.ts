import {
  CallHandler,
  ExecutionContext,
  Inject,
  Injectable,
  NestInterceptor,
  Optional,
} from '@nestjs/common';
import { FastifyReply, FastifyRequest } from 'fastify';
import { Observable, map } from 'rxjs';
import { Clock } from '../shared/clock';
import { requestIdOf } from './request-id';

export type SuccessEnvelope<T> = {
  data: T;
  meta: { requestId: string; serverTime: string; nextCursor: string | null };
};

@Injectable()
export class EnvelopeInterceptor implements NestInterceptor {
  constructor(@Optional() @Inject(Clock) private readonly clock: Clock = new Clock()) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp();
    const request = http.getRequest<FastifyRequest>();
    const reply = http.getResponse<FastifyReply>();
    const requestId = requestIdOf(request);
    reply.header('x-request-id', requestId);

    return next.handle().pipe(
      map((data: unknown) => {
        if (isEnvelope(data)) return data;
        const envelope: SuccessEnvelope<unknown> = {
          data: data ?? null,
          meta: {
            requestId,
            serverTime: (this.clock ?? new Clock()).nowIso(),
            nextCursor: null,
          },
        };
        return envelope;
      }),
    );
  }
}

function isEnvelope(value: unknown): boolean {
  if (!value || typeof value !== 'object') return false;
  return 'data' in value && 'meta' in value;
}
