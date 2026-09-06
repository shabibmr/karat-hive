import { describe, expect, it, vi } from 'vitest';
import { PlatformConfigService } from './platform-config.service';
import type { SettingsRepository } from '../repository/settings.repository';
import type { PlatformSetting } from '@prisma/client';

describe('PlatformConfigService', () => {
  function createRepoMock(settings: Partial<PlatformSetting>[] = []): SettingsRepository {
    return {
      findAll: vi.fn().mockResolvedValue(settings as PlatformSetting[]),
      findByKey: vi.fn(),
      upsert: vi.fn(),
    } as unknown as SettingsRepository;
  }

  it('returns default platform configuration when repository is empty', async () => {
    const repo = createRepoMock([]);
    const service = new PlatformConfigService(repo);

    const config = await service.getConfig();

    expect(config.requestLifetimeHours).toBe(48);
    expect(config.offerValidityHours).toEqual([12, 24, 48]);
    expect(config.defaultOfferValidityHours).toBe(24);
    expect(config.bullionMinimumAed).toBe('500.00');
    expect(config.maxConcurrentLiveRequests).toBe(10);
    expect(config.maxOfferRevisions).toBe(3);
    expect(config.requestExpiryWarningHours).toBe(6);
    expect(config.karatList).toEqual(['24K', '22K', '21K', '18K']);
    expect(config.karats).toEqual(['24K', '22K', '21K', '18K']);
    expect(config.maxRequestImages).toBe(5);
    expect(config.maxOfferImages).toBe(3);
    expect(config.maxImageBytes).toBe(5_242_880);
    expect(config.acceptedImageTypes).toEqual(['image/jpeg', 'image/png', 'image/webp']);
    expect(config.mediaLimits).toEqual({
      maxRequestImages: 5,
      maxOfferImages: 3,
      maxImageBytes: 5_242_880,
      maxKycBytes: 10_485_760,
      acceptedImageTypes: ['image/jpeg', 'image/png', 'image/webp'],
    });
    expect(config.legal).toEqual({
      termsUrl: 'https://karathive.ae/legal/terms',
      privacyUrl: 'https://karathive.ae/legal/privacy',
      currentTermsVersion: '1.0',
      currentPrivacyVersion: '1.0',
    });
    expect(config.support).toEqual({
      contactUrl: 'https://karathive.ae/support',
    });
    expect(config.supportContactUrl).toBe('https://karathive.ae/support');
    expect(config.subscriptionContactUrl).toBe('https://karathive.ae/support');
  });

  it('surfaces seeded database settings faithfully (CP-1 seeds)', async () => {
    const seededSettings: Partial<PlatformSetting>[] = [
      { key: 'request.lifetime_hours', value: 48, dataType: 'number' },
      { key: 'request.max_concurrent_live', value: 10, dataType: 'number' },
      { key: 'request.expiry_warning_hours', value: 6, dataType: 'number' },
      { key: 'bullion.minimum_value_aed', value: '500.00', dataType: 'money' },
      { key: 'offer.validity_hours_options', value: [12, 24, 48], dataType: 'number[]' },
      { key: 'offer.default_validity_hours', value: 24, dataType: 'number' },
      { key: 'offer.max_revisions', value: 3, dataType: 'number' },
      { key: 'karat.options', value: ['24K', '22K', '21K', '18K'], dataType: 'string[]' },
      { key: 'media.kyc.max_bytes', value: 10485760, dataType: 'number' },
      { key: 'media.image.max_bytes', value: 5242880, dataType: 'number' },
      { key: 'legal.terms_url', value: 'https://karathive.ae/legal/terms', dataType: 'url' },
      { key: 'legal.privacy_url', value: 'https://karathive.ae/legal/privacy', dataType: 'url' },
      { key: 'support.contact_url', value: 'https://karathive.ae/support', dataType: 'url' },
      { key: 'legal.current_terms_version', value: '1.0', dataType: 'string' },
      { key: 'legal.current_privacy_version', value: '1.0', dataType: 'string' },
    ];

    const repo = createRepoMock(seededSettings);
    const service = new PlatformConfigService(repo);

    const config = await service.getConfig();

    expect(config.offerValidityHours).toEqual([12, 24, 48]);
    expect(config.requestLifetimeHours).toBe(48);
    expect(config.karatList).toEqual(['24K', '22K', '21K', '18K']);
    expect(config.legal.termsUrl).toBe('https://karathive.ae/legal/terms');
    expect(config.legal.privacyUrl).toBe('https://karathive.ae/legal/privacy');
    expect(config.support.contactUrl).toBe('https://karathive.ae/support');
    expect(config.supportContactUrl).toBe('https://karathive.ae/support');
    expect(config.subscriptionContactUrl).toBe('https://karathive.ae/support');
    expect(config.mediaLimits.maxImageBytes).toBe(5242880);
    expect(config.mediaLimits.maxKycBytes).toBe(10485760);
  });

  it('supports custom overrides from database', async () => {
    const customSettings: Partial<PlatformSetting>[] = [
      { key: 'request.lifetime_hours', value: 72, dataType: 'number' },
      { key: 'offer.validity_hours_options', value: [24, 48, 72], dataType: 'number[]' },
      { key: 'karat.options', value: [18, 21, 22, 24], dataType: 'number[]' },
      { key: 'legal.terms_url', value: 'https://custom.ae/terms', dataType: 'url' },
      { key: 'legal.privacy_url', value: 'https://custom.ae/privacy', dataType: 'url' },
      { key: 'support.contact_url', value: 'https://custom.ae/support', dataType: 'url' },
      { key: 'subscription.contact_url', value: 'https://wa.me/971500000000', dataType: 'url' },
    ];

    const repo = createRepoMock(customSettings);
    const service = new PlatformConfigService(repo);

    const config = await service.getConfig();

    expect(config.requestLifetimeHours).toBe(72);
    expect(config.offerValidityHours).toEqual([24, 48, 72]);
    expect(config.karatList).toEqual([18, 21, 22, 24]);
    expect(config.legal.termsUrl).toBe('https://custom.ae/terms');
    expect(config.legal.privacyUrl).toBe('https://custom.ae/privacy');
    expect(config.support.contactUrl).toBe('https://custom.ae/support');
    expect(config.supportContactUrl).toBe('https://custom.ae/support');
    expect(config.subscriptionContactUrl).toBe('https://wa.me/971500000000');
  });
});
