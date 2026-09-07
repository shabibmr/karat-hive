import { randomUUID } from 'node:crypto';
import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import type { Prisma, RequestType, VendorProfile } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { LocalDiskStorageAdapter } from '../../../platform/adapters/storage/local-disk-storage.adapter';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx, type DbTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { OBJECT_STORAGE, type ObjectStorage } from '../../../platform/ports/storage.port';
import { Clock } from '../../../shared/clock';
import { AuditWriter } from '../../audit';
import {
  presentRequestForVendor,
  type RequestForVendor,
} from '../../requests/presenter/request.presenter';
import {
  presentSubscription,
  type SubscriptionView,
} from '../../subscription/presenter/subscription.presenter';
import {
  buildVendorPerformanceCsv,
  type VendorPerformanceCsvRow,
} from '../domain/vendor-performance-csv';
import { presentVendorMe, type VendorMe } from '../presenter/vendor-me.presenter';
import {
  VendorOnboardingRepository,
  type CreateVendorProfileInput,
} from '../repository/vendor-onboarding.repository';
import { buildLifecycleInput } from './vendor-lifecycle-input';

const EXPORT_BUCKET = 'export';
const EXPORT_DOWNLOAD_TTL_SECONDS = 900;
const MS_PER_HOUR = 60 * 60 * 1000;

export type PerformanceExportFilters = {
  from?: Date;
  to?: Date;
  requestType?: RequestType;
  categoryId?: string;
  regionId?: string;
};

export type VendorDashboard = {
  newRequests: { count: number; preview: RequestForVendor[] };
  pendingOffers: { count: number; expiringWithin24h: number };
  activeConnections: { count: number; noTalkCount: number };
  rating: { average: number | null; reviewCount: number };
  goldRates: null;
  subscriptions: SubscriptionView[];
};

@Injectable()
export class VendorOnboardingService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly repo: VendorOnboardingRepository,
    private readonly audit: AuditWriter,
    private readonly clock: Clock,
    @Inject(OBJECT_STORAGE) private readonly storage: ObjectStorage,
  ) {}

  /**
   * module-public. Creates the vendor_profile plus its declared categories/regions
   * inside the caller's transaction (identity's register/vendor). Emits vendor.registered.
   */
  async createProfile(
    tx: DbTx,
    input: CreateVendorProfileInput & {
      categoryIds: string[];
      servedRegionIds: string[];
      ipAddress?: string | null;
      userAgent?: string | null;
    },
  ): Promise<VendorProfile> {
    const profile = await this.repo.createProfile(tx, input);
    await this.repo.replaceCategories(tx, profile.id, unique(input.categoryIds));
    await this.repo.replaceRegions(tx, profile.id, unique(input.servedRegionIds));
    await enqueueOutbox(tx, {
      eventType: 'vendor.registered',
      aggregateType: 'vendor_profile',
      aggregateId: profile.id,
      payload: { vendorProfileId: profile.id, vendorUserId: input.userId },
    });
    await this.audit.append(tx, {
      actorUserId: input.userId,
      action: 'VENDOR_REGISTERED',
      entityType: 'vendor_profile',
      entityId: profile.id,
      afterValue: { verificationState: profile.verificationState },
      ipAddress: input.ipAddress ?? null,
      userAgent: input.userAgent ?? null,
    });
    return profile;
  }

  /** module-public: uniqueness check used by identity's register/vendor. */
  async licenceExists(tradeLicenceNumber: string): Promise<boolean> {
    return (await this.repo.licenceExists(tradeLicenceNumber)) !== null;
  }

  /** module-public: login gate (API §8) — REJECTED Vendors cannot start a session. */
  async assertMayAuthenticate(userId: string): Promise<void> {
    const profile = await this.repo.findByUserId(userId);
    if (profile?.verificationState === 'REJECTED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
  }

  async requireProfile(viewer: ViewerContext): Promise<VendorProfile> {
    const id = viewer.vendorProfileId;
    const profile = id ? await this.repo.findById(id) : null;
    if (!profile) throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    return profile;
  }

  async getVendorMe(viewer: ViewerContext): Promise<VendorMe> {
    const profile = await this.requireProfile(viewer);
    const { input, categoryCount, regionCount } = await buildLifecycleInput(
      this.repo,
      profile,
      viewer.accountState,
    );
    const [categoryIds, regionIds] = await Promise.all([
      this.repo.listCategoryIds(profile.id),
      this.repo.listRegionIds(profile.id),
    ]);
    return presentVendorMe(profile, input, {
      categoryCount,
      regionCount,
      categoryIds,
      regionIds,
    });
  }

  async patchProfile(
    viewer: ViewerContext,
    dto: {
      tradingName?: string;
      description?: string;
      contactPersonName?: string;
      businessEmail?: string;
      legalBusinessName?: string;
      tradeLicenceNumber?: string;
      businessAddress?: string;
    },
  ): Promise<VendorMe> {
    const profile = await this.requireProfile(viewer);
    const reverifyFields =
      dto.legalBusinessName !== undefined ||
      dto.tradeLicenceNumber !== undefined ||
      dto.businessAddress !== undefined;

    await withTx(this.prisma, async (tx) => {
      await this.repo.update(tx, profile.id, {
        ...pick(dto, [
          'tradingName',
          'description',
          'contactPersonName',
          'businessEmail',
          'legalBusinessName',
          'tradeLicenceNumber',
          'businessAddress',
        ]),
        ...(reverifyFields ? { verificationState: 'PENDING_VERIFICATION', activatedAt: null } : {}),
      });
      if (reverifyFields) {
        await enqueueOutbox(tx, {
          eventType: 'vendor.eligibility.changed',
          aggregateType: 'vendor_profile',
          aggregateId: profile.id,
          payload: {
            vendorProfileId: profile.id,
            vendorUserId: viewer.userId,
            reason: 'PROFILE_REVERIFY',
          },
        });
        await this.audit.append(tx, {
          actorUserId: viewer.userId,
          action: 'VENDOR_PROFILE_REVERIFY',
          entityType: 'vendor_profile',
          entityId: profile.id,
        });
      }
    });
    return this.getVendorMe(viewer);
  }

  /**
   * VEN-S05 / FR-VEN-004–007. Real counts for new matches, pending offers, active
   * connections, plus subscription summary. Gold rates stay null until G2-GR02.
   */
  async dashboard(viewer: ViewerContext): Promise<VendorDashboard> {
    const profile = await this.requireProfile(viewer);
    const now = this.clock.now();
    const within24h = new Date(now.getTime() + 24 * MS_PER_HOUR);

    const newMatchWhere: Prisma.RequestMatchWhereInput = {
      vendorProfileId: profile.id,
      isEligible: true,
      viewedAt: null,
      request: {
        state: { in: ['PUBLISHED', 'OFFERS_RECEIVED'] },
        expiresAt: { gt: now },
        offers: { none: { vendorProfileId: profile.id } },
      },
    };

    const [
      newCount,
      previewMatches,
      pendingCount,
      expiringWithin24h,
      activeConnectionCount,
      noTalkCount,
      subscriptions,
    ] = await Promise.all([
      this.prisma.requestMatch.count({ where: newMatchWhere }),
      this.prisma.requestMatch.findMany({
        where: newMatchWhere,
        orderBy: { matchedAt: 'desc' },
        take: 3,
        include: {
          request: {
            include: {
              category: true,
              region: true,
              media: { include: { media: true } },
              customerProfile: {
                select: {
                  connectionCount: true,
                  aggregateRating: true,
                  reviewCount: true,
                },
              },
            },
          },
        },
      }),
      this.prisma.offer.count({
        where: { vendorProfileId: profile.id, state: 'PENDING' },
      }),
      this.prisma.offer.count({
        where: {
          vendorProfileId: profile.id,
          state: 'PENDING',
          expiresAt: { gt: now, lte: within24h },
        },
      }),
      this.prisma.connection.count({
        where: { vendorProfileId: profile.id, state: 'ACTIVE' },
      }),
      this.prisma.connection.count({
        where: {
          vendorProfileId: profile.id,
          state: 'ACTIVE',
          contactEvents: { none: {} },
        },
      }),
      this.prisma.vendorTypeSubscription.findMany({
        where: { vendorProfileId: profile.id },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    const preview: RequestForVendor[] = previewMatches.map((m) => {
      const cust = m.request.customerProfile;
      return presentRequestForVendor(m.request, {
        customerConnectionCount: cust?.connectionCount ?? 0,
        customerRating: cust?.aggregateRating
          ? {
              average: cust.aggregateRating.toString(),
              count: cust.reviewCount,
              distribution: {},
              limitedHistory: cust.reviewCount < 3,
            }
          : undefined,
        viewedAt: m.viewedAt,
      });
    });

    return {
      newRequests: { count: newCount, preview },
      pendingOffers: { count: pendingCount, expiringWithin24h },
      activeConnections: { count: activeConnectionCount, noTalkCount },
      rating: {
        average: profile.aggregateRating ? Number(profile.aggregateRating) : null,
        reviewCount: profile.reviewCount,
      },
      goldRates: null,
      subscriptions: subscriptions.map(presentSubscription),
    };
  }

  /**
   * FR-VEN-023 AC3. Signed CSV of this Vendor's own Offer history only (BR-008).
   * Watermark + shared export-job pipeline deferred to G2-ADM07 — writes the CSV
   * directly to the EXPORT bucket and returns a short-lived signed download URL.
   */
  async exportPerformance(
    viewer: ViewerContext,
    filters: PerformanceExportFilters = {},
  ): Promise<{ downloadUrl: string; expiresAt: string }> {
    const profile = await this.requireProfile(viewer);
    const rows = await this.loadPerformanceCsvRows(profile.id, filters);
    const csv = buildVendorPerformanceCsv(rows);
    const body = Buffer.from(csv, 'utf8');
    const key = `vendor/${profile.id}/performance/${randomUUID()}.csv`;

    await putExportObject(this.storage, EXPORT_BUCKET, key, body, 'text/csv');

    const signed = await this.storage.createSignedDownloadUrl(
      EXPORT_BUCKET,
      key,
      EXPORT_DOWNLOAD_TTL_SECONDS,
    );

    await this.audit.append(this.prisma, {
      actorUserId: viewer.userId,
      action: 'VENDOR_PERFORMANCE_EXPORT',
      entityType: 'vendor_profile',
      entityId: profile.id,
      afterValue: {
        objectKey: key,
        rowCount: rows.length,
        filters: {
          from: filters.from?.toISOString() ?? null,
          to: filters.to?.toISOString() ?? null,
          requestType: filters.requestType ?? null,
          categoryId: filters.categoryId ?? null,
          regionId: filters.regionId ?? null,
        },
      },
    });

    return {
      downloadUrl: signed.url,
      expiresAt: signed.expiresAt.toISOString(),
    };
  }

  private async loadPerformanceCsvRows(
    vendorProfileId: string,
    filters: PerformanceExportFilters,
  ): Promise<VendorPerformanceCsvRow[]> {
    const where: Prisma.OfferWhereInput = {
      vendorProfileId,
      ...(filters.from || filters.to
        ? {
            createdAt: {
              ...(filters.from ? { gte: filters.from } : {}),
              ...(filters.to ? { lte: filters.to } : {}),
            },
          }
        : {}),
      ...(filters.requestType || filters.categoryId || filters.regionId
        ? {
            request: {
              ...(filters.requestType ? { requestType: filters.requestType } : {}),
              ...(filters.categoryId ? { categoryId: filters.categoryId } : {}),
              ...(filters.regionId ? { regionId: filters.regionId } : {}),
            },
          }
        : {}),
    };

    const offers = await this.prisma.offer.findMany({
      where,
      orderBy: { submittedAt: 'desc' },
      include: {
        request: {
          select: {
            reference: true,
            requestType: true,
            publishedAt: true,
            category: { select: { nameEn: true } },
            region: { select: { nameEn: true } },
          },
        },
      },
    });

    return offers.map((o) => {
      let responseMinutes = '';
      if (o.request.publishedAt) {
        const diffMs = o.submittedAt.getTime() - o.request.publishedAt.getTime();
        if (diffMs >= 0) {
          responseMinutes = String(Math.round(diffMs / (60 * 1000)));
        }
      }
      return {
        offerId: o.id,
        requestReference: o.request.reference ?? '',
        requestType: o.request.requestType,
        categoryNameEn: o.request.category.nameEn,
        regionNameEn: o.request.region.nameEn,
        state: o.state,
        offeredPriceAed: Number(o.offeredPrice).toFixed(2),
        submittedAt: o.submittedAt.toISOString(),
        expiresAt: o.expiresAt.toISOString(),
        decidedAt: o.decidedAt?.toISOString() ?? '',
        declineReason: o.declineReason ?? '',
        responseMinutes,
      };
    });
  }

  /** module-public: VendorMe sub-object for GET /v1/me, given the owning user id. */
  async vendorMeForUser(
    userId: string,
    accountState: ViewerContext['accountState'],
  ): Promise<VendorMe | null> {
    const profile = await this.repo.findByUserId(userId);
    if (!profile) return null;
    const { input, categoryCount, regionCount } = await buildLifecycleInput(
      this.repo,
      profile,
      accountState,
    );
    const [categoryIds, regionIds] = await Promise.all([
      this.repo.listCategoryIds(profile.id),
      this.repo.listRegionIds(profile.id),
    ]);
    return presentVendorMe(profile, input, {
      categoryCount,
      regionCount,
      categoryIds,
      regionIds,
    });
  }
}

/** ObjectStorage has no putObject yet — local adapter exposes putForTest; else signed PUT. */
async function putExportObject(
  storage: ObjectStorage,
  bucket: string,
  key: string,
  body: Buffer,
  contentType: string,
): Promise<void> {
  if (storage instanceof LocalDiskStorageAdapter) {
    await storage.putForTest(bucket, key, body, contentType);
    return;
  }
  const signed = await storage.createSignedUploadUrl({
    bucket,
    key,
    contentType,
    maxBytes: body.length,
    ttlSeconds: 60,
  });
  const res = await fetch(signed.uploadUrl, {
    method: 'PUT',
    headers: signed.requiredHeaders,
    body: new Uint8Array(body),
  });
  if (!res.ok) {
    throw new Error(`Export upload failed: ${res.status} ${await res.text()}`);
  }
}


function unique(ids: string[]): string[] {
  return [...new Set(ids)];
}

function pick<T extends object, K extends keyof T>(obj: T, keys: K[]): Partial<T> {
  const out: Partial<T> = {};
  for (const k of keys) if (obj[k] !== undefined) out[k] = obj[k];
  return out;
}
