import {
  Body,
  Controller,
  HttpStatus,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import type { RequestType } from '@prisma/client';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { SubscriptionService } from '../application/subscription.service';

const grantSubscriptionSchema = z.object({
  requestType: z.enum([
    'FIND_ORNAMENT',
    'SELL_OLD_GOLD',
    'GOLD_COIN',
    'GOLD_BULLION',
  ]),
  periodStart: z.coerce.date(),
  periodEnd: z.coerce.date(),
  priceAed: z.union([z.string(), z.number()]),
  paymentReference: z.string().max(100).optional(),
});

const patchSubscriptionSchema = z.object({
  state: z.enum(['GRACE', 'EXPIRED', 'CANCELLED']).optional(),
  periodEnd: z.coerce.date().optional(),
  reasonText: z.string().trim().min(1).max(500),
});

@Controller('v1/admin/vendors')
export class AdminSubscriptionController {
  constructor(private readonly service: SubscriptionService) {}

  private assertAdmin(viewer: ViewerContext) {
    if (viewer.role !== 'ADMIN') {
      // Non-Admin on /v1/admin -> 404 (AD-API-01)
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
  }

  @Post(':id/subscriptions')
  async grantSubscription(
    @Viewer() viewer: ViewerContext,
    @Param('id') vendorProfileId: string,
    @Body(zodBody(grantSubscriptionSchema))
    body: z.infer<typeof grantSubscriptionSchema>,
  ) {
    this.assertAdmin(viewer);
    const data = await this.service.grantSubscriptionByAdmin(
      vendorProfileId,
      body,
      viewer.userId,
    );
    return { data };
  }

  @Patch(':id/subscriptions/:requestType')
  async patchSubscription(
    @Viewer() viewer: ViewerContext,
    @Param('id') vendorProfileId: string,
    @Param('requestType') requestType: RequestType,
    @Body(zodBody(patchSubscriptionSchema))
    body: z.infer<typeof patchSubscriptionSchema>,
  ) {
    this.assertAdmin(viewer);
    const data = await this.service.patchSubscriptionByAdmin(
      vendorProfileId,
      requestType,
      body,
      viewer.userId,
    );
    return { data };
  }
}
