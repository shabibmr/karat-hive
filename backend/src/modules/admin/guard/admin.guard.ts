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
import { hasAdminPermission, permissionForAdminRequest } from './admin-permissions';

@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest<FastifyRequest>();
    const viewer = viewerOf(req);
    if (!viewer || viewer.role !== 'ADMIN') {
      // Non-Admin on /v1/admin -> 404 (AD-API-01)
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const role = viewer.adminRole;
    if (!role) {
      // A role is mandatory for an Admin identity. This should only be reachable
      // during an incomplete deployment/migration; fail closed rather than
      // silently granting the legacy ADMIN role every permission.
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    const request = context.switchToHttp().getRequest<FastifyRequest>();
    const permission = permissionForAdminRequest(
      request.method,
      request.url ?? request.raw?.url ?? '',
    );
    if (!permission || !hasAdminPermission(role, permission)) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    return true;
  }
}
