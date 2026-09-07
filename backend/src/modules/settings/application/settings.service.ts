import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { SettingsRepository } from '../repository/settings.repository';

export interface PlatformConfigResponse {
  requestLifetimeHours: number;
  offerValidityHours: number[];
  defaultOfferValidityHours: number;
  bullionMinimumAed: string;
  maxConcurrentLiveRequests: number;
  maxRequestImages: number;
  maxOfferImages: number;
  maxImageBytes: number;
  acceptedImageTypes: string[];
  karatList: string[];
  maxOfferRevisions: number;
  requestExpiryWarningHours: number;
  termsUrl: string;
  privacyUrl: string;
  supportContactUrl: string;
  subscriptionContactUrl: string;
}

export interface UserSettingsResponse {
  preferredLanguage: 'en' | 'ar';
  defaultRegionId?: string | null;
  quietHours?: {
    start: string;
    end: string;
    timezone: 'Asia/Dubai';
  } | null;
  defaultFilterPresetId?: string | null;
  notifications: Record<string, { inApp: boolean; push: boolean; email: boolean }>;
}

export interface UpdateUserSettingsDto {
  preferredLanguage?: 'en' | 'ar';
  defaultRegionId?: string | null;
  quietHours?: {
    start: string;
    end: string;
    timezone?: string;
  } | null;
  defaultFilterPresetId?: string | null;
  notifications?: Record<string, { inApp?: boolean; push?: boolean; email?: boolean }>;
}

@Injectable()
export class SettingsService {
  constructor(private readonly repository: SettingsRepository) {}

  async getPlatformConfig(): Promise<PlatformConfigResponse> {
    const rows = await this.repository.getAllPlatformSettings();
    if (!rows || rows.length === 0) {
      // Empty DB -> 500, not invented defaults (G2-P01)
      throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, ErrorCode.INTERNAL);
    }

    const map = new Map<string, unknown>();
    for (const row of rows) {
      map.set(row.key, row.value);
    }

    return {
      requestLifetimeHours: Number(map.get('request.lifetime_hours') ?? 48),
      offerValidityHours: (map.get('offer.validity_hours_options') as number[]) ?? [12, 24, 48],
      defaultOfferValidityHours: Number(map.get('offer.default_validity_hours') ?? 24),
      bullionMinimumAed: String(map.get('bullion.minimum_value_aed') ?? '500.00'),
      maxConcurrentLiveRequests: Number(map.get('request.max_concurrent_live') ?? 10),
      maxRequestImages: Number(map.get('request.max_images') ?? 5),
      maxOfferImages: Number(map.get('offer.max_images') ?? 3),
      maxImageBytes: Number(map.get('media.image.max_bytes') ?? 5242880),
      acceptedImageTypes: (map.get('media.image.accepted_types') as string[]) ?? [
        'image/jpeg',
        'image/png',
        'image/webp',
      ],
      karatList: (map.get('karat.options') as string[]) ?? ['24K', '22K', '21K', '18K'],
      maxOfferRevisions: Number(map.get('offer.max_revisions') ?? 3),
      requestExpiryWarningHours: Number(map.get('request.expiry_warning_hours') ?? 6),
      termsUrl: String(map.get('legal.terms_url') ?? ''),
      privacyUrl: String(map.get('legal.privacy_url') ?? ''),
      supportContactUrl: String(map.get('support.contact_url') ?? ''),
      subscriptionContactUrl: String(map.get('subscription.contact_url') ?? ''),
    };
  }

  async getMySettings(viewer: ViewerContext): Promise<UserSettingsResponse> {
    const user = await this.repository.getUserSettings(viewer.userId);
    if (!user) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    }

    const notifications: Record<string, { inApp: boolean; push: boolean; email: boolean }> = {};
    for (const pref of user.notificationPreferences) {
      notifications[pref.category] = {
        inApp: pref.inApp,
        push: pref.push,
        email: pref.email,
      };
    }

    const quietHours =
      user.quietHoursStart && user.quietHoursEnd
        ? {
            start: user.quietHoursStart,
            end: user.quietHoursEnd,
            timezone: 'Asia/Dubai' as const,
          }
        : null;

    return {
      preferredLanguage: user.preferredLanguage as 'en' | 'ar',
      defaultRegionId: user.customerProfile?.defaultRegionId ?? null,
      quietHours,
      notifications,
    };
  }

  async updateMySettings(
    viewer: ViewerContext,
    dto: UpdateUserSettingsDto,
  ): Promise<UserSettingsResponse> {
    await this.repository.updateUserSettings(viewer.userId, {
      preferredLanguage: dto.preferredLanguage,
      defaultRegionId: dto.defaultRegionId,
      quietHoursStart: dto.quietHours ? dto.quietHours.start : dto.quietHours === null ? null : undefined,
      quietHoursEnd: dto.quietHours ? dto.quietHours.end : dto.quietHours === null ? null : undefined,
      notifications: dto.notifications,
    });

    return this.getMySettings(viewer);
  }

  async getAllAdminSettings() {
    return this.repository.getAllPlatformSettings();
  }

  async updateAdminSetting(key: string, value: unknown, adminId: string) {
    const setting = await this.repository.getPlatformSetting(key);
    if (!setting) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // Check allowed_range if present
    if (setting.allowedRange && typeof setting.allowedRange === 'object') {
      const range = setting.allowedRange as { min?: number; max?: number; enum?: string[] };
      if (range.min !== undefined && Number(value) < range.min) {
        throw new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.SETTING_OUT_OF_RANGE);
      }
      if (range.max !== undefined && Number(value) > range.max) {
        throw new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.SETTING_OUT_OF_RANGE);
      }
      if (range.enum && Array.isArray(range.enum) && !range.enum.includes(String(value))) {
        throw new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.SETTING_OUT_OF_RANGE);
      }
    }

    return this.repository.updatePlatformSetting(key, value, adminId);
  }
}
