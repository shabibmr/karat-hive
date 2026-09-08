import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type {
  Direction,
  Karat,
  RequestState,
  RequestType,
} from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';
import type { FullPrismaRequest } from '../presenter/request.presenter';

export type CreateDraftInput = {
  customerProfileId: string;
  requestType: RequestType;
  direction: Direction;
  categoryId: string;
  regionId: string;
  notes?: string;
  weightGrams?: Prisma.Decimal | number | string;
  weightIsApproximate?: boolean;
  purityKarat?: Karat;
  ornamentType?: Prisma.RequestCreateInput['ornamentType'];
  condition?: Prisma.RequestCreateInput['condition'];
  denominationGrams?: Prisma.Decimal | number | string;
  quantity?: number;
  mintOrRefiner?: string;
  budgetMin?: Prisma.Decimal | number | string;
  budgetMax?: Prisma.Decimal | number | string;
  budgetIsFlexible?: boolean;
  gemstones?: Prisma.InputJsonValue;
  mediaIds?: string[];
};

export type ListCustomerRequestsParams = {
  customerProfileId: string;
  states?: RequestState[];
  requestType?: RequestType;
  direction?: Direction;
  q?: string;
  from?: Date;
  to?: Date;
  limit: number;
  cursor?: string;
};

/** Unique Connection.offer_id join — no denormalised request.connection_id (SAM-GAP-3). */
const acceptedOfferConnectionInclude = {
  acceptedOffer: {
    select: {
      id: true,
      connection: { select: { id: true } },
    },
  },
} as const;

/**
 * SAM-GAP-1 / CBG-01: presenter-time unread-Offer badge. Filtered relation count of
 * offers that are still PENDING and not yet marked viewed by the Customer. No
 * denormalised column — mirrors the acceptedOfferConnectionInclude join approach.
 */
const unreadOfferCountInclude = {
  _count: {
    select: {
      offers: {
        where: {
          state: 'PENDING' as const,
          viewedByCustomerAt: null,
        },
      },
    },
  },
} satisfies Prisma.RequestInclude;

@Injectable()
export class RequestRepository {
  constructor(private readonly prisma: PrismaService) {}

  private db(tx?: DbTx) {
    return tx ?? this.prisma;
  }

  async createDraft(input: CreateDraftInput, tx?: DbTx): Promise<FullPrismaRequest> {
    const db = this.db(tx);
    return db.request.create({
      data: {
        customerProfileId: input.customerProfileId,
        requestType: input.requestType,
        direction: input.direction,
        state: 'DRAFT',
        categoryId: input.categoryId,
        regionId: input.regionId,
        notes: input.notes,
        weightGrams: input.weightGrams ? new Prisma.Decimal(input.weightGrams) : undefined,
        weightIsApproximate: input.weightIsApproximate ?? false,
        purityKarat: input.purityKarat,
        ornamentType: input.ornamentType,
        condition: input.condition,
        denominationGrams: input.denominationGrams
          ? new Prisma.Decimal(input.denominationGrams)
          : undefined,
        quantity: input.quantity,
        mintOrRefiner: input.mintOrRefiner,
        budgetMin: input.budgetMin ? new Prisma.Decimal(input.budgetMin) : undefined,
        budgetMax: input.budgetMax ? new Prisma.Decimal(input.budgetMax) : undefined,
        budgetIsFlexible: input.budgetIsFlexible ?? false,
        gemstones: input.gemstones,
        media: input.mediaIds?.length
          ? {
              create: input.mediaIds.map((mediaId, index) => ({
                mediaId,
                displayOrder: index,
              })),
            }
          : undefined,
      },
      include: {
        category: true,
        region: true,
        media: {
          include: {
            media: true,
          },
          orderBy: { displayOrder: 'asc' },
        },
      },
    }) as Promise<FullPrismaRequest>;
  }

  async findById(id: string, tx?: DbTx): Promise<FullPrismaRequest | null> {
    const db = this.db(tx);
    return db.request.findUnique({
      where: { id },
      include: {
        category: true,
        region: true,
        media: {
          include: {
            media: true,
          },
          orderBy: { displayOrder: 'asc' },
        },
        offers: {
          orderBy: { createdAt: 'desc' },
        },
        ...acceptedOfferConnectionInclude,
        ...unreadOfferCountInclude,
      },
    }) as Promise<FullPrismaRequest | null>;
  }

  async findByIdForCustomer(
    id: string,
    customerProfileId: string,
    tx?: DbTx,
  ): Promise<FullPrismaRequest | null> {
    const db = this.db(tx);
    return db.request.findFirst({
      where: { id, customerProfileId },
      include: {
        category: true,
        region: true,
        media: {
          include: {
            media: true,
          },
          orderBy: { displayOrder: 'asc' },
        },
        offers: {
          orderBy: { createdAt: 'desc' },
        },
        ...acceptedOfferConnectionInclude,
        ...unreadOfferCountInclude,
      },
    }) as Promise<FullPrismaRequest | null>;
  }

  async countLiveRequestsForCustomer(customerProfileId: string, tx?: DbTx): Promise<number> {
    const db = this.db(tx);
    return db.request.count({
      where: {
        customerProfileId,
        state: { in: ['PUBLISHED', 'OFFERS_RECEIVED'] },
      },
    });
  }

  async update(
    id: string,
    data: Prisma.RequestUpdateInput,
    tx?: DbTx,
  ): Promise<FullPrismaRequest> {
    const db = this.db(tx);
    return db.request.update({
      where: { id },
      data,
      include: {
        category: true,
        region: true,
        media: {
          include: {
            media: true,
          },
          orderBy: { displayOrder: 'asc' },
        },
        offers: {
          orderBy: { createdAt: 'desc' },
        },
        ...acceptedOfferConnectionInclude,
        ...unreadOfferCountInclude,
      },
    }) as Promise<FullPrismaRequest>;
  }

  async syncMedia(requestId: string, mediaIds: string[], tx?: DbTx): Promise<void> {
    const db = this.db(tx);
    await db.requestMedia.deleteMany({
      where: { requestId },
    });
    if (mediaIds.length > 0) {
      await db.requestMedia.createMany({
        data: mediaIds.map((mediaId, index) => ({
          requestId,
          mediaId,
          displayOrder: index,
        })),
      });
    }
  }

  async listForCustomer(
    params: ListCustomerRequestsParams,
  ): Promise<{ items: FullPrismaRequest[]; nextCursor: string | null }> {
    const where: Prisma.RequestWhereInput = {
      customerProfileId: params.customerProfileId,
    };

    if (params.states && params.states.length > 0) {
      where.state = { in: params.states };
    } else {
      where.state = { in: ['DRAFT', 'PUBLISHED', 'OFFERS_RECEIVED', 'ACCEPTED'] };
    }

    if (params.requestType) {
      where.requestType = params.requestType;
    }

    if (params.direction) {
      where.direction = params.direction;
    }

    if (params.q) {
      where.OR = [
        { reference: { contains: params.q, mode: 'insensitive' } },
        { notes: { contains: params.q, mode: 'insensitive' } },
      ];
    }

    if (params.from || params.to) {
      where.createdAt = {};
      if (params.from) where.createdAt.gte = params.from;
      if (params.to) where.createdAt.lte = params.to;
    }

    const rows = (await this.prisma.request.findMany({
      where,
      take: params.limit + 1,
      cursor: params.cursor ? { id: params.cursor } : undefined,
      skip: params.cursor ? 1 : 0,
      orderBy: { createdAt: 'desc' },
      include: {
        category: true,
        region: true,
        media: {
          include: {
            media: true,
          },
          orderBy: { displayOrder: 'asc' },
        },
        ...acceptedOfferConnectionInclude,
        ...unreadOfferCountInclude,
      },
    })) as FullPrismaRequest[];

    let nextCursor: string | null = null;
    if (rows.length > params.limit) {
      const nextItem = rows.pop();
      nextCursor = nextItem?.id ?? null;
    }

    return { items: rows, nextCursor };
  }

  async findActiveMatch(
    requestId: string,
    vendorProfileId: string,
    tx?: DbTx,
  ): Promise<{ id: string; viewedAt: Date | null; isEligible: boolean } | null> {
    const db = this.db(tx);
    return db.requestMatch.findUnique({
      where: {
        requestId_vendorProfileId: {
          requestId,
          vendorProfileId,
        },
      },
      select: {
        id: true,
        viewedAt: true,
        isEligible: true,
      },
    });
  }

  async getLatestGoldRate(karat: Karat, tx?: DbTx) {
    const db = this.db(tx);
    return db.goldRate.findFirst({
      where: { purityKarat: karat },
      orderBy: { createdAt: 'desc' },
    });
  }

  async hasOauthBinding(userId: string, tx?: DbTx): Promise<boolean> {
    const db = this.db(tx);
    const count = await db.oauthBinding.count({
      where: { userId },
    });
    return count > 0;
  }
}
