import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { VendorOnboardingModule } from '../vendor-onboarding';
import { AdminOffersService } from './application/admin-offers.service';
import { AdminRequestsService } from './application/admin-requests.service';
import { AdminVendorService } from './application/admin-vendor.service';
import { AdminOffersController } from './controller/admin-offers.controller';
import { AdminRequestsController } from './controller/admin-requests.controller';
import { AdminVendorController } from './controller/admin-vendor.controller';
import { AdminOffersRepository } from './repository/admin-offers.repository';
import { AdminRequestsRepository } from './repository/admin-requests.repository';
import { AdminVendorRepository } from './repository/admin-vendor.repository';

@Module({
  imports: [AuditModule, VendorOnboardingModule],
  controllers: [
    AdminVendorController,
    AdminRequestsController,
    AdminOffersController,
  ],
  providers: [
    AdminVendorRepository,
    AdminVendorService,
    AdminRequestsRepository,
    AdminRequestsService,
    AdminOffersRepository,
    AdminOffersService,
  ],
  exports: [
    AdminVendorService,
    AdminVendorRepository,
    AdminRequestsService,
    AdminRequestsRepository,
    AdminOffersService,
    AdminOffersRepository,
  ],
})
export class AdminModule {}
