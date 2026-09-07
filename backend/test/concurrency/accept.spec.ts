import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import { Decimal } from '@prisma/client/runtime/library';
import type { ViewerContext } from '../../src/edge/auth/viewer-context';
import { Clock } from '../../src/shared/clock';
import { ConnectionService } from '../../src/modules/connections/application/connection.service';
import type { ConnectionRepository } from '../../src/modules/connections/repository/connection.repository';
import type { PrismaService } from '../../src/platform/db/prisma.service';
import type { AuditWriter } from '../../src/modules/audit';

describe('Acceptance Concurrency (G2-C06 / BR-011)', () => {
  let service: ConnectionService;
  let repo: ConnectionRepository;
  let prisma: PrismaService;
  let auditWriter: AuditWriter;
  const mockNow = new Date('2026-09-07T12:00:00Z');
  const mockClock: Clock = { now: () => mockNow } as Clock;

  const customerViewer: ViewerContext = {
    userId: 'cust-user-1',
    role: 'CUSTOMER',
    tokenVersion: 1,
    customerProfileId: 'cust-profile-1',
  };

  const sampleConnection = {
    id: 'conn-1',
    offerId: 'offer-1',
    requestId: 'req-1',
    customerProfileId: 'cust-profile-1',
    vendorProfileId: 'vendor-1',
    state: 'ACTIVE' as const,
    identityRevealedAt: mockNow,
    closedAt: null,
    closedBy: null,
    offer: {
      id: 'offer-1',
      offeredPrice: new Decimal(1000),
      validityHours: 24,
    },
    request: {
      id: 'req-1',
      reference: 'KH-001',
      requestType: 'FIND_ORNAMENT',
      direction: 'BUY',
      category: { id: 'c-1', nameEn: 'Rings', nameAr: 'خواتم', isActive: true, displayOrder: 1 },
      region: { id: 'r-1', nameEn: 'Dubai', nameAr: 'دبي', isActive: true, displayOrder: 1 },
    },
    customerProfile: {
      id: 'cust-profile-1',
      displayName: 'Customer 1',
      connectionCount: 1,
      user: { id: 'cust-user-1', mobileNumber: '+971501111111' },
    },
    vendorProfile: {
      id: 'vendor-1',
      legalBusinessName: 'Vendor 1 LLC',
      tradingName: 'Vendor 1',
      tradeLicenceNumber: 'CN-111',
      offersAcceptedCount: 1,
      user: { id: 'vendor-user-1', mobileNumber: '+971502222222' },
      regions: [],
    },
  };

  // Shared in-memory mock database state for concurrency simulation
  let simulatedDb: {
    requestState: 'OFFERS_RECEIVED' | 'ACCEPTED';
    connectionsCreated: number;
    auditLogs: Array<{ action: string; entityId: string }>;
    outboxEvents: string[];
    offers: Record<string, { state: string; decidedAt?: Date }>;
  };

  beforeEach(() => {
    simulatedDb = {
      requestState: 'OFFERS_RECEIVED',
      connectionsCreated: 0,
      auditLogs: [],
      outboxEvents: [],
      offers: {
        'offer-1': { state: 'PENDING' },
        'offer-2': { state: 'PENDING' },
      },
    };

    repo = {
      findConnectionById: vi.fn().mockImplementation(async (id: string) => ({
        ...sampleConnection,
        id,
      })),
      findConnectionByOfferId: vi.fn(),
      listConnectionsForCustomer: vi.fn(),
      listConnectionsForVendor: vi.fn(),
      closeConnection: vi.fn(),
      recordContactEvent: vi.fn(),
    } as unknown as ConnectionRepository;

    auditWriter = {
      append: vi.fn().mockImplementation(async (_tx, input) => {
        simulatedDb.auditLogs.push({ action: input.action, entityId: input.entityId ?? '' });
      }),
    } as unknown as AuditWriter;

    // Mutex to simulate serializable PostgreSQL row-lock on SELECT ... FOR UPDATE
    let lockAcquired = false;
    const acquireLock = async () => {
      while (lockAcquired) {
        await new Promise((resolve) => setTimeout(resolve, 5));
      }
      lockAcquired = true;
    };
    const releaseLock = () => {
      lockAcquired = false;
    };

    prisma = {
      $transaction: vi.fn(async (callback: (tx: any) => Promise<any>) => {
        await acquireLock();
        try {
          const tx = {
            offer: {
              findUnique: vi.fn().mockImplementation(async ({ where }: { where: { id: string } }) => {
                const off = simulatedDb.offers[where.id];
                if (!off) return null;
                return {
                  id: where.id,
                  requestId: 'req-1',
                  vendorProfileId: where.id === 'offer-1' ? 'vendor-1' : 'vendor-2',
                  state: off.state,
                  expiresAt: new Date(mockNow.getTime() + 24 * 3600000),
                };
              }),
              update: vi.fn().mockImplementation(async ({ where, data }: any) => {
                simulatedDb.offers[where.id] = {
                  ...simulatedDb.offers[where.id],
                  state: data.state,
                  decidedAt: data.decidedAt,
                };
              }),
              findMany: vi.fn().mockImplementation(async () => {
                return Object.entries(simulatedDb.offers)
                  .filter(([_, o]) => o.state === 'PENDING')
                  .map(([id]) => ({ id }));
              }),
              updateMany: vi.fn().mockImplementation(async ({ where, data }: any) => {
                for (const [id, o] of Object.entries(simulatedDb.offers)) {
                  if (o.state === 'PENDING' && id !== where.id?.not) {
                    simulatedDb.offers[id] = { ...o, state: data.state, decidedAt: data.decidedAt };
                  }
                }
              }),
            },
            $queryRaw: vi.fn().mockImplementation(async () => {
              // Simulated SELECT ... FOR UPDATE returns current DB row state
              return [
                {
                  id: 'req-1',
                  state: simulatedDb.requestState,
                  customer_profile_id: 'cust-profile-1',
                  expires_at: new Date(mockNow.getTime() + 48 * 3600000),
                },
              ];
            }),
            request: {
              update: vi.fn().mockImplementation(async ({ data }: any) => {
                if (data.state) simulatedDb.requestState = data.state;
              }),
            },
            connection: {
              create: vi.fn().mockImplementation(async () => {
                simulatedDb.connectionsCreated += 1;
                return { id: `conn-${simulatedDb.connectionsCreated}` };
              }),
            },
            customerProfile: {
              update: vi.fn().mockResolvedValue({}),
            },
            vendorProfile: {
              update: vi.fn().mockResolvedValue({}),
              findUnique: vi.fn().mockResolvedValue({ userId: 'vendor-user-1' }),
            },
            outboxEvent: {
              create: vi.fn().mockImplementation(async ({ data }: any) => {
                simulatedDb.outboxEvents.push(data.eventType);
              }),
            },
          };

          return await callback(tx);
        } finally {
          releaseLock();
        }
      }),
      offer: {
        findUnique: vi.fn().mockImplementation(async ({ where }: any) => ({
          id: where.id,
          requestId: 'req-1',
          state: 'ACCEPTED',
          offeredPrice: new Decimal(1000),
          makingCharges: null,
          ratePerGram: null,
          validityHours: 24,
          submittedAt: mockNow,
          expiresAt: new Date(mockNow.getTime() + 24 * 3600000),
          revisionCount: 0,
          media: [],
          vendorProfile: sampleConnection.vendorProfile,
        })),
      },
    } as unknown as PrismaService;

    service = new ConnectionService(repo, prisma, auditWriter, mockClock);
  });

  it('handles two simultaneous accepts: exactly one succeeds with 200, the other fails with 409 OFFER_ALREADY_ACCEPTED', async () => {
    // Launch two simultaneous accept requests for different offers on the same request
    const results = await Promise.allSettled([
      service.acceptOffer(customerViewer, 'offer-1', 'REVEAL_AND_CONNECT'),
      service.acceptOffer(customerViewer, 'offer-2', 'REVEAL_AND_CONNECT'),
    ]);

    const fulfilled = results.filter((r) => r.status === 'fulfilled');
    const rejected = results.filter((r) => r.status === 'rejected');

    // 1. Exactly one must succeed
    expect(fulfilled).toHaveLength(1);
    expect(rejected).toHaveLength(1);

    // 2. The second must fail with 409 OFFER_ALREADY_ACCEPTED
    const failureReason = (rejected[0] as PromiseRejectedResult).reason;
    expect(failureReason).toMatchObject({
      status: HttpStatus.CONFLICT,
      errorCode: 'OFFER_ALREADY_ACCEPTED',
    });

    // 3. Database invariants
    expect(simulatedDb.connectionsCreated).toBe(1);
    expect(simulatedDb.requestState).toBe('ACCEPTED');
    expect(simulatedDb.auditLogs).toHaveLength(1);
    expect(simulatedDb.auditLogs[0]?.action).toBe('IDENTITY_REVEALED');
    expect(simulatedDb.outboxEvents).toContain('offer.accepted');
  });
});
