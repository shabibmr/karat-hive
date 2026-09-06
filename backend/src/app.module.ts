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
import { MatchingModule } from './modules/matching';
import { MediaModule } from './modules/media';
import { RequestsModule } from './modules/requests';
import { SettingsModule } from './modules/settings';
import { SubscriptionModule } from './modules/subscription';
import { TaxonomyModule } from './modules/taxonomy';
import { VendorOnboardingModule } from './modules/vendor-onboarding';
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
    SettingsModule,
    SubscriptionModule,
    RequestsModule,
    MatchingModule,
    TaxonomyModule,
    MediaModule,
    VendorOnboardingModule,
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
