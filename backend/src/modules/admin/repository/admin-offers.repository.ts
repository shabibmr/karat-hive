import { HttpStatus, Injectable } from '@nestjs/common';
import {
  OfferState,
  Prisma,
  RequestType,
} from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { AuditWriter } from '../../audit';
import type {
  OfferDetailRow,
  OfferListRow,
} from '../presenter/admin-offers.presenter';
import type { StateTransitionView } from '../presenter/admin-requests.presenter';

export type AdminOfferListFilters = {
  state?: OfferState;
  vendorId?: string;
  requestType?: RequestType;
  priceMin?: number;
  priceMax?: number;
  cursor?: string;
  limit?: number;
  page?: number;
};

export type PaginationOptions = {
  cursor?: string;
  limit?: number;
  page?: number;
};

const DEFAULT_LIST_LIMIT = 20;
const MAX_LIST_LIMIT = 50;

@Injectable()
export class AdminOffersRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditWriter,
  ) {}

  async listOffers(
    filters: AdminOfferListFilters = {},
    cursorOrPagination?: string | PaginationOptions,
    limitArg?: number,
  ): Promise<{
    items: OfferListRow[];
    total: number;
    nextCursor: string | null;
    hasMore: boolean;
  }> {
    const pagination: PaginationOptions =
      typeof cursorOrPagination === 'string'
        ? { cursor: cursorOrPagination, limit: limitArg }
        : cursorOrPagination ?? {};

    const limit = Math.min(
      Math.max(pagination.limit ?? filters.limit ?? DEFAULT_LIST_LIMIT, 1),
      MAX_LIST_LIMIT,
    );
    const cursor = pagination.cursor ?? filters.cursor;
    const page = pagination.page ?? filters.page;

    const where: Prisma.OfferWhereInput = {};

    if (filters.state) {
      where.state = filters.state;
    }
    if (filters.vendorId) {
      where.vendorProfileId = filters.vendorId;
    }
    if (filters.requestType) {
      where.request = { requestType: filters.requestType };
    }
    if (filters.priceMin !== undefined || filters.priceMax !== undefined) {
      where.offeredPrice = {};
      if (filters.priceMin !== undefined) {
        where.offeredPrice.gte = new Prisma.Decimal(filters.priceMin);
      }
      if (filters.priceMax !== undefined) {
        where.offeredPrice.lte = new Prisma.Decimal(filters.priceMax);
      }
    }

    const orderBy: Prisma.OfferOrderByWithRelationInput[] = [
      { submittedAt: 'desc' },
      { id: 'desc' },
    ];

    const skip = page && page > 1 && !cursor ? (page - 1) * limit : undefined;

    const [total, rows] = await Promise.all([
      this.prisma.offer.count({ where }),
      this.prisma.offer.findMany({
        where,
        include: {
          vendorProfile: { include: { user: true } },
          request: {
            include: {
              customerProfile: { include: { user: true } },
              category: true,
              region: true,
            },
          },
        },
        orderBy,
        cursor: cursor ? { id: cursor } : undefined,
        skip: cursor ? 1 : skip,
        take: limit + 1,
      }),
    ]);

    const hasMore = rows.length > limit;
    const items = (hasMore ? rows.slice(0, limit) : rows) as OfferListRow[];
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1]!.id : null;

    return { items, total, nextCursor, hasMore };
  }

  async findOfferById(id: string): Promise<OfferDetailRow | null> {
    const [offer, notes, auditLogs] = await Promise.all([
      this.prisma.offer.findUnique({
        where: { id },
        include: {
          vendorProfile: { include: { user: true } },
          request: {
            include: {
              customerProfile: { include: { user: true } },
              category: true,
              region: true,
              acceptedOffer: true,
            },
          },
          revisions: {
            orderBy: { revisionNumber: 'desc' },
          },
          media: {
            include: { media: true },
            orderBy: { displayOrder: 'asc' },
          },
          connection: true,
        },
      }),
      this.prisma.adminNote.findMany({
        where: { entityType: 'offer', entityId: id },
        include: { author: { include: { user: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.auditLog.findMany({
        where: { entityType: 'offer', entityId: id },
        include: { actor: true },
        orderBy: { occurredAt: 'asc' },
      }),
    ]);

    if (!offer) {
      return null;
    }

    const auditTransitions: StateTransitionView[] = auditLogs.map((entry) => ({
      fromState: (entry.beforeValue as Record<string, unknown> | null)?.state as string | undefined,
      toState: ((entry.afterValue as Record<string, unknown> | null)?.state as string | undefined) ?? entry.action,
      transition: entry.action,
      timestamp: entry.occurredAt.toISOString(),
      actorUserId: entry.actorUserId,
      actorName: entry.actor?.email ?? null,
      reason: ((entry.afterValue as Record<string, unknown> | null)?.reasonText as string | undefined) ?? null,
    }));

    return {
      ...offer,
      notes,
      transitions: auditTransitions,
    } as OfferDetailRow;
  }

  async addOfferNote(offerId: string, adminId: string, content: string) {
    return withTx(this.prisma, async (tx) => {
      const offer = await tx.offer.findUnique({ where: { id: offerId } });
      if (!offer) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      const admin = await tx.adminProfile.findFirst({
        where: { OR: [{ id: adminId }, { userId: adminId }] },
      });
      if (!admin) {
        throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
      }

      const note = await tx.adminNote.create({
        data: {
          entityType: 'offer',
          entityId: offerId,
          authorAdminId: admin.id,
          text: content,
        },
        include: {
          author: { include: { user: true } },
        },
      });

      await this.audit.append(tx, {
        actorUserId: admin.userId,
        action: 'ADMIN_NOTE_ADDED',
        entityType: 'offer',
        entityId: offerId,
        afterValue: { noteId: note.id, text: content },
      });

      return note;
    });
  }
}
