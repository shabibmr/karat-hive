import { Body, Controller, Get, Patch, Query, UseGuards } from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { zodBody, zodQuery } from '../../../edge/validation/zod-validation.pipe';
import { VendorOnboardingService } from '../application/vendor-onboarding.service';
import type { VendorMe } from '../presenter/vendor-me.presenter';
import { VendorAccessGuard, VendorStageRequired } from './vendor-access.guard';

const patchSchema = z
  .object({
    tradingName: z.string().min(1).max(200).optional(),
    description: z.string().max(2000).optional(),
    contactPersonName: z.string().min(1).max(100).optional(),
    businessEmail: z.string().email().max(255).optional(),
    legalBusinessName: z.string().min(1).max(200).optional(),
    tradeLicenceNumber: z.string().min(1).max(50).optional(),
    businessAddress: z.string().min(1).optional(),
  })
  .refine((v) => Object.keys(v).length > 0, { message: 'At least one field is required.' });

const performanceExportQuerySchema = z.object({
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
  requestType: z
    .enum(['FIND_ORNAMENT', 'SELL_OLD_GOLD', 'GOLD_COIN', 'GOLD_BULLION'])
    .optional(),
  categoryId: z.string().uuid().optional(),
  regionId: z.string().uuid().optional(),
});

@Controller('v1/me/vendor')
@UseGuards(VendorAccessGuard)
@VendorStageRequired('SHELL')
@RevealsIdentity()
export class VendorProfileController {
  constructor(private readonly onboarding: VendorOnboardingService) {}

  @Get()
  me(@Viewer() viewer: ViewerContext): Promise<VendorMe> {
    return this.onboarding.getVendorMe(viewer);
  }

  @Patch()
  patch(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(patchSchema)) body: z.infer<typeof patchSchema>,
  ): Promise<VendorMe> {
    return this.onboarding.patchProfile(viewer, body);
  }

  /** FR-VEN-023 AC3 — own Offer history CSV. Filters match GET /v1/me/vendor/performance. */
  @Get('performance/export')
  @VendorStageRequired('ACTIVE')
  exportPerformance(
    @Viewer() viewer: ViewerContext,
    @Query(zodQuery(performanceExportQuerySchema))
    query: z.infer<typeof performanceExportQuerySchema>,
  ) {
    return this.onboarding.exportPerformance(viewer, query);
  }
}

