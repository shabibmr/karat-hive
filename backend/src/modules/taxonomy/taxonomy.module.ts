import { Module } from '@nestjs/common';
import { TaxonomyQuery } from './application/taxonomy.query';
import { TaxonomyController } from './controller/taxonomy.controller';
import { TaxonomyRepository } from './repository/taxonomy.repository';

@Module({
  controllers: [TaxonomyController],
  providers: [TaxonomyQuery, TaxonomyRepository],
  exports: [TaxonomyQuery],
})
export class TaxonomyModule {}
