import {
  CallHandler,
  ExecutionContext,
  HttpStatus,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { FastifyReply, FastifyRequest } from 'fastify';
import { lastValueFrom, Observable, of } from 'rxjs';
import { PrismaService } from '../../platform/db/prisma.service';
import { Clock } from '../../shared/clock';
import { viewerOf } from '../auth/auth.guard';
import { clientIpOf } from '../client-ip';
import { ApiException } from '../errors/api-exception';
import { ErrorCode } from '../errors/error-codes';
import {
  hashBody,
  IDEMPOTENCY_IN_FLIGHT,
  isIdempotencyRequired,
  isMutating,
  isReplayFresh,
  normalizeRoute,
} from './idempotency.policy';

const HEADER = 'idempotency-key';

@Injectable()
export class IdempotencyInterceptor implements NestInterceptor {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
  ) {}

  async intercept(context: ExecutionContext, next: CallHandler): Promise<Observable<unknown>> {
    const http = context.switchToHttp();
    const request = http.getRequest<FastifyRequest>();
    const reply = http.getResponse<FastifyReply>();
    const method = request.method;
    const url = request.url;

    if (!isMutating(method)) return next.handle();

    const keyHeader = request.headers[HEADER];
    const key = typeof keyHeader === 'string' ? keyHeader.trim() : '';
    if (isIdempotencyRequired(method, url) && key.length === 0) {
      throw new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.IDEMPOTENCY_KEY_REQUIRED);
    }
    if (key.length === 0) return next.handle();

    const viewer = viewerOf(request);
    const callerSubject = viewer?.userId ?? clientIpOf(request);
    const route = normalizeRoute(method, url);
    const bodyHash = hashBody(request.body);
    const unique = { key_route_callerSubject: { key, route, callerSubject } };

    const claimed = await this.claimOrReplay({
      unique,
      key,
      route,
      callerSubject,
      callerUserId: viewer?.userId ?? null,
      bodyHash,
      reply,
    });
    if (claimed.kind === 'replay') {
      return of(claimed.body);
    }

    try {
      const responseBody = await lastValueFrom(next.handle());
      await this.prisma.idempotencyKey.update({
        where: unique,
        data: { statusCode: reply.statusCode, responseBody: responseBody as object },
      });
      return of(responseBody);
    } catch (error: unknown) {
      await this.prisma.idempotencyKey.deleteMany({
        where: { key, route, callerSubject, statusCode: IDEMPOTENCY_IN_FLIGHT },
      });
      throw error;
    }
  }

  private async claimOrReplay(args: {
    unique: { key_route_callerSubject: { key: string; route: string; callerSubject: string } };
    key: string;
    route: string;
    callerSubject: string;
    callerUserId: string | null;
    bodyHash: string;
    reply: FastifyReply;
  }): Promise<{ kind: 'claimed' } | { kind: 'replay'; body: unknown }> {
    try {
      await this.prisma.idempotencyKey.create({
        data: {
          key: args.key,
          route: args.route,
          callerSubject: args.callerSubject,
          callerUserId: args.callerUserId,
          bodyHash: args.bodyHash,
          statusCode: IDEMPOTENCY_IN_FLIGHT,
          responseBody: {},
        },
      });
      return { kind: 'claimed' };
    } catch (error: unknown) {
      if (!(error instanceof Prisma.PrismaClientKnownRequestError) || error.code !== 'P2002') {
        throw error;
      }
    }

    const existing = await this.prisma.idempotencyKey.findUnique({ where: args.unique });
    if (!existing) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT);
    }
    if (existing.statusCode === IDEMPOTENCY_IN_FLIGHT) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT);
    }
    if (existing.bodyHash !== args.bodyHash) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.IDEMPOTENCY_KEY_REUSED);
    }
    if (!isReplayFresh(existing.createdAt, this.clock.now())) {
      await this.prisma.idempotencyKey.delete({ where: { id: existing.id } });
      await this.prisma.idempotencyKey.create({
        data: {
          key: args.key,
          route: args.route,
          callerSubject: args.callerSubject,
          callerUserId: args.callerUserId,
          bodyHash: args.bodyHash,
          statusCode: IDEMPOTENCY_IN_FLIGHT,
          responseBody: {},
        },
      });
      return { kind: 'claimed' };
    }
    void args.reply.status(existing.statusCode);
    return { kind: 'replay', body: existing.responseBody };
  }
}
