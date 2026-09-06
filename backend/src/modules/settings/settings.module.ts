import { Module } from '@nestjs/common';
import { PlatformConfigController } from './controller/platform-config.controller';
import { PlatformConfigService } from './application/platform-config.service';
import { SettingsRepository } from './repository/settings.repository';

@Module({
  controllers: [PlatformConfigController],
  providers: [SettingsRepository, PlatformConfigService],
  exports: [SettingsRepository, PlatformConfigService],
})
export class SettingsModule {}
