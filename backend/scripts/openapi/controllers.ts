/**
 * Controllers scanned for OpenAPI path discovery (G2-GR05 / NFR-030).
 * Keep in sync with Nest module `controllers` arrays — generation does not boot AppModule.
 */
import { HealthController } from '../../src/edge/health/health.controller';
import { AbuseController } from '../../src/modules/abuse/controller/abuse.controller';
import { AdminController } from '../../src/modules/admin/controller/admin.controller';
import { ConnectionController } from '../../src/modules/connections/controller/connection.controller';
import { AuthController } from '../../src/modules/identity/controller/auth.controller';
import { MeController } from '../../src/modules/identity/controller/me.controller';
import { MatchingController } from '../../src/modules/matching/controller/matching.controller';
import { MediaController } from '../../src/modules/media/controller/media.controller';
import { DeviceController } from '../../src/modules/notifications/controller/device.controller';
import { NotificationController } from '../../src/modules/notifications/controller/notification.controller';
import { OfferController } from '../../src/modules/offers/controller/offer.controller';
import { RequestController } from '../../src/modules/requests/controller/request.controller';
import { ReviewController } from '../../src/modules/reviews/controller/review.controller';
import { SettingsController } from '../../src/modules/settings/controller/settings.controller';
import { AdminSubscriptionController } from '../../src/modules/subscription/controller/admin-subscription.controller';
import { SubscriptionController } from '../../src/modules/subscription/controller/subscription.controller';
import { AdminTaxonomyController } from '../../src/modules/taxonomy/controller/admin-taxonomy.controller';
import { TaxonomyController } from '../../src/modules/taxonomy/controller/taxonomy.controller';
import { DevVerifyController } from '../../src/modules/vendor-onboarding/controller/dev-verify.controller';
import { VendorDashboardController } from '../../src/modules/vendor-onboarding/controller/vendor-dashboard.controller';
import { VendorDocumentsController } from '../../src/modules/vendor-onboarding/controller/vendor-documents.controller';
import { VendorProfileController } from '../../src/modules/vendor-onboarding/controller/vendor-profile.controller';
import { VendorTaxonomyController } from '../../src/modules/vendor-onboarding/controller/vendor-taxonomy.controller';

export type ControllerClass = new (...args: never[]) => unknown;

export const OPENAPI_CONTROLLERS: ControllerClass[] = [
  HealthController,
  AbuseController,
  AdminController,
  ConnectionController,
  AuthController,
  MeController,
  MatchingController,
  MediaController,
  DeviceController,
  NotificationController,
  OfferController,
  RequestController,
  ReviewController,
  SettingsController,
  AdminSubscriptionController,
  SubscriptionController,
  AdminTaxonomyController,
  TaxonomyController,
  DevVerifyController,
  VendorDashboardController,
  VendorDocumentsController,
  VendorProfileController,
  VendorTaxonomyController,
];
