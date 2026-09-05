import {
  Body,
  CanActivate,
  Controller,
  ExecutionContext,
  HttpCode,
  HttpStatus,
  Inject,
  Injectable,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import { z } from 'zod';
import { Public } from '../../../edge/auth/public.decorator';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { ENV, type Env } from '../../../config/env';
import { VendorVerificationService } from '../application/vendor-verification.service';

/** Guards the dev-only shortcut: disabled unless explicitly enabled + a matching header key. */
@Injectable()
export class DevVerifyGuard implements CanActivate {
  constructor(@Inject(ENV) private readonly env: Env) {}

  canActivate(context: ExecutionContext): boolean {
    const notFound = new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    if (!this.env.DEV_VERIFY_ENABLED || this.env.NODE_ENV === 'production') throw notFound;
    const request = context.switchToHttp().getRequest<FastifyRequest>();
    const key = request.headers['x-dev-key'];
    if (typeof key !== 'string' || key !== this.env.DEV_VERIFY_KEY) throw notFound;
    return true;
  }
}

const bodySchema = z.object({
  decision: z.enum(['VERIFY', 'REJECT', 'REQUEST_INFO']),
  rationale: z.string().max(2000).optional(),
  message: z.string().max(2000).optional(),
});

@Controller('v1/dev/vendors')
export class DevVerifyController {
  constructor(private readonly verification: VendorVerificationService) {}

  @Public()
  @UseGuards(DevVerifyGuard)
  @HttpCode(HttpStatus.OK)
  @Post(':id/verify')
  verify(
    @Param('id') id: string,
    @Body(zodBody(bodySchema)) body: z.infer<typeof bodySchema>,
  ): Promise<{ lifecycle: string }> {
    return this.verification.applyDecision(null, id, body);
  }
}
