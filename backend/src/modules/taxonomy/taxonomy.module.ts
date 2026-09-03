import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { TaxonomyQuery } from './application/taxonomy.query';
import { TaxonomyService } from './application/taxonomy.service';
import { AdminTaxonomyController } from './controller/admin-taxonomy.controller';
import { TaxonomyController } from './controller/taxonomy.controller';
import { TaxonomyRepository } from './repository/taxonomy.repository';

@Module({
  imports: [AuditModule],
  controllers: [TaxonomyController, AdminTaxonomyController],
  providers: [TaxonomyRepository, TaxonomyQuery, TaxonomyService],
  exports: [TaxonomyQuery, TaxonomyRepository, TaxonomyService],
})
export class TaxonomyModule {}
