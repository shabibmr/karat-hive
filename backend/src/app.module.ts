import { Module } from '@nestjs/common';
import { APP_FILTER, APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { ConfigModule } from './config/config.module';
import { AuthModule } from './edge/auth/auth.module';
import { AuthGuard } from './edge/auth/auth.guard';
import { EnvelopeInterceptor } from './edge/envelope.interceptor';
import { HttpErrorFilter } from './edge/errors/http-error.filter';
import { HealthController } from './edge/health/health.controller';
import { IdempotencyInterceptor } from './edge/idempotency/idempotency.interceptor';
import { MaskingInterceptor } from './edge/masking/masking.interceptor';
import { RateLimitGuard } from './edge/rate-limit/rate-limit.guard';
import { RateLimitService } from './edge/rate-limit/rate-limit.service';
import { AuditModule } from './modules/audit';
import { IdentityModule } from './modules/identity';
import { AbuseModule } from './modules/abuse';
import { ConnectionsModule } from './modules/connections';
import { MatchingModule } from './modules/matching';
import { MediaModule } from './modules/media';
import { NotificationsModule } from './modules/notifications';
import { OffersModule } from './modules/offers';
import { RequestsModule } from './modules/requests';
import { ReviewsModule } from './modules/reviews';
import { SettingsModule } from './modules/settings';
import { SubscriptionModule } from './modules/subscription';
import { TaxonomyModule } from './modules/taxonomy';
import { AdminModule } from './modules/admin';
import { VendorOnboardingModule } from './modules/vendor-onboarding';
import { GoldRateModule } from './modules/gold-rate';
import { PrismaModule } from './platform/db/prisma.module';
import { LifecycleModule } from './platform/lifecycle/lifecycle.module';
import { OutboxModule } from './platform/outbox/outbox.module';
import { PlatformModule } from './platform/platform.module';
import { SchedulerModule } from './platform/scheduler/scheduler.module';
import { SharedModule } from './shared/shared.module';

@Module({
  imports: [
    ConfigModule,
    SharedModule,
    PrismaModule,
    PlatformModule,
    LifecycleModule,
    AuditModule,
    TaxonomyModule,
    AdminModule,
    SettingsModule,
    SubscriptionModule,
    ReviewsModule,
    AbuseModule,
    NotificationsModule,
    MediaModule,
    RequestsModule,
    MatchingModule,
    OffersModule,
    ConnectionsModule,
    VendorOnboardingModule,
    GoldRateModule,
    IdentityModule,
    AuthModule,
    OutboxModule,
    SchedulerModule,
  ],
  controllers: [HealthController],
  providers: [
    RateLimitService,
    { provide: APP_GUARD, useClass: AuthGuard },
    { provide: APP_GUARD, useClass: RateLimitGuard },
    { provide: APP_INTERCEPTOR, useClass: IdempotencyInterceptor },
    { provide: APP_INTERCEPTOR, useClass: EnvelopeInterceptor },
    { provide: APP_INTERCEPTOR, useClass: MaskingInterceptor },
    { provide: APP_FILTER, useClass: HttpErrorFilter },
  ],
})
export class AppModule {}
