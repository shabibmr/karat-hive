import { HttpStatus, Injectable } from '@nestjs/common';
import {
  ConnectionState,
  OfferState,
  Prisma,
  RequestState,
  type VendorProfile,
} from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx, type DbTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { Clock } from '../../../shared/clock';
import { AuditWriter } from '../../audit';
import { SubscriptionService } from '../../subscription/application/subscription.service';
import type { SubscriptionView } from '../../subscription/presenter/subscription.presenter';
import {
  presentVendorRequest,
  type VendorRequestView,
} from '../../requests/presenter/request-vendor.presenter';
import { buildLifecycleInput } from './vendor-lifecycle-input';
import { presentVendorMe, type VendorMe } from '../presenter/vendor-me.presenter';
import {
  VendorOnboardingRepository,
  type CreateVendorProfileInput,
} from '../repository/vendor-onboarding.repository';

@Injectable()
export class VendorOnboardingService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly repo: VendorOnboardingRepository,
    private readonly audit: AuditWriter,
    private readonly subscriptionService: SubscriptionService,
    private readonly clock: Clock,
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

  /** VEN-S05. Real dashboard aggregates (CP2-A13). */
  async dashboard(viewer: ViewerContext): Promise<{
    newRequests: { count: number; preview: VendorRequestView[] };
    pendingOffers: { count: number; expiringWithin24h: number };
    activeConnections: { count: number; noTalkCount: number };
    rating: { average: number | null; reviewCount: number };
    goldRates: null;
    subscriptions: SubscriptionView[];
  }> {
    const profile = await this.requireProfile(viewer);
    const now = this.clock.now();
    const in24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const unviewedWhere: Prisma.RequestMatchWhereInput = {
      vendorProfileId: profile.id,
      isEligible: true,
      viewedAt: null,
      request: {
        state: { in: [RequestState.PUBLISHED, RequestState.OFFERS_RECEIVED] },
        expiresAt: { gt: now },
      },
    };

    const [
      newRequestsCount,
      previewMatches,
      pendingOffersCount,
      expiringOffersCount,
      activeConnectionsCount,
      noTalkCount,
      subscriptions,
    ] = await Promise.all([
      this.prisma.requestMatch.count({ where: unviewedWhere }),
      this.prisma.requestMatch.findMany({
        where: unviewedWhere,
        take: 3,
        orderBy: { matchedAt: 'desc' },
        include: {
          request: {
            include: {
              category: true,
              region: true,
              media: {
                include: { media: true },
                orderBy: { displayOrder: 'asc' },
              },
            },
          },
        },
      }),
      this.prisma.offer.count({
        where: {
          vendorProfileId: profile.id,
          state: OfferState.PENDING,
          expiresAt: { gt: now },
        },
      }),
      this.prisma.offer.count({
        where: {
          vendorProfileId: profile.id,
          state: OfferState.PENDING,
          expiresAt: { gt: now, lte: in24h },
        },
      }),
      this.prisma.connection.count({
        where: {
          vendorProfileId: profile.id,
          state: ConnectionState.ACTIVE,
        },
      }),
      this.prisma.connection.count({
        where: {
          vendorProfileId: profile.id,
          state: ConnectionState.ACTIVE,
          contactEvents: { none: {} },
        },
      }),
      this.subscriptionService.getSubscriptions(profile.id),
    ]);

    const preview = previewMatches.map((m) =>
      presentVendorRequest(
        m.request as Parameters<typeof presentVendorRequest>[0],
        {
          label: `Customer in ${m.request.region?.nameEn ?? 'UAE'}`,
          region: m.request.region?.nameEn ?? 'UAE',
          ratingScore: 5.0,
          dealCount: 1,
        },
        m.viewedAt,
      ),
    );

    return {
      newRequests: {
        count: newRequestsCount,
        preview,
      },
      pendingOffers: {
        count: pendingOffersCount,
        expiringWithin24h: expiringOffersCount,
      },
      activeConnections: {
        count: activeConnectionsCount,
        noTalkCount,
      },
      rating: {
        average: profile.aggregateRating ? Number(profile.aggregateRating) : null,
        reviewCount: profile.reviewCount,
      },
      goldRates: null,
      subscriptions,
    };
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

function unique(ids: string[]): string[] {
  return [...new Set(ids)];
}

function pick<T extends object, K extends keyof T>(obj: T, keys: K[]): Partial<T> {
  const out: Partial<T> = {};
  for (const k of keys) if (obj[k] !== undefined) out[k] = obj[k];
  return out;
}
