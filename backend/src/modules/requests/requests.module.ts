import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { MediaModule } from '../media';
import { TaxonomyModule } from '../taxonomy';
import { RequestService } from './application/request.service';
import { RequestController } from './controller/request.controller';
import { RequestRepository } from './repository/request.repository';

@Module({
  imports: [AuditModule, MediaModule, TaxonomyModule],
  controllers: [RequestController],
  providers: [RequestRepository, RequestService],
  exports: [RequestRepository, RequestService],
})
export class RequestsModule {}
