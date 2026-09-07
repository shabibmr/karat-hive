import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { PrismaService } from '../../../platform/db/prisma.service';

export type PlatformConfig = {
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
  termsUrl?: string;
  privacyUrl?: string;
  supportContactUrl?: string;
  subscriptionContactUrl?: string;
};

const DEFAULT_CONFIG: PlatformConfig = {
  requestLifetimeHours: 48,
  offerValidityHours: [12, 24, 48],
  defaultOfferValidityHours: 24,
  bullionMinimumAed: '500.00',
  maxConcurrentLiveRequests: 10,
  maxRequestImages: 5,
  maxOfferImages: 3,
  maxImageBytes: 5242880,
  acceptedImageTypes: ['image/jpeg', 'image/png', 'image/webp'],
  karatList: ['24K', '22K', '21K', '18K'],
  maxOfferRevisions: 3,
  requestExpiryWarningHours: 6,
  termsUrl: 'https://karathive.ae/legal/terms',
  privacyUrl: 'https://karathive.ae/legal/privacy',
  supportContactUrl: 'https://karathive.ae/support',
  subscriptionContactUrl: 'https://karathive.ae/subscriptions',
};

@Injectable()
export class PlatformConfigQuery {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Clients must not cache past meta.serverTime + 5 min (BR-020, G2-P01).
   */
  async getPlatformConfig(): Promise<PlatformConfig> {
    const rows = await this.prisma.platformSetting.findMany();
    if (!rows || rows.length === 0) {
      // Empty DB -> 500, not invented defaults (G2-P01)
      throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, ErrorCode.INTERNAL);
    }

    const map = new Map<string, unknown>();
    for (const r of rows) {
      map.set(r.key, r.value);
    }

    return {
      requestLifetimeHours:
        (map.get('request.lifetime_hours') as number) ?? DEFAULT_CONFIG.requestLifetimeHours,
      offerValidityHours:
        (map.get('offer.validity_hours_options') as number[]) ?? DEFAULT_CONFIG.offerValidityHours,
      defaultOfferValidityHours:
        (map.get('offer.default_validity_hours') as number) ??
        DEFAULT_CONFIG.defaultOfferValidityHours,
      bullionMinimumAed: String(
        map.get('bullion.minimum_value_aed') ?? DEFAULT_CONFIG.bullionMinimumAed,
      ),
      maxConcurrentLiveRequests:
        (map.get('request.max_concurrent_live') as number) ??
        DEFAULT_CONFIG.maxConcurrentLiveRequests,
      maxRequestImages:
        (map.get('media.request.max_images') as number) ?? DEFAULT_CONFIG.maxRequestImages,
      maxOfferImages:
        (map.get('media.offer.max_images') as number) ?? DEFAULT_CONFIG.maxOfferImages,
      maxImageBytes:
        (map.get('media.image.max_bytes') as number) ?? DEFAULT_CONFIG.maxImageBytes,
      acceptedImageTypes:
        (map.get('media.image.accepted_types') as string[]) ?? DEFAULT_CONFIG.acceptedImageTypes,
      karatList: (map.get('karat.options') as string[]) ?? DEFAULT_CONFIG.karatList,
      maxOfferRevisions:
        (map.get('offer.max_revisions') as number) ?? DEFAULT_CONFIG.maxOfferRevisions,
      requestExpiryWarningHours:
        (map.get('request.expiry_warning_hours') as number) ??
        DEFAULT_CONFIG.requestExpiryWarningHours,
      termsUrl: (map.get('legal.terms_url') as string) ?? DEFAULT_CONFIG.termsUrl,
      privacyUrl: (map.get('legal.privacy_url') as string) ?? DEFAULT_CONFIG.privacyUrl,
      supportContactUrl:
        (map.get('support.contact_url') as string) ?? DEFAULT_CONFIG.supportContactUrl,
    };
  }
}
