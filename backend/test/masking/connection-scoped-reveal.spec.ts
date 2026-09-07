import { describe, expect, it } from 'vitest';
import { Prisma } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';
import {
  presentConnectionForCustomer,
  presentConnectionForVendor,
  type PrismaConnectionWithDetails,
} from '../../src/modules/connections/presenter/connection.presenter';
import { presentOfferForCustomer } from '../../src/modules/offers/presenter/offer.presenter';
import {
  presentRequestForCustomer,
  presentRequestForVendor,
  type FullPrismaRequest,
} from '../../src/modules/requests/presenter/request.presenter';
import { assertIdentityKeysAbsent } from './assert-identity-absent';

/**
 * G2-C07 / BR-007: identity revealed on Connection N does not generalise to
 * a later Request between the same Customer and Vendor.
 */
describe('Masking: reveal is scoped to this Connection (G2-C07 / BR-007)', () => {
  const now = new Date('2026-09-07T12:00:00Z');

  const category = {
    id: 'cat-1',
    nameEn: 'Jewellery',
    nameAr: 'مجوهرات',
    parentId: null,
    icon: null,
    displayOrder: 1,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  };

  const region = {
    id: 'reg-1',
    nameEn: 'Dubai',
    nameAr: 'دبي',
    parentId: null,
    displayOrder: 1,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  };

  const acceptedConnection = {
    id: 'conn-1',
    offerId: 'offer-1',
    requestId: 'req-1',
    customerProfileId: 'cust-prof-1',
    vendorProfileId: 'vend-prof-1',
    state: 'ACTIVE',
    identityRevealedAt: now,
    closedAt: null,
    closedBy: null,
    createdAt: now,
    updatedAt: now,
    offer: {
      id: 'offer-1',
      offeredPrice: new Decimal(2500),
      makingCharges: null,
      ratePerGram: null,
      validityHours: 24,
      deliveryTimeframe: null,
      warrantyTerms: null,
      vendorNote: null,
    },
    request: {
      id: 'req-1',
      reference: 'KH-RQ-2026-000001',
      requestType: 'FIND_ORNAMENT',
      direction: 'BUY',
      category,
      region,
    },
    customerProfile: {
      id: 'cust-prof-1',
      displayName: 'Fatima Al Mansoori',
      connectionCount: 1,
      aggregateRating: new Decimal(5.0),
      reviewCount: 3,
      user: {
        id: 'user-c1',
        mobileNumber: '+971501112233',
      },
    },
    vendorProfile: {
      id: 'vend-prof-1',
      legalBusinessName: 'Al Baraka Jewellery LLC',
      tradingName: 'Al Baraka Gold',
      tradeLicenceNumber: 'CN-9876543',
      offersAcceptedCount: 5,
      aggregateRating: new Decimal(4.9),
      reviewCount: 10,
      user: {
        id: 'user-v1',
        mobileNumber: '+971509998877',
      },
      regions: [{ region }],
    },
  } as unknown as PrismaConnectionWithDetails;

  const secondRequest: FullPrismaRequest = {
    id: 'req-2',
    reference: 'KH-RQ-2026-000002',
    customerProfileId: 'cust-prof-1',
    requestType: 'FIND_ORNAMENT',
    direction: 'BUY',
    state: 'PUBLISHED',
    categoryId: 'cat-1',
    regionId: 'reg-1',
    notes: 'Another ring',
    weightGrams: new Prisma.Decimal(10),
    weightIsApproximate: false,
    purityKarat: 'K18',
    ornamentType: 'RING',
    condition: null,
    denominationGrams: null,
    quantity: null,
    mintOrRefiner: null,
    budgetMin: new Prisma.Decimal(2000),
    budgetMax: new Prisma.Decimal(3000),
    budgetIsFlexible: false,
    indicativeValue: null,
    goldRateId: null,
    gemstones: null,
    publishedAt: now,
    expiresAt: new Date('2026-09-09T12:00:00Z'),
    expiryWarnedAt: null,
    draftPurgeWarnedAt: null,
    offerCount: 1,
    acceptedOfferId: null,
    cancellationReason: null,
    createdAt: now,
    updatedAt: now,
    category,
    region,
    media: [],
  };

  const secondOfferFromSameVendor = {
    id: 'offer-2',
    requestId: 'req-2',
    vendorProfileId: 'vend-prof-1',
    state: 'PENDING' as const,
    offeredPrice: new Decimal(2600),
    makingCharges: null,
    ratePerGram: null,
    deliveryTimeframe: null,
    warrantyTerms: null,
    vendorNote: null,
    validityHours: 24,
    expiresAt: new Date('2026-09-08T12:00:00Z'),
    expiryWarnedAt: null,
    viewedByCustomerAt: null,
    revisionCount: 0,
    submittedAt: now,
    decidedAt: null,
    declineReason: null,
    createdAt: now,
    updatedAt: now,
    vendorProfile: {
      id: 'vend-prof-1',
      userId: 'user-v1',
      legalBusinessName: 'Al Baraka Jewellery LLC',
      tradingName: 'Al Baraka Gold',
      tradeLicenceNumber: 'CN-9876543',
      licenceExpiryDate: new Date('2027-01-01'),
      yearsInBusiness: 10,
      description: null,
      verificationState: 'VERIFIED' as const,
      verifiedAt: now,
      verifiedByAdminId: null,
      verificationNotes: null,
      isAvailable: true,
      lastAvailabilityChange: now,
      logoMediaId: null,
      aggregateRating: new Decimal(4.9),
      reviewCount: 10,
      ratingDistribution: {},
      ratingTrend: null,
      offersSubmittedCount: 21,
      offersAcceptedCount: 5,
      connectionCount: 5,
      createdAt: now,
      updatedAt: now,
      regions: [
        {
          vendorProfileId: 'vend-prof-1',
          regionId: 'reg-1',
          region,
        },
      ],
    },
    media: [],
  };

  it('reveals identities on the Connection that produced the accept', () => {
    const forCustomer = presentConnectionForCustomer(acceptedConnection);
    expect(forCustomer.vendor.tradingName).toBe('Al Baraka Gold');
    expect(forCustomer.vendor.legalBusinessName).toBe('Al Baraka Jewellery LLC');
    expect(forCustomer.vendor.tradeLicenceNumber).toBe('CN-9876543');
    expect(forCustomer.vendor.phone).toBe('+971509998877');

    const forVendor = presentConnectionForVendor(acceptedConnection);
    expect(forVendor.customer.displayName).toBe('Fatima Al Mansoori');
    expect(forVendor.customer.phone).toBe('+971501112233');
  });

  it('keeps a second Request between the same parties masked', () => {
    const vendorView = presentRequestForVendor(secondRequest, {
      customerConnectionCount: 1,
    });
    assertIdentityKeysAbsent(vendorView, 'second RequestForVendor');
    expect(vendorView.customer.label).toBe('Customer · Dubai');
    expect((vendorView as Record<string, unknown>).displayName).toBeUndefined();
    expect((vendorView as Record<string, unknown>).mobileNumber).toBeUndefined();
    expect(JSON.stringify(vendorView)).not.toContain('Fatima Al Mansoori');
    expect(JSON.stringify(vendorView)).not.toContain('+971501112233');

    const customerView = presentRequestForCustomer(secondRequest);
    assertIdentityKeysAbsent(customerView, 'second RequestForCustomer');
    expect(customerView.connectionId).toBeUndefined();
    expect(JSON.stringify(customerView)).not.toContain('Al Baraka Gold');
    expect(JSON.stringify(customerView)).not.toContain('+971509998877');

    const offerView = presentOfferForCustomer(secondOfferFromSameVendor);
    assertIdentityKeysAbsent(offerView, 'second OfferForCustomer');
    expect(offerView.vendor.label).toBe('Vendor · Dubai');
    expect(JSON.stringify(offerView)).not.toContain('Al Baraka Jewellery LLC');
    expect(JSON.stringify(offerView)).not.toContain('Al Baraka Gold');
    expect(JSON.stringify(offerView)).not.toContain('CN-9876543');
    expect(JSON.stringify(offerView)).not.toContain('+971509998877');
  });
});
