import { Module } from '@nestjs/common';
import { PrismaModule } from '../../platform/db/prisma.module';
import { SharedModule } from '../../shared/shared.module';
import { RequestsService } from './application/requests.service';
import { DevRequestsController } from './controller/dev-requests.controller';
import { RequestsController } from './controller/requests.controller';
import { RequestsRepository } from './repository/requests.repository';

@Module({
  imports: [PrismaModule, SharedModule],
  controllers: [RequestsController, DevRequestsController],
  providers: [RequestsRepository, RequestsService],
  exports: [RequestsService, RequestsRepository],
})
export class RequestsModule {}
