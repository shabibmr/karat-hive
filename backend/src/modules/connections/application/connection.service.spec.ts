import { describe, expect, it, vi, beforeEach } from 'vitest';
import { Decimal } from '@prisma/client/runtime/library';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { Clock } from '../../../shared/clock';
import { ConnectionService } from './connection.service';
import type { ConnectionRepository } from '../repository/connection.repository';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';

describe('ConnectionService', () => {
  let service: ConnectionService;
  let repo: ConnectionRepository;
  let prisma: PrismaService;
  let auditWriter: AuditWriter;
  const mockNow = new Date('2026-09-07T12:00:00Z');
  const mockClock: Clock = { now: () => mockNow } as Clock;

  const customerViewer: ViewerContext = {
    userId: 'user-c1',
    role: 'CUSTOMER',
    tokenVersion: 1,
    customerProfileId: 'cust-1',
  };

  const mockConnection = {
    id: 'conn-1',
    offerId: 'offer-1',
    requestId: 'req-1',
    customerProfileId: 'cust-1',
    vendorProfileId: 'vendor-1',
    state: 'ACTIVE',
    identityRevealedAt: mockNow,
    closedAt: null,
    closedBy: null,
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
      user: {
        id: 'user-c1',
        mobileNumber: '+971501112233',
      },
    },
    vendorProfile: {
      id: 'vendor-1',
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
      regions: [
        {
          region: { id: 'reg-1', nameEn: 'Dubai', nameAr: 'دبي', isActive: true, displayOrder: 1 },
        },
      ],
    },
  };

  beforeEach(() => {
    repo = {
      findConnectionById: vi.fn().mockResolvedValue(mockConnection),
      findConnectionByOfferId: vi.fn().mockResolvedValue(mockConnection),
      listConnectionsForCustomer: vi.fn().mockResolvedValue({ items: [mockConnection] }),
      listConnectionsForVendor: vi.fn().mockResolvedValue({ items: [mockConnection] }),
      closeConnection: vi.fn().mockImplementation(async (id, closedBy, now) => ({
        ...mockConnection,
        state: 'CLOSED',
        closedBy,
        closedAt: now,
      })),
      recordContactEvent: vi.fn().mockResolvedValue({ id: 'evt-1' }),
    } as unknown as ConnectionRepository;

    auditWriter = {
      append: vi.fn().mockResolvedValue(undefined),
    } as unknown as AuditWriter;

    prisma = {
      $transaction: vi.fn(async (cb) =>
        cb({
          offer: {
            findUnique: vi.fn().mockResolvedValue({
              id: 'offer-1',
              requestId: 'req-1',
              vendorProfileId: 'vendor-1',
              state: 'PENDING',
              expiresAt: new Date('2026-09-08T12:00:00Z'),
            }),
            findMany: vi.fn().mockResolvedValue([{ id: 'offer-loser' }]),
            update: vi.fn().mockResolvedValue({}),
            updateMany: vi.fn().mockResolvedValue({ count: 1 }),
          },
          $queryRaw: vi.fn().mockResolvedValue([
            {
              id: 'req-1',
              state: 'OFFERS_RECEIVED',
              customer_profile_id: 'cust-1',
              expires_at: new Date('2026-09-09T12:00:00Z'),
            },
          ]),
          request: {
            update: vi.fn().mockResolvedValue({}),
          },
          connection: {
            create: vi.fn().mockResolvedValue({ id: 'conn-1' }),
          },
          customerProfile: {
            update: vi.fn().mockResolvedValue({}),
          },
          vendorProfile: {
            update: vi.fn().mockResolvedValue({}),
            findUnique: vi.fn().mockResolvedValue({ userId: 'user-v1' }),
          },
          outboxEvent: {
            create: vi.fn().mockResolvedValue({}),
          },
        }),
      ),
      offer: {
        findUnique: vi.fn().mockResolvedValue({
          id: 'offer-1',
          requestId: 'req-1',
          state: 'ACCEPTED',
          offeredPrice: new Decimal(2500),
          makingCharges: null,
          ratePerGram: null,
          validityHours: 24,
          submittedAt: mockNow,
          expiresAt: new Date('2026-09-08T12:00:00Z'),
          revisionCount: 0,
          media: [],
          vendorProfile: mockConnection.vendorProfile,
        }),
      },
    } as unknown as PrismaService;

    service = new ConnectionService(repo, prisma, auditWriter, mockClock);
  });

  describe('acceptOffer', () => {
    it('successfully executes atomic acceptance transaction', async () => {
      const res = await service.acceptOffer(
        customerViewer,
        'offer-1',
        'REVEAL_AND_CONNECT',
      );

      expect(res.connection.id).toBe('conn-1');
      expect(res.connection.state).toBe('ACTIVE');
      expect(res.connection.vendor.tradingName).toBe('Al Baraka Gold');
      expect(res.connection.talk.waUrl).toContain('wa.me/971509998877');
      expect(auditWriter.append).toHaveBeenCalled();
    });

    it('rejects without explicit confirmation string', async () => {
      await expect(
        service.acceptOffer(customerViewer, 'offer-1', 'YES' as unknown as 'REVEAL_AND_CONNECT'),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: 'VALIDATION_FAILED',
        }),
      );
    });

    it('rejects if request is already accepted', async () => {
      vi.mocked(prisma.$transaction).mockImplementationOnce(async (cb) =>
        cb({
          offer: {
            findUnique: vi.fn().mockResolvedValue({
              id: 'offer-1',
              requestId: 'req-1',
              vendorProfileId: 'vendor-1',
              state: 'PENDING',
              expiresAt: new Date('2026-09-08T12:00:00Z'),
            }),
          },
          $queryRaw: vi.fn().mockResolvedValue([
            {
              id: 'req-1',
              state: 'ACCEPTED',
              customer_profile_id: 'cust-1',
              expires_at: new Date('2026-09-09T12:00:00Z'),
            },
          ]),
        } as unknown as Parameters<Parameters<typeof prisma.$transaction>[0]>[0]),
      );

      await expect(
        service.acceptOffer(customerViewer, 'offer-1', 'REVEAL_AND_CONNECT'),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: 'OFFER_ALREADY_ACCEPTED',
        }),
      );
    });

    it('rejects if offer has expired', async () => {
      vi.mocked(prisma.$transaction).mockImplementationOnce(async (cb) =>
        cb({
          offer: {
            findUnique: vi.fn().mockResolvedValue({
              id: 'offer-1',
              requestId: 'req-1',
              vendorProfileId: 'vendor-1',
              state: 'PENDING',
              expiresAt: new Date('2026-09-07T11:00:00Z'), // in the past!
            }),
          },
          $queryRaw: vi.fn().mockResolvedValue([
            {
              id: 'req-1',
              state: 'OFFERS_RECEIVED',
              customer_profile_id: 'cust-1',
              expires_at: new Date('2026-09-09T12:00:00Z'),
            },
          ]),
        } as unknown as Parameters<Parameters<typeof prisma.$transaction>[0]>[0]),
      );

      await expect(
        service.acceptOffer(customerViewer, 'offer-1', 'REVEAL_AND_CONNECT'),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: 'OFFER_EXPIRED',
        }),
      );
    });
  });

  describe('closeConnection', () => {
    it('closes an active connection and emits connection.closed', async () => {
      const res = await service.closeConnection(customerViewer, 'conn-1');
      expect(res.state).toBe('CLOSED');
      expect(repo.closeConnection).toHaveBeenCalled();
    });

    it('rejects closing an already closed connection', async () => {
      vi.mocked(repo.findConnectionById).mockResolvedValueOnce({
        ...mockConnection,
        state: 'CLOSED',
      } as unknown as Awaited<ReturnType<typeof repo.findConnectionById>>);

      await expect(
        service.closeConnection(customerViewer, 'conn-1'),
      ).rejects.toThrow(
        expect.objectContaining({
          errorCode: 'CONNECTION_CLOSED',
        }),
      );
    });
  });
});
