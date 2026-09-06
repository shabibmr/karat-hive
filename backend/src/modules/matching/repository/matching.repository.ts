import { Injectable } from '@nestjs/common';
import {
  Prisma,
  RequestMatch,
  RequestState,
  SubscriptionState,
  UserAccountState,
  VendorVerificationState,
} from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';
import type { MatchFilters } from '../domain/matching.types';

@Injectable()
export class MatchingRepository {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Finds all vendors eligible for a given request per BR-002:
   * - VERIFIED vendorProfile
   * - ACTIVE user
   * - Category matches request.categoryId
   * - Region matches request.regionId
   * - Active or grace subscription for request.requestType
   */
  async findEligibleVendorProfileIds(
    requestId: string,
    now: Date,
    tx?: DbTx,
  ): Promise<string[]> {
    const client = tx ?? this.prisma;

    const request = await client.request.findUnique({
      where: { id: requestId },
      select: {
        id: true,
        categoryId: true,
        regionId: true,
        requestType: true,
        state: true,
      },
    });

    if (!request || request.state !== RequestState.PUBLISHED) {
      return [];
    }

    const eligibleVendors = await client.vendorProfile.findMany({
      where: {
        verificationState: VendorVerificationState.VERIFIED,
        user: {
          accountState: UserAccountState.ACTIVE,
        },
        categories: {
          some: { categoryId: request.categoryId },
        },
        regions: {
          some: { regionId: request.regionId },
        },
        subscriptions: {
          some: {
            requestType: request.requestType,
            state: { in: [SubscriptionState.ACTIVE, SubscriptionState.GRACE] },
            periodStart: { lte: now },
            OR: [
              { periodEnd: { gte: now } },
              { graceEndsAt: { gte: now } },
            ],
          },
        },
      },
      select: { id: true },
    });

    return eligibleVendors.map((v) => v.id);
  }

  async createMatch(
    requestId: string,
    vendorProfileId: string,
    matchedAt: Date,
    tx?: DbTx,
  ): Promise<RequestMatch | null> {
    const client = tx ?? this.prisma;
    try {
      return await client.requestMatch.create({
        data: {
          requestId,
          vendorProfileId,
          matchedAt,
          isEligible: true,
        },
      });
    } catch (error: unknown) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        // Already matched
        return null;
      }
      throw error;
    }
  }

  async markViewed(
    vendorProfileId: string,
    requestId: string,
    viewedAt: Date,
    tx?: DbTx,
  ): Promise<boolean> {
    const client = tx ?? this.prisma;
    const result = await client.requestMatch.updateMany({
      where: {
        vendorProfileId,
        requestId,
        viewedAt: null,
      },
      data: { viewedAt },
    });
    return result.count > 0;
  }

  async listMatches(
    vendorProfileId: string,
    filters: MatchFilters,
    now: Date,
    tx?: DbTx,
  ) {
    const client = tx ?? this.prisma;
    const limit = Math.min(Math.max(filters.limit ?? 20, 1), 50);

    const where: Prisma.RequestMatchWhereInput = {
      vendorProfileId,
      isEligible: true,
      request: {
        state: { in: [RequestState.PUBLISHED, RequestState.OFFERS_RECEIVED] },
        expiresAt: { gt: now },
        ...(filters.requestType && { requestType: filters.requestType }),
        ...(filters.direction && { direction: filters.direction }),
        ...(filters.categoryId && { categoryId: filters.categoryId }),
        ...(filters.regionId && { regionId: filters.regionId }),
        ...(filters.purityKarat && { purityKarat: filters.purityKarat }),
        ...(filters.weightMin !== undefined && { weightGrams: { gte: filters.weightMin } }),
        ...(filters.weightMax !== undefined && { weightGrams: { lte: filters.weightMax } }),
        ...(filters.budgetMin !== undefined && { budgetMin: { gte: filters.budgetMin } }),
        ...(filters.budgetMax !== undefined && { budgetMax: { lte: filters.budgetMax } }),
        ...(filters.publishedWithinHours && {
          publishedAt: { gte: new Date(now.getTime() - filters.publishedWithinHours * 60 * 60 * 1000) },
        }),
      },
    };

    if (filters.cursor) {
      where.id = { lt: filters.cursor };
    }

    const matches = await client.requestMatch.findMany({
      where,
      take: limit + 1,
      orderBy: { matchedAt: 'desc' },
      include: {
        request: {
          include: {
            category: true,
            region: true,
          },
        },
      },
    });

    const hasMore = matches.length > limit;
    const items = hasMore ? matches.slice(0, limit) : matches;
    const lastItem = items[items.length - 1];
    const nextCursor = hasMore && lastItem ? lastItem.id : null;

    return {
      items,
      nextCursor,
    };
  }

  /**
   * Recomputes a vendor's match set upon vendor.eligibility.changed (T37, CP2-A12).
   * Lapsed subscriptions or lost categories/regions remove future eligibility without deleting offer history.
   */
  async recomputeVendorEligibility(
    vendorProfileId: string,
    now: Date,
    tx?: DbTx,
  ): Promise<{ addedRequestIds: string[]; removedCount: number }> {
    const client = tx ?? this.prisma;

    const vendor = await client.vendorProfile.findUnique({
      where: { id: vendorProfileId },
      include: {
        user: true,
        categories: true,
        regions: true,
        subscriptions: {
          where: {
            state: { in: [SubscriptionState.ACTIVE, SubscriptionState.GRACE] },
            periodStart: { lte: now },
            OR: [{ periodEnd: { gte: now } }, { graceEndsAt: { gte: now } }],
          },
        },
      },
    });

    const isEligible =
      vendor &&
      vendor.verificationState === VendorVerificationState.VERIFIED &&
      vendor.user.accountState === UserAccountState.ACTIVE;

    const categoryIds = isEligible ? vendor.categories.map((c) => c.categoryId) : [];
    const regionIds = isEligible ? vendor.regions.map((r) => r.regionId) : [];
    const subscribedTypes = isEligible ? vendor.subscriptions.map((s) => s.requestType) : [];

    const canMatch =
      isEligible &&
      categoryIds.length > 0 &&
      regionIds.length > 0 &&
      subscribedTypes.length > 0;

    const eligibleRequests = canMatch
      ? await client.request.findMany({
          where: {
            state: { in: [RequestState.PUBLISHED, RequestState.OFFERS_RECEIVED] },
            expiresAt: { gt: now },
            categoryId: { in: categoryIds },
            regionId: { in: regionIds },
            requestType: { in: subscribedTypes },
          },
          select: { id: true },
        })
      : [];

    const eligibleRequestIds = new Set(eligibleRequests.map((r) => r.id));

    const currentOpenMatches = await client.requestMatch.findMany({
      where: {
        vendorProfileId,
        request: {
          state: { in: [RequestState.PUBLISHED, RequestState.OFFERS_RECEIVED] },
          expiresAt: { gt: now },
        },
      },
      select: { id: true, requestId: true, isEligible: true },
    });

    const existingMatchMap = new Map(currentOpenMatches.map((m) => [m.requestId, m]));

    const toDisableIds = currentOpenMatches
      .filter((m) => m.isEligible && !eligibleRequestIds.has(m.requestId))
      .map((m) => m.id);

    if (toDisableIds.length > 0) {
      await client.requestMatch.updateMany({
        where: { id: { in: toDisableIds } },
        data: { isEligible: false },
      });
    }

    const toEnableIds = currentOpenMatches
      .filter((m) => !m.isEligible && eligibleRequestIds.has(m.requestId))
      .map((m) => m.id);

    if (toEnableIds.length > 0) {
      await client.requestMatch.updateMany({
        where: { id: { in: toEnableIds } },
        data: { isEligible: true },
      });
    }

    const addedRequestIds: string[] = [];
    for (const req of eligibleRequests) {
      if (!existingMatchMap.has(req.id)) {
        await client.requestMatch.create({
          data: {
            requestId: req.id,
            vendorProfileId,
            matchedAt: now,
            isEligible: true,
          },
        });
        addedRequestIds.push(req.id);
      }
    }

    return {
      addedRequestIds,
      removedCount: toDisableIds.length,
    };
  }
}
