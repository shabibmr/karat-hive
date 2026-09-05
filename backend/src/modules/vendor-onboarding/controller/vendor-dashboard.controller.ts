import { Controller, Get, UseGuards } from '@nestjs/common';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { VendorOnboardingService } from '../application/vendor-onboarding.service';
import { VendorAccessGuard, VendorStageRequired } from './vendor-access.guard';

@Controller('v1/me/dashboard')
@UseGuards(VendorAccessGuard)
@VendorStageRequired('ACTIVE')
export class VendorDashboardController {
  constructor(private readonly onboarding: VendorOnboardingService) {}

  @Get()
  dashboard(@Viewer() viewer: ViewerContext) {
    return this.onboarding.dashboard(viewer);
  }
}
