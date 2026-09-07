import { describe, expect, it } from 'vitest';
import { Decimal } from '@prisma/client/runtime/library';
import {
  presentOfferForCustomer,
  presentOfferForVendor,
  type PrismaOfferWithDetails,
} from './offer.presenter';

describe('offer.presenter', () => {
  const sampleOffer: PrismaOfferWithDetails = {
    id: '11111111-1111-1111-1111-111111111111',
    requestId: '22222222-2222-2222-2222-222222222222',
    vendorProfileId: '33333333-3333-3333-3333-333333333333',
    state: 'PENDING',
    offeredPrice: new Decimal(2500),
    makingCharges: new Decimal(100),
    ratePerGram: new Decimal(250),
    deliveryTimeframe: '2-3 days',
    warrantyTerms: '1 year certificate',
    vendorNote: 'Best price for hallmarked jewellery',
    validityHours: 24,
    expiresAt: new Date('2026-09-08T12:00:00Z'),
    expiryWarnedAt: null,
    viewedByCustomerAt: null,
    revisionCount: 0,
    submittedAt: new Date('2026-09-07T12:00:00Z'),
    decidedAt: null,
    declineReason: null,
    createdAt: new Date('2026-09-07T12:00:00Z'),
    updatedAt: new Date('2026-09-07T12:00:00Z'),
    vendorProfile: {
      id: '33333333-3333-3333-3333-333333333333',
      userId: '44444444-4444-4444-4444-444444444444',
      legalBusinessName: 'Secret Gold LLC',
      tradingName: 'Gold Palace',
      tradeLicenceNumber: 'CN-1234567',
      licenceExpiryDate: new Date('2027-01-01'),
      yearsInBusiness: 10,
      description: null,
      verificationState: 'VERIFIED',
      verifiedAt: new Date(),
      verifiedByAdminId: null,
      verificationNotes: null,
      isAvailable: true,
      lastAvailabilityChange: new Date(),
      logoMediaId: null,
      aggregateRating: new Decimal(4.8),
      reviewCount: 15,
      ratingDistribution: { '5': 12, '4': 3 },
      ratingTrend: null,
      offersSubmittedCount: 20,
      offersAcceptedCount: 8,
      connectionCount: 8,
      createdAt: new Date(),
      updatedAt: new Date(),
      regions: [
        {
          vendorProfileId: '33333333-3333-3333-3333-333333333333',
          regionId: '55555555-5555-5555-5555-555555555555',
          region: {
            id: '55555555-5555-5555-5555-555555555555',
            nameEn: 'Deira Gold Souk',
            nameAr: 'سوق الذهب ديرة',
            parentId: null,
            isActive: true,
            displayOrder: 1,
            createdAt: new Date(),
            updatedAt: new Date(),
          },
        },
      ],
    },
    media: [],
  };

  it('masks vendor identity on customer presenter (BR-006 / NFR-013)', () => {
    const presented = presentOfferForCustomer(sampleOffer);

    expect(presented.vendor.label).toBe('Vendor · Deira Gold Souk');
    expect(presented.vendor.connectionCount).toBe(8);
    expect(presented.vendor.rating?.average).toBe('4.8');
    expect(presented.vendor.rating?.count).toBe(15);
    expect(presented.vendor.rating?.limitedHistory).toBe(false);

    // Assert sensitive vendor identity is completely absent from the object
    const serialized = JSON.stringify(presented);
    expect(serialized).not.toContain('Secret Gold LLC');
    expect(serialized).not.toContain('Gold Palace');
    expect(serialized).not.toContain('CN-1234567');
    expect(serialized).not.toContain('44444444-4444-4444-4444-444444444444');
  });

  it('indicates limitedHistory true when reviewCount < 3', () => {
    const freshVendorOffer: PrismaOfferWithDetails = {
      ...sampleOffer,
      vendorProfile: {
        ...sampleOffer.vendorProfile!,
        reviewCount: 2,
        aggregateRating: new Decimal(5.0),
      },
    };

    const presented = presentOfferForCustomer(freshVendorOffer);
    expect(presented.vendor.rating?.limitedHistory).toBe(true);
  });

  it('presents vendor offer without leaking counterparty sensitive fields', () => {
    const presented = presentOfferForVendor(sampleOffer, { awardedElsewhere: true });
    expect(presented.id).toBe(sampleOffer.id);
    expect(presented.awardedElsewhere).toBe(true);
    expect(presented.terms.offeredPrice).toBe('2500');
  });
});
