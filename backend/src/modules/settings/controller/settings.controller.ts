import { Body, Controller, Get, Patch } from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { SettingsService } from '../application/settings.service';

const patchSettingsSchema = z.object({
  preferredLanguage: z.enum(['en', 'ar']).optional(),
  defaultRegionId: z.string().uuid().nullable().optional(),
  quietHours: z
    .object({
      start: z.string().regex(/^\d{2}:\d{2}$/),
      end: z.string().regex(/^\d{2}:\d{2}$/),
    })
    .nullable()
    .optional(),
  notifications: z
    .record(
      z.object({
        inApp: z.boolean().optional(),
        push: z.boolean().optional(),
        email: z.boolean().optional(),
      }),
    )
    .optional(),
});

@Controller('v1/me/settings')
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  @Get()
  async getMySettings(@Viewer() viewer: ViewerContext) {
    const data = await this.settingsService.getMySettings(viewer);
    return { data };
  }

  @Patch()
  async updateMySettings(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(patchSettingsSchema)) body: z.infer<typeof patchSettingsSchema>,
  ) {
    const data = await this.settingsService.updateMySettings(viewer, body);
    return { data };
  }
}
