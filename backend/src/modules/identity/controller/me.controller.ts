import { Body, Controller, Get, Patch } from '@nestjs/common';
import { z } from 'zod';
import { AllowSuspended } from '../../../edge/auth/allow-suspended.decorator';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { MeService } from '../application/me.service';
import type { Me } from '../presenter/me.presenter';

const patchMeSchema = z
  .object({ preferredLanguage: z.enum(['en', 'ar']).optional() })
  .refine((v) => Object.keys(v).length > 0, { message: 'At least one field is required.' });

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
}
