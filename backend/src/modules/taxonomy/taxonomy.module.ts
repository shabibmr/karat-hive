import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { PlatformConfigQuery } from './application/platform-config.query';
import { TaxonomyQuery } from './application/taxonomy.query';
import { TaxonomyService } from './application/taxonomy.service';
import { AdminTaxonomyController } from './controller/admin-taxonomy.controller';
import { TaxonomyController } from './controller/taxonomy.controller';
import { TaxonomyRepository } from './repository/taxonomy.repository';

@Module({
  imports: [AuditModule],
  controllers: [TaxonomyController, AdminTaxonomyController],
  providers: [TaxonomyRepository, TaxonomyQuery, TaxonomyService, PlatformConfigQuery],
  exports: [TaxonomyQuery, TaxonomyRepository, TaxonomyService, PlatformConfigQuery],
})
export class TaxonomyModule {}
