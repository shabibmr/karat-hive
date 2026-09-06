import { Module } from '@nestjs/common';
import { PrismaModule } from '../../platform/db/prisma.module';
import { SharedModule } from '../../shared/shared.module';
import { SubscriptionService } from './application/subscription.service';
import { SubscriptionController } from './controller/subscription.controller';
import { SubscriptionRepository } from './repository/subscription.repository';

@Module({
  imports: [PrismaModule, SharedModule],
  controllers: [SubscriptionController],
  providers: [SubscriptionRepository, SubscriptionService],
  exports: [SubscriptionService, SubscriptionRepository],
})
export class SubscriptionModule {}
