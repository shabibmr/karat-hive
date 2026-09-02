import { Global, Module } from '@nestjs/common';
import { IdentityModule } from '../../modules/identity';
import { AuthGuard } from './auth.guard';

@Global()
@Module({
  imports: [IdentityModule],
  providers: [AuthGuard],
  exports: [AuthGuard, IdentityModule],
})
export class AuthModule {}
