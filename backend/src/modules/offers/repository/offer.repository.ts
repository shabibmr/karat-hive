import { Injectable } from '@nestjs/common';
import {
  Prisma,
  type DeclineReason,
  type OfferState,
  type RequestType,
} from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';
import type { SubmitOfferInput } from '../domain/offer-validator';
import type { PrismaOfferWithDetails } from '../presenter/offer.presenter';

export type ListRequestOffersFilter = {
  sort?: 'PRICE_ASC' | 'PRICE_DESC' | 'RATING' | 'NEWEST' | 'OLDEST' | 'EXPIRING';
  minRating?: number;
  priceMin?: number;
  priceMax?: number;
  excludeExpiringWithinHours?: number;
  limit?: number;
  cursor?: string;
};

export type ListVendorOffersFilter = {
  tab?: 'PENDING' | 'ACCEPTED' | 'CLOSED';
  requestType?: RequestType;
  from?: Date;
  to?: Date;
  q?: string;
  limit?: number;
  cursor?: string;
};

@Injectable()
export class OfferRepository {
  constructor(private readonly prisma: PrismaService) {}

  private db(tx?: DbTx) {
    return tx ?? this.prisma;
  }

  async findRequestForOffer(requestId: string, tx?: DbTx) {
    return this.db(tx).request.findUnique({
      where: { id: requestId },
      include: {
        customerProfile: {
          include: {
            user: true,
          },
        },
        category: true,
        region: true,
      },
    });
  }

  async checkVendorEligibility(vendorProfileId: string, requestType: RequestType, tx?: DbTx) {
    const vendor = await this.db(tx).vendorProfile.findUnique({
      where: { id: vendorProfileId },
      include: {
        user: true,
        subscriptions: {
          where: {
            requestType,
            state: { in: ['ACTIVE', 'GRACE'] },
          },
        },
      },
    });

    if (!vendor) return { isFound: false, isActive: false, hasSubscription: false };

    const isActive =
      vendor.verificationState === 'VERIFIED' &&
      vendor.user.accountState === 'ACTIVE' &&
      vendor.user.deletedAt === null;

    const hasSubscription = vendor.subscriptions.length > 0;

    return {
      isFound: true,
      isActive,
      hasSubscription,
      vendor,
    };
  }

  async isInMatchSet(vendorProfileId: string, requestId: string, tx?: DbTx): Promise<boolean> {
    const match = await this.db(tx).requestMatch.findUnique({
      where: {
        requestId_vendorProfileId: {
          requestId,
          vendorProfileId,
        },
      },
    });

    return !!match && match.isEligible;
  }

  async findPendingOfferByVendor(
    vendorProfileId: string,
    requestId: string,
    tx?: DbTx,
  ) {
    return this.db(tx).offer.findFirst({
      where: {
        vendorProfileId,
        requestId,
        state: 'PENDING',
      },
    });
  }

  async createOffer(
    input: {
      requestId: string;
      vendorProfileId: string;
      terms: SubmitOfferInput;
      expiresAt: Date;
      now: Date;
    },
    tx: DbTx,
  ): Promise<PrismaOfferWithDetails> {
    // 1. Create offer
    const offer = await tx.offer.create({
      data: {
        requestId: input.requestId,
        vendorProfileId: input.vendorProfileId,
        state: 'PENDING',
        offeredPrice: new Prisma.Decimal(input.terms.offeredPrice),
        makingCharges: input.terms.makingCharges !== undefined
          ? new Prisma.Decimal(input.terms.makingCharges)
          : null,
        ratePerGram: input.terms.ratePerGram !== undefined
          ? new Prisma.Decimal(input.terms.ratePerGram)
          : null,
        deliveryTimeframe: input.terms.deliveryTimeframe ?? null,
        warrantyTerms: input.terms.warrantyTerms ?? null,
        vendorNote: input.terms.vendorNote ?? null,
        validityHours: input.terms.validityHours,
        expiresAt: input.expiresAt,
        submittedAt: input.now,
        revisionCount: 0,
      },
    });

    // 2. Attach media keys if provided
    if (input.terms.mediaKeys && input.terms.mediaKeys.length > 0) {
      const mediaRecords = await tx.media.findMany({
        where: {
          key: { in: input.terms.mediaKeys },
          state: 'READY',
        },
      });

      const keyToId = new Map(mediaRecords.map((m) => [m.key, m.id]));
      const mediaData: Prisma.OfferMediaCreateManyInput[] = [];

      input.terms.mediaKeys.forEach((key, index) => {
        const mediaId = keyToId.get(key);
        if (mediaId) {
          mediaData.push({
            offerId: offer.id,
            mediaId,
            displayOrder: index,
          });
        }
      });

      if (mediaData.length > 0) {
        await tx.offerMedia.createMany({
          data: mediaData,
          skipDuplicates: true,
        });
      }
    }

    // 3. Update parent request offerCount and transition from PUBLISHED to OFFERS_RECEIVED if first offer
    const req = await tx.request.findUnique({
      where: { id: input.requestId },
      select: { state: true },
    });

    await tx.request.update({
      where: { id: input.requestId },
      data: {
        offerCount: { increment: 1 },
        ...(req?.state === 'PUBLISHED' ? { state: 'OFFERS_RECEIVED' } : {}),
      },
    });

    // 4. Update vendor profile submitted offers count
    await tx.vendorProfile.update({
      where: { id: input.vendorProfileId },
      data: {
        offersSubmittedCount: { increment: 1 },
      },
    });

    return (await this.findOfferById(offer.id, tx)) as PrismaOfferWithDetails;
  }

  async findOfferById(id: string, tx?: DbTx): Promise<PrismaOfferWithDetails | null> {
    return this.db(tx).offer.findUnique({
      where: { id },
      include: {
        media: {
          include: { media: true },
        },
        vendorProfile: {
          include: {
            regions: {
              include: { region: true },
            },
          },
        },
        request: {
          include: {
            category: true,
            region: true,
          },
        },
        connection: {
          select: { id: true },
        },
      },
    });
  }

  async createRevision(
    input: {
      offerId: string;
      previousTerms: Prisma.InputJsonValue;
      newPrice: Prisma.Decimal;
      newMakingCharges?: Prisma.Decimal | null;
      newRatePerGram?: Prisma.Decimal | null;
      newDeliveryTimeframe?: string | null;
      newWarrantyTerms?: string | null;
      newVendorNote?: string | null;
      newValidityHours: number;
      newExpiresAt: Date;
      newRevisionCount: number;
      now: Date;
    },
    tx: DbTx,
  ): Promise<PrismaOfferWithDetails> {
    // 1. Record revision row
    await tx.offerRevision.create({
      data: {
        offerId: input.offerId,
        revisionNumber: input.newRevisionCount,
        previousTerms: input.previousTerms,
        revisedAt: input.now,
      },
    });

    // 2. Update offer
    await tx.offer.update({
      where: { id: input.offerId },
      data: {
        offeredPrice: input.newPrice,
        makingCharges: input.newMakingCharges,
        ratePerGram: input.newRatePerGram,
        deliveryTimeframe: input.newDeliveryTimeframe,
        warrantyTerms: input.newWarrantyTerms,
        vendorNote: input.newVendorNote,
        validityHours: input.newValidityHours,
        expiresAt: input.newExpiresAt,
        revisionCount: input.newRevisionCount,
        submittedAt: input.now,
      },
    });

    return (await this.findOfferById(input.offerId, tx)) as PrismaOfferWithDetails;
  }

  async updateOfferState(
    offerId: string,
    state: OfferState,
    extra?: {
      declineReason?: DeclineReason | null;
      decidedAt?: Date | null;
    },
    tx?: DbTx,
  ): Promise<PrismaOfferWithDetails> {
    const updated = await this.db(tx).offer.update({
      where: { id: offerId },
      data: {
        state,
        declineReason: extra?.declineReason,
        decidedAt: extra?.decidedAt,
      },
      include: {
        media: { include: { media: true } },
        vendorProfile: {
          include: {
            regions: { include: { region: true } },
          },
        },
        request: {
          include: {
            category: true,
            region: true,
          },
        },
      },
    });

    return updated;
  }

  async countPendingOffersOnRequest(requestId: string, tx?: DbTx): Promise<number> {
    return this.db(tx).offer.count({
      where: {
        requestId,
        state: 'PENDING',
      },
    });
  }

  async listOffersForRequest(
    requestId: string,
    filter: ListRequestOffersFilter,
    now: Date = new Date(),
  ): Promise<{ items: PrismaOfferWithDetails[]; nextCursor?: string }> {
    const limit = filter.limit ? Math.min(Math.max(filter.limit, 1), 50) : 20;

    const where: Prisma.OfferWhereInput = {
      requestId,
      ...(filter.priceMin || filter.priceMax
        ? {
            offeredPrice: {
              ...(filter.priceMin ? { gte: new Prisma.Decimal(filter.priceMin) } : {}),
              ...(filter.priceMax ? { lte: new Prisma.Decimal(filter.priceMax) } : {}),
            },
          }
        : {}),
      ...(filter.minRating
        ? {
            vendorProfile: {
              aggregateRating: { gte: new Prisma.Decimal(filter.minRating) },
            },
          }
        : {}),
      ...(filter.excludeExpiringWithinHours
        ? {
            expiresAt: {
              gt: new Date(now.getTime() + filter.excludeExpiringWithinHours * 60 * 60 * 1000),
            },
          }
        : {}),
    };

    let orderBy: Prisma.OfferOrderByWithRelationInput = { submittedAt: 'desc' };
    if (filter.sort === 'PRICE_ASC') {
      orderBy = { offeredPrice: 'asc' };
    } else if (filter.sort === 'PRICE_DESC') {
      orderBy = { offeredPrice: 'desc' };
    } else if (filter.sort === 'RATING') {
      orderBy = { vendorProfile: { aggregateRating: 'desc' } };
    } else if (filter.sort === 'OLDEST') {
      orderBy = { submittedAt: 'asc' };
    } else if (filter.sort === 'EXPIRING') {
      orderBy = { expiresAt: 'asc' };
    }

    const offers = await this.prisma.offer.findMany({
      where,
      take: limit + 1,
      ...(filter.cursor ? { cursor: { id: filter.cursor }, skip: 1 } : {}),
      orderBy,
      include: {
        media: { include: { media: true } },
        vendorProfile: {
          include: {
            regions: { include: { region: true } },
          },
        },
        connection: {
          select: { id: true },
        },
      },
    });

    let nextCursor: string | undefined = undefined;
    let items = offers;
    if (offers.length > limit) {
      const next = offers[limit];
      if (next) {
        nextCursor = next.id;
      }
      items = offers.slice(0, limit);
    }

    return { items, nextCursor };
  }

  async listOffersForVendor(
    vendorProfileId: string,
    filter: ListVendorOffersFilter,
  ): Promise<{ items: PrismaOfferWithDetails[]; nextCursor?: string }> {
    const limit = filter.limit ? Math.min(Math.max(filter.limit, 1), 50) : 20;

    let stateFilter: Prisma.OfferWhereInput['state'] | undefined = undefined;
    if (filter.tab === 'PENDING') {
      stateFilter = 'PENDING';
    } else if (filter.tab === 'ACCEPTED') {
      stateFilter = 'ACCEPTED';
    } else if (filter.tab === 'CLOSED') {
      stateFilter = { in: ['REJECTED', 'EXPIRED', 'WITHDRAWN', 'WITHDRAWN_BY_SYSTEM'] };
    }

    const where: Prisma.OfferWhereInput = {
      vendorProfileId,
      ...(stateFilter ? { state: stateFilter } : {}),
      ...(filter.from || filter.to
        ? {
            submittedAt: {
              ...(filter.from ? { gte: filter.from } : {}),
              ...(filter.to ? { lte: filter.to } : {}),
            },
          }
        : {}),
      ...(filter.requestType
        ? {
            request: {
              requestType: filter.requestType,
            },
          }
        : {}),
      ...(filter.q
        ? {
            request: {
              OR: [
                { reference: { contains: filter.q, mode: 'insensitive' } },
                { notes: { contains: filter.q, mode: 'insensitive' } },
              ],
            },
          }
        : {}),
    };

    const offers = await this.prisma.offer.findMany({
      where,
      take: limit + 1,
      ...(filter.cursor ? { cursor: { id: filter.cursor }, skip: 1 } : {}),
      orderBy: { submittedAt: 'desc' },
      include: {
        media: { include: { media: true } },
        request: {
          include: {
            category: true,
            region: true,
          },
        },
        connection: {
          select: { id: true },
        },
      },
    });

    let nextCursor: string | undefined = undefined;
    let items = offers;
    if (offers.length > limit) {
      const next = offers[limit];
      if (next) {
        nextCursor = next.id;
      }
      items = offers.slice(0, limit);
    }

    return { items, nextCursor };
  }

  /**
   * CBG-03: first-write-wins (`viewedByCustomerAt: null` guard) and a no-op on
   * terminal offers (`state: 'PENDING'` guard). Ownership is enforced by the
   * caller in OfferService. Safe to call on every offer-detail open / list render.
   */
  async markOfferViewedByCustomer(offerId: string, now: Date): Promise<void> {
    await this.prisma.offer.updateMany({
      where: {
        id: offerId,
        state: 'PENDING',
        viewedByCustomerAt: null,
      },
      data: {
        viewedByCustomerAt: now,
      },
    });
  }

  async findExpiredPendingOffers(now: Date) {
    return this.prisma.offer.findMany({
      where: {
        state: 'PENDING',
        expiresAt: { lte: now },
      },
      include: {
        request: {
          include: {
            customerProfile: { include: { user: true } },
          },
        },
        vendorProfile: {
          include: { user: true },
        },
      },
      take: 100,
    });
  }

  async findExpiringPendingOffersWarning(threshold: Date) {
    return this.prisma.offer.findMany({
      where: {
        state: 'PENDING',
        expiryWarnedAt: null,
        expiresAt: { lte: threshold },
      },
      include: {
        vendorProfile: { include: { user: true } },
      },
      take: 100,
    });
  }
}
