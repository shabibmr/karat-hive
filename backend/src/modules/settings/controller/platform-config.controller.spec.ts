import { describe, expect, it, vi } from 'vitest';
import { Reflector } from '@nestjs/core';
import { PlatformConfigController } from './platform-config.controller';
import type { PlatformConfigService } from '../application/platform-config.service';
import type { PlatformConfigResponse } from '../presenter/platform-config.presenter';
import { IS_PUBLIC_KEY } from '../../../edge/auth/public.decorator';

describe('PlatformConfigController', () => {
  const mockConfig: PlatformConfigResponse = {
    requestLifetimeHours: 48,
    offerValidityHours: [12, 24, 48],
    defaultOfferValidityHours: 24,
    bullionMinimumAed: '500.00',
    maxConcurrentLiveRequests: 10,
    maxOfferRevisions: 3,
    requestExpiryWarningHours: 6,
    karatList: ['24K', '22K', '21K', '18K'],
    karats: ['24K', '22K', '21K', '18K'],
    maxRequestImages: 5,
    maxOfferImages: 3,
    maxImageBytes: 5_242_880,
    acceptedImageTypes: ['image/jpeg', 'image/png', 'image/webp'],
    mediaLimits: {
      maxRequestImages: 5,
      maxOfferImages: 3,
      maxImageBytes: 5_242_880,
      maxKycBytes: 10_485_760,
      acceptedImageTypes: ['image/jpeg', 'image/png', 'image/webp'],
    },
    media: {
      maxRequestImages: 5,
      maxOfferImages: 3,
      maxImageBytes: 5_242_880,
      maxKycBytes: 10_485_760,
      acceptedImageTypes: ['image/jpeg', 'image/png', 'image/webp'],
    },
    legal: {
      termsUrl: 'https://karathive.ae/legal/terms',
      privacyUrl: 'https://karathive.ae/legal/privacy',
      currentTermsVersion: '1.0',
      currentPrivacyVersion: '1.0',
    },
    support: {
      contactUrl: 'https://karathive.ae/support',
    },
    supportContactUrl: 'https://karathive.ae/support',
    subscriptionContactUrl: 'https://karathive.ae/support',
  };

  function createServiceMock(): PlatformConfigService {
    return {
      getConfig: vi.fn().mockResolvedValue(mockConfig),
    } as unknown as PlatformConfigService;
  }

  it('delegates to PlatformConfigService.getConfig()', async () => {
    const service = createServiceMock();
    const controller = new PlatformConfigController(service);

    const result = await controller.getConfig();

    expect(result).toEqual(mockConfig);
    expect(service.getConfig).toHaveBeenCalledOnce();
  });

  it('is decorated with @Public() so no authentication is required', () => {
    const reflector = new Reflector();
    const isPublic = reflector.get<boolean>(
      IS_PUBLIC_KEY,
      PlatformConfigController.prototype.getConfig,
    );

    expect(isPublic).toBe(true);
  });
});
