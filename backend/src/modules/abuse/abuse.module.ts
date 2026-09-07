import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { AbuseRepository } from './repository/abuse.repository';
import { AbuseService } from './application/abuse.service';
import { AbuseController } from './controller/abuse.controller';

@Module({
  imports: [AuditModule],
  controllers: [AbuseController],
  providers: [AbuseRepository, AbuseService],
  exports: [AbuseService, AbuseRepository],
})
export class AbuseModule {}
