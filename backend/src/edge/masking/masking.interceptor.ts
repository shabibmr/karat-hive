import {
  CallHandler,
  ExecutionContext,
  HttpStatus,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable, map } from 'rxjs';
import { ApiException } from '../errors/api-exception';
import { ErrorCode } from '../errors/error-codes';
import { findIdentityKey } from './identity-keys';
import { REVEALS_IDENTITY_KEY } from './reveals-identity.decorator';

@Injectable()
export class MaskingInterceptor implements NestInterceptor {
  private readonly logger = new Logger(MaskingInterceptor.name);

  constructor(private readonly reflector: Reflector) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const reveals = this.reflector.getAllAndOverride<boolean>(REVEALS_IDENTITY_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    return next.handle().pipe(
      map((body: unknown) => {
        if (reveals) return body;
        const hit = findIdentityKey(body);
        if (hit) {
          this.logger.error(`Identity key "${hit}" leaked on a masked route`);
          throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, ErrorCode.INTERNAL);
        }
        return body;
      }),
    );
  }
}
