import { describe, expect, it } from 'vitest';
import { presentRequestForVendor } from '../../src/modules/requests/presenter/request.presenter';
import { assertIdentityKeysAbsent } from './assert-identity-absent';

describe('Masking: GET /v1/matches (G2-M07, NFR-013, FR-VEN-011)', () => {
  const samplePrismaRequest = {
    id: 'req-uuid-1',
    customerId: 'cust-user-1',
    customerProfileId: 'cust-prof-1',
    reference: 'KH-REQ-2026-00042',
    requestType: 'FIND_ORNAMENT' as const,
    direction: 'BUY' as const,
    state: 'PUBLISHED' as const,
    categoryId: 'cat-1',
    regionId: 'reg-1',
    notes: 'Custom engagement ring in 22K',
    weightGrams: '12.50' as unknown as import('@prisma/client').Prisma.Decimal,
    weightIsApproximate: false,
    purityKarat: 'K22' as const,
    ornamentType: 'RING' as const,
    condition: 'NEW' as const,
    denominationGrams: null,
    quantity: null,
    mintOrRefiner: null,
    budgetMin: '3000.00' as unknown as import('@prisma/client').Prisma.Decimal,
    budgetMax: '4000.00' as unknown as import('@prisma/client').Prisma.Decimal,
    budgetIsFlexible: false,
    indicativeValue: null,
    gemstones: null,
    cancellationReason: null,
    acceptedOfferId: null,
    draftPurgeWarnedAt: null,
    publishedAt: new Date('2026-09-06T10:00:00Z'),
    expiresAt: new Date('2026-09-08T10:00:00Z'),
    offerCount: 1,
    createdAt: new Date('2026-09-06T10:00:00Z'),
    updatedAt: new Date('2026-09-06T10:00:00Z'),
    category: {
      id: 'cat-1',
      parentId: null,
      nameEn: 'Gold Ring',
      nameAr: 'خاتم ذهب',
      displayOrder: 1,
      isActive: true,
      icon: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    region: {
      id: 'reg-1',
      parentId: null,
      nameEn: 'Dubai',
      nameAr: 'دبي',
      displayOrder: 1,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    media: [],
  };

  it('ensures Customer identity keys are strictly absent from vendor match feed item', () => {
    const presented = presentRequestForVendor(samplePrismaRequest, {
      customerConnectionCount: 3,
      customerRating: {
        average: '4.8',
        count: 5,
        distribution: {},
        limitedHistory: false,
      },
      viewedAt: null,
    });

    // Masking assertion on full payload structure
    assertIdentityKeysAbsent(presented, 'GET /v1/matches payload');

    // Explicit absence checks
    expect((presented as Record<string, unknown>).displayName).toBeUndefined();
    expect((presented as Record<string, unknown>).mobileNumber).toBeUndefined();
    expect((presented as Record<string, unknown>).email).toBeUndefined();
    expect((presented as Record<string, unknown>).customerId).toBeUndefined();
    expect((presented as Record<string, unknown>).customerProfileId).toBeUndefined();

    // Verify pseudonym is correctly formed per specification
    expect(presented.customer.label).toBe('Customer · Dubai');
  });
});
