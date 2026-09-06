import { Controller, Get, UseGuards } from '@nestjs/common';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import {
  VendorAccessGuard,
  VendorStageRequired,
} from '../../vendor-onboarding/controller/vendor-access.guard';
import { SubscriptionService } from '../application/subscription.service';
import type { SubscriptionView } from '../presenter/subscription.presenter';

@Controller('v1/me/subscriptions')
@UseGuards(VendorAccessGuard)
@VendorStageRequired('SHELL')
@RevealsIdentity()
export class SubscriptionController {
  constructor(private readonly subscriptionService: SubscriptionService) {}

  @Get()
  async getSubscriptions(@Viewer() viewer: ViewerContext): Promise<SubscriptionView[]> {
    return this.subscriptionService.getSubscriptions(viewer.vendorProfileId!);
  }
}
