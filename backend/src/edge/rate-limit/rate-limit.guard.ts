import { CanActivate, ExecutionContext, HttpStatus, Injectable } from '@nestjs/common';
import { FastifyReply, FastifyRequest } from 'fastify';
import { viewerOf } from '../auth/auth.guard';
import { clientIpOf } from '../client-ip';
import { ApiException } from '../errors/api-exception';
import { ErrorCode } from '../errors/error-codes';
import { scopeFor } from './rate-limit.policy';
import { RateLimitService } from './rate-limit.service';
import { PerfTimer } from '../../platform/perf/perf-timer';
import { requestIdOf } from '../request-id';

@Injectable()
export class RateLimitGuard implements CanActivate {
  constructor(private readonly limiter: RateLimitService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const http = context.switchToHttp();
    const request = http.getRequest<FastifyRequest>();
    const reply = http.getResponse<FastifyReply>();
    const scope = scopeFor(request.method, request.url);
    if (scope === null) return true;

    const viewer = viewerOf(request);
    const subject = viewer?.userId ?? clientIpOf(request);
    const perf = new PerfTimer('[Perf] edge.rateLimit', { rid: requestIdOf(request), scope });
    const decision = await this.limiter.take(scope, subject);
    perf.lap('take');
    perf.done();
    void reply.header('x-ratelimit-limit', String(decision.limit));
    void reply.header('x-ratelimit-remaining', String(decision.remaining));
    void reply.header('x-ratelimit-reset', decision.resetAt.toISOString());
    if (!decision.allowed) {
      throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, ErrorCode.RATE_LIMITED);
    }
    return true;
  }
}
