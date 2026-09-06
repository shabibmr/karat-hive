import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { Direction, Karat, RequestType } from '@prisma/client';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodQuery } from '../../../edge/validation/zod-validation.pipe';
import {
  VendorAccessGuard,
  VendorStageRequired,
} from '../../vendor-onboarding/controller/vendor-access.guard';
import { MatchingService } from '../application/matching.service';
import type { MatchesListView } from '../presenter/matching.presenter';

const matchesQuerySchema = z.object({
  requestType: z.nativeEnum(RequestType).optional(),
  direction: z.nativeEnum(Direction).optional(),
  categoryId: z.string().uuid().optional(),
  regionId: z.string().uuid().optional(),
  purityKarat: z.nativeEnum(Karat).optional(),
  weightMin: z.coerce.number().optional(),
  weightMax: z.coerce.number().optional(),
  budgetMin: z.coerce.number().optional(),
  budgetMax: z.coerce.number().optional(),
  publishedWithinHours: z.coerce.number().optional(),
  includeResponded: z.coerce.boolean().optional(),
  q: z.string().optional(),
  sort: z.enum(['NEWEST', 'EXPIRING', 'HIGHEST_VALUE', 'FEWEST_OFFERS']).optional(),
  presetId: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
  cursor: z.string().optional(),
});

@Controller('v1/matches')
@UseGuards(VendorAccessGuard)
@VendorStageRequired('ACTIVE')
export class MatchingController {
  constructor(private readonly matchingService: MatchingService) {}

  @Get()
  getMatches(
    @Viewer() viewer: ViewerContext,
    @Query(zodQuery(matchesQuerySchema)) query: z.infer<typeof matchesQuerySchema>,
  ): Promise<MatchesListView> {
    return this.matchingService.listMatches(viewer.vendorProfileId!, query);
  }

  @Post(':requestId/viewed')
  @HttpCode(HttpStatus.NO_CONTENT)
  async markViewed(
    @Viewer() viewer: ViewerContext,
    @Param('requestId', ParseUUIDPipe) requestId: string,
  ): Promise<void> {
    await this.matchingService.markViewed(viewer.vendorProfileId!, requestId);
  }
}
