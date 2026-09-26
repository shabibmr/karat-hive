import { describe, expect, it } from 'vitest';
import { Decimal } from '@prisma/client/runtime/library';
import { presentConnectionForCustomer } from './connection.presenter';
import type { PrismaConnectionWithDetails } from './connection.presenter';

function baseConnection(
  overrides: Partial<PrismaConnectionWithDetails['vendorProfile']> = {},
): PrismaConnectionWithDetails {
  return {
    id: 'conn-1',
    offerId: 'offer-1',
    requestId: 'req-1',
    state: 'ACTIVE',
    identityRevealedAt: new Date('2026-09-07T12:00:00Z'),
    closedAt: null,
    closedBy: null,
    offer: {
      id: 'offer-1',
      offeredPrice: new Decimal(2500),
      weightGrams: new Decimal(10),
      purityKarat: '22K',
      makingCharges: null,
      ratePerGram: null,
      deliveryTimeframe: null,
      warrantyTerms: null,
      vendorNote: null,
    },
    request: {
      id: 'req-1',
      reference: 'KH-2026-0001',
      requestType: 'FIND_ORNAMENT',
      direction: 'BUY',
      category: { id: 'cat-1', nameEn: 'Rings', nameAr: 'خواتم', isActive: true, displayOrder: 1 },
      region: { id: 'reg-1', nameEn: 'Dubai', nameAr: 'دبي', isActive: true, displayOrder: 1 },
    },
    customerProfile: {
      id: 'cust-1',
      displayName: 'Fatima Al Mansoori',
      connectionCount: 1,
      aggregateRating: new Decimal(5.0),
      reviewCount: 3,
      user: { id: 'user-c1', mobileNumber: '+971501112233' },
    },
    vendorProfile: {
      id: 'vendor-1',
      legalBusinessName: 'Al Baraka Jewellery LLC',
      tradingName: 'Al Baraka Gold',
      tradeLicenceNumber: 'CN-9876543',
      offersAcceptedCount: 5,
      aggregateRating: new Decimal(4.9),
      reviewCount: 10,
      user: { id: 'user-v1', mobileNumber: '+971509998877' },
      regions: [
        { region: { id: 'reg-1', nameEn: 'Dubai', nameAr: 'دبي', isActive: true, displayOrder: 1 } },
      ],
      ...overrides,
    },
  } as unknown as PrismaConnectionWithDetails;
}

describe('presentConnectionForCustomer logoUrl (Phase 4 fix)', () => {
  it('resolves vendor.logoUrl from the logoMedia relation when a logo is set', () => {
    const conn = baseConnection({
      logoMedia: { key: 'media-key-abc' },
    } as never);

    const result = presentConnectionForCustomer(conn);

    expect(result.vendor.logoUrl).toBe('/v1/media/media-key-abc');
  });

  it('is null when the vendor has no logoMedia', () => {
    const conn = baseConnection();

    const result = presentConnectionForCustomer(conn);

    expect(result.vendor.logoUrl).toBeNull();
  });
});
