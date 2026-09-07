import { describe, expect, it } from 'vitest';
import { Prisma } from '@prisma/client';
import { findIdentityKey } from '../../../edge/masking/identity-keys';
import {
  presentRequestForCustomer,
  presentRequestForVendor,
  type FullPrismaRequest,
} from './request.presenter';

describe('request.presenter', () => {
  const mockFullRequest: FullPrismaRequest = {
    id: '11111111-1111-1111-1111-111111111111',
    reference: 'KH-RQ-2026-001234',
    customerProfileId: '22222222-2222-2222-2222-222222222222',
    requestType: 'FIND_ORNAMENT',
    direction: 'BUY',
    state: 'PUBLISHED',
    categoryId: 'cat-1',
    regionId: 'reg-1',
    notes: 'Looking for a ring',
    weightGrams: new Prisma.Decimal(8.5),
    weightIsApproximate: true,
    purityKarat: 'K18',
    ornamentType: 'RING',
    condition: null,
    denominationGrams: null,
    quantity: null,
    mintOrRefiner: null,
    budgetMin: new Prisma.Decimal(2000),
    budgetMax: new Prisma.Decimal(2500),
    budgetIsFlexible: true,
    indicativeValue: new Prisma.Decimal(2200),
    goldRateId: 'gr-1',
    gemstones: { present: true, type: 'diamond' },
    publishedAt: new Date('2026-01-01T10:00:00Z'),
    expiresAt: new Date('2026-01-03T10:00:00Z'),
    expiryWarnedAt: null,
    draftPurgeWarnedAt: null,
    offerCount: 2,
    acceptedOfferId: null,
    cancellationReason: null,
    createdAt: new Date('2026-01-01T09:00:00Z'),
    updatedAt: new Date('2026-01-01T10:00:00Z'),
    category: {
      id: 'cat-1',
      nameEn: 'Jewellery',
      nameAr: 'مجوهرات',
      parentId: null,
      icon: 'sparkle',
      displayOrder: 1,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    region: {
      id: 'reg-1',
      nameEn: 'Dubai',
      nameAr: 'دبي',
      parentId: null,
      displayOrder: 1,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    media: [
      {
        requestId: '11111111-1111-1111-1111-111111111111',
        mediaId: 'm-1',
        displayOrder: 0,
        media: {
          id: 'm-1',
          key: 'med-key-1',
          purpose: 'REQUEST_IMAGE',
          state: 'READY',
          bucket: 'REQUEST_MEDIA',
          contentType: 'image/jpeg',
          byteSize: 102400,
          uploadedByUserId: 'user-999',
          quarantineReason: null,
          malwareScanState: 'CLEAN',
          exifStripped: true,
          sha256: null,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      },
    ],
  };

  it('does NOT leak any identity keys on presentRequestForCustomer', () => {
    const presented = presentRequestForCustomer(mockFullRequest);
    const leakedKey = findIdentityKey(presented);
    expect(leakedKey).toBeNull();
    expect(presented.id).toBe(mockFullRequest.id);
    expect(presented.reference).toBe('KH-RQ-2026-001234');
    expect(presented.category.nameEn).toBe('Jewellery');
    expect(presented.region.nameEn).toBe('Dubai');
    expect(presented.media).toHaveLength(1);
    expect(presented.media[0].key).toBe('med-key-1');
  });

  it('does NOT leak any identity keys on presentRequestForVendor', () => {
    const presented = presentRequestForVendor(mockFullRequest, {
      customerConnectionCount: 3,
      viewedAt: new Date('2026-01-01T11:00:00Z'),
    });
    const leakedKey = findIdentityKey(presented);
    expect(leakedKey).toBeNull();
    expect(presented.customer.label).toBe('Customer · Dubai');
    expect(presented.customer.connectionCount).toBe(3);
    expect(presented.viewedAt).toBe('2026-01-01T11:00:00.000Z');
  });

  it('joins connectionId from unique Connection.offer_id when ACCEPTED (G2-C05 / SAM-GAP-3)', () => {
    const presented = presentRequestForCustomer({
      ...mockFullRequest,
      state: 'ACCEPTED',
      acceptedOfferId: 'offer-win',
      acceptedOffer: { id: 'offer-win', connection: { id: 'conn-deep-link' } },
    });
    expect(presented.state).toBe('ACCEPTED');
    expect(presented.acceptedOfferId).toBe('offer-win');
    expect(presented.connectionId).toBe('conn-deep-link');
    expect(findIdentityKey(presented)).toBeNull();
  });

  it('omits connectionId unless state is ACCEPTED', () => {
    const presented = presentRequestForCustomer({
      ...mockFullRequest,
      state: 'PUBLISHED',
      acceptedOffer: { id: 'offer-win', connection: { id: 'conn-deep-link' } },
    });
    expect(presented.connectionId).toBeUndefined();
  });
});
