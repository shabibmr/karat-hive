import { Module } from '@nestjs/common';
import { PrismaModule } from '../../platform/db/prisma.module';
import { OutboxModule } from '../../platform/outbox/outbox.module';
import { SharedModule } from '../../shared/shared.module';
import { FilterPresetsService } from './application/filter-presets.service';
import { MatchingConsumerService } from './application/matching-consumer.service';
import { MatchingService } from './application/matching.service';
import { FilterPresetsController } from './controller/filter-presets.controller';
import { MatchingController } from './controller/matching.controller';
import { FilterPresetsRepository } from './repository/filter-presets.repository';
import { MatchingRepository } from './repository/matching.repository';

@Module({
  imports: [PrismaModule, SharedModule, OutboxModule],
  controllers: [MatchingController, FilterPresetsController],
  providers: [
    MatchingRepository,
    MatchingService,
    MatchingConsumerService,
    FilterPresetsRepository,
    FilterPresetsService,
  ],
  exports: [MatchingService, MatchingRepository, FilterPresetsService],
})
export class MatchingModule {}
