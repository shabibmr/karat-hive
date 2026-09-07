import { Controller, Get } from '@nestjs/common';
import { Public } from '../../../edge/auth/public.decorator';
import { PlatformConfig, PlatformConfigQuery } from '../application/platform-config.query';
import { TaxonomyQuery } from '../application/taxonomy.query';
import type { TaxonomyNode } from '../presenter/taxonomy.presenter';

/**
 * Public reference data. Needed unauthenticated by the Vendor registration screen
 * (VEN-S01) as well as by authenticated Customer/Vendor/Admin screens.
 */
@Controller('v1')
export class TaxonomyController {
  constructor(
    private readonly taxonomy: TaxonomyQuery,
    private readonly platformConfig: PlatformConfigQuery,
  ) {}

  @Public()
  @Get('categories')
  categories(): Promise<TaxonomyNode[]> {
    return this.taxonomy.categories();
  }

  @Public()
  @Get('regions')
  regions(): Promise<TaxonomyNode[]> {
    return this.taxonomy.regions();
  }

  @Public()
  @Get('platform-config')
  getPlatformConfig(): Promise<PlatformConfig> {
    return this.platformConfig.getPlatformConfig();
  }
}
