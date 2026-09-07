import { Body, Controller, Delete, HttpCode, HttpStatus, Param, Post } from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { NotificationService } from '../application/notification.service';

const registerDeviceSchema = z.object({
  platform: z.enum(['IOS', 'ANDROID']),
  pushToken: z.string().min(1).max(500),
  label: z.string().max(100).optional(),
});

@Controller('v1/devices')
export class DeviceController {
  constructor(private readonly service: NotificationService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async registerDevice(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(registerDeviceSchema))
    body: z.infer<typeof registerDeviceSchema>,
  ) {
    const data = await this.service.registerDevice(viewer, body);
    return { data };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteDevice(
    @Viewer() viewer: ViewerContext,
    @Param('id') deviceId: string,
  ): Promise<void> {
    await this.service.deleteDevice(viewer, deviceId);
  }
}
