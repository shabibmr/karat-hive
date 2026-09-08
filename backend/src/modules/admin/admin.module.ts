import { Module } from '@nestjs/common';
import { PlatformModule } from '../../platform/platform.module';
import { AuditModule } from '../audit';
import { ReviewsModule } from '../reviews';
import { SettingsModule } from '../settings';
import { AdminService } from './application/admin.service';
import { AdminController } from './controller/admin.controller';
import { AdminGuard } from './guard/admin.guard';
import { AdminRepository } from './repository/admin.repository';

@Module({
  imports: [PlatformModule, AuditModule, ReviewsModule, SettingsModule],
  controllers: [AdminController],
  providers: [AdminRepository, AdminService, AdminGuard],
  exports: [AdminService, AdminRepository, AdminGuard],
})
export class AdminModule {}
