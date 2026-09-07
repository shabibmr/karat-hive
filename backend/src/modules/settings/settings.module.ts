import { Module } from '@nestjs/common';
import { SettingsRepository } from './repository/settings.repository';
import { SettingsService } from './application/settings.service';
import { SettingsController } from './controller/settings.controller';

@Module({
  controllers: [SettingsController],
  providers: [SettingsRepository, SettingsService],
  exports: [SettingsService, SettingsRepository],
})
export class SettingsModule {}
