import { Controller, Get } from '@nestjs/common';
import { Public } from '../../../edge/auth/public.decorator';
import { TaxonomyQuery } from '../application/taxonomy.query';
import type { TaxonomyNode } from '../presenter/taxonomy.presenter';

/**
 * Public reference data. Needed unauthenticated by the Vendor registration screen
 * (VEN-S01) as well as by authenticated Customer/Vendor/Admin screens.
 */
@Controller('v1')
export class TaxonomyController {
  constructor(private readonly taxonomy: TaxonomyQuery) {}

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
}
