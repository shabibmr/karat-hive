import { HttpStatus, Injectable } from '@nestjs/common';
import type {
  AbuseReportState,
  ExportFormat,
  Prisma,
  RequestState,
  UserAccountState,
  VendorVerificationState,
} from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { PrismaService } from '../../../platform/db/prisma.service';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { AuditWriter } from '../../audit';
import { ReviewService } from '../../reviews';
import { SettingsService } from '../../settings';
import { AdminRepository } from '../repository/admin.repository';

@Injectable()
export class AdminService {
  constructor(
    private readonly repo: AdminRepository,
    private readonly prisma: PrismaService,
    private readonly audit: AuditWriter,
    private readonly reviews: ReviewService,
    private readonly settings: SettingsService,
  ) {}

  async getDashboard() {
    return this.repo.getDashboardStats();
  }

  // --- Customers ---
  async listCustomers(query: {
    q?: string;
    state?: UserAccountState;
    limit?: number;
    cursor?: string;
  }) {
    return this.repo.listCustomers(query);
  }

  async getCustomer(id: string) {
    const cust = await this.repo.findCustomer(id);
    if (!cust) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    return cust;
  }

  async suspendCustomer(
    id: string,
    dto: { reasonCode: string; reasonText: string },
    adminUserId: string,
  ) {
    const cust = await this.repo.findCustomer(id);
    if (!cust) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const user = await this.repo.updateCustomerState(cust.userId, 'SUSPENDED');
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'CUSTOMER_SUSPENDED',
      entityType: 'customer_profile',
      entityId: cust.id,
      afterValue: { reasonCode: dto.reasonCode, reasonText: dto.reasonText },
    });
    return user;
  }

  async reactivateCustomer(
    id: string,
    dto: { reasonText: string },
    adminUserId: string,
  ) {
    const cust = await this.repo.findCustomer(id);
    if (!cust) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const user = await this.repo.updateCustomerState(cust.userId, 'ACTIVE');
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'CUSTOMER_REACTIVATED',
      entityType: 'customer_profile',
      entityId: cust.id,
      afterValue: { reasonText: dto.reasonText },
    });
    return user;
  }

  async erasureCustomer(id: string, adminUserId: string) {
    const cust = await this.repo.findCustomer(id);
    if (!cust) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const result = await this.repo.anonymizeCustomer(cust.userId);
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'CUSTOMER_ERASURE_COMPLETED',
      entityType: 'customer_profile',
      entityId: cust.id,
    });
    return { completed: true, userId: result.id };
  }

  // --- Vendors ---
  async listVendors(query: {
    q?: string;
    verificationState?: VendorVerificationState;
    accountState?: UserAccountState;
    regionId?: string;
    limit?: number;
    cursor?: string;
  }) {
    return this.repo.listVendors(query);
  }

  async getVendor(id: string) {
    const vendor = await this.repo.findVendor(id);
    if (!vendor) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    return vendor;
  }

  async getVerificationQueue() {
    return this.repo.listVerificationQueue();
  }

  async verifyVendor(
    id: string,
    dto: { rationale: string },
    adminUserId: string,
  ) {
    const vendor = await this.repo.findVendor(id);
    if (!vendor) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const hasTaxonomy =
      vendor.categories.length > 0 && vendor.regions.length > 0;
    const now = new Date();

    const updated = await this.repo.updateVendorVerification(id, {
      verificationState: 'VERIFIED',
      verifiedByAdminId: adminUserId,
      verifiedAt: now,
      ...(hasTaxonomy
        ? { activatedAt: now }
        : {}),
    });

    if (hasTaxonomy) {
      await this.repo.updateVendorAccountState(id, 'ACTIVE');
    }

    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'VENDOR_VERIFIED',
      entityType: 'vendor_profile',
      entityId: id,
      afterValue: { rationale: dto.rationale, accountState: hasTaxonomy ? 'ACTIVE' : 'REGISTERED' },
    });

    return updated;
  }

  async rejectVendor(
    id: string,
    dto: { rationale: string },
    adminUserId: string,
  ) {
    const vendor = await this.repo.findVendor(id);
    if (!vendor) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const updated = await this.repo.updateVendorVerification(id, {
      verificationState: 'REJECTED',
      verificationMessage: dto.rationale,
    });

    await this.repo.updateVendorAccountState(id, 'DEACTIVATED');

    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'VENDOR_VERIFICATION_REJECTED',
      entityType: 'vendor_profile',
      entityId: id,
      afterValue: { rationale: dto.rationale },
    });

    return updated;
  }

  async requestVendorInfo(
    id: string,
    dto: { message: string },
    adminUserId: string,
  ) {
    const vendor = await this.repo.findVendor(id);
    if (!vendor) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const updated = await this.repo.updateVendorVerification(id, {
      verificationState: 'PENDING_VERIFICATION',
      verificationMessage: dto.message,
    });

    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'VENDOR_INFO_REQUESTED',
      entityType: 'vendor_profile',
      entityId: id,
      afterValue: { message: dto.message },
    });

    return updated;
  }

  async setVendorState(
    id: string,
    accountState: UserAccountState,
    reason: { reasonCode?: string; reasonText?: string },
    adminUserId: string,
  ) {
    const vendor = await this.repo.findVendor(id);
    if (!vendor) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const updated = await this.repo.updateVendorAccountState(id, accountState);

    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: `VENDOR_STATE_${accountState}`,
      entityType: 'vendor_profile',
      entityId: id,
      afterValue: { accountState, ...reason },
    });

    return updated;
  }

  async getVendorDocumentUrl(
    vendorProfileId: string,
    docId: string,
    adminUserId: string,
  ) {
    const doc = await this.repo.findVendorDocument(vendorProfileId, docId);
    if (!doc || !doc.media) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // Audited call (NFR-015)
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'KYC_DOCUMENT_ACCESSED',
      entityType: 'vendor_document',
      entityId: doc.id,
    });

    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);
    return {
      url: `/v1/media/${doc.media.key}`,
      expiresAt: expiresAt.toISOString(),
    };
  }

  // --- Requests ---
  async listRequests(query: {
    q?: string;
    state?: RequestState;
    limit?: number;
    cursor?: string;
  }) {
    return this.repo.listRequests(query);
  }

  async getRequest(id: string) {
    const req = await this.repo.findRequest(id);
    if (!req) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    return req;
  }

  async removeRequest(
    id: string,
    dto: { reasonCode: string; reasonText: string; policyClause?: string },
    adminUserId: string,
  ) {
    const req = await this.repo.findRequest(id);
    if (!req) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const removed = await this.prisma.$transaction(async (tx) => {
      const res = await this.repo.removeRequest(
        tx,
        id,
        dto.reasonCode,
        dto.reasonText,
      );

      await this.audit.append(tx, {
        actorUserId: adminUserId,
        action: 'REQUEST_REMOVED_BY_ADMIN',
        entityType: 'request',
        entityId: id,
        afterValue: {
          reasonCode: dto.reasonCode,
          reasonText: dto.reasonText,
          policyClause: dto.policyClause,
        },
      });

      return res;
    });

    return removed;
  }

  // --- Offers ---
  async listOffers(query: {
    state?: string;
    vendorId?: string;
    limit?: number;
    cursor?: string;
  }) {
    return this.repo.listOffers(query);
  }

  async getOffer(id: string) {
    const offer = await this.repo.findOffer(id);
    if (!offer) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    return offer;
  }

  // --- Connections ---
  async listConnections(query: {
    state?: string;
    limit?: number;
    cursor?: string;
  }) {
    return this.repo.listConnections(query);
  }

  async getConnection(id: string) {
    const conn = await this.repo.findConnection(id);
    if (!conn) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    return conn;
  }

  async closeConnection(
    id: string,
    dto: { reasonText: string },
    adminUserId: string,
  ) {
    const conn = await this.repo.findConnection(id);
    if (!conn) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const closed = await this.prisma.$transaction(async (tx) => {
      const res = await this.repo.closeConnection(tx, id, dto.reasonText);
      await this.audit.append(tx, {
        actorUserId: adminUserId,
        action: 'CONNECTION_CLOSED_BY_ADMIN',
        entityType: 'connection',
        entityId: id,
        afterValue: { reasonText: dto.reasonText },
      });
      return res;
    });

    return closed;
  }

  // --- Review Moderation ---
  async approveReview(id: string, adminUserId: string) {
    return this.reviews.approveReviewByAdmin(id, adminUserId);
  }

  async rejectReview(
    id: string,
    dto: { rationale: string },
    adminUserId: string,
  ) {
    return this.reviews.rejectReviewByAdmin(id, dto.rationale, adminUserId);
  }

  async redactReview(
    id: string,
    dto: { rationale: string; redactedComment: string },
    adminUserId: string,
  ) {
    return this.reviews.redactReviewByAdmin(
      id,
      dto.rationale,
      dto.redactedComment,
      adminUserId,
    );
  }

  // --- Abuse Queue ---
  async listAbuseReports(query: {
    state?: AbuseReportState;
    limit?: number;
    cursor?: string;
  }) {
    return this.repo.listAbuseReports(query);
  }

  async getAbuseReport(id: string) {
    const rep = await this.repo.findAbuseReport(id);
    if (!rep) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    return rep;
  }

  async resolveAbuseReport(
    id: string,
    dto: { resolution: string },
    adminUserId: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const res = await this.repo.resolveAbuseReport(
        tx,
        id,
        'RESOLVED',
        dto.resolution,
        adminUserId,
      );
      await this.audit.append(tx, {
        actorUserId: adminUserId,
        action: 'ABUSE_REPORT_RESOLVED',
        entityType: 'abuse_report',
        entityId: id,
        afterValue: { resolution: dto.resolution },
      });
      return res;
    });
  }

  async dismissAbuseReport(
    id: string,
    dto: { resolution: string },
    adminUserId: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const res = await this.repo.resolveAbuseReport(
        tx,
        id,
        'DISMISSED',
        dto.resolution,
        adminUserId,
      );
      await this.audit.append(tx, {
        actorUserId: adminUserId,
        action: 'ABUSE_REPORT_DISMISSED',
        entityType: 'abuse_report',
        entityId: id,
        afterValue: { resolution: dto.resolution },
      });
      return res;
    });
  }

  // --- Platform Settings ---
  async getSettings() {
    return this.settings.getAllAdminSettings();
  }

  async updateSetting(key: string, value: unknown, adminUserId: string) {
    return this.settings.updateAdminSetting(key, value, adminUserId);
  }

  // --- Audit Log ---
  async listAuditLogs(query: { limit?: number; cursor?: string }) {
    return this.repo.listAuditLogs(query);
  }

  // --- Admin Notes ---
  async createAdminNote(
    collection: string,
    id: string,
    noteText: string,
    adminProfileId: string,
  ) {
    return this.repo.createAdminNote({
      entityType: collection,
      entityId: id,
      text: noteText,
      authorAdminId: adminProfileId,
    });
  }

  async listAdminNotes(collection: string, id: string) {
    return this.repo.listAdminNotes(collection, id);
  }

  // --- Admin User Provisioning ---
  async listAdmins() {
    return this.repo.listAdmins();
  }

  async createAdmin(dto: { email: string; displayName: string }, adminUserId: string) {
    const res = await this.repo.createAdmin(dto);
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'ADMIN_USER_CREATED',
      entityType: 'admin_profile',
      entityId: res.profile.id,
      afterValue: { email: dto.email, displayName: dto.displayName },
    });
    return res;
  }

  async suspendAdmin(id: string, adminUserId: string) {
    const admin = await this.repo.findAdmin(id);
    if (!admin) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const user = await this.repo.updateAdminAccountState(admin.userId, 'SUSPENDED');
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'ADMIN_USER_SUSPENDED',
      entityType: 'admin_profile',
      entityId: admin.id,
    });
    return user;
  }

  async revokeAdmin(id: string, adminUserId: string) {
    const admin = await this.repo.findAdmin(id);
    if (!admin) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const activeCount = await this.repo.countActiveAdmins();
    if (admin.user.accountState === 'ACTIVE' && activeCount <= 1) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT);
    }

    const user = await this.repo.updateAdminAccountState(admin.userId, 'DEACTIVATED');
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'ADMIN_USER_REVOKED',
      entityType: 'admin_profile',
      entityId: admin.id,
    });
    return user;
  }

  // --- Announcements ---
  async listAnnouncements(query: { limit?: number; cursor?: string }) {
    return this.repo.listAnnouncements(query);
  }

  async createAnnouncement(
    dto: {
      titleEn: string;
      titleAr: string;
      bodyEn: string;
      bodyAr: string;
      audience: Prisma.InputJsonValue;
      channels: Prisma.InputJsonValue;
      critical?: boolean;
      scheduledFor?: Date;
    },
    adminProfileId: string,
    adminUserId: string,
  ) {
    const created = await this.repo.createAnnouncement({
      ...dto,
      createdById: adminProfileId,
    });

    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'ANNOUNCEMENT_CREATED',
      entityType: 'announcement',
      entityId: created.id,
      afterValue: { titleEn: dto.titleEn, scheduledFor: dto.scheduledFor },
    });

    return created;
  }

  async cancelAnnouncement(id: string, adminUserId: string) {
    const ann = await this.repo.findAnnouncement(id);
    if (!ann) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    if (ann.cancelledAt || ann.dispatchStats) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT);
    }

    const cancelled = await this.repo.cancelAnnouncement(id);
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'ANNOUNCEMENT_CANCELLED',
      entityType: 'announcement',
      entityId: id,
    });

    return cancelled;
  }

  async sweepAnnouncementDispatch(): Promise<number> {
    const due = await this.repo.findDueAnnouncements();
    let processed = 0;

    for (const ann of due) {
      await this.prisma.$transaction(async (tx) => {
        const recipientCount = await tx.user.count({
          where: { accountState: 'ACTIVE' },
        });

        const stats = { sent: recipientCount, delivered: recipientCount, opened: 0 };
        await this.repo.recordAnnouncementDispatched(tx, ann.id, stats);

        await enqueueOutbox(tx, {
          eventType: 'announcement.scheduled',
          aggregateType: 'announcement',
          aggregateId: ann.id,
          payload: {
            announcementId: ann.id,
            titleEn: ann.titleEn,
            titleAr: ann.titleAr,
            sentCount: recipientCount,
          },
        });
      });
      processed += 1;
    }

    return processed;
  }

  // --- Reports & Exports ---
  async getReport(
    name: string,
    filters: { from?: string; to?: string; regionId?: string; categoryId?: string },
  ) {
    return this.repo.getReportData(name, filters);
  }

  async createExportJob(
    dto: {
      reportName: string;
      format: ExportFormat;
      filters: Prisma.InputJsonValue;
      purpose: string;
    },
    adminProfileId: string,
    adminUserId: string,
  ) {
    const watermark = {
      generatedByAdminId: adminUserId,
      generatedAt: new Date().toISOString(),
      purpose: dto.purpose,
    };

    const job = await this.repo.createExportJob({
      reportName: dto.reportName,
      format: dto.format,
      filters: dto.filters,
      purpose: dto.purpose,
      createdById: adminProfileId,
      watermark,
    });

    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'REPORT_EXPORT_REQUESTED',
      entityType: 'export_job',
      entityId: job.id,
      afterValue: { reportName: dto.reportName, purpose: dto.purpose },
    });

    return job;
  }

  async getExportJob(id: string, adminUserId: string) {
    const job = await this.repo.findExportJob(id);
    if (!job) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'EXPORT_DOWNLOADED',
      entityType: 'export_job',
      entityId: job.id,
    });

    return {
      id: job.id,
      status: job.state,
      downloadUrl: `/v1/admin/exports/${job.id}/download`,
      watermark: job.watermark,
      completedAt: job.completedAt,
    };
  }
}
