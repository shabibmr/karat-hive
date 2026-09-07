import { HttpStatus, Inject, Injectable, Logger } from '@nestjs/common';
import { Prisma, type GoldRateSource, type Karat } from '@prisma/client';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import {
  GOLD_RATE_FEED,
  YAHOO_FEED_PROVIDER,
  type GoldRateFeed,
} from '../../../platform/ports/gold-rate.port';
import { AuditWriter } from '../../audit';
import { NotificationService } from '../../notifications';
import type { RateRow } from '../domain/effective-rate';
import {
  ALL_KARATS,
  DEFAULT_PURITY_FACTORS,
  derivePurityRates,
  fromWireKarat,
  InvalidSpotRateError,
  type WireKarat,
} from '../domain/purity';
import {
  DEFAULT_POLL_INTERVAL_MINUTES,
  DEFAULT_STALENESS_THRESHOLD_MINUTES,
  GOLD_RATE_SETTING,
  INGESTION_FAILURE_ALERT_MS,
  isEndUserDisplayEnabled,
  type GoldRateIngestState,
} from '../domain/settings-keys';
import {
  presentDisplayNotLicensed,
  presentFeedHealth,
  presentHistoryRow,
  presentSnapshot,
  type AdminGoldRatePayload,
  type DisplayNotLicensedPayload,
  type GoldRateHistoryRow,
  type GoldRateSnapshot,
} from '../presenter/gold-rate.presenter';
import { GoldRateRepository } from '../repository/gold-rate.repository';

export type OverrideInput = {
  karat: string;
  ratePerGramAed: string | number;
  reason: string;
  expiresAt: Date;
};

export type PollResult = {
  status: 'ingested' | 'failed' | 'skipped';
  karatsWritten: number;
  error?: string;
};

export type StaleAlertResult = {
  status: 'sent' | 'skipped' | 'not_due';
  adminCount: number;
};

function asNumber(value: unknown, fallback: number): number {
  if (typeof value === 'number' && Number.isFinite(value)) return value;
  if (typeof value === 'string' && Number.isFinite(Number(value))) return Number(value);
  return fallback;
}

function parsePurityFactors(value: unknown): Record<Karat, number> {
  if (!value || typeof value !== 'object') return { ...DEFAULT_PURITY_FACTORS };
  const raw = value as Record<string, unknown>;
  const out = { ...DEFAULT_PURITY_FACTORS };
  for (const karat of ALL_KARATS) {
    const wire =
      karat === 'K24' ? '24K' : karat === 'K22' ? '22K' : karat === 'K21' ? '21K' : '18K';
    const candidate = raw[karat] ?? raw[wire];
    const n = asNumber(candidate, out[karat]);
    if (n > 0) out[karat] = n;
  }
  return out;
}

function parsePositiveMoney(value: string | number): Prisma.Decimal {
  let decimal: Prisma.Decimal;
  try {
    decimal = new Prisma.Decimal(value).toDecimalPlaces(2);
  } catch {
    throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
      {
        path: 'ratePerGramAed',
        code: 'INVALID',
        message: 'ratePerGramAed must be a positive AED amount.',
      },
    ]);
  }
  if (!decimal.isFinite() || decimal.lte(0)) {
    throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
      {
        path: 'ratePerGramAed',
        code: 'NON_POSITIVE',
        message: 'ratePerGramAed must be greater than zero. Zero is never stored (FR-SYS-010 AC2).',
      },
    ]);
  }
  return decimal;
}

@Injectable()
export class GoldRateService {
  private readonly logger = new Logger(GoldRateService.name);

  constructor(
    private readonly repo: GoldRateRepository,
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
    private readonly audit: AuditWriter,
    private readonly notifications: NotificationService,
    @Inject(GOLD_RATE_FEED) private readonly feed: GoldRateFeed,
  ) {}

  /**
   * End-user display. Until G2-D04 the platform setting stays false and this
   * returns `{ available: false, reason: "DISPLAY_NOT_LICENSED" }` — rates are
   * not redistributed. Bullion publish reads ingest via {@link getEffectiveRate}.
   */
  async getPublicRates(
    viewer: ViewerContext,
  ): Promise<GoldRateSnapshot | DisplayNotLicensedPayload> {
    const flag = await this.repo.getSetting(GOLD_RATE_SETTING.endUserDisplay);
    if (!isEndUserDisplayEnabled(flag)) {
      return presentDisplayNotLicensed();
    }
    return this.buildSnapshot(viewer.preferredLanguage === 'ar' ? 'ar' : 'en');
  }

  /** Admin current rates + feed health. Not display-gated (AD-API-09). */
  async getAdminRates(): Promise<AdminGoldRatePayload> {
    const [snapshot, ingest, pollMinutes, staleMinutes] = await Promise.all([
      this.buildSnapshot('en'),
      this.repo.getIngestState(),
      this.pollIntervalMinutes(),
      this.stalenessThresholdMinutes(),
    ]);
    return {
      ...snapshot,
      feedHealth: presentFeedHealth(ingest),
      pollIntervalMinutes: pollMinutes,
      stalenessThresholdMinutes: staleMinutes,
    };
  }

  async listHistory(query: {
    limit?: number;
    cursor?: string;
    karat?: string;
    source?: GoldRateSource;
  }): Promise<{ items: GoldRateHistoryRow[]; nextCursor: string | null }> {
    const karat = query.karat ? fromWireKarat(query.karat) : undefined;
    if (query.karat && !karat) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        { path: 'karat', code: 'INVALID', message: 'karat must be 24K, 22K, 21K or 18K.' },
      ]);
    }
    const { items, nextCursor } = await this.repo.listHistory({
      limit: query.limit ?? 20,
      cursor: query.cursor,
      karat: karat ?? undefined,
      source: query.source,
    });
    return { items: items.map(presentHistoryRow), nextCursor };
  }

  /**
   * Per-purity manual override with mandatory reason and expiry (FR-ADM-031).
   * Does not call the feed — still works when the adapter is down (G2-GR01).
   */
  async override(
    input: OverrideInput,
    viewer: ViewerContext,
    client: { ip: string | null; userAgent: string | null },
  ): Promise<GoldRateHistoryRow> {
    const karat = fromWireKarat(input.karat);
    if (!karat) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        { path: 'karat', code: 'INVALID', message: 'karat must be 24K, 22K, 21K or 18K.' },
      ]);
    }
    const reason = input.reason.trim();
    if (reason.length === 0) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        {
          path: 'reason',
          code: 'REQUIRED',
          message: 'A reason is required for a manual override.',
        },
      ]);
    }
    const now = this.clock.now();
    if (
      !(input.expiresAt instanceof Date) ||
      Number.isNaN(input.expiresAt.getTime()) ||
      input.expiresAt <= now
    ) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        { path: 'expiresAt', code: 'INVALID', message: 'expiresAt must be a future timestamp.' },
      ]);
    }
    const rate = parsePositiveMoney(input.ratePerGramAed);

    const row = await withTx(this.prisma, async (tx) => {
      const created = await this.repo.createOverride(
        {
          purityKarat: karat,
          ratePerGramAed: rate,
          sourceTimestamp: now,
          overrideReason: reason,
          overrideExpiresAt: input.expiresAt,
        },
        tx,
      );
      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'GOLD_RATE_OVERRIDE',
        entityType: 'gold_rate',
        entityId: created.id,
        afterValue: {
          karat: input.karat,
          ratePerGramAed: rate.toFixed(2),
          reason,
          expiresAt: input.expiresAt.toISOString(),
        },
        ipAddress: client.ip,
        userAgent: client.userAgent,
      });
      return created;
    });

    return presentHistoryRow(row);
  }

  /**
   * Ingest availability for bullion publish (G2-R05). Independent of
   * `goldRates.endUserDisplay`. Last-good (including expired override) counts.
   */
  async getEffectiveRate(karat: Karat): Promise<RateRow | null> {
    return this.repo.findEffectiveRate(karat, this.clock.now());
  }

  /**
   * G2-GR01 / `gold-rate-poll`. Upserts `(purity_karat, source, source_timestamp)`.
   * Failure retains last-good and does not write 0.
   */
  async pollGoldRates(): Promise<PollResult> {
    const now = this.clock.now();
    const intervalMinutes = await this.pollIntervalMinutes();
    const ingest = await this.repo.getIngestState();

    if (ingest.lastAttemptAt) {
      const elapsedMs = now.getTime() - new Date(ingest.lastAttemptAt).getTime();
      if (elapsedMs < intervalMinutes * 60_000 - 1_000) {
        return { status: 'skipped', karatsWritten: 0 };
      }
    }

    let spot;
    try {
      spot = await this.feed.fetchSpotRate();
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      await this.recordPollFailure(ingest, now, message);
      this.logger.warn(`gold-rate-poll feed failed: ${message}`);
      return { status: 'failed', karatsWritten: 0, error: message };
    }

    try {
      if (
        !(spot.aedPerGram24k > 0) ||
        !Number.isFinite(spot.aedPerGram24k) ||
        !(spot.sourceTimestamp instanceof Date) ||
        Number.isNaN(spot.sourceTimestamp.getTime())
      ) {
        throw new InvalidSpotRateError('Feed returned a non-positive or unusable spot rate');
      }
      const factors = parsePurityFactors(
        await this.repo.getSetting(GOLD_RATE_SETTING.purityFactors),
      );
      const derived = derivePurityRates(spot.aedPerGram24k, factors);

      await withTx(this.prisma, async (tx) => {
        for (const row of derived) {
          await this.repo.upsertFeedRate(
            {
              purityKarat: row.purityKarat,
              ratePerGramAed: new Prisma.Decimal(row.ratePerGramAed.toFixed(2)),
              sourceTimestamp: spot.sourceTimestamp,
              feedProvider: YAHOO_FEED_PROVIDER,
            },
            tx,
          );
        }
        await this.repo.setIngestState(
          {
            lastAttemptAt: now.toISOString(),
            lastSuccessAt: now.toISOString(),
            consecutiveFailures: 0,
            lastError: null,
            failingSinceAt: null,
            staleAlertSentAt: ingest.staleAlertSentAt,
          },
          tx,
        );
      });

      this.logger.log(
        `gold-rate-poll ingested ${derived.length} purities sourceTs=${spot.sourceTimestamp.toISOString()}`,
      );
      return { status: 'ingested', karatsWritten: derived.length };
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      await this.recordPollFailure(ingest, now, message);
      this.logger.warn(`gold-rate-poll refused persist: ${message}`);
      return { status: 'failed', karatsWritten: 0, error: message };
    }
  }

  /**
   * G2-GR04 / `gold-rate-stale-alert`. One Admin in-app notice per failure window
   * after 2 h without a successful ingest (FR-SYS-010.5).
   */
  async alertIfStale(): Promise<StaleAlertResult> {
    const now = this.clock.now();
    const ingest = await this.repo.getIngestState();
    const failingSince = ingest.failingSinceAt ? new Date(ingest.failingSinceAt) : null;
    if (!failingSince) {
      return { status: 'not_due', adminCount: 0 };
    }
    if (now.getTime() - failingSince.getTime() < INGESTION_FAILURE_ALERT_MS) {
      return { status: 'not_due', adminCount: 0 };
    }

    const alreadySent =
      ingest.staleAlertSentAt !== null &&
      new Date(ingest.staleAlertSentAt).getTime() >= failingSince.getTime();
    if (alreadySent) {
      return { status: 'skipped', adminCount: 0 };
    }

    const adminIds = await this.repo.listActiveAdminUserIds();
    for (const adminId of adminIds) {
      await this.notifications.createInAppNotification(adminId, {
        type: 'GOLD_RATE_INGESTION_FAILURE',
        titleEn: 'Gold rate feed has been down for 2 hours',
        titleAr: 'تغذية سعر الذهب متوقفة منذ ساعتين',
        bodyEn:
          'Yahoo Finance ingestion has failed for at least two hours. Last good rates are retained and marked stale. Apply a manual override if needed.',
        bodyAr:
          'فشل جلب أسعار الذهب من Yahoo Finance لمدة ساعتين على الأقل. تم الاحتفاظ بآخر سعر صالح ووسمه كقديم. استخدم التجاوز اليدوي عند الحاجة.',
        deepLink: '/admin/gold-rates',
        isCritical: true,
      });
    }

    await this.repo.setIngestState({
      ...ingest,
      staleAlertSentAt: now.toISOString(),
    });

    await this.audit.append(this.prisma, {
      actorUserId: null,
      action: 'GOLD_RATE_STALE_ALERT',
      entityType: 'gold_rate',
      afterValue: {
        failingSinceAt: ingest.failingSinceAt,
        consecutiveFailures: ingest.consecutiveFailures,
        adminCount: adminIds.length,
      },
    });

    this.logger.warn(`gold-rate-stale-alert sent to ${adminIds.length} admin(s)`);
    return { status: 'sent', adminCount: adminIds.length };
  }

  private async buildSnapshot(lang: 'en' | 'ar'): Promise<GoldRateSnapshot> {
    const now = this.clock.now();
    const staleMinutes = await this.stalenessThresholdMinutes();
    const rows = await this.repo.findEffectiveRates(now);
    return presentSnapshot(rows, now, staleMinutes * 60_000, lang);
  }

  private async pollIntervalMinutes(): Promise<number> {
    const value = await this.repo.getSetting(GOLD_RATE_SETTING.pollIntervalMinutes);
    const n = asNumber(value, DEFAULT_POLL_INTERVAL_MINUTES);
    return n > 0 ? n : DEFAULT_POLL_INTERVAL_MINUTES;
  }

  private async stalenessThresholdMinutes(): Promise<number> {
    const value = await this.repo.getSetting(GOLD_RATE_SETTING.stalenessThresholdMinutes);
    const n = asNumber(value, DEFAULT_STALENESS_THRESHOLD_MINUTES);
    return n > 0 ? n : DEFAULT_STALENESS_THRESHOLD_MINUTES;
  }

  private async recordPollFailure(
    previous: GoldRateIngestState,
    now: Date,
    message: string,
  ): Promise<void> {
    const consecutiveFailures = previous.consecutiveFailures + 1;
    const failingSinceAt = previous.failingSinceAt ?? now.toISOString();
    const next: GoldRateIngestState = {
      lastAttemptAt: now.toISOString(),
      lastSuccessAt: previous.lastSuccessAt,
      consecutiveFailures,
      lastError: message.slice(0, 500),
      failingSinceAt,
      staleAlertSentAt: previous.staleAlertSentAt,
    };
    await withTx(this.prisma, async (tx) => {
      await this.repo.setIngestState(next, tx);
      if (previous.consecutiveFailures === 0) {
        await this.audit.append(tx, {
          actorUserId: null,
          action: 'GOLD_RATE_FEED_FAILOVER',
          entityType: 'gold_rate',
          afterValue: { lastError: next.lastError, failingSinceAt },
        });
      }
    });
  }
}

export type PublicGoldRatePayload = GoldRateSnapshot | DisplayNotLicensedPayload;
export type { WireKarat };
