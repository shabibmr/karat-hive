import { Controller, Get } from '@nestjs/common';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { GoldRateService } from '../application/gold-rate.service';

@Controller('v1/gold-rates')
export class GoldRateController {
  constructor(private readonly goldRates: GoldRateService) {}

  @Get()
  async getGoldRates(@Viewer() viewer: ViewerContext) {
    const data = await this.goldRates.getPublicRates(viewer);
    return { data };
  }
}
