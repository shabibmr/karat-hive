import { Global, Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { TaxonomyModule } from '../taxonomy';
import { VendorOnboardingModule } from '../vendor-onboarding';
import { FirebaseTokenService } from './application/firebase-token.service';
import { LoginService } from './application/login.service';
import { MeService } from './application/me.service';
import { OtpService } from './application/otp.service';
import { RegistrationService } from './application/registration.service';
import { SessionQuery } from './application/session.query';
import { SessionService } from './application/session.service';
import { TokenService } from './application/token.service';
import { AuthController } from './controller/auth.controller';
import { MeController } from './controller/me.controller';
import { OtpRepository } from './repository/otp.repository';
import { UserRepository } from './repository/user.repository';

@Global()
@Module({
  imports: [AuditModule, TaxonomyModule, VendorOnboardingModule],
  controllers: [AuthController, MeController],
  providers: [
    TokenService,
    FirebaseTokenService,
    SessionQuery,
    OtpService,
    RegistrationService,
    LoginService,
    SessionService,
    MeService,
    OtpRepository,
    UserRepository,
  ],
  exports: [TokenService, FirebaseTokenService, SessionQuery],
})
export class IdentityModule {}
