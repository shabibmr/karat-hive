export { SettingsModule } from './settings.module';
export { PlatformConfigService } from './application/platform-config.service';
export { SettingsRepository } from './repository/settings.repository';
export { PlatformConfigController } from './controller/platform-config.controller';
export type {
  PlatformConfigResponse,
  MediaLimits,
  LegalConfig,
  SupportConfig,
} from './presenter/platform-config.presenter';
