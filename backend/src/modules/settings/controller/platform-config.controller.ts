import { Controller, Get } from '@nestjs/common';
import { Public } from '../../../edge/auth/public.decorator';
import { PlatformConfigService } from '../application/platform-config.service';
import type { PlatformConfigResponse } from '../presenter/platform-config.presenter';

/**
 * Public platform configuration (CP2-A04 / SAM-GAP-5).
 * Read-only snapshot of settings needed by clients (Customer, Vendor, Web)
 * to render forms and reference external URLs without authentication.
 */
@Controller('v1')
export class PlatformConfigController {
  constructor(private readonly service: PlatformConfigService) {}

  @Public()
  @Get('platform-config')
  getConfig(): Promise<PlatformConfigResponse> {
    return this.service.getConfig();
  }
}
