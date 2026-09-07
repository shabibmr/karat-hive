import {
  CanActivate,
  ExecutionContext,
  HttpStatus,
  Injectable,
} from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { viewerOf } from '../../../edge/auth/viewer-context';

@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest<FastifyRequest>();
    const viewer = viewerOf(req);
    if (!viewer || viewer.role !== 'ADMIN') {
      // Non-Admin on /v1/admin -> 404 (AD-API-01)
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return true;
  }
}
