import { Injectable } from '@nestjs/common';
import { SettingsRepository } from '../repository/settings.repository';
import type {
  MediaLimits,
  PlatformConfigResponse,
} from '../presenter/platform-config.presenter';

const DEFAULT_SETTINGS = {
  requestLifetimeHours: 48,
  offerValidityHours: [12, 24, 48],
  defaultOfferValidityHours: 24,
  bullionMinimumAed: '500.00',
  maxConcurrentLiveRequests: 10,
  maxOfferRevisions: 3,
  requestExpiryWarningHours: 6,
  karatList: ['24K', '22K', '21K', '18K'],
  maxRequestImages: 5,
  maxOfferImages: 3,
  maxImageBytes: 5_242_880,
  maxKycBytes: 10_485_760,
  acceptedImageTypes: ['image/jpeg', 'image/png', 'image/webp'],
  legalTermsUrl: 'https://karathive.ae/legal/terms',
  legalPrivacyUrl: 'https://karathive.ae/legal/privacy',
  legalCurrentTermsVersion: '1.0',
  legalCurrentPrivacyVersion: '1.0',
  supportContactUrl: 'https://karathive.ae/support',
  subscriptionContactUrl: 'https://karathive.ae/support',
};

@Injectable()
export class PlatformConfigService {
  constructor(private readonly repository: SettingsRepository) {}

  async getConfig(): Promise<PlatformConfigResponse> {
    const rows = await this.repository.findAll();
    const map = new Map<string, unknown>();
    for (const row of rows) {
      map.set(row.key, row.value);
    }

    const requestLifetimeHours =
      (map.get('request.lifetime_hours') as number) ??
      DEFAULT_SETTINGS.requestLifetimeHours;

    const offerValidityHours =
      (map.get('offer.validity_hours_options') as number[]) ??
      DEFAULT_SETTINGS.offerValidityHours;

    const defaultOfferValidityHours =
      (map.get('offer.default_validity_hours') as number) ??
      DEFAULT_SETTINGS.defaultOfferValidityHours;

    const bullionMinimumAed =
      (map.get('bullion.minimum_value_aed') as string) ??
      DEFAULT_SETTINGS.bullionMinimumAed;

    const maxConcurrentLiveRequests =
      (map.get('request.max_concurrent_live') as number) ??
      DEFAULT_SETTINGS.maxConcurrentLiveRequests;

    const maxOfferRevisions =
      (map.get('offer.max_revisions') as number) ??
      DEFAULT_SETTINGS.maxOfferRevisions;

    const requestExpiryWarningHours =
      (map.get('request.expiry_warning_hours') as number) ??
      DEFAULT_SETTINGS.requestExpiryWarningHours;

    const rawKarat = map.get('karat.options');
    const karatList: (string | number)[] = Array.isArray(rawKarat)
      ? (rawKarat as (string | number)[])
      : DEFAULT_SETTINGS.karatList;

    const maxImageBytes =
      (map.get('media.image.max_bytes') as number) ??
      DEFAULT_SETTINGS.maxImageBytes;

    const maxKycBytes =
      (map.get('media.kyc.max_bytes') as number) ??
      DEFAULT_SETTINGS.maxKycBytes;

    const termsUrl =
      (map.get('legal.terms_url') as string) ??
      DEFAULT_SETTINGS.legalTermsUrl;

    const privacyUrl =
      (map.get('legal.privacy_url') as string) ??
      DEFAULT_SETTINGS.legalPrivacyUrl;

    const currentTermsVersion =
      (map.get('legal.current_terms_version') as string) ??
      DEFAULT_SETTINGS.legalCurrentTermsVersion;

    const currentPrivacyVersion =
      (map.get('legal.current_privacy_version') as string) ??
      DEFAULT_SETTINGS.legalCurrentPrivacyVersion;

    const supportContactUrl =
      (map.get('support.contact_url') as string) ??
      DEFAULT_SETTINGS.supportContactUrl;

    const subscriptionContactUrl =
      (map.get('subscription.contact_url') as string) ??
      (map.get('subscription_contact_url') as string) ??
      supportContactUrl ??
      DEFAULT_SETTINGS.subscriptionContactUrl;

    const mediaLimits: MediaLimits = {
      maxRequestImages: DEFAULT_SETTINGS.maxRequestImages,
      maxOfferImages: DEFAULT_SETTINGS.maxOfferImages,
      maxImageBytes,
      maxKycBytes,
      acceptedImageTypes: DEFAULT_SETTINGS.acceptedImageTypes,
    };

    return {
      requestLifetimeHours,
      offerValidityHours,
      defaultOfferValidityHours,
      bullionMinimumAed,
      maxConcurrentLiveRequests,
      maxOfferRevisions,
      requestExpiryWarningHours,
      karatList,
      karats: karatList,
      maxRequestImages: DEFAULT_SETTINGS.maxRequestImages,
      maxOfferImages: DEFAULT_SETTINGS.maxOfferImages,
      maxImageBytes,
      acceptedImageTypes: DEFAULT_SETTINGS.acceptedImageTypes,
      mediaLimits,
      media: mediaLimits,
      legal: {
        termsUrl,
        privacyUrl,
        currentTermsVersion,
        currentPrivacyVersion,
      },
      support: {
        contactUrl: supportContactUrl,
      },
      supportContactUrl,
      subscriptionContactUrl,
    };
  }
}
