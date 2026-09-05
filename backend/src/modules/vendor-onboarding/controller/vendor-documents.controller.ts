import { Body, Controller, Get, HttpCode, Post, UseGuards } from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { VendorDocumentsService } from '../application/vendor-documents.service';
import { VendorOnboardingService } from '../application/vendor-onboarding.service';
import type { VendorDocumentView, VendorMe } from '../presenter/vendor-me.presenter';
import { VendorAccessGuard, VendorStageRequired } from './vendor-access.guard';

const attachSchema = z.object({
  documentType: z.enum([
    'TRADE_LICENCE',
    'EMIRATES_ID',
    'VAT_CERT',
    'TRADING_PERMIT',
    'TENANCY',
    'OTHER',
  ]),
  mediaKey: z.string().uuid(),
  expiryDate: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/)
    .optional(),
});

@Controller('v1/me/vendor')
@UseGuards(VendorAccessGuard)
@VendorStageRequired('SHELL')
@RevealsIdentity()
export class VendorDocumentsController {
  constructor(
    private readonly documents: VendorDocumentsService,
    private readonly onboarding: VendorOnboardingService,
  ) {}

  @Get('documents')
  list(@Viewer() viewer: ViewerContext): Promise<VendorDocumentView[]> {
    return this.documents.list(viewer);
  }

  @Post('documents')
  attach(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(attachSchema)) body: z.infer<typeof attachSchema>,
  ): Promise<VendorDocumentView[]> {
    return this.documents.attach(viewer, body);
  }

  @Post('resubmit')
  @HttpCode(200)
  async resubmit(@Viewer() viewer: ViewerContext): Promise<VendorMe> {
    await this.documents.resubmit(viewer);
    return this.onboarding.getVendorMe(viewer);
  }
}
