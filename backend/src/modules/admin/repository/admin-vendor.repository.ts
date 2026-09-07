import { HttpStatus, Injectable } from '@nestjs/common';
import type { Prisma, UserAccountState, VendorVerificationState } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { AuditWriter } from '../../audit';
import { waitingHoursSince } from '../presenter/admin-vendor.presenter';

export type AdminVendorListFilters = {
  verificationState?: VendorVerificationState;
  accountState?: UserAccountState;
  regionId?: string;
  categoryId?: string;
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
export class AdminVendorRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditWriter,
  ) {}

  async findVerificationQueue() {
    const now = new Date();
    const rows = await this.prisma.vendorProfile.findMany({
      where: { verificationState: 'PENDING_VERIFICATION' },
      include: {
        user: true,
        categories: { include: { category: true } },
        regions: { include: { region: true } },
        documents: { include: { media: true } },
      },
      orderBy: { createdAt: 'asc' },
    });

    return rows.map((row) => ({
      ...row,
      oldestWaitingHours: waitingHoursSince(row.createdAt, now),
    }));
  }

  listVerificationQueue() {
    return this.findVerificationQueue();
  }

  async listVendors(
    filters: AdminVendorListFilters = {},
    pagination?: PaginationOptions,
  ) {
    const limit = Math.min(
      Math.max(pagination?.limit ?? filters.limit ?? DEFAULT_LIST_LIMIT, 1),
      MAX_LIST_LIMIT,
    );
    const cursor = pagination?.cursor ?? filters.cursor;
    const page = pagination?.page ?? filters.page;

    const where: Prisma.VendorProfileWhereInput = {};

    if (filters.verificationState) {
      where.verificationState = filters.verificationState;
    }
    if (filters.accountState) {
      where.user = { accountState: filters.accountState };
    }
    if (filters.regionId) {
      where.regions = { some: { regionId: filters.regionId } };
    }
    if (filters.categoryId) {
      where.categories = { some: { categoryId: filters.categoryId } };
    }
    if (filters.q) {
      const q = filters.q.trim();
      if (q.length > 0) {
        where.OR = [
          { legalBusinessName: { contains: q, mode: 'insensitive' } },
          { tradingName: { contains: q, mode: 'insensitive' } },
          { tradeLicenceNumber: { contains: q, mode: 'insensitive' } },
          { user: { mobileNumber: { contains: q } } },
        ];
      }
    }

    const isPendingVerification = filters.verificationState === 'PENDING_VERIFICATION';

    const orderBy: Prisma.VendorProfileOrderByWithRelationInput[] = isPendingVerification
      ? [{ createdAt: 'asc' }, { id: 'asc' }]
      : [{ createdAt: 'desc' }, { id: 'desc' }];

    if (cursor) {
      where.id = isPendingVerification ? { gt: cursor } : { lt: cursor };
    }

    const skip = page && page > 1 && !cursor ? (page - 1) * limit : undefined;

    const [total, rows] = await Promise.all([
      this.prisma.vendorProfile.count({ where }),
      this.prisma.vendorProfile.findMany({
        where,
        include: {
          user: true,
          categories: { include: { category: true } },
          regions: { include: { region: true } },
        },
        orderBy,
        skip,
        take: limit + 1,
      }),
    ]);

    const hasMore = rows.length > limit;
    const items = hasMore ? rows.slice(0, limit) : rows;
    const nextCursor = hasMore && items.length > 0 ? items[items.length - 1]!.id : null;

    return { items, total, nextCursor, hasMore };
  }

  async findVendorById(id: string) {
    const profile = await this.prisma.vendorProfile.findUnique({
      where: { id },
      include: {
        user: true,
        logoMedia: true,
        documents: {
          include: { media: true },
          orderBy: { uploadedAt: 'desc' },
        },
        categories: { include: { category: true } },
        regions: { include: { region: true } },
        verifiedByAdmin: { include: { user: true } },
        subscriptions: true,
        offers: {
          take: 20,
          orderBy: { submittedAt: 'desc' },
        },
        connections: {
          take: 20,
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!profile) return null;

    const notes = await this.prisma.adminNote.findMany({
      where: {
        entityType: { in: ['vendor_profile', 'VENDOR'] },
        entityId: id,
      },
      include: {
        author: { include: { user: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      ...profile,
      notes,
    };
  }

  findVendorDetail(id: string) {
    return this.findVendorById(id);
  }

  async updateVerificationState(
    id: string,
    state: VendorVerificationState,
    adminId: string,
    rationale?: string,
    message?: string,
  ) {
    return withTx(this.prisma, async (tx) => {
      const profile = await tx.vendorProfile.findUnique({
        where: { id },
        include: { user: true },
      });
      if (!profile) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      const admin = await tx.adminProfile.findFirst({
        where: { OR: [{ id: adminId }, { userId: adminId }] },
      });
      const adminProfileId = admin?.id ?? null;
      const actorUserId = admin?.userId ?? adminId;

      const now = new Date();
      let activate = false;
      if (state === 'VERIFIED') {
        const [categoryCount, regionCount] = await Promise.all([
          tx.vendorCategory.count({ where: { vendorProfileId: id } }),
          tx.vendorRegion.count({ where: { vendorProfileId: id } }),
        ]);
        activate = categoryCount > 0 && regionCount > 0;
      }

      const updateData: Prisma.VendorProfileUpdateInput = {
        verificationState: state,
      };

      if (state === 'VERIFIED') {
        updateData.verifiedAt = now;
        if (adminProfileId) {
          updateData.verifiedByAdmin = { connect: { id: adminProfileId } };
        }
        updateData.verificationNotes = rationale ?? profile.verificationNotes;
        updateData.verificationMessage = null;
        if (activate) {
          updateData.activatedAt = now;
        }
      } else if (state === 'REJECTED') {
        updateData.verificationNotes = rationale ?? null;
        updateData.verificationMessage = message ?? rationale ?? null;
      } else {
        if (message !== undefined) {
          updateData.verificationMessage = message;
        }
      }

      const updated = await tx.vendorProfile.update({
        where: { id },
        data: updateData,
        include: { user: true },
      });

      const action =
        state === 'VERIFIED'
          ? 'VENDOR_VERIFIED'
          : state === 'REJECTED'
            ? 'VENDOR_REJECTED'
            : message
              ? 'VENDOR_INFO_REQUESTED'
              : 'VENDOR_VERIFICATION_UPDATED';

      await this.audit.append(tx, {
        actorUserId,
        action,
        entityType: 'vendor_profile',
        entityId: id,
        beforeValue: { verificationState: profile.verificationState },
        afterValue: {
          verificationState: state,
          ...(state === 'VERIFIED' ? { activated: activate } : {}),
          ...(rationale ? { rationale } : {}),
          ...(message ? { message } : {}),
        },
      });

      await enqueueOutbox(tx, {
        eventType: 'vendor.verification.decided',
        aggregateType: 'vendor_profile',
        aggregateId: id,
        payload: {
          vendorProfileId: id,
          vendorUserId: profile.userId,
          decision: state,
          rationale,
          message,
        },
      });

      if (state === 'VERIFIED' && activate) {
        await enqueueOutbox(tx, {
          eventType: 'vendor.eligibility.changed',
          aggregateType: 'vendor_profile',
          aggregateId: id,
          payload: {
            vendorProfileId: id,
            vendorUserId: profile.userId,
            reason: 'VERIFIED_WITH_TAXONOMY',
          },
        });
        await this.audit.append(tx, {
          actorUserId,
          action: 'VENDOR_ACTIVATED',
          entityType: 'vendor_profile',
          entityId: id,
          afterValue: { activatedAt: now.toISOString() },
        });
      }

      return updated;
    });
  }

  async updateAccountState(
    id: string,
    state: UserAccountState,
    adminId: string,
    reasonCode?: string,
    reasonText?: string,
  ) {
    return withTx(this.prisma, async (tx) => {
      const profile = await tx.vendorProfile.findUnique({
        where: { id },
        include: { user: true },
      });
      if (!profile) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      const admin = await tx.adminProfile.findFirst({
        where: { OR: [{ id: adminId }, { userId: adminId }] },
      });
      const actorUserId = admin?.userId ?? adminId;

      const beforeState = profile.user.accountState;

      await tx.user.update({
        where: { id: profile.userId },
        data: { accountState: state },
      });

      if (state === 'SUSPENDED') {
        const pendingOffers = await tx.offer.findMany({
          where: { vendorProfileId: id, state: 'PENDING' },
          select: { id: true, requestId: true },
        });

        if (pendingOffers.length > 0) {
          await tx.offer.updateMany({
            where: { vendorProfileId: id, state: 'PENDING' },
            data: { state: 'WITHDRAWN_BY_SYSTEM' },
          });

          for (const offer of pendingOffers) {
            await enqueueOutbox(tx, {
              eventType: 'offer.withdrawn',
              aggregateType: 'offer',
              aggregateId: offer.id,
              payload: {
                offerId: offer.id,
                requestId: offer.requestId,
                vendorProfileId: id,
                reason: 'VENDOR_SUSPENDED',
              },
            });
          }
        }
      }

      const now = new Date();
      if (state === 'ACTIVE' && profile.verificationState === 'VERIFIED' && !profile.activatedAt) {
        const [catCount, regCount] = await Promise.all([
          tx.vendorCategory.count({ where: { vendorProfileId: id } }),
          tx.vendorRegion.count({ where: { vendorProfileId: id } }),
        ]);
        if (catCount > 0 && regCount > 0) {
          await tx.vendorProfile.update({
            where: { id },
            data: { activatedAt: now },
          });
        }
      }

      await enqueueOutbox(tx, {
        eventType: 'vendor.eligibility.changed',
        aggregateType: 'vendor_profile',
        aggregateId: id,
        payload: {
          vendorProfileId: id,
          vendorUserId: profile.userId,
          reason: `ACCOUNT_STATE_${state}`,
          accountState: state,
        },
      });

      const action =
        state === 'ACTIVE'
          ? 'VENDOR_ACTIVATED'
          : state === 'SUSPENDED'
            ? 'VENDOR_SUSPENDED'
            : 'VENDOR_DEACTIVATED';

      await this.audit.append(tx, {
        actorUserId,
        action,
        entityType: 'vendor_profile',
        entityId: id,
        beforeValue: { accountState: beforeState },
        afterValue: {
          accountState: state,
          reasonCode: reasonCode ?? null,
          reasonText: reasonText ?? null,
        },
      });

      return {
        vendorProfileId: id,
        accountState: state,
      };
    });
  }

  async addNote(id: string, adminId: string, text: string) {
    return withTx(this.prisma, async (tx) => {
      const profile = await tx.vendorProfile.findUnique({ where: { id } });
      if (!profile) {
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
          entityType: 'vendor_profile',
          entityId: id,
          authorAdminId: admin.id,
          text,
        },
        include: {
          author: { include: { user: true } },
        },
      });

      await this.audit.append(tx, {
        actorUserId: admin.userId,
        action: 'ADMIN_NOTE_ADDED',
        entityType: 'vendor_profile',
        entityId: id,
        afterValue: { noteId: note.id, text },
      });

      return note;
    });
  }

  findVendorDocument(vendorProfileId: string, documentId: string) {
    return this.prisma.vendorDocument.findFirst({
      where: { id: documentId, vendorProfileId },
      include: {
        media: true,
        vendorProfile: { include: { user: true } },
      },
    });
  }
}
