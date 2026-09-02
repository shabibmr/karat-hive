import { createParamDecorator, ExecutionContext, HttpStatus } from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import { ApiException } from '../errors/api-exception';
import { ErrorCode } from '../errors/error-codes';
import { viewerOf, type ViewerContext } from './viewer-context';

/** Injects the authenticated ViewerContext; throws UNAUTHENTICATED on a public route. */
export const Viewer = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): ViewerContext => {
    const request = ctx.switchToHttp().getRequest<FastifyRequest>();
    const viewer = viewerOf(request);
    if (!viewer) throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    return viewer;
  },
);
