import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { MediaModule } from '../media';
import { SubscriptionModule } from '../subscription/subscription.module';
import { TaxonomyModule } from '../taxonomy';
import { VendorDocumentsService } from './application/vendor-documents.service';
import { VendorOnboardingService } from './application/vendor-onboarding.service';
import { VendorTaxonomyService } from './application/vendor-taxonomy.service';
import { VendorVerificationService } from './application/vendor-verification.service';
import { DevVerifyController, DevVerifyGuard } from './controller/dev-verify.controller';
import { VendorAccessGuard } from './controller/vendor-access.guard';
import { VendorDashboardController } from './controller/vendor-dashboard.controller';
import { VendorDocumentsController } from './controller/vendor-documents.controller';
import { VendorProfileController } from './controller/vendor-profile.controller';
import { VendorTaxonomyController } from './controller/vendor-taxonomy.controller';
import { VendorOnboardingRepository } from './repository/vendor-onboarding.repository';

@Module({
  imports: [AuditModule, MediaModule, TaxonomyModule, SubscriptionModule],
  controllers: [
    VendorProfileController,
    VendorDocumentsController,
    VendorTaxonomyController,
    VendorDashboardController,
    DevVerifyController,
  ],
  providers: [
    VendorOnboardingRepository,
    VendorOnboardingService,
    VendorDocumentsService,
    VendorTaxonomyService,
    VendorVerificationService,
    VendorAccessGuard,
    DevVerifyGuard,
  ],
  exports: [VendorOnboardingService, VendorAccessGuard],
})
export class VendorOnboardingModule {}
