import { Body, Controller, Get, HttpCode, HttpStatus, Param, Patch, Post } from '@nestjs/common';
import { z } from 'zod';
import { AllowSuspended } from '../../../edge/auth/allow-suspended.decorator';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { MeService } from '../application/me.service';
import type { DeletionRequestView, Me } from '../presenter/me.presenter';

const patchMeSchema = z
  .object({
    preferredLanguage: z.enum(['en', 'ar']).optional(),
    displayName: z.string().trim().min(1).max(100).optional(),
    defaultRegionId: z.string().uuid().nullable().optional(),
  })
  .refine((v) => Object.keys(v).length > 0, { message: 'At least one field is required.' });

const changeMobileSchema = z.object({
  challengeId: z.string().uuid(),
});

const confirmDeletionSchema = z.object({
  challengeId: z.string().uuid(),
});

@Controller('v1/me')
@RevealsIdentity()
export class MeController {
  constructor(private readonly me: MeService) {}

  @Get()
  @AllowSuspended()
  get(@Viewer() viewer: ViewerContext): Promise<Me> {
    return this.me.get(viewer);
  }

  @Patch()
  patch(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(patchMeSchema)) body: z.infer<typeof patchMeSchema>,
  ): Promise<Me> {
    return this.me.patch(viewer, body);
  }

  @Post('mobile/change')
  @HttpCode(200)
  changeMobile(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(changeMobileSchema)) body: z.infer<typeof changeMobileSchema>,
  ): Promise<Me> {
    return this.me.changeMobile(viewer, body.challengeId);
  }

  @Post('deactivate')
  @HttpCode(200)
  deactivate(@Viewer() viewer: ViewerContext): Promise<Me> {
    return this.me.deactivate(viewer);
  }

  @Post('deletion-requests')
  @HttpCode(201)
  @AllowSuspended()
  createDeletionRequest(@Viewer() viewer: ViewerContext): Promise<DeletionRequestView> {
    return this.me.createDeletionRequest(viewer);
  }

  @Post('deletion-requests/:id/confirm')
  @HttpCode(200)
  @AllowSuspended()
  confirmDeletionRequest(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(confirmDeletionSchema)) body: z.infer<typeof confirmDeletionSchema>,
  ): Promise<DeletionRequestView> {
    if (!z.string().uuid().safeParse(id).success) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return this.me.confirmDeletionRequest(viewer, id, body.challengeId);
  }
}
