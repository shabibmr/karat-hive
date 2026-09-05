import { Body, Controller, Patch, Put, UseGuards } from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { VendorTaxonomyService } from '../application/vendor-taxonomy.service';
import type { VendorMe } from '../presenter/vendor-me.presenter';
import { VendorAccessGuard, VendorStageRequired } from './vendor-access.guard';

const categoriesSchema = z.object({ categoryIds: z.array(z.string().uuid()).min(1) });
const regionsSchema = z.object({ regionIds: z.array(z.string().uuid()).min(1) });
const availabilitySchema = z
  .object({ awayMode: z.boolean().optional(), businessHours: z.unknown().optional() })
  .refine((v) => v.awayMode !== undefined || v.businessHours !== undefined, {
    message: 'At least one field is required.',
  });

@Controller('v1/me/vendor')
@UseGuards(VendorAccessGuard)
@RevealsIdentity()
export class VendorTaxonomyController {
  constructor(private readonly taxonomy: VendorTaxonomyService) {}

  @Put('categories')
  @VendorStageRequired('VERIFIED')
  setCategories(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(categoriesSchema)) body: z.infer<typeof categoriesSchema>,
  ): Promise<VendorMe> {
    return this.taxonomy.setCategories(viewer, body.categoryIds);
  }

  @Put('regions')
  @VendorStageRequired('VERIFIED')
  setRegions(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(regionsSchema)) body: z.infer<typeof regionsSchema>,
  ): Promise<VendorMe> {
    return this.taxonomy.setRegions(viewer, body.regionIds);
  }

  @Patch('availability')
  @VendorStageRequired('VERIFIED')
  setAvailability(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(availabilitySchema)) body: z.infer<typeof availabilitySchema>,
  ): Promise<VendorMe> {
    return this.taxonomy.setAvailability(viewer, body);
  }
}
