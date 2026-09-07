import { Injectable } from '@nestjs/common';
import type {
  OfferState,
  Prisma,
  RequestType,
  SubscriptionState,
  VendorTypeSubscription,
} from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';

export interface PerformanceFilters {
  from?: Date;
  to?: Date;
  requestType?: RequestType;
  categoryId?: string;
  regionId?: string;
}

export interface VendorPerformanceData {
  offersSubmitted: number;
  acceptanceRate: string;
  averageResponseMinutes: number;
  averageOfferedVsAccepted?: string;
  byOutcome: { state: OfferState; count: number }[];
}

@Injectable()
export class SubscriptionRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findVendorProfileByUserId(userId: string) {
    return this.prisma.vendorProfile.findUnique({
      where: { userId },
    });
  }

  async findVendorProfileById(id: string) {
    return this.prisma.vendorProfile.findUnique({
      where: { id },
    });
  }

  async listSubscriptionsForVendor(vendorProfileId: string): Promise<VendorTypeSubscription[]> {
    return this.prisma.vendorTypeSubscription.findMany({
      where: { vendorProfileId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findActiveOrGraceByVendorAndType(
    vendorProfileId: string,
    requestType: RequestType,
  ): Promise<VendorTypeSubscription | null> {
    return this.prisma.vendorTypeSubscription.findFirst({
      where: {
        vendorProfileId,
        requestType,
        state: { in: ['ACTIVE', 'GRACE'] },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createSubscription(
    tx: Prisma.TransactionClient,
    data: {
      vendorProfileId: string;
      requestType: RequestType;
      state: SubscriptionState;
      periodStart: Date;
      periodEnd: Date;
      priceAed: string | number;
      paymentReference?: string;
      graceEndsAt?: Date;
    },
  ): Promise<VendorTypeSubscription> {
    // Expire any existing ACTIVE or GRACE subscriptions for this vendor and type
    await tx.vendorTypeSubscription.updateMany({
      where: {
        vendorProfileId: data.vendorProfileId,
        requestType: data.requestType,
        state: { in: ['ACTIVE', 'GRACE'] },
      },
      data: {
        state: 'EXPIRED',
      },
    });

    return tx.vendorTypeSubscription.create({
      data: {
        vendorProfileId: data.vendorProfileId,
        requestType: data.requestType,
        state: data.state,
        periodStart: data.periodStart,
        periodEnd: data.periodEnd,
        priceAed: data.priceAed,
        paymentReference: data.paymentReference,
        graceEndsAt: data.graceEndsAt,
      },
    });
  }

  async updateSubscription(
    tx: Prisma.TransactionClient,
    id: string,
    data: {
      state?: SubscriptionState;
      periodEnd?: Date;
      graceEndsAt?: Date | null;
    },
  ): Promise<VendorTypeSubscription> {
    return tx.vendorTypeSubscription.update({
      where: { id },
      data: {
        ...(data.state ? { state: data.state } : {}),
        ...(data.periodEnd ? { periodEnd: data.periodEnd } : {}),
        ...(data.graceEndsAt !== undefined ? { graceEndsAt: data.graceEndsAt } : {}),
      },
    });
  }

  async getVendorPerformance(
    vendorProfileId: string,
    filters: PerformanceFilters,
  ): Promise<VendorPerformanceData> {
    const whereClause: Prisma.OfferWhereInput = {
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
      where: whereClause,
      include: {
        request: {
          select: {
            publishedAt: true,
          },
        },
      },
    });

    const offersSubmitted = offers.length;
    const acceptedCount = offers.filter((o) => o.state === 'ACCEPTED').length;
    const acceptanceRate =
      offersSubmitted > 0 ? (acceptedCount / offersSubmitted).toFixed(2) : '0.00';

    let totalResponseMinutes = 0;
    let responseCount = 0;
    for (const o of offers) {
      if (o.request?.publishedAt) {
        const diffMs = o.createdAt.getTime() - o.request.publishedAt.getTime();
        if (diffMs >= 0) {
          totalResponseMinutes += Math.round(diffMs / (60 * 1000));
          responseCount++;
        }
      }
    }
    const averageResponseMinutes =
      responseCount > 0 ? Math.round(totalResponseMinutes / responseCount) : 0;

    const allStates: OfferState[] = [
      'PENDING',
      'ACCEPTED',
      'REJECTED',
      'EXPIRED',
      'WITHDRAWN',
      'WITHDRAWN_BY_SYSTEM',
    ];
    const byOutcome = allStates.map((state) => ({
      state,
      count: offers.filter((o) => o.state === state).length,
    }));

    return {
      offersSubmitted,
      acceptanceRate,
      averageResponseMinutes,
      byOutcome,
    };
  }
}
