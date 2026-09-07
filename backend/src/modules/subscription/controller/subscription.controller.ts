import { Controller, Get, Query } from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodQuery } from '../../../edge/validation/zod-validation.pipe';
import { SubscriptionService } from '../application/subscription.service';

const performanceQuerySchema = z.object({
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
  requestType: z
    .enum(['FIND_ORNAMENT', 'SELL_OLD_GOLD', 'GOLD_COIN', 'GOLD_BULLION'])
    .optional(),
  categoryId: z.string().uuid().optional(),
  regionId: z.string().uuid().optional(),
});

@Controller('v1/me')
export class SubscriptionController {
  constructor(private readonly service: SubscriptionService) {}

  @Get('subscriptions')
  async getMySubscriptions(@Viewer() viewer: ViewerContext) {
    const data = await this.service.getMySubscriptions(viewer);
    return { data };
  }

  @Get('vendor/performance')
  async getVendorPerformance(
    @Viewer() viewer: ViewerContext,
    @Query(zodQuery(performanceQuerySchema)) query: z.infer<typeof performanceQuerySchema>,
  ) {
    const data = await this.service.getVendorPerformance(viewer, query);
    return { data };
  }
}
