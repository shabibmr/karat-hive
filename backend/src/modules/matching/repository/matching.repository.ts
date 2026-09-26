import { Injectable } from '@nestjs/common';
import type { Prisma, RequestType } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { MatchesFilterDto } from '../domain/matching-engine';

/** Live Type Subscription: stored ACTIVE/GRACE and still within periodEnd or graceEndsAt. */
function liveSubscriptionWhere(
  now: Date,
  requestType?: RequestType,
): Prisma.VendorTypeSubscriptionWhereInput {
  return {
    ...(requestType ? { requestType } : {}),
    state: { in: ['ACTIVE', 'GRACE'] },
    OR: [{ periodEnd: { gte: now } }, { graceEndsAt: { gte: now } }],
  };
}

@Injectable()
export class MatchingRepository {
  constructor(private readonly prisma: PrismaService) {}

  async fanOutMatches(
    requestId: string,
    requestType: RequestType,
    now: Date = new Date(),
  ): Promise<number> {
    // Eligibility gates on VERIFIED + ACTIVE + an active Type Subscription only
    // (BR-002) — every subscribed Vendor sees every Request of that type.
    const eligibleVendors = await this.prisma.vendorProfile.findMany({
      where: {
        verificationState: 'VERIFIED',
        activatedAt: { not: null },
        user: { accountState: 'ACTIVE', deletedAt: null },
        subscriptions: {
          some: liveSubscriptionWhere(now, requestType),
        },
      },
      select: { id: true },
    });

    if (eligibleVendors.length === 0) return 0;

    const res = await this.prisma.requestMatch.createMany({
      data: eligibleVendors.map((v) => ({
        requestId,
        vendorProfileId: v.id,
        matchedAt: now,
        isEligible: true,
      })),
      skipDuplicates: true,
    });

    return res.count;
  }

  async recomputeForVendor(vendorProfileId: string, now: Date = new Date()): Promise<number> {
    const vendor = await this.prisma.vendorProfile.findUnique({
      where: { id: vendorProfileId },
      include: {
        user: true,
        subscriptions: {
          where: liveSubscriptionWhere(now),
        },
      },
    });

    if (
      !vendor ||
      vendor.verificationState !== 'VERIFIED' ||
      vendor.activatedAt === null ||
      vendor.user.accountState !== 'ACTIVE'
    ) {
      return 0;
    }

    const subTypes = vendor.subscriptions.map((s) => s.requestType);

    if (subTypes.length === 0) {
      return 0;
    }

    const eligibleRequests = await this.prisma.request.findMany({
      where: {
        state: 'PUBLISHED',
        expiresAt: { gt: now },
        requestType: { in: subTypes },
      },
      select: { id: true },
    });

    if (eligibleRequests.length === 0) return 0;

    const res = await this.prisma.requestMatch.createMany({
      data: eligibleRequests.map((r) => ({
        requestId: r.id,
        vendorProfileId,
        matchedAt: now,
        isEligible: true,
      })),
      skipDuplicates: true,
    });

    return res.count;
  }

  async markMatchViewed(
    vendorProfileId: string,
    requestId: string,
    now: Date = new Date(),
  ): Promise<void> {
    await this.prisma.requestMatch.updateMany({
      where: {
        vendorProfileId,
        requestId,
        viewedAt: null,
      },
      data: {
        viewedAt: now,
      },
    });
  }

  async listMatchesForVendor(
    vendorProfileId: string,
    filter: MatchesFilterDto,
    now: Date = new Date(),
  ) {
    const limit = filter.limit ? Math.min(Math.max(filter.limit, 1), 50) : 20;

    const where: Prisma.RequestMatchWhereInput = {
      vendorProfileId,
      isEligible: true,
      request: {
        state: 'PUBLISHED',
        expiresAt: { gt: now },
        ...(filter.requestType ? { requestType: filter.requestType } : {}),
        ...(filter.direction ? { direction: filter.direction } : {}),
        ...(filter.regionId ? { regionId: filter.regionId } : {}),
        ...(filter.purityKarat ? { purityKarat: filter.purityKarat } : {}),
        ...(filter.weightMin || filter.weightMax
          ? {
              weightGrams: {
                ...(filter.weightMin ? { gte: filter.weightMin } : {}),
                ...(filter.weightMax ? { lte: filter.weightMax } : {}),
              },
            }
          : {}),
        ...(filter.budgetMin || filter.budgetMax
          ? {
              budgetMax: {
                ...(filter.budgetMin ? { gte: filter.budgetMin } : {}),
                ...(filter.budgetMax ? { lte: filter.budgetMax } : {}),
              },
            }
          : {}),
        ...(filter.publishedWithinHours
          ? {
              publishedAt: {
                gte: new Date(now.getTime() - filter.publishedWithinHours * 60 * 60 * 1000),
              },
            }
          : {}),
        ...(filter.q
          ? {
              OR: [
                { reference: { contains: filter.q, mode: 'insensitive' } },
                { notes: { contains: filter.q, mode: 'insensitive' } },
              ],
            }
          : {}),
        ...(filter.includeResponded !== true
          ? {
              offers: {
                none: {
                  vendorProfileId,
                },
              },
            }
          : {}),
      },
    };

    let orderBy: Prisma.RequestMatchOrderByWithRelationInput = { matchedAt: 'desc' };
    if (filter.sort === 'EXPIRING') {
      orderBy = { request: { expiresAt: 'asc' } };
    } else if (filter.sort === 'FEWEST_OFFERS') {
      orderBy = { request: { offerCount: 'asc' } };
    } else if (filter.sort === 'HIGHEST_VALUE') {
      orderBy = { request: { budgetMax: 'desc' } };
    }

    const matches = await this.prisma.requestMatch.findMany({
      where,
      take: limit + 1,
      ...(filter.cursor
        ? {
            cursor: { id: filter.cursor },
            skip: 1,
          }
        : {}),
      orderBy,
      include: {
        request: {
          include: {
            region: true,
            media: { include: { media: true } },
            offers: {
              where: { vendorProfileId },
            },
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
    });

    let nextCursor: string | undefined = undefined;
    let items = matches;
    if (matches.length > limit) {
      const next = matches[limit];
      if (next) {
        nextCursor = next.id;
      }
      items = matches.slice(0, limit);
    }

    return { items, nextCursor };
  }

  // Filter Presets CRUD (FR-VEN-009, VEN-S07)
  async listFilterPresets(vendorProfileId: string) {
    return this.prisma.filterPreset.findMany({
      where: { vendorProfileId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findFilterPreset(vendorProfileId: string, id: string) {
    return this.prisma.filterPreset.findFirst({
      where: { id, vendorProfileId },
    });
  }

  async createFilterPreset(
    vendorProfileId: string,
    name: string,
    filters: Prisma.InputJsonValue,
  ) {
    return this.prisma.filterPreset.create({
      data: {
        vendorProfileId,
        name,
        filters,
      },
    });
  }

  async updateFilterPreset(
    vendorProfileId: string,
    id: string,
    name?: string,
    filters?: Prisma.InputJsonValue,
  ) {
    return this.prisma.filterPreset.update({
      where: { id },
      data: {
        ...(name !== undefined ? { name } : {}),
        ...(filters !== undefined ? { filters } : {}),
      },
    });
  }

  async deleteFilterPreset(vendorProfileId: string, id: string) {
    return this.prisma.filterPreset.deleteMany({
      where: { id, vendorProfileId },
    });
  }
}
