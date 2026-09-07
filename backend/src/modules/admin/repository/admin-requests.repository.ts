import { HttpStatus, Injectable } from '@nestjs/common';
import {
  DeclineReason,
  Direction,
  OfferState,
  Prisma,
  RequestState,
  RequestType,
} from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { AuditWriter } from '../../audit';
import type {
  RequestDetailRow,
  RequestListRow,
  StateTransitionView,
} from '../presenter/admin-requests.presenter';

export type AdminRequestListFilters = {
  requestType?: RequestType;
  direction?: Direction;
  state?: RequestState;
  categoryId?: string;
  regionId?: string;
  valueMin?: number;
  valueMax?: number;
  zeroOffers?: boolean;
  q?: string;
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
export class AdminRequestsRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditWriter,
  ) {}

  async listRequests(
    filters: AdminRequestListFilters = {},
    cursorOrPagination?: string | PaginationOptions,
    limitArg?: number,
  ): Promise<{
    items: RequestListRow[];
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

    const where: Prisma.RequestWhereInput = {};

    if (filters.requestType) {
      where.requestType = filters.requestType;
    }
    if (filters.direction) {
      where.direction = filters.direction;
    }
    if (filters.state) {
      where.state = filters.state;
    }
    if (filters.categoryId) {
      where.categoryId = filters.categoryId;
    }
    if (filters.regionId) {
      where.regionId = filters.regionId;
    }
    if (filters.valueMin !== undefined || filters.valueMax !== undefined) {
      where.indicativeValue = {};
      if (filters.valueMin !== undefined) {
        where.indicativeValue.gte = new Prisma.Decimal(filters.valueMin);
      }
      if (filters.valueMax !== undefined) {
        where.indicativeValue.lte = new Prisma.Decimal(filters.valueMax);
      }
    }
    if (filters.zeroOffers === true) {
      where.offerCount = 0;
    }
    if (filters.q) {
      const q = filters.q.trim();
      if (q.length > 0) {
        where.OR = [
          { reference: { contains: q, mode: 'insensitive' } },
          { notes: { contains: q, mode: 'insensitive' } },
        ];
      }
    }

    const orderBy: Prisma.RequestOrderByWithRelationInput[] = [
      { createdAt: 'desc' },
      { id: 'desc' },
    ];

    const skip = page && page > 1 && !cursor ? (page - 1) * limit : undefined;

    const [total, rows] = await Promise.all([
      this.prisma.request.count({ where }),
      this.prisma.request.findMany({
        where,
        include: {
          customerProfile: { include: { user: true } },
          category: true,
          region: true,
        },
        orderBy,
        cursor: cursor ? { id: cursor } : undefined,
        skip: cursor ? 1 : skip,
        take: limit + 1,
      }),
    ]);

    const hasMore = rows.length > limit;
    const items = (hasMore ? rows.slice(0, limit) : rows) as RequestListRow[];
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1]!.id : null;

    return { items, total, nextCursor, hasMore };
  }

  async findRequestById(id: string): Promise<RequestDetailRow | null> {
    const [request, notes, auditLogs] = await Promise.all([
      this.prisma.request.findUnique({
        where: { id },
        include: {
          customerProfile: { include: { user: true } },
          category: true,
          region: true,
          media: {
            include: { media: true },
            orderBy: { displayOrder: 'asc' },
          },
          matches: {
            include: {
              vendorProfile: {
                include: { user: true },
              },
            },
            orderBy: { matchedAt: 'desc' },
          },
          offers: {
            include: {
              vendorProfile: {
                include: { user: true },
              },
              revisions: {
                orderBy: { revisionNumber: 'desc' },
              },
            },
            orderBy: { submittedAt: 'desc' },
          },
          connections: {
            include: {
              vendorProfile: {
                include: { user: true },
              },
              customerProfile: {
                include: { user: true },
              },
            },
          },
          acceptedOffer: {
            include: {
              vendorProfile: {
                include: { user: true },
              },
            },
          },
        },
      }),
      this.prisma.adminNote.findMany({
        where: { entityType: 'request', entityId: id },
        include: { author: { include: { user: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.auditLog.findMany({
        where: { entityType: 'request', entityId: id },
        include: { actor: true },
        orderBy: { occurredAt: 'asc' },
      }),
    ]);

    if (!request) {
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
      ...request,
      notes,
      transitions: auditTransitions,
    } as RequestDetailRow;
  }

  async removeRequest(
    id: string,
    adminId: string,
    reasonCode?: string,
    reasonText?: string,
    policyClause?: string,
    ipAddress?: string,
  ): Promise<RequestDetailRow> {
    return withTx(this.prisma, async (tx) => {
      const existing = await tx.request.findUnique({
        where: { id },
        include: {
          customerProfile: { include: { user: true } },
          category: true,
          region: true,
        },
      });

      if (!existing) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      if (existing.state === RequestState.REMOVED) {
        throw new ApiException(
          HttpStatus.CONFLICT,
          ErrorCode.CONFLICT,
          [{ path: 'state', code: 'ALREADY_REMOVED', message: 'Request is already removed' }],
        );
      }

      // Update request state to REMOVED (FR-ADM-019)
      const updated = await tx.request.update({
        where: { id },
        data: {
          state: RequestState.REMOVED,
          cancellationReason: reasonText,
        },
        include: {
          customerProfile: { include: { user: true } },
          category: true,
          region: true,
        },
      });

      // Update pending offers on that request to WITHDRAWN_BY_SYSTEM
      await tx.offer.updateMany({
        where: {
          requestId: id,
          state: OfferState.PENDING,
        },
        data: {
          state: OfferState.WITHDRAWN_BY_SYSTEM,
          declineReason: DeclineReason.OTHER,
        },
      });

      const admin = await tx.adminProfile.findFirst({
        where: { OR: [{ id: adminId }, { userId: adminId }] },
      });

      const actorUserId = admin?.userId ?? adminId;

      await this.audit.append(tx, {
        actorUserId,
        action: 'REQUEST_REMOVED',
        entityType: 'request',
        entityId: id,
        beforeValue: { state: existing.state },
        afterValue: {
          state: RequestState.REMOVED,
          reasonCode: reasonCode ?? null,
          reasonText: reasonText ?? null,
          policyClause: policyClause ?? null,
        },
        ipAddress: ipAddress ?? null,
      });

      return updated as RequestDetailRow;
    });
  }

  async addRequestNote(requestId: string, adminId: string, content: string) {
    return withTx(this.prisma, async (tx) => {
      const request = await tx.request.findUnique({ where: { id: requestId } });
      if (!request) {
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
          entityType: 'request',
          entityId: requestId,
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
        entityType: 'request',
        entityId: requestId,
        afterValue: { noteId: note.id, text: content },
      });

      return note;
    });
  }
}
