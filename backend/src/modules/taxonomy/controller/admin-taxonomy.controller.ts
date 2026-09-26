import { Body, Controller, Get, HttpCode, Param, Patch, Post, Query, Req } from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import { z } from 'zod';
import { AdminOnly } from '../../../edge/auth/admin-only.decorator';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { clientInfoOf } from '../../../edge/client-ip';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { TaxonomyService } from '../application/taxonomy.service';
import type { RegionSummary, TaxonomyNode } from '../presenter/taxonomy.presenter';

const createRegionSchema = z.object({
  nameEn: z.string().trim().min(1, 'nameEn is required').max(100),
  nameAr: z.string().trim().min(1, 'nameAr is required').max(100),
  displayOrder: z.coerce.number().int().optional(),
  isActive: z.boolean().optional(),
});

const updateRegionSchema = z
  .object({
    nameEn: z.string().trim().min(1, 'nameEn cannot be blank').max(100).optional(),
    nameAr: z.string().trim().min(1, 'nameAr cannot be blank').max(100).optional(),
    displayOrder: z.coerce.number().int().optional(),
    isActive: z.boolean().optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'At least one field must be provided for update.',
  });

@Controller('v1/admin')
@AdminOnly()
export class AdminTaxonomyController {
  constructor(private readonly taxonomy: TaxonomyService) {}

  @Get('regions')
  getRegions(@Query('includeInactive') includeInactive?: string): Promise<TaxonomyNode[]> {
    const shouldInclude = includeInactive === undefined ? true : includeInactive === 'true';
    return this.taxonomy.listRegions({ includeInactive: shouldInclude });
  }

  @Post('regions')
  @HttpCode(201)
  createRegion(
    @Viewer() viewer: ViewerContext,
    @Req() request: FastifyRequest,
    @Body(zodBody(createRegionSchema)) body: z.infer<typeof createRegionSchema>,
  ): Promise<RegionSummary> {
    return this.taxonomy.createRegion(body, viewer, clientInfoOf(request));
  }

  @Patch('regions/:id')
  updateRegion(
    @Param('id') id: string,
    @Viewer() viewer: ViewerContext,
    @Req() request: FastifyRequest,
    @Body(zodBody(updateRegionSchema)) body: z.infer<typeof updateRegionSchema>,
  ): Promise<RegionSummary> {
    return this.taxonomy.updateRegion(id, body, viewer, clientInfoOf(request));
  }

  @Post('regions/:id/deactivate')
  @HttpCode(200)
  deactivateRegion(
    @Param('id') id: string,
    @Viewer() viewer: ViewerContext,
    @Req() request: FastifyRequest,
  ): Promise<RegionSummary> {
    return this.taxonomy.deactivateRegion(id, viewer, clientInfoOf(request));
  }
}
