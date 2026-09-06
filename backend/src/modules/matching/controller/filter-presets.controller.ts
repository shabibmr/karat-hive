import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import {
  VendorAccessGuard,
  VendorStageRequired,
} from '../../vendor-onboarding/controller/vendor-access.guard';
import {
  FilterPresetsService,
  type FilterPresetView,
} from '../application/filter-presets.service';

const createFilterPresetSchema = z.object({
  name: z.string().trim().min(1).max(100),
  filters: z.record(z.unknown()),
});

const updateFilterPresetSchema = z.object({
  name: z.string().trim().min(1).max(100).optional(),
  filters: z.record(z.unknown()).optional(),
});

@Controller('v1/filter-presets')
@UseGuards(VendorAccessGuard)
@VendorStageRequired('ACTIVE')
export class FilterPresetsController {
  constructor(private readonly presetsService: FilterPresetsService) {}

  @Get()
  list(@Viewer() viewer: ViewerContext): Promise<FilterPresetView[]> {
    return this.presetsService.list(viewer.vendorProfileId!);
  }

  @Post()
  create(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(createFilterPresetSchema)) body: z.infer<typeof createFilterPresetSchema>,
  ): Promise<FilterPresetView> {
    return this.presetsService.create(viewer.vendorProfileId!, body.name, body.filters);
  }

  @Patch(':id')
  update(
    @Viewer() viewer: ViewerContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body(zodBody(updateFilterPresetSchema)) body: z.infer<typeof updateFilterPresetSchema>,
  ): Promise<FilterPresetView> {
    return this.presetsService.update(id, viewer.vendorProfileId!, body);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async delete(
    @Viewer() viewer: ViewerContext,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<void> {
    await this.presetsService.delete(id, viewer.vendorProfileId!);
  }
}
