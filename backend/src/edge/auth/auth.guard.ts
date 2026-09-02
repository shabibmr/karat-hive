import { CanActivate, ExecutionContext, HttpStatus, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { FastifyRequest } from 'fastify';
import { IdentityAuthError, SessionQuery, TokenService } from '../../modules/identity';
import { ApiException } from '../errors/api-exception';
import { ErrorCode } from '../errors/error-codes';
import { IS_PUBLIC_KEY } from './public.decorator';
import { VIEWER_CONTEXT_KEY, viewerOf, type ViewerContext } from './viewer-context';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly tokens: TokenService,
    private readonly sessions: SessionQuery,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const request = context
      .switchToHttp()
      .getRequest<FastifyRequest & { [VIEWER_CONTEXT_KEY]?: ViewerContext }>();
    const header = request.headers.authorization;
    if (typeof header !== 'string' || !header.startsWith('Bearer ')) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    }
    try {
      const claims = await this.tokens.verifyAccess(header.slice('Bearer '.length));
      const user = await this.sessions.findUserForViewer(claims.sub);
      if (!user || user.deletedAt !== null) {
        throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
      }
      if (user.tokenVersion !== claims.ver || user.userType !== claims.role) {
        throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
      }
      request[VIEWER_CONTEXT_KEY] = {
        userId: user.id,
        role: user.userType,
        tokenVersion: user.tokenVersion,
        accountState: user.accountState,
        preferredLanguage: user.preferredLanguage,
        vendorProfileId: user.vendorProfileId,
        vendorVerificationState: user.vendorVerificationState,
        vendorActivatedAt: user.vendorActivatedAt,
        customerProfileId: user.customerProfileId,
        adminProfileId: user.adminProfileId,
      };
      return true;
    } catch (error: unknown) {
      if (error instanceof ApiException) throw error;
      if (error instanceof IdentityAuthError) {
        const code =
          error.code === 'TOKEN_EXPIRED'
            ? ErrorCode.TOKEN_EXPIRED
            : error.code === 'REFRESH_REUSE_DETECTED'
              ? ErrorCode.REFRESH_REUSE_DETECTED
              : ErrorCode.UNAUTHENTICATED;
        throw new ApiException(HttpStatus.UNAUTHORIZED, code);
      }
      throw error;
    }
  }
}

export { viewerOf };
