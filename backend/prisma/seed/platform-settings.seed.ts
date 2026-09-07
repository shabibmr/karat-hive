import type { PrismaClient } from '@prisma/client';

type Setting = { key: string; value: unknown; dataType: string };

const SETTINGS: Setting[] = [
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
  { key: 'subscription.contact_url', value: 'https://karathive.ae/subscriptions', dataType: 'url' },
  { key: 'request.max_images', value: 5, dataType: 'number' },
  { key: 'offer.max_images', value: 3, dataType: 'number' },
  {
    key: 'media.image.accepted_types',
    value: ['image/jpeg', 'image/png', 'image/webp'],
    dataType: 'string[]',
  },
  { key: 'legal.current_terms_version', value: '1.0', dataType: 'string' },
  { key: 'legal.current_privacy_version', value: '1.0', dataType: 'string' },
  // Gold-rate ingest + Admin override (G2-GR01–GR04). End-user display stays
  // off until G2-D04 (Yahoo redistribution) is signed.
  { key: 'goldRates.endUserDisplay', value: false, dataType: 'boolean' },
  { key: 'goldRates.pollIntervalMinutes', value: 15, dataType: 'number' },
  { key: 'goldRates.stalenessThresholdMinutes', value: 60, dataType: 'number' },
  {
    key: 'goldRates.purityFactors',
    value: { '24K': 1, '22K': 22 / 24, '21K': 21 / 24, '18K': 18 / 24 },
    dataType: 'json',
  },
];

export async function seedPlatformSettings(prisma: PrismaClient): Promise<void> {
  for (const s of SETTINGS) {
    await prisma.platformSetting.upsert({
      where: { key: s.key },
      update: { value: s.value as object, dataType: s.dataType },
      create: { key: s.key, value: s.value as object, dataType: s.dataType },
    });
  }
}
