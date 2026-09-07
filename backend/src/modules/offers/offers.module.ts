import { Module } from '@nestjs/common';
import { Clock } from '../../shared/clock';
import { OfferController } from './controller/offer.controller';
import { OfferService } from './application/offer.service';
import { OfferRepository } from './repository/offer.repository';

@Module({
  controllers: [OfferController],
  providers: [OfferService, OfferRepository, Clock],
  exports: [OfferService, OfferRepository],
})
export class OffersModule {}
