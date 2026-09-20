import { Module } from '@nestjs/common';
import { Clock } from '../../shared/clock';
import { VendorOnboardingModule } from '../vendor-onboarding';
import { OfferController } from './controller/offer.controller';
import { OfferService } from './application/offer.service';
import { OfferRepository } from './repository/offer.repository';

@Module({
  imports: [VendorOnboardingModule],
  controllers: [OfferController],
  providers: [OfferService, OfferRepository, Clock],
  exports: [OfferService, OfferRepository],
})
export class OffersModule {}
