import { Module } from '@nestjs/common';
import { OutboxModule } from '../../platform/outbox/outbox.module';
import { SharedModule } from '../../shared/shared.module';
import { VendorOnboardingModule } from '../vendor-onboarding';
import { MatchingConsumer } from './application/matching.consumer';
import { MatchingService } from './application/matching.service';
import { MatchingController } from './controller/matching.controller';
import { MatchingRepository } from './repository/matching.repository';

@Module({
  imports: [VendorOnboardingModule, OutboxModule, SharedModule],
  controllers: [MatchingController],
  providers: [MatchingRepository, MatchingService, MatchingConsumer],
  exports: [MatchingRepository, MatchingService],
})
export class MatchingModule {}
