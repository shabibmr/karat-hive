import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { VendorOnboardingModule } from '../vendor-onboarding';
import { SubscriptionRepository } from './repository/subscription.repository';
import { SubscriptionService } from './application/subscription.service';
import { SubscriptionController } from './controller/subscription.controller';
import { AdminSubscriptionController } from './controller/admin-subscription.controller';

@Module({
  imports: [AuditModule, VendorOnboardingModule],
  controllers: [SubscriptionController, AdminSubscriptionController],
  providers: [SubscriptionRepository, SubscriptionService],
  exports: [SubscriptionService, SubscriptionRepository],
})
export class SubscriptionModule {}
