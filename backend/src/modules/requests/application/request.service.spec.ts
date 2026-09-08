import { beforeEach, describe, expect, it, vi } from 'vitest';
import { Prisma } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';
import type { MediaService } from '../../media/application/media.service';
import type { PlatformConfigQuery } from '../../taxonomy/application/platform-config.query';
import type { FullPrismaRequest, RequestForVendor } from '../presenter/request.presenter';
import type { RequestRepository } from '../repository/request.repository';
import { RequestService } from './request.service';

type MockPrisma = {
  $transaction: ReturnType<typeof vi.fn>;
  category: { findFirst: ReturnType<typeof vi.fn> };
  customerProfile: { findUnique: ReturnType<typeof vi.fn> };
  region: { findFirst: ReturnType<typeof vi.fn> };
  outboxEvent: { create: ReturnType<typeof vi.fn> };
  offer: { updateMany: ReturnType<typeof vi.fn> };
};

type MockRepo = {
  createDraft: ReturnType<typeof vi.fn>;
  findById: ReturnType<typeof vi.fn>;
  findByIdForCustomer: ReturnType<typeof vi.fn>;
  countLiveRequestsForCustomer: ReturnType<typeof vi.fn>;
  update: ReturnType<typeof vi.fn>;
  syncMedia: ReturnType<typeof vi.fn>;
  listForCustomer: ReturnType<typeof vi.fn>;
  findActiveMatch: ReturnType<typeof vi.fn>;
  getLatestGoldRate: ReturnType<typeof vi.fn>;
  hasOauthBinding: ReturnType<typeof vi.fn>;
};

type MockMediaService = {
  getAttachable: ReturnType<typeof vi.fn>;
};

type MockPlatformConfig = {
  getPlatformConfig: ReturnType<typeof vi.fn>;
};

type MockAudit = {
  append: ReturnType<typeof vi.fn>;
};

describe('RequestService', () => {
  let service: RequestService;
  let mockPrisma: MockPrisma;
  let mockRepo: MockRepo;
  let mockMediaService: MockMediaService;
  let mockPlatformConfig: MockPlatformConfig;
  let mockAudit: MockAudit;

  const customerViewer: ViewerContext = {
    userId: 'user-cust-1',
    role: 'CUSTOMER',
    tokenVersion: 0,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    customerProfileId: 'cust-prof-1',
    vendorProfileId: null,
    vendorVerificationState: null,
    vendorActivatedAt: null,
    adminProfileId: null,
  };

  const sampleRequestRow: FullPrismaRequest = {
    id: 'req-1',
    reference: null,
    customerProfileId: 'cust-prof-1',
    requestType: 'FIND_ORNAMENT',
    direction: 'BUY',
    state: 'DRAFT',
    categoryId: 'cat-1',
    regionId: 'reg-1',
    notes: 'A sample ring request',
    weightGrams: null,
    weightIsApproximate: false,
    purityKarat: 'K18',
    ornamentType: 'RING',
    condition: null,
    denominationGrams: null,
    quantity: null,
    mintOrRefiner: null,
    budgetMin: null,
    budgetMax: null,
    budgetIsFlexible: false,
    indicativeValue: null,
    goldRateId: null,
    gemstones: null,
    publishedAt: null,
    expiresAt: null,
    expiryWarnedAt: null,
    draftPurgeWarnedAt: null,
    offerCount: 0,
    acceptedOfferId: null,
    cancellationReason: null,
    createdAt: new Date('2026-01-01T10:00:00Z'),
    updatedAt: new Date('2026-01-01T10:00:00Z'),
    category: {
      id: 'cat-1',
      nameEn: 'Jewellery',
      nameAr: 'مجوهرات',
      parentId: null,
      icon: null,
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
        requestId: 'req-1',
        mediaId: 'm-1',
        displayOrder: 0,
        media: {
          id: 'm-1',
          key: 'key-1',
          purpose: 'REQUEST_IMAGE',
          state: 'READY',
          bucket: 'REQUEST_MEDIA',
          contentType: 'image/jpeg',
          byteSize: 1000,
          uploadedByUserId: 'user-cust-1',
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

  beforeEach(() => {
    mockPrisma = {
      $transaction: vi.fn((cb) => cb(mockPrisma)),
      category: {
        findFirst: vi.fn().mockResolvedValue({ id: 'cat-1' }),
      },
      customerProfile: {
        findUnique: vi.fn().mockResolvedValue({ defaultRegionId: 'reg-1', connectionCount: 2 }),
      },
      region: {
        findFirst: vi.fn().mockResolvedValue({ id: 'reg-1' }),
      },
      outboxEvent: {
        create: vi.fn().mockResolvedValue({ id: 'outbox-1' }),
      },
      offer: {
        updateMany: vi.fn().mockResolvedValue({ count: 1 }),
      },
    };

    mockRepo = {
      createDraft: vi.fn().mockResolvedValue(sampleRequestRow),
      findById: vi.fn().mockResolvedValue(sampleRequestRow),
      findByIdForCustomer: vi.fn().mockResolvedValue(sampleRequestRow),
      countLiveRequestsForCustomer: vi.fn().mockResolvedValue(0),
      update: vi.fn().mockImplementation((id, data) => ({
        ...sampleRequestRow,
        ...data,
      })),
      syncMedia: vi.fn().mockResolvedValue(undefined),
      listForCustomer: vi.fn().mockResolvedValue({ items: [sampleRequestRow], nextCursor: null }),
      findActiveMatch: vi
        .fn()
        .mockResolvedValue({ id: 'match-1', viewedAt: null, isEligible: true }),
      getLatestGoldRate: vi.fn().mockResolvedValue({
        id: 'rate-1',
        purityKarat: 'K18',
        ratePerGramAed: new Prisma.Decimal(250),
      }),
      hasOauthBinding: vi.fn().mockResolvedValue(true),
    };

    mockMediaService = {
      getAttachable: vi.fn().mockResolvedValue({ id: 'm-1', key: 'key-1', state: 'READY' }),
    };

    mockPlatformConfig = {
      getPlatformConfig: vi.fn().mockResolvedValue({
        requestLifetimeHours: 48,
        bullionMinimumAed: '500.00',
        maxConcurrentLiveRequests: 10,
      }),
    };

    mockAudit = {
      append: vi.fn().mockResolvedValue(undefined),
    };

    service = new RequestService(
      mockPrisma as unknown as PrismaService,
      mockRepo as unknown as RequestRepository,
      mockMediaService as unknown as MediaService,
      mockPlatformConfig as unknown as PlatformConfigQuery,
      mockAudit as unknown as AuditWriter,
    );
  });

  describe('createDraft', () => {
    it('creates a draft and returns warnings if contact details are in notes', async () => {
      const res = await service.createDraft(customerViewer, {
        requestType: 'FIND_ORNAMENT',
        notes: 'Call me at 0501234567',
        categoryId: 'cat-1',
        regionId: 'reg-1',
      });

      expect(res.data.id).toBe('req-1');
      expect(res.warnings).toHaveLength(1);
      expect(res.warnings[0]).toContain('Potential contact details detected');
      expect(mockRepo.createDraft).toHaveBeenCalled();
      expect(mockAudit.append).toHaveBeenCalled();
    });

    it('rejects if non-customer attempts to create', async () => {
      const vendorViewer: ViewerContext = {
        ...customerViewer,
        role: 'VENDOR',
        customerProfileId: null,
      };
      await expect(
        service.createDraft(vendorViewer, { requestType: 'FIND_ORNAMENT' }),
      ).rejects.toThrow(ApiException);
    });
  });

  describe('update', () => {
    it('allows full edit in DRAFT state', async () => {
      const res = await service.update(customerViewer, 'req-1', {
        notes: 'Updated notes',
        budgetMin: 1000,
      });

      expect(res.data.notes).toBe('Updated notes');
      expect(mockRepo.update).toHaveBeenCalled();
    });

    it('throws 409 STRUCTURAL_FIELD_IMMUTABLE if structural fields edited on PUBLISHED request', async () => {
      mockRepo.findByIdForCustomer.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'PUBLISHED',
      });

      await expect(
        service.update(customerViewer, 'req-1', {
          purityKarat: 'K22',
        }),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.STRUCTURAL_FIELD_IMMUTABLE,
        }),
      );
    });

    it('blocks contact details in notes when updating a PUBLISHED request', async () => {
      mockRepo.findByIdForCustomer.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'PUBLISHED',
      });

      await expect(
        service.update(customerViewer, 'req-1', {
          notes: 'Contact 050-987-6543 for discounts',
        }),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.CONTACT_DETAILS_IN_TEXT,
        }),
      );
    });
  });

  describe('publish', () => {
    it('throws 403 OAUTH_REQUIRED when user lacks OAuth binding', async () => {
      mockRepo.hasOauthBinding.mockResolvedValueOnce(false);

      await expect(service.publish(customerViewer, 'req-1')).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.OAUTH_REQUIRED,
        }),
      );
    });

    it('throws 409 CONCURRENT_REQUEST_LIMIT when customer reached live limit', async () => {
      mockRepo.countLiveRequestsForCustomer.mockResolvedValueOnce(10);

      await expect(service.publish(customerViewer, 'req-1')).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.CONCURRENT_REQUEST_LIMIT,
        }),
      );
    });

    it('throws 422 CONTACT_DETAILS_IN_TEXT when notes contain contact info', async () => {
      mockRepo.findByIdForCustomer.mockResolvedValueOnce({
        ...sampleRequestRow,
        notes: 'Email me at test@example.com',
      });

      await expect(service.publish(customerViewer, 'req-1')).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.CONTACT_DETAILS_IN_TEXT,
        }),
      );
    });

    it('throws 422 MEDIA_NOT_READY when an attached media item is not READY', async () => {
      mockRepo.findByIdForCustomer.mockResolvedValueOnce({
        ...sampleRequestRow,
        media: [
          {
            requestId: 'req-1',
            mediaId: 'm-1',
            displayOrder: 0,
            media: {
              ...sampleRequestRow.media[0].media,
              state: 'PENDING_PROCESSING',
            },
          },
        ],
      });

      await expect(service.publish(customerViewer, 'req-1')).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.MEDIA_NOT_READY,
        }),
      );
    });

    it('throws 422 MEDIA_QUARANTINED when an attached media item is quarantined', async () => {
      mockRepo.findByIdForCustomer.mockResolvedValueOnce({
        ...sampleRequestRow,
        media: [
          {
            requestId: 'req-1',
            mediaId: 'm-1',
            displayOrder: 0,
            media: {
              ...sampleRequestRow.media[0].media,
              state: 'QUARANTINED',
            },
          },
        ],
      });

      await expect(service.publish(customerViewer, 'req-1')).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.MEDIA_QUARANTINED,
        }),
      );
    });

    it('publishes successfully and enqueues outbox event', async () => {
      const res = await service.publish(customerViewer, 'req-1');

      expect(res.data.state).toBe('PUBLISHED');
      expect(mockRepo.update).toHaveBeenCalled();
      expect(mockPrisma.outboxEvent.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            eventType: 'request.published',
            aggregateType: 'request',
          }),
        }),
      );
    });
  });

  describe('cancel', () => {
    it('cancels request and withdraws pending offers', async () => {
      mockRepo.findByIdForCustomer.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'PUBLISHED',
      });

      const res = await service.cancel(customerViewer, 'req-1', 'Changed mind');

      expect(res.state).toBe('CANCELLED');
      expect(mockPrisma.offer.updateMany).toHaveBeenCalledWith({
        where: { requestId: 'req-1', state: 'PENDING' },
        data: { state: 'WITHDRAWN_BY_SYSTEM' },
      });
      expect(mockPrisma.outboxEvent.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            eventType: 'request.cancelled',
          }),
        }),
      );
    });

    it('throws 409 REQUEST_NOT_CANCELLABLE when request is ACCEPTED', async () => {
      mockRepo.findByIdForCustomer.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'ACCEPTED',
      });

      await expect(service.cancel(customerViewer, 'req-1')).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.REQUEST_NOT_CANCELLABLE,
        }),
      );
    });
  });

  describe('duplicate', () => {
    it('duplicates EXPIRED or CANCELLED requests into new DRAFT', async () => {
      mockRepo.findByIdForCustomer.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'CANCELLED',
      });

      const res = await service.duplicate(customerViewer, 'req-1');

      expect(res.state).toBe('DRAFT');
      expect(mockRepo.createDraft).toHaveBeenCalled();
      expect(mockAudit.append).toHaveBeenCalledWith(
        mockPrisma,
        expect.objectContaining({ action: 'REQUEST_DUPLICATED' }),
      );
    });

    it('throws 409 CONFLICT if request is still active', async () => {
      mockRepo.findByIdForCustomer.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'PUBLISHED',
      });

      await expect(service.duplicate(customerViewer, 'req-1')).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.CONFLICT,
        }),
      );
    });
  });

  describe('getById', () => {
    it('returns RequestForCustomer with offers for owning customer', async () => {
      const res = await service.getById(customerViewer, 'req-1');
      expect(res.id).toBe('req-1');
      expect('customer' in res).toBe(false); // Customer sees their own request directly
    });

    it('populates connectionId on ACCEPTED customer GET via offer_id join (G2-C05)', async () => {
      mockRepo.findById.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'ACCEPTED',
        acceptedOfferId: 'offer-win',
        acceptedOffer: { id: 'offer-win', connection: { id: 'conn-1' } },
      });

      const res = await service.getById(customerViewer, 'req-1');
      expect(res).toMatchObject({
        id: 'req-1',
        state: 'ACCEPTED',
        acceptedOfferId: 'offer-win',
        connectionId: 'conn-1',
      });
    });

    it('returns 404 for other customer', async () => {
      const otherCust: ViewerContext = { ...customerViewer, customerProfileId: 'other-cust' };
      await expect(service.getById(otherCust, 'req-1')).rejects.toThrow(
        expect.objectContaining({
          errorCode: ErrorCode.NOT_FOUND,
        }),
      );
    });

    it('returns RequestForVendor with masked customer for matched vendor', async () => {
      const vendorViewer: ViewerContext = {
        ...customerViewer,
        role: 'VENDOR',
        customerProfileId: null,
        vendorProfileId: 'vend-prof-1',
      };
      mockRepo.findById.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'PUBLISHED',
      });

      const res = (await service.getById(vendorViewer, 'req-1')) as RequestForVendor;
      expect(res.customer).toBeDefined();
      expect(res.customer.label).toBe('Customer · Dubai');
    });
  });

  describe('listCustomerRequests', () => {
    it('populates connectionId on ACCEPTED list rows (G2-C05)', async () => {
      mockRepo.listForCustomer.mockResolvedValueOnce({
        items: [
          {
            ...sampleRequestRow,
            state: 'ACCEPTED',
            acceptedOfferId: 'offer-win',
            acceptedOffer: { id: 'offer-win', connection: { id: 'conn-1' } },
          },
        ],
        nextCursor: null,
      });

      const res = await service.listCustomerRequests(customerViewer, {});
      expect(res.items).toHaveLength(1);
      expect(res.items[0]?.connectionId).toBe('conn-1');
    });

    it('carries unreadOfferCount from the repo _count on list rows (SAM-GAP-1 / CBG-01)', async () => {
      mockRepo.listForCustomer.mockResolvedValueOnce({
        items: [
          { ...sampleRequestRow, state: 'OFFERS_RECEIVED', offerCount: 3, _count: { offers: 3 } },
        ],
        nextCursor: null,
      });

      const res = await service.listCustomerRequests(customerViewer, {});
      expect(res.items[0]?.offerCount).toBe(3);
      expect(res.items[0]?.unreadOfferCount).toBe(3);
    });
  });

  describe('unreadOfferCount on getById', () => {
    it('carries unreadOfferCount from the repo _count on GET /v1/requests/:id (SAM-GAP-1 / CBG-01)', async () => {
      mockRepo.findById.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'OFFERS_RECEIVED',
        offerCount: 2,
        _count: { offers: 1 },
      });

      const res = await service.getById(customerViewer, 'req-1');
      expect(res).toMatchObject({ offerCount: 2, unreadOfferCount: 1 });
    });

    it('reports unreadOfferCount 0 when every offer has been viewed', async () => {
      mockRepo.findById.mockResolvedValueOnce({
        ...sampleRequestRow,
        state: 'OFFERS_RECEIVED',
        offerCount: 2,
        _count: { offers: 0 },
      });

      const res = await service.getById(customerViewer, 'req-1');
      expect(res).toMatchObject({ unreadOfferCount: 0 });
    });
  });
});
