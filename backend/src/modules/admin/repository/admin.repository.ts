import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type {
  AbuseReportState,
  ConnectionState,
  ExportFormat,
  OfferState,
  RequestState,
  UserAccountState,
  VendorVerificationState,
} from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';

@Injectable()
export class AdminRepository {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboardStats() {
    const [
      totalCustomers,
      totalVendors,
      pendingVerificationVendors,
      activeRequests,
      activeOffers,
      activeConnections,
    ] = await Promise.all([
      this.prisma.user.count({ where: { userType: 'CUSTOMER' } }),
      this.prisma.user.count({ where: { userType: 'VENDOR' } }),
      this.prisma.vendorProfile.count({
        where: { verificationState: 'PENDING_VERIFICATION' },
      }),
      this.prisma.request.count({
        where: { state: { in: ['PUBLISHED', 'OFFERS_RECEIVED'] } },
      }),
      this.prisma.offer.count({ where: { state: 'PENDING' } }),
      this.prisma.connection.count({ where: { state: 'ACTIVE' } }),
    ]);

    return {
      totalCustomers,
      totalVendors,
      pendingVerificationVendors,
      activeRequests,
      activeOffers,
      activeConnections,
    };
  }

  // --- Customers ---
  async listCustomers(options: {
    q?: string;
    state?: UserAccountState;
    limit?: number;
    cursor?: string;
  }) {
    const limit = Math.min(options.limit ?? 20, 100);
    const where: Prisma.CustomerProfileWhereInput = {
      ...(options.state ? { user: { accountState: options.state } } : {}),
      ...(options.q
        ? {
            OR: [
              { displayName: { contains: options.q, mode: 'insensitive' } },
              { user: { mobileNumber: { contains: options.q } } },
              { user: { email: { contains: options.q, mode: 'insensitive' } } },
            ],
          }
        : {}),
    };

    const items = await this.prisma.customerProfile.findMany({
      where,
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            id: true,
            mobileNumber: true,
            email: true,
            accountState: true,
            createdAt: true,
          },
        },
        _count: { select: { requests: true } },
      },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const nextItem = items.pop();
      nextCursor = nextItem?.id;
    }

    return { items, nextCursor };
  }

  async findCustomer(id: string) {
    return this.prisma.customerProfile.findFirst({
      where: { OR: [{ id }, { userId: id }] },
      include: {
        user: true,
        defaultRegion: true,
        requests: {
          take: 10,
          orderBy: { createdAt: 'desc' },
          include: { _count: { select: { offers: true } } },
        },
      },
    });
  }

  async updateCustomerState(userId: string, accountState: UserAccountState) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { accountState },
    });
  }

  async anonymizeCustomer(userId: string) {
    return this.prisma.$transaction(async (tx) => {
      await tx.customerProfile.updateMany({
        where: { userId },
        data: {
          displayName: 'Anonymized User',
          photoMediaId: null,
          defaultRegionId: null,
        },
      });

      return tx.user.update({
        where: { id: userId },
        data: {
          mobileNumber: `+9710000${Math.floor(1000000 + Math.random() * 9000000)}`,
          email: `anonymized-${userId.slice(0, 8)}@deleted.karathive.local`,
          accountState: 'DEACTIVATED',
        },
      });
    });
  }

  // --- Vendors ---
  async listVendors(options: {
    q?: string;
    verificationState?: VendorVerificationState;
    accountState?: UserAccountState;
    regionId?: string;
    limit?: number;
    cursor?: string;
  }) {
    const limit = Math.min(options.limit ?? 20, 100);
    const where: Prisma.VendorProfileWhereInput = {
      ...(options.verificationState ? { verificationState: options.verificationState } : {}),
      ...(options.accountState ? { user: { accountState: options.accountState } } : {}),
      ...(options.regionId
        ? { regions: { some: { regionId: options.regionId } } }
        : {}),
      ...(options.q
        ? {
            OR: [
              { tradingName: { contains: options.q, mode: 'insensitive' } },
              { legalBusinessName: { contains: options.q, mode: 'insensitive' } },
              { tradeLicenceNumber: { contains: options.q } },
            ],
          }
        : {}),
    };

    const items = await this.prisma.vendorProfile.findMany({
      where,
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            mobileNumber: true,
            email: true,
            accountState: true,
          },
        },
      },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const nextItem = items.pop();
      nextCursor = nextItem?.id;
    }

    return { items, nextCursor };
  }

  async findVendor(id: string) {
    return this.prisma.vendorProfile.findFirst({
      where: { OR: [{ id }, { userId: id }] },
      include: {
        user: true,
        documents: {
          include: {
            media: true,
          },
        },
        categories: { include: { category: true } },
        regions: { include: { region: true } },
        subscriptions: true,
      },
    });
  }

  async listVerificationQueue() {
    return this.prisma.vendorProfile.findMany({
      where: {
        verificationState: 'PENDING_VERIFICATION',
      },
      orderBy: { createdAt: 'asc' },
      include: {
        user: true,
        documents: {
          include: { media: true },
        },
      },
    });
  }

  async updateVendorVerification(
    id: string,
    data: {
      verificationState: VendorVerificationState;
      verificationMessage?: string | null;
      verifiedByAdminId?: string;
      verifiedAt?: Date | null;
      activatedAt?: Date | null;
    },
  ) {
    return this.prisma.vendorProfile.update({
      where: { id },
      data,
    });
  }

  async updateVendorAccountState(id: string, accountState: UserAccountState) {
    const vendor = await this.prisma.vendorProfile.findUnique({
      where: { id },
      select: { userId: true },
    });
    if (!vendor) return null;

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.update({
        where: { id: vendor.userId },
        data: { accountState },
      });
      if (accountState === 'ACTIVE') {
        await tx.vendorProfile.update({
          where: { id },
          data: { activatedAt: new Date() },
        });
      } else if (accountState === 'DEACTIVATED') {
        await tx.vendorProfile.update({
          where: { id },
          data: { activatedAt: null },
        });
      }
      return user;
    });
  }

  async findVendorDocument(vendorProfileId: string, docId: string) {
    return this.prisma.vendorDocument.findFirst({
      where: { id: docId, vendorProfileId },
      include: { media: true },
    });
  }

  // --- Requests ---
  async listRequests(options: {
    q?: string;
    state?: RequestState;
    limit?: number;
    cursor?: string;
  }) {
    const limit = Math.min(options.limit ?? 20, 100);
    const where: Prisma.RequestWhereInput = {
      ...(options.state ? { state: options.state } : {}),
      ...(options.q
        ? {
            OR: [
              { reference: { contains: options.q } },
              { notes: { contains: options.q, mode: 'insensitive' } },
            ],
          }
        : {}),
    };

    const items = await this.prisma.request.findMany({
      where,
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        customerProfile: {
          include: {
            user: {
              select: {
                mobileNumber: true,
                email: true,
              },
            },
          },
        },
        category: true,
        region: true,
      },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const nextItem = items.pop();
      nextCursor = nextItem?.id;
    }

    return { items, nextCursor };
  }

  async findRequest(id: string) {
    return this.prisma.request.findUnique({
      where: { id },
      include: {
        customerProfile: {
          include: { user: true },
        },
        category: true,
        region: true,
        media: { include: { media: true } },
        offers: {
          include: {
            vendorProfile: {
              include: { user: true },
            },
          },
        },
        connections: true,
      },
    });
  }

  async removeRequest(
    tx: Prisma.TransactionClient,
    id: string,
    reasonCode: string,
    reasonText: string,
  ) {
    // 1. Mark request REMOVED
    const req = await tx.request.update({
      where: { id },
      data: {
        state: 'REMOVED',
        cancellationReason: `[${reasonCode}] ${reasonText}`,
      },
    });

    // 2. Pending offers -> WITHDRAWN_BY_SYSTEM
    await tx.offer.updateMany({
      where: { requestId: id, state: 'PENDING' },
      data: { state: 'WITHDRAWN_BY_SYSTEM' },
    });

    return req;
  }

  // --- Offers ---
  async listOffers(options: {
    state?: string;
    vendorId?: string;
    limit?: number;
    cursor?: string;
  }) {
    const limit = Math.min(options.limit ?? 20, 100);
    const items = await this.prisma.offer.findMany({
      where: {
        ...(options.state ? { state: options.state as OfferState } : {}),
        ...(options.vendorId ? { vendorProfileId: options.vendorId } : {}),
      },
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        vendorProfile: true,
        request: true,
      },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const nextItem = items.pop();
      nextCursor = nextItem?.id;
    }

    return { items, nextCursor };
  }

  async findOffer(id: string) {
    return this.prisma.offer.findUnique({
      where: { id },
      include: {
        vendorProfile: { include: { user: true } },
        request: { include: { customerProfile: { include: { user: true } } } },
        revisions: true,
      },
    });
  }

  // --- Connections ---
  async listConnections(options: {
    state?: string;
    limit?: number;
    cursor?: string;
  }) {
    const limit = Math.min(options.limit ?? 20, 100);
    const items = await this.prisma.connection.findMany({
      where: {
        ...(options.state ? { state: options.state as ConnectionState } : {}),
      },
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        request: { include: { customerProfile: { include: { user: true } } } },
        offer: { include: { vendorProfile: { include: { user: true } } } },
        contactEvents: {
          orderBy: { occurredAt: 'desc' },
          take: 1,
          select: { occurredAt: true },
        },
        _count: { select: { contactEvents: true } },
      },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const nextItem = items.pop();
      nextCursor = nextItem?.id;
    }

    return { items, nextCursor };
  }

  async findConnection(id: string) {
    return this.prisma.connection.findUnique({
      where: { id },
      include: {
        request: { include: { customerProfile: { include: { user: true } } } },
        offer: { include: { vendorProfile: { include: { user: true } } } },
        contactEvents: true,
      },
    });
  }

  async closeConnection(
    tx: Prisma.TransactionClient,
    id: string,
    _reasonText: string,
  ) {
    return tx.connection.update({
      where: { id },
      data: {
        state: 'CLOSED',
        closedBy: 'ADMIN',
        closedAt: new Date(),
      },
    });
  }

  // --- Abuse Reports ---
  async listAbuseReports(options: {
    state?: AbuseReportState;
    limit?: number;
    cursor?: string;
  }) {
    const limit = Math.min(options.limit ?? 20, 100);
    const items = await this.prisma.abuseReport.findMany({
      where: {
        ...(options.state ? { state: options.state } : {}),
      },
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        reporter: {
          select: { id: true, email: true, mobileNumber: true },
        },
        reported: {
          select: { id: true, email: true, mobileNumber: true },
        },
      },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const nextItem = items.pop();
      nextCursor = nextItem?.id;
    }

    return { items, nextCursor };
  }

  async findAbuseReport(id: string) {
    return this.prisma.abuseReport.findUnique({
      where: { id },
      include: {
        reporter: true,
        reported: true,
      },
    });
  }

  async resolveAbuseReport(
    tx: Prisma.TransactionClient,
    id: string,
    state: AbuseReportState,
    resolution: string,
    adminId: string,
  ) {
    return tx.abuseReport.update({
      where: { id },
      data: {
        state,
        resolution,
        resolvedByAdminId: adminId,
      },
    });
  }

  // --- Audit Log ---
  async listAuditLogs(options: {
    limit?: number;
    cursor?: string;
    actorUserId?: string;
    action?: string;
    entityType?: string;
    entityId?: string;
    from?: string;
    to?: string;
    ip?: string;
  }) {
    const limit = Math.min(options.limit ?? 50, 100);
    const occurredAt =
      options.from || options.to
        ? {
            ...(options.from ? { gte: new Date(options.from) } : {}),
            ...(options.to ? { lte: new Date(options.to) } : {}),
          }
        : undefined;
    const items = await this.prisma.auditLog.findMany({
      where: {
        ...(options.actorUserId ? { actorUserId: options.actorUserId } : {}),
        ...(options.action
          ? { action: { contains: options.action, mode: 'insensitive' } }
          : {}),
        ...(options.entityType ? { entityType: options.entityType } : {}),
        ...(options.entityId ? { entityId: options.entityId } : {}),
        ...(options.ip
          ? { ipAddress: { contains: options.ip, mode: 'insensitive' } }
          : {}),
        ...(occurredAt ? { occurredAt } : {}),
      },
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { occurredAt: 'desc' },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const nextItem = items.pop();
      nextCursor = nextItem?.id;
    }

    return { items, nextCursor };
  }

  // --- Admin Notes ---
  async createAdminNote(data: {
    entityType: string;
    entityId: string;
    text: string;
    authorAdminId: string;
  }) {
    return this.prisma.adminNote.create({
      data,
    });
  }

  async listAdminNotes(entityType: string, entityId: string) {
    return this.prisma.adminNote.findMany({
      where: { entityType, entityId },
      orderBy: { createdAt: 'desc' },
      include: {
        author: {
          select: { displayName: true },
        },
      },
    });
  }

  // --- Admin Provisioning ---
  async listAdmins() {
    return this.prisma.adminProfile.findMany({
      include: {
        user: {
          select: {
            id: true,
            email: true,
            accountState: true,
            createdAt: true,
          },
        },
      },
    });
  }

  async createAdmin(data: {
    email: string;
    displayName: string;
  }) {
    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          userType: 'ADMIN',
          accountState: 'ACTIVE',
          email: data.email,
          mobileNumber: `+97150${Math.floor(1000000 + Math.random() * 9000000)}`,
        },
      });

      const profile = await tx.adminProfile.create({
        data: {
          userId: user.id,
          displayName: data.displayName,
        },
      });

      return { user, profile };
    });
  }

  async findAdmin(id: string) {
    return this.prisma.adminProfile.findFirst({
      where: { OR: [{ id }, { userId: id }] },
      include: { user: true },
    });
  }

  async countActiveAdmins(): Promise<number> {
    return this.prisma.user.count({
      where: { userType: 'ADMIN', accountState: 'ACTIVE' },
    });
  }

  async updateAdminAccountState(userId: string, accountState: UserAccountState) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { accountState },
    });
  }

  // --- Announcements ---
  async listAnnouncements(options: { limit?: number; cursor?: string }) {
    const limit = Math.min(options.limit ?? 20, 100);
    const items = await this.prisma.announcement.findMany({
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        createdBy: {
          select: { displayName: true },
        },
      },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const nextItem = items.pop();
      nextCursor = nextItem?.id;
    }

    return { items, nextCursor };
  }

  async findAnnouncement(id: string) {
    return this.prisma.announcement.findUnique({
      where: { id },
      include: {
        createdBy: {
          select: { displayName: true },
        },
      },
    });
  }

  async createAnnouncement(data: {
    titleEn: string;
    titleAr: string;
    bodyEn: string;
    bodyAr: string;
    audience: Prisma.InputJsonValue;
    channels: Prisma.InputJsonValue;
    critical?: boolean;
    scheduledFor?: Date;
    createdById: string;
  }) {
    return this.prisma.announcement.create({
      data: {
        titleEn: data.titleEn,
        titleAr: data.titleAr,
        bodyEn: data.bodyEn,
        bodyAr: data.bodyAr,
        audience: data.audience,
        channels: data.channels,
        critical: data.critical ?? false,
        scheduledFor: data.scheduledFor,
        createdById: data.createdById,
      },
    });
  }

  async cancelAnnouncement(id: string) {
    return this.prisma.announcement.update({
      where: { id },
      data: { cancelledAt: new Date() },
    });
  }

  async findDueAnnouncements() {
    const now = new Date();
    return this.prisma.announcement.findMany({
      where: {
        cancelledAt: null,
        dispatchStats: { equals: Prisma.AnyNull },
        OR: [{ scheduledFor: null }, { scheduledFor: { lte: now } }],
      },
      take: 10,
    });
  }

  async recordAnnouncementDispatched(
    tx: Prisma.TransactionClient,
    id: string,
    stats: { sent: number; delivered: number; opened: number },
  ) {
    return tx.announcement.update({
      where: { id },
      data: { dispatchStats: stats },
    });
  }

  // --- Reports & Exports ---
  async getReportData(
    name: string,
    filters: { from?: string; to?: string; regionId?: string; categoryId?: string },
  ) {
    const fromDate = filters.from ? new Date(filters.from) : new Date(Date.now() - 30 * 86400 * 1000);
    const toDate = filters.to ? new Date(filters.to) : new Date();

    if (name === 'rating-distribution') {
      const distribution = await this.prisma.review.groupBy({
        by: ['rating'],
        _count: { rating: true },
        where: {
          state: 'PUBLISHED',
          createdAt: { gte: fromDate, lte: toDate },
        },
      });
      return {
        name,
        generatedAt: new Date().toISOString(),
        rows: distribution.map((d) => ({ rating: d.rating, count: d._count.rating })),
        series: [],
      };
    }

    if (name === 'request-volume') {
      const countsByState = await this.prisma.request.groupBy({
        by: ['state'],
        _count: { state: true },
        where: { createdAt: { gte: fromDate, lte: toDate } },
      });
      return {
        name,
        generatedAt: new Date().toISOString(),
        rows: countsByState.map((c) => ({ state: c.state, count: c._count.state })),
        series: [],
      };
    }

    if (name === 'funnel') {
      const [requests, offers, connections, reviews] = await Promise.all([
        this.prisma.request.count({ where: { createdAt: { gte: fromDate, lte: toDate } } }),
        this.prisma.offer.count({ where: { createdAt: { gte: fromDate, lte: toDate } } }),
        this.prisma.connection.count({ where: { createdAt: { gte: fromDate, lte: toDate } } }),
        this.prisma.review.count({ where: { createdAt: { gte: fromDate, lte: toDate } } }),
      ]);
      return {
        name,
        generatedAt: new Date().toISOString(),
        rows: [
          { stage: 'requests', count: requests },
          { stage: 'offers', count: offers },
          { stage: 'connections', count: connections },
          { stage: 'reviews', count: reviews },
        ],
        series: [],
      };
    }

    // Default generic report structure
    return {
      name,
      generatedAt: new Date().toISOString(),
      rows: [],
      series: [],
    };
  }

  async createExportJob(data: {
    reportName: string;
    format: ExportFormat;
    filters: Prisma.InputJsonValue;
    purpose: string;
    createdById: string;
    watermark?: Prisma.InputJsonValue;
  }) {
    return this.prisma.exportJob.create({
      data: {
        reportName: data.reportName,
        format: data.format,
        filters: data.filters,
        purpose: data.purpose,
        state: 'READY',
        watermark: data.watermark,
        createdById: data.createdById,
        completedAt: new Date(),
      },
    });
  }

  async findExportJob(id: string) {
    return this.prisma.exportJob.findUnique({
      where: { id },
      include: {
        createdBy: { select: { displayName: true } },
      },
    });
  }
}
