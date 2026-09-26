import { describe, expect, it, vi, beforeEach } from 'vitest';
import type { VendorProfile } from '@prisma/client';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { LocalDiskStorageAdapter } from '../../../platform/adapters/storage/local-disk-storage.adapter';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { Clock } from '../../../shared/clock';
import type { AuditWriter } from '../../audit';
import type { MediaService } from '../../media';
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
  let media: MediaService;
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

    media = { getAttachable: vi.fn() } as unknown as MediaService;
    storage = new LocalDiskStorageAdapter();
    service = new VendorOnboardingService(prisma, repo, audit, mockClock, media, storage);
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

describe('VendorOnboardingService.patchProfile (VO-06 / BR-004)', () => {
  const now = new Date('2026-09-20T12:00:00.000Z');
  const mockClock: Clock = { now: () => now, nowIso: () => now.toISOString() };

  const baseProfile = {
    id: 'vp-1',
    userId: 'usr-1',
    legalBusinessName: 'Gold House LLC',
    tradingName: 'Gold House',
    tradeLicenceNumber: 'TL-1',
    licenceExpiryDate: new Date('2027-01-01T00:00:00Z'),
    businessAddress: 'Dubai',
    contactPersonName: 'Ali',
    businessEmail: 'shop@example.com',
    contactWhatsApp: null,
    description: null,
    businessHours: null,
    verificationState: 'VERIFIED' as const,
    verificationMessage: null,
    verificationNotes: null,
    verifiedAt: new Date('2026-09-01T00:00:00Z'),
    activatedAt: new Date('2026-09-01T00:00:00Z'),
    awayMode: false,
    aggregateRating: null,
    reviewCount: 0,
    offersSubmittedCount: 0,
    ratingTrend: null,
    createdAt: now,
    updatedAt: now,
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
  let service: VendorOnboardingService;
  let update: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    update = vi.fn().mockImplementation(async (_tx, _id, data) => ({
      ...baseProfile,
      ...data,
      activatedAt: data.activatedAt === undefined ? baseProfile.activatedAt : data.activatedAt,
      verificationState: data.verificationState ?? baseProfile.verificationState,
    }));

    repo = {
      findById: vi.fn().mockResolvedValue(baseProfile),
      findByIdWithLogo: vi.fn().mockResolvedValue({ ...baseProfile, logoMedia: null }),
      update,
      distinctDocumentTypes: vi.fn().mockResolvedValue(['TRADE_LICENCE', 'EMIRATES_ID']),
      countCategories: vi.fn().mockResolvedValue(1),
      countRegions: vi.fn().mockResolvedValue(1),
      listCategoryIds: vi.fn().mockResolvedValue(['cat-1']),
      listRegionIds: vi.fn().mockResolvedValue(['reg-1']),
    } as unknown as VendorOnboardingRepository;

    prisma = {
      $transaction: vi.fn(async (cb) =>
        cb({
          outboxEvent: { create: vi.fn().mockResolvedValue({}) },
        }),
      ),
    } as unknown as PrismaService;

    audit = { append: vi.fn().mockResolvedValue(undefined) } as unknown as AuditWriter;
    const media = { getAttachable: vi.fn() } as unknown as MediaService;
    service = new VendorOnboardingService(
      prisma,
      repo,
      audit,
      mockClock,
      media,
      new LocalDiskStorageAdapter(),
    );
  });

  it('transitions VERIFIED → PENDING_VERIFICATION and clears activatedAt', async () => {
    await service.patchProfile(viewer, { legalBusinessName: 'New Legal Name LLC' });

    expect(update).toHaveBeenCalledWith(
      expect.anything(),
      'vp-1',
      expect.objectContaining({
        legalBusinessName: 'New Legal Name LLC',
        verificationState: 'PENDING_VERIFICATION',
        activatedAt: null,
      }),
    );
    expect(audit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'VENDOR_PROFILE_REVERIFY' }),
    );
  });

  it('keeps PENDING_VERIFICATION and only clears activatedAt', async () => {
    vi.mocked(repo.findById).mockResolvedValue({
      ...baseProfile,
      verificationState: 'PENDING_VERIFICATION',
      activatedAt: null,
    } as VendorProfile);

    await service.patchProfile(viewer, { tradeLicenceNumber: 'TL-2' });

    expect(update).toHaveBeenCalledWith(
      expect.anything(),
      'vp-1',
      expect.objectContaining({
        tradeLicenceNumber: 'TL-2',
        activatedAt: null,
      }),
    );
    const data = update.mock.calls[0]?.[2] as Record<string, unknown>;
    expect(data).not.toHaveProperty('verificationState');
  });

  it('does not touch verificationState for cosmetic fields', async () => {
    await service.patchProfile(viewer, { tradingName: 'Cosmetic Only' });
    const data = update.mock.calls[0]?.[2] as Record<string, unknown>;
    expect(data).toEqual(expect.objectContaining({ tradingName: 'Cosmetic Only' }));
    expect(data).not.toHaveProperty('verificationState');
    expect(data).not.toHaveProperty('activatedAt');
    expect(audit.append).not.toHaveBeenCalled();
  });

  it('round-trips logoMediaKey into logoUrl on the returned VendorMe (Phase 0 fix)', async () => {
    const media = {
      getAttachable: vi.fn().mockResolvedValue({ id: 'media-1', purpose: 'VENDOR_LOGO' }),
    } as unknown as MediaService;
    service = new VendorOnboardingService(
      prisma,
      repo,
      audit,
      mockClock,
      media,
      new LocalDiskStorageAdapter(),
    );
    vi.mocked(repo.findByIdWithLogo).mockResolvedValue({
      ...baseProfile,
      logoMediaId: 'media-1',
      logoMedia: { key: 'media-key-abc' },
    } as unknown as VendorProfile & { logoMedia: { key: string } });

    const result = await service.patchProfile(viewer, { logoMediaKey: 'logo-key-in' });

    expect(media.getAttachable).toHaveBeenCalledWith('logo-key-in', 'usr-1');
    expect(update).toHaveBeenCalledWith(
      expect.anything(),
      'vp-1',
      expect.objectContaining({ logoMediaId: 'media-1' }),
    );
    expect(result.logoUrl).toBe('/v1/media/media-key-abc');
  });
});
