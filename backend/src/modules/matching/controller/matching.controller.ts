import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import type { Karat, RequestType } from '@prisma/client';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodBody, zodQuery } from '../../../edge/validation/zod-validation.pipe';
import {
  VendorAccessGuard,
  VendorStageRequired,
} from '../../vendor-onboarding';
import type { RequestForVendor } from '../../requests';
import type { MatchesSortOption } from '../domain/matching-engine';
import { MatchingService } from '../application/matching.service';

function toKarat(k?: string | null): Karat | undefined {
  if (!k) return undefined;
  if (k === '24K' || k === 'K24') return 'K24';
  if (k === '22K' || k === 'K22') return 'K22';
  if (k === '21K' || k === 'K21') return 'K21';
  if (k === '18K' || k === 'K18') return 'K18';
  return undefined;
}

const karatEnum = z.enum(['24K', '22K', '21K', '18K', 'K24', 'K22', 'K21', 'K18']);

const matchesQuerySchema = z.object({
  requestType: z.enum(['FIND_ORNAMENT', 'SELL_OLD_GOLD', 'GOLD_COIN', 'GOLD_BULLION']).optional(),
  direction: z.enum(['BUY', 'SELL']).optional(),
  categoryId: z.string().uuid().optional(),
  regionId: z.string().uuid().optional(),
  purityKarat: karatEnum.optional(),
  weightMin: z.coerce.number().positive().optional(),
  weightMax: z.coerce.number().positive().optional(),
  budgetMin: z.coerce.number().nonnegative().optional(),
  budgetMax: z.coerce.number().positive().optional(),
  publishedWithinHours: z.coerce.number().int().positive().optional(),
  includeResponded: z
    .enum(['true', 'false'])
    .optional()
    .transform((v) => v === 'true'),
  q: z.string().optional(),
  sort: z.enum(['NEWEST', 'EXPIRING', 'HIGHEST_VALUE', 'FEWEST_OFFERS']).optional(),
  presetId: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20).optional(),
  cursor: z.string().uuid().optional(),
});

const filterPresetCreateSchema = z.object({
  name: z.string().min(1).max(100),
  filters: z.record(z.unknown()),
});

const filterPresetUpdateSchema = z
  .object({
    name: z.string().min(1).max(100).optional(),
    filters: z.record(z.unknown()).optional(),
  })
  .refine((v) => Object.keys(v).length > 0, { message: 'At least one field is required.' });

@Controller('v1')
@UseGuards(VendorAccessGuard)
@VendorStageRequired('ACTIVE')
export class MatchingController {
  constructor(private readonly matching: MatchingService) {}

  @Get('matches')
  async listMatches(
    @Viewer() viewer: ViewerContext,
    @Query(zodQuery(matchesQuerySchema)) query: z.infer<typeof matchesQuerySchema>,
  ): Promise<{ data: RequestForVendor[]; meta: { nextCursor?: string } }> {
    return this.matching.listMatches(viewer, {
      ...query,
      purityKarat: toKarat(query.purityKarat),
      sort: query.sort as MatchesSortOption | undefined,
      requestType: query.requestType as RequestType | undefined,
    });
  }

  @Post('matches/:requestId/viewed')
  @HttpCode(HttpStatus.NO_CONTENT)
  async markViewed(
    @Viewer() viewer: ViewerContext,
    @Param('requestId') requestId: string,
  ): Promise<void> {
    await this.matching.markViewed(viewer, requestId);
  }

  @Get('filter-presets')
  async listPresets(@Viewer() viewer: ViewerContext) {
    const data = await this.matching.listPresets(viewer);
    return { data };
  }

  @Post('filter-presets')
  @HttpCode(HttpStatus.CREATED)
  async createPreset(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(filterPresetCreateSchema)) body: z.infer<typeof filterPresetCreateSchema>,
  ) {
    const data = await this.matching.createPreset(
      viewer,
      body.name,
      body.filters as import('@prisma/client').Prisma.InputJsonValue,
    );
    return { data };
  }

  @Patch('filter-presets/:id')
  async updatePreset(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(filterPresetUpdateSchema)) body: z.infer<typeof filterPresetUpdateSchema>,
  ) {
    const data = await this.matching.updatePreset(
      viewer,
      id,
      body.name,
      body.filters as import('@prisma/client').Prisma.InputJsonValue,
    );
    return { data };
  }

  @Delete('filter-presets/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deletePreset(@Viewer() viewer: ViewerContext, @Param('id') id: string): Promise<void> {
    await this.matching.deletePreset(viewer, id);
  }
}
