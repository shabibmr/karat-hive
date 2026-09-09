import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { SettingsService } from './settings.service';
import type { SettingsRepository } from '../repository/settings.repository';

describe('SettingsService — defaultFilterPresetId (CP6-A01.1)', () => {
  let service: SettingsService;
  let repo: {
    getAllPlatformSettings: ReturnType<typeof vi.fn>;
    getPlatformSetting: ReturnType<typeof vi.fn>;
    updatePlatformSetting: ReturnType<typeof vi.fn>;
    getUserSettings: ReturnType<typeof vi.fn>;
    vendorOwnsFilterPreset: ReturnType<typeof vi.fn>;
    updateUserSettings: ReturnType<typeof vi.fn>;
  };

  const vendorViewer: ViewerContext = {
    userId: 'usr-v-1',
    role: 'VENDOR',
    tokenVersion: 1,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    vendorProfileId: 'vp-1',
    vendorVerificationState: 'VERIFIED',
    vendorActivatedAt: new Date('2026-09-01T00:00:00Z'),
    customerProfileId: null,
    adminProfileId: null,
  };

  function userRow(defaultFilterPresetId: string | null) {
    return {
      id: 'usr-v-1',
      preferredLanguage: 'en',
      quietHoursStart: null,
      quietHoursEnd: null,
      customerProfile: null,
      vendorProfile: { id: 'vp-1', defaultFilterPresetId },
      notificationPreferences: [],
    };
  }

  beforeEach(() => {
    repo = {
      getAllPlatformSettings: vi.fn(),
      getPlatformSetting: vi.fn(),
      updatePlatformSetting: vi.fn(),
      getUserSettings: vi.fn(),
      vendorOwnsFilterPreset: vi.fn(),
      updateUserSettings: vi.fn().mockResolvedValue(undefined),
    };
    service = new SettingsService(repo as unknown as SettingsRepository);
  });

  it('GET returns defaultFilterPresetId from vendor profile', async () => {
    repo.getUserSettings.mockResolvedValue(userRow('preset-a'));

    const result = await service.getMySettings(vendorViewer);

    expect(result.defaultFilterPresetId).toBe('preset-a');
  });

  it('PATCH persists defaultFilterPresetId when owned', async () => {
    repo.vendorOwnsFilterPreset.mockResolvedValue(true);
    repo.getUserSettings.mockResolvedValue(userRow('preset-a'));

    const result = await service.updateMySettings(vendorViewer, {
      defaultFilterPresetId: 'preset-a',
    });

    expect(repo.vendorOwnsFilterPreset).toHaveBeenCalledWith('usr-v-1', 'preset-a');
    expect(repo.updateUserSettings).toHaveBeenCalledWith(
      'usr-v-1',
      expect.objectContaining({ defaultFilterPresetId: 'preset-a' }),
    );
    expect(result.defaultFilterPresetId).toBe('preset-a');
  });

  it('PATCH null clears defaultFilterPresetId without ownership check', async () => {
    repo.getUserSettings.mockResolvedValue(userRow(null));

    const result = await service.updateMySettings(vendorViewer, {
      defaultFilterPresetId: null,
    });

    expect(repo.vendorOwnsFilterPreset).not.toHaveBeenCalled();
    expect(repo.updateUserSettings).toHaveBeenCalledWith(
      'usr-v-1',
      expect.objectContaining({ defaultFilterPresetId: null }),
    );
    expect(result.defaultFilterPresetId).toBeNull();
  });

  it('PATCH second preset replaces the first (single FK write)', async () => {
    repo.vendorOwnsFilterPreset.mockResolvedValue(true);
    repo.getUserSettings
      .mockResolvedValueOnce(userRow('preset-a'))
      .mockResolvedValueOnce(userRow('preset-b'));

    await service.updateMySettings(vendorViewer, { defaultFilterPresetId: 'preset-a' });
    const after = await service.updateMySettings(vendorViewer, {
      defaultFilterPresetId: 'preset-b',
    });

    expect(repo.updateUserSettings).toHaveBeenLastCalledWith(
      'usr-v-1',
      expect.objectContaining({ defaultFilterPresetId: 'preset-b' }),
    );
    expect(after.defaultFilterPresetId).toBe('preset-b');
  });

  it('PATCH rejects a preset not owned by the vendor', async () => {
    repo.vendorOwnsFilterPreset.mockResolvedValue(false);

    await expect(
      service.updateMySettings(vendorViewer, { defaultFilterPresetId: 'preset-other' }),
    ).rejects.toMatchObject({
      status: HttpStatus.NOT_FOUND,
      errorCode: ErrorCode.NOT_FOUND,
    });
    expect(repo.updateUserSettings).not.toHaveBeenCalled();
  });
});

describe('SettingsService — locked notification categories (CP6-A01.2)', () => {
  let service: SettingsService;
  let repo: {
    getAllPlatformSettings: ReturnType<typeof vi.fn>;
    getPlatformSetting: ReturnType<typeof vi.fn>;
    updatePlatformSetting: ReturnType<typeof vi.fn>;
    getUserSettings: ReturnType<typeof vi.fn>;
    vendorOwnsFilterPreset: ReturnType<typeof vi.fn>;
    updateUserSettings: ReturnType<typeof vi.fn>;
  };

  const customerViewer: ViewerContext = {
    userId: 'usr-c-1',
    role: 'CUSTOMER',
    tokenVersion: 1,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    vendorProfileId: null,
    vendorVerificationState: null,
    vendorActivatedAt: null,
    customerProfileId: 'cp-1',
    adminProfileId: null,
  };

  function userRow(
    notificationPreferences: Array<{
      category: string;
      inApp: boolean;
      push: boolean;
      email: boolean;
    }>,
  ) {
    return {
      id: 'usr-c-1',
      preferredLanguage: 'en',
      quietHoursStart: null,
      quietHoursEnd: null,
      customerProfile: { defaultRegionId: null },
      vendorProfile: null,
      notificationPreferences,
    };
  }

  beforeEach(() => {
    repo = {
      getAllPlatformSettings: vi.fn(),
      getPlatformSetting: vi.fn(),
      updatePlatformSetting: vi.fn(),
      getUserSettings: vi.fn(),
      vendorOwnsFilterPreset: vi.fn(),
      updateUserSettings: vi.fn().mockResolvedValue(undefined),
    };
    service = new SettingsService(repo as unknown as SettingsRepository);
  });

  it('PATCH rejects turning off a locked security category channel', async () => {
    await expect(
      service.updateMySettings(customerViewer, {
        notifications: { security: { push: false } },
      }),
    ).rejects.toMatchObject({
      status: HttpStatus.BAD_REQUEST,
      errorCode: ErrorCode.SETTING_OUT_OF_RANGE,
    });
    expect(repo.updateUserSettings).not.toHaveBeenCalled();
  });

  it('PATCH allows keeping a locked category fully on', async () => {
    repo.getUserSettings.mockResolvedValue(
      userRow([{ category: 'security', inApp: true, push: true, email: true }]),
    );

    const result = await service.updateMySettings(customerViewer, {
      notifications: { security: { inApp: true, push: true, email: true } },
    });

    expect(repo.updateUserSettings).toHaveBeenCalledWith(
      'usr-c-1',
      expect.objectContaining({
        notifications: { security: { inApp: true, push: true, email: true } },
      }),
    );
    expect(result.notifications.security).toEqual({
      inApp: true,
      push: true,
      email: true,
    });
  });

  it('PATCH still updates non-locked categories', async () => {
    repo.getUserSettings.mockResolvedValue(
      userRow([{ category: 'offer.submitted', inApp: false, push: false, email: true }]),
    );

    const result = await service.updateMySettings(customerViewer, {
      notifications: { 'offer.submitted': { push: false, inApp: false } },
    });

    expect(repo.updateUserSettings).toHaveBeenCalled();
    expect(result.notifications['offer.submitted']).toEqual({
      inApp: false,
      push: false,
      email: true,
    });
  });

  it('GET presents locked categories as fully on even if stored off', async () => {
    repo.getUserSettings.mockResolvedValue(
      userRow([{ category: 'security', inApp: false, push: false, email: false }]),
    );

    const result = await service.getMySettings(customerViewer);

    expect(result.notifications.security).toEqual({
      inApp: true,
      push: true,
      email: true,
    });
  });
});
