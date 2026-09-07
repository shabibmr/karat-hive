import { describe, expect, it, vi, beforeEach } from 'vitest';
import type { VendorProfile } from '@prisma/client';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { LocalDiskStorageAdapter } from '../../../platform/adapters/storage/local-disk-storage.adapter';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { Clock } from '../../../shared/clock';
import type { AuditWriter } from '../../audit';
import type { VendorOnboardingRepository } from '../repository/vendor-onboarding.repository';
import { VendorOnboardingService } from './vendor-onboarding.service';

describe('VendorOnboardingService dashboard + export (G2-M06 / G2-P07)', () => {
  const now = new Date('2026-09-07T12:00:00.000Z');
  const mockClock: Clock = { now: () => now, nowIso: () => now.toISOString() };

  const profile = {
    id: 'vp-1',
    aggregateRating: null,
    reviewCount: 0,
  } as unknown as VendorProfile;

  const viewer: ViewerContext = {
    userId: 'usr-1',
    role: 'VENDOR',
    tokenVersion: 1,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    vendorProfileId: 'vp-1',
    vendorVerificationState: 'VERIFIED',
    vendorActivatedAt: new Date('2026-09-01T00:00:00Z'),
    customerProfileId: null,
    adminProfileId: null,
  };

  let repo: VendorOnboardingRepository;
  let prisma: PrismaService;
  let audit: AuditWriter;
  let storage: LocalDiskStorageAdapter;
  let service: VendorOnboardingService;

  beforeEach(() => {
    repo = {
      findById: vi.fn().mockResolvedValue(profile),
    } as unknown as VendorOnboardingRepository;

    prisma = {
      requestMatch: {
        count: vi.fn().mockResolvedValue(0),
        findMany: vi.fn().mockResolvedValue([]),
      },
      offer: {
        count: vi.fn().mockResolvedValue(0),
        findMany: vi.fn().mockResolvedValue([]),
      },
      connection: {
        count: vi.fn().mockResolvedValue(0),
      },
      vendorTypeSubscription: {
        findMany: vi.fn().mockResolvedValue([]),
      },
      auditLog: {
        create: vi.fn().mockResolvedValue({}),
      },
    } as unknown as PrismaService;

    audit = {
      append: vi.fn().mockResolvedValue(undefined),
    } as unknown as AuditWriter;

    storage = new LocalDiskStorageAdapter();
    service = new VendorOnboardingService(prisma, repo, audit, mockClock, storage);
  });

  it('returns empty-safe zero counts and empty subscriptions (G2-M06)', async () => {
    const dash = await service.dashboard(viewer);

    expect(dash.newRequests).toEqual({ count: 0, preview: [] });
    expect(dash.pendingOffers).toEqual({ count: 0, expiringWithin24h: 0 });
    expect(dash.activeConnections).toEqual({ count: 0, noTalkCount: 0 });
    expect(dash.goldRates).toBeNull();
    expect(dash.subscriptions).toEqual([]);
    expect(dash.rating).toEqual({ average: null, reviewCount: 0 });
  });

  it('surfaces real new-match / pending-offer / connection counts', async () => {
    vi.mocked(prisma.requestMatch.count).mockResolvedValueOnce(2);
    vi.mocked(prisma.requestMatch.findMany).mockResolvedValueOnce([]);
    vi.mocked(prisma.offer.count)
      .mockResolvedValueOnce(4) // pending
      .mockResolvedValueOnce(1); // expiring within 24h
    vi.mocked(prisma.connection.count)
      .mockResolvedValueOnce(3) // active
      .mockResolvedValueOnce(2); // no talk
    vi.mocked(prisma.vendorTypeSubscription.findMany).mockResolvedValueOnce([
      {
        id: 'sub-1',
        vendorProfileId: 'vp-1',
        requestType: 'FIND_ORNAMENT',
        state: 'ACTIVE',
        periodStart: new Date('2026-09-01T00:00:00Z'),
        periodEnd: new Date('2026-10-01T00:00:00Z'),
        priceAed: 100,
        graceEndsAt: null,
        paymentReference: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ] as never);

    const dash = await service.dashboard(viewer);

    expect(dash.newRequests.count).toBe(2);
    expect(dash.pendingOffers).toEqual({ count: 4, expiringWithin24h: 1 });
    expect(dash.activeConnections).toEqual({ count: 3, noTalkCount: 2 });
    expect(dash.subscriptions).toHaveLength(1);
    expect(dash.subscriptions[0]?.requestType).toBe('FIND_ORNAMENT');
    expect(dash.goldRates).toBeNull();

    expect(prisma.requestMatch.count).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          vendorProfileId: 'vp-1',
          viewedAt: null,
          isEligible: true,
        }),
      }),
    );
  });

  it('exports own-offer CSV to storage and returns a signed download URL (G2-P07)', async () => {
    vi.mocked(prisma.offer.findMany).mockResolvedValueOnce([
      {
        id: 'off-1',
        state: 'PENDING',
        offeredPrice: 500,
        submittedAt: new Date('2026-09-06T10:00:00Z'),
        expiresAt: new Date('2026-09-07T10:00:00Z'),
        decidedAt: null,
        declineReason: null,
        request: {
          reference: 'KH-2026-9',
          requestType: 'GOLD_COIN',
          publishedAt: new Date('2026-09-06T09:00:00Z'),
          category: { nameEn: 'Coins' },
          region: { nameEn: 'Dubai' },
        },
      },
    ] as never);

    const result = await service.exportPerformance(viewer, {});

    expect(result.downloadUrl).toMatch(/^local:\/\/export\/vendor\/vp-1\/performance\//);
    expect(result.expiresAt).toBeTruthy();
    expect(audit.append).toHaveBeenCalledWith(
      prisma,
      expect.objectContaining({
        action: 'VENDOR_PERFORMANCE_EXPORT',
        entityId: 'vp-1',
        afterValue: expect.objectContaining({ rowCount: 1 }),
      }),
    );

    // Own vendor only — query scoped by vendorProfileId
    expect(prisma.offer.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ vendorProfileId: 'vp-1' }),
      }),
    );
  });

  it('exports header-only CSV when vendor has no offers', async () => {
    const result = await service.exportPerformance(viewer);
    expect(result.downloadUrl).toContain('local://export/');
    expect(audit.append).toHaveBeenCalledWith(
      prisma,
      expect.objectContaining({
        afterValue: expect.objectContaining({ rowCount: 0 }),
      }),
    );
  });
});
