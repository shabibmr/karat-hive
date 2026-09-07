import { Prisma } from '@prisma/client';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { Clock } from '../../../shared/clock';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { GoldRateFeed } from '../../../platform/ports/gold-rate.port';
import { GoldRateFeedError } from '../../../platform/ports/gold-rate.port';
import type { AuditWriter } from '../../audit';
import type { NotificationService } from '../../notifications';
import type { RateRow } from '../domain/effective-rate';
import { GOLD_RATE_SETTING } from '../domain/settings-keys';
import type { GoldRateRepository } from '../repository/gold-rate.repository';
import { GoldRateService } from './gold-rate.service';

const NOW = new Date('2026-09-07T12:00:00Z');

const adminViewer: ViewerContext = {
  userId: 'admin-user-1',
  role: 'ADMIN',
  tokenVersion: 1,
  accountState: 'ACTIVE',
  preferredLanguage: 'en',
  vendorProfileId: null,
  vendorVerificationState: null,
  vendorActivatedAt: null,
  customerProfileId: null,
  adminProfileId: 'admin-prof-1',
};

const customerViewer: ViewerContext = {
  ...adminViewer,
  userId: 'cust-1',
  role: 'CUSTOMER',
  adminProfileId: null,
  customerProfileId: 'cust-prof-1',
};

function feedRow(partial: Partial<RateRow> = {}): RateRow {
  return {
    id: 'rate-24k',
    purityKarat: 'K24',
    ratePerGramAed: new Prisma.Decimal('300.00'),
    source: 'FEED',
    feedProvider: 'YAHOO_FINANCE',
    sourceTimestamp: new Date('2026-09-07T11:45:00Z'),
    overrideReason: null,
    overrideExpiresAt: null,
    createdAt: new Date('2026-09-07T11:45:05Z'),
    ...partial,
  };
}

describe('GoldRateService', () => {
  let service: GoldRateService;
  let repo: {
    getSetting: ReturnType<typeof vi.fn>;
    setSetting: ReturnType<typeof vi.fn>;
    getIngestState: ReturnType<typeof vi.fn>;
    setIngestState: ReturnType<typeof vi.fn>;
    upsertFeedRate: ReturnType<typeof vi.fn>;
    createOverride: ReturnType<typeof vi.fn>;
    findEffectiveRate: ReturnType<typeof vi.fn>;
    findEffectiveRates: ReturnType<typeof vi.fn>;
    listHistory: ReturnType<typeof vi.fn>;
    listActiveAdminUserIds: ReturnType<typeof vi.fn>;
  };
  let feed: { fetchSpotRate: ReturnType<typeof vi.fn> };
  let audit: { append: ReturnType<typeof vi.fn> };
  let notifications: { createInAppNotification: ReturnType<typeof vi.fn> };

  beforeEach(() => {
    repo = {
      getSetting: vi.fn().mockImplementation(async (key: string) => {
        if (key === GOLD_RATE_SETTING.endUserDisplay) return false;
        if (key === GOLD_RATE_SETTING.pollIntervalMinutes) return 15;
        if (key === GOLD_RATE_SETTING.stalenessThresholdMinutes) return 60;
        if (key === GOLD_RATE_SETTING.purityFactors) return null;
        return null;
      }),
      setSetting: vi.fn(),
      getIngestState: vi.fn().mockResolvedValue({
        lastAttemptAt: null,
        lastSuccessAt: null,
        consecutiveFailures: 0,
        lastError: null,
        failingSinceAt: null,
        staleAlertSentAt: null,
      }),
      setIngestState: vi.fn().mockResolvedValue(undefined),
      upsertFeedRate: vi.fn().mockImplementation(async (input) =>
        feedRow({
          purityKarat: input.purityKarat,
          ratePerGramAed: input.ratePerGramAed,
          sourceTimestamp: input.sourceTimestamp,
        }),
      ),
      createOverride: vi.fn(),
      findEffectiveRate: vi.fn(),
      findEffectiveRates: vi
        .fn()
        .mockResolvedValue([
          feedRow(),
          feedRow({ id: 'r22', purityKarat: 'K22', ratePerGramAed: new Prisma.Decimal('275.00') }),
        ]),
      listHistory: vi.fn().mockResolvedValue({ items: [], nextCursor: null }),
      listActiveAdminUserIds: vi.fn().mockResolvedValue(['admin-user-1']),
    };

    feed = {
      fetchSpotRate: vi.fn().mockResolvedValue({
        aedPerGram24k: 240,
        sourceTimestamp: new Date('2026-09-07T11:50:00Z'),
      }),
    };

    const prisma = {
      $transaction: vi.fn(async (fn: (tx: unknown) => Promise<unknown>) => fn(prisma)),
    };

    audit = { append: vi.fn().mockResolvedValue(undefined) };
    notifications = { createInAppNotification: vi.fn().mockResolvedValue({ id: 'n1' }) };

    const clock = { now: () => NOW, nowIso: () => NOW.toISOString() };

    service = new GoldRateService(
      repo as unknown as GoldRateRepository,
      prisma as unknown as PrismaService,
      clock as Clock,
      audit as unknown as AuditWriter,
      notifications as unknown as NotificationService,
      feed as unknown as GoldRateFeed,
    );
  });

  describe('pollGoldRates (G2-GR01)', () => {
    it('upserts 24K + derived purities on (purity, source, source_timestamp)', async () => {
      const result = await service.pollGoldRates();
      expect(result).toEqual({ status: 'ingested', karatsWritten: 4 });
      expect(repo.upsertFeedRate).toHaveBeenCalledTimes(4);

      const karats = repo.upsertFeedRate.mock.calls.map((c) => c[0].purityKarat);
      expect(karats).toEqual(['K24', 'K22', 'K21', 'K18']);
      for (const call of repo.upsertFeedRate.mock.calls) {
        const input = call[0] as { ratePerGramAed: Prisma.Decimal; sourceTimestamp: Date };
        expect(Number(input.ratePerGramAed)).toBeGreaterThan(0);
        expect(input.sourceTimestamp.toISOString()).toBe('2026-09-07T11:50:00.000Z');
      }
      expect(repo.setIngestState).toHaveBeenCalledWith(
        expect.objectContaining({ consecutiveFailures: 0, lastError: null, failingSinceAt: null }),
        expect.anything(),
      );
    });

    it('does not write a fabricated 0 when the adapter fails; last-good is retained', async () => {
      feed.fetchSpotRate.mockRejectedValueOnce(new GoldRateFeedError('Yahoo Finance HTTP 503'));
      const result = await service.pollGoldRates();
      expect(result.status).toBe('failed');
      expect(repo.upsertFeedRate).not.toHaveBeenCalled();
      expect(repo.setIngestState).toHaveBeenCalledWith(
        expect.objectContaining({
          consecutiveFailures: 1,
          failingSinceAt: NOW.toISOString(),
          lastError: expect.stringContaining('HTTP 503'),
        }),
        expect.anything(),
      );
    });

    it('refuses to persist a zero spot from a misbehaving adapter', async () => {
      feed.fetchSpotRate.mockResolvedValueOnce({
        aedPerGram24k: 0,
        sourceTimestamp: new Date('2026-09-07T11:50:00Z'),
      });
      const result = await service.pollGoldRates();
      expect(result.status).toBe('failed');
      expect(repo.upsertFeedRate).not.toHaveBeenCalled();
    });
  });

  describe('getPublicRates (G2-GR02)', () => {
    it('returns DISPLAY_NOT_LICENSED while goldRates.endUserDisplay is false', async () => {
      const data = await service.getPublicRates(customerViewer);
      expect(data).toEqual({ available: false, reason: 'DISPLAY_NOT_LICENSED' });
      expect(repo.findEffectiveRates).not.toHaveBeenCalled();
    });

    it('populates rates when the display flag is on (ingest, not a Yahoo redistributed default)', async () => {
      repo.getSetting.mockImplementation(async (key: string) => {
        if (key === GOLD_RATE_SETTING.endUserDisplay) return true;
        if (key === GOLD_RATE_SETTING.stalenessThresholdMinutes) return 60;
        return null;
      });
      const data = await service.getPublicRates(customerViewer);
      expect(data).toMatchObject({
        available: true,
        source: 'FEED',
        rates: expect.arrayContaining([
          { karat: '24K', ratePerGramAed: '300.00' },
          { karat: '22K', ratePerGramAed: '275.00' },
        ]),
      });
      expect('reason' in data).toBe(false);
    });

    it('returns available:false and empty rates when the flag is on but no last-good exists', async () => {
      repo.getSetting.mockImplementation(async (key: string) => {
        if (key === GOLD_RATE_SETTING.endUserDisplay) return true;
        if (key === GOLD_RATE_SETTING.stalenessThresholdMinutes) return 60;
        return null;
      });
      repo.findEffectiveRates.mockResolvedValueOnce([]);
      const data = await service.getPublicRates(customerViewer);
      expect(data).toMatchObject({ available: false, rates: [] });
    });
  });

  describe('admin override (G2-GR03)', () => {
    it('writes a MANUAL_OVERRIDE without calling the feed (works when adapter is down)', async () => {
      const created = feedRow({
        id: 'ov-1',
        source: 'MANUAL_OVERRIDE',
        ratePerGramAed: new Prisma.Decimal('305.50'),
        overrideReason: 'feed outage',
        overrideExpiresAt: new Date('2026-09-07T18:00:00Z'),
        sourceTimestamp: NOW,
        createdAt: NOW,
        feedProvider: null,
      });
      repo.createOverride.mockResolvedValueOnce(created);

      const data = await service.override(
        {
          karat: '24K',
          ratePerGramAed: '305.50',
          reason: 'feed outage',
          expiresAt: new Date('2026-09-07T18:00:00Z'),
        },
        adminViewer,
        { ip: '127.0.0.1', userAgent: 'vitest' },
      );

      expect(feed.fetchSpotRate).not.toHaveBeenCalled();
      expect(repo.createOverride).toHaveBeenCalledWith(
        expect.objectContaining({
          purityKarat: 'K24',
          overrideReason: 'feed outage',
        }),
        expect.anything(),
      );
      expect(data).toMatchObject({
        karat: '24K',
        ratePerGramAed: '305.50',
        source: 'MANUAL_OVERRIDE',
        overrideReason: 'feed outage',
      });
      expect(audit.append).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({ action: 'GOLD_RATE_OVERRIDE' }),
      );
    });

    it('rejects a zero override rate', async () => {
      await expect(
        service.override(
          {
            karat: '24K',
            ratePerGramAed: '0.00',
            reason: 'nope',
            expiresAt: new Date('2026-09-07T18:00:00Z'),
          },
          adminViewer,
          { ip: null, userAgent: null },
        ),
      ).rejects.toMatchObject({ errorCode: ErrorCode.VALIDATION_FAILED });
      expect(repo.createOverride).not.toHaveBeenCalled();
    });

    it('returns current rates + feed health without the display flag', async () => {
      const data = await service.getAdminRates();
      expect(data.available).toBe(true);
      expect(data.feedHealth.provider).toBe('YAHOO_FINANCE');
      expect(data.pollIntervalMinutes).toBe(15);
      expect(data.stalenessThresholdMinutes).toBe(60);
      expect(data.rates.length).toBeGreaterThan(0);
    });
  });

  describe('alertIfStale (G2-GR04)', () => {
    it('does not alert before 2 hours of ingestion failure', async () => {
      repo.getIngestState.mockResolvedValueOnce({
        lastAttemptAt: NOW.toISOString(),
        lastSuccessAt: null,
        consecutiveFailures: 3,
        lastError: 'down',
        failingSinceAt: new Date(NOW.getTime() - 60 * 60 * 1000).toISOString(),
        staleAlertSentAt: null,
      });
      const result = await service.alertIfStale();
      expect(result.status).toBe('not_due');
      expect(notifications.createInAppNotification).not.toHaveBeenCalled();
    });

    it('alerts Admins once after 2 hours and de-duplicates the same window', async () => {
      const failingSince = new Date(NOW.getTime() - 3 * 60 * 60 * 1000).toISOString();
      repo.getIngestState.mockResolvedValueOnce({
        lastAttemptAt: NOW.toISOString(),
        lastSuccessAt: null,
        consecutiveFailures: 8,
        lastError: 'down',
        failingSinceAt: failingSince,
        staleAlertSentAt: null,
      });

      const first = await service.alertIfStale();
      expect(first).toEqual({ status: 'sent', adminCount: 1 });
      expect(notifications.createInAppNotification).toHaveBeenCalledTimes(1);
      expect(notifications.createInAppNotification).toHaveBeenCalledWith(
        'admin-user-1',
        expect.objectContaining({ type: 'GOLD_RATE_INGESTION_FAILURE', isCritical: true }),
      );
      expect(repo.setIngestState).toHaveBeenCalledWith(
        expect.objectContaining({ staleAlertSentAt: NOW.toISOString() }),
      );

      repo.getIngestState.mockResolvedValueOnce({
        lastAttemptAt: NOW.toISOString(),
        lastSuccessAt: null,
        consecutiveFailures: 9,
        lastError: 'down',
        failingSinceAt: failingSince,
        staleAlertSentAt: NOW.toISOString(),
      });
      notifications.createInAppNotification.mockClear();
      const second = await service.alertIfStale();
      expect(second.status).toBe('skipped');
      expect(notifications.createInAppNotification).not.toHaveBeenCalled();
    });
  });

  describe('getEffectiveRate (ingest, independent of display flag)', () => {
    it('returns last-good even while end-user display is unlicensed', async () => {
      repo.findEffectiveRate.mockResolvedValueOnce(feedRow());
      const row = await service.getEffectiveRate('K24');
      expect(row?.id).toBe('rate-24k');
      expect(repo.getSetting).not.toHaveBeenCalledWith(GOLD_RATE_SETTING.endUserDisplay);
    });
  });
});
