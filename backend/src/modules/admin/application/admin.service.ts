import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import type {
  AbuseReportState,
  ExportFormat,
  Prisma,
  RequestState,
  UserAccountState,
  VendorVerificationState,
} from '@prisma/client';
import { ENV, type Env } from '../../../config/env';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { PrismaService } from '../../../platform/db/prisma.service';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { OBJECT_STORAGE, type ObjectStorage } from '../../../platform/ports/storage.port';
import { AuditWriter } from '../../audit';
import { storagePath } from '../../media/domain/media-rules';
import { ReviewService } from '../../reviews';
import { SettingsService } from '../../settings';
import { AdminRepository } from '../repository/admin.repository';

const SIGNED_DOCUMENT_URL_TTL_SECONDS = 15 * 60;

@Injectable()
export class AdminService {
  constructor(
    private readonly repo: AdminRepository,
    private readonly prisma: PrismaService,
    private readonly audit: AuditWriter,
    private readonly reviews: ReviewService,
    private readonly settings: SettingsService,
    @Inject(OBJECT_STORAGE) private readonly storage: ObjectStorage,
    @Inject(ENV) private readonly env: Env,
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

  async erasureCustomer(
    id: string,
    dto: { reasonText: string },
    adminUserId: string,
  ) {
    const cust = await this.repo.findCustomer(id);
    if (!cust) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    const result = await this.repo.anonymizeCustomer(cust.userId);
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'CUSTOMER_ERASURE_COMPLETED',
      entityType: 'customer_profile',
      entityId: cust.id,
      afterValue: { reasonText: dto.reasonText },
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
    if (doc.media.state === 'QUARANTINED') {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.MEDIA_QUARANTINED);
    }
    if (doc.media.state === 'PENDING_UPLOAD' || doc.media.state === 'FAILED') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.UPLOAD_NOT_COMPLETED);
    }

    const objectKey = storagePath({
      purpose: 'KYC_DOCUMENT',
      key: doc.media.key,
      vendorProfileId: doc.vendorProfileId,
      ownerUserId: doc.media.uploadedByUserId ?? vendorProfileId,
    });
    const signed = await this.storage.createSignedDownloadUrl(
      this.env.SUPABASE_STORAGE_BUCKET_KYC,
      objectKey,
      SIGNED_DOCUMENT_URL_TTL_SECONDS,
    );

    // Audited call (NFR-015)
    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'KYC_DOCUMENT_ACCESSED',
      entityType: 'vendor_document',
      entityId: doc.id,
    });

    return {
      url: signed.url,
      expiresAt: signed.expiresAt.toISOString(),
    };
  }

  // --- Requests ---
  async listRequests(query: {
    q?: string;
    state?: RequestState;
    requestType?: string;
    direction?: string;
    categoryId?: string;
    regionId?: string;
    zeroOffers?: boolean;
    minValue?: number;
    maxValue?: number;
    valueMin?: number;
    valueMax?: number;
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
    requestType?: string;
    minPrice?: number;
    maxPrice?: number;
    priceMin?: number;
    priceMax?: number;
    dateFrom?: string;
    dateTo?: string;
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
      const request = (conn as { request?: { customerProfile?: { userId?: string } } })
        .request;
      const offer = (conn as { offer?: { vendorProfile?: { userId?: string } } }).offer;
      await enqueueOutbox(tx, {
        eventType: 'connection.closed',
        aggregateType: 'connection',
        aggregateId: id,
        payload: {
          connectionId: id,
          requestId: conn.requestId,
          customerUserId: request?.customerProfile?.userId,
          vendorUserId: offer?.vendorProfile?.userId,
          closedBy: 'ADMIN',
          closedAt: res.closedAt?.toISOString() ?? new Date().toISOString(),
          reasonText: dto.reasonText,
        },
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

  /// FR-ADM-032 AC3 — the four resolutions the Admin can take against the
  /// reported party from an abuse report: dismiss, warn, suspend, or deactivate.
  /// DISMISS closes the report with no sanction; WARN records a caution without a
  /// state change; SUSPEND / DEACTIVATE move the reported user's account. All four
  /// close the report and write a party-facing audit entry (AC5) in one
  /// transaction.
  async actionAbuseReport(
    id: string,
    dto: {
      action: 'DISMISS' | 'WARN' | 'SUSPEND' | 'DEACTIVATE';
      rationale: string;
    },
    adminUserId: string,
  ) {
    const report = await this.repo.findAbuseReport(id);
    if (!report) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    return this.prisma.$transaction(async (tx) => {
      if (dto.action === 'SUSPEND' || dto.action === 'DEACTIVATE') {
        await this.repo.updateUserAccountState(
          tx,
          report.reportedUserId,
          dto.action === 'SUSPEND' ? 'SUSPENDED' : 'DEACTIVATED',
        );
      }

      const res = await this.repo.resolveAbuseReport(
        tx,
        id,
        dto.action === 'DISMISS' ? 'DISMISSED' : 'RESOLVED',
        dto.rationale,
        adminUserId,
      );

      const auditAction = {
        DISMISS: 'ABUSE_REPORT_DISMISSED',
        WARN: 'ABUSE_PARTY_WARNED',
        SUSPEND: 'ABUSE_PARTY_SUSPENDED',
        DEACTIVATE: 'ABUSE_PARTY_DEACTIVATED',
      }[dto.action];
      await this.audit.append(tx, {
        actorUserId: adminUserId,
        action: auditAction,
        entityType: 'abuse_report',
        entityId: id,
        afterValue: {
          action: dto.action,
          rationale: dto.rationale,
          reportedUserId: report.reportedUserId,
        },
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
  async listAuditLogs(query: {
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

  async getExportJob(id: string, _adminUserId?: string) {
    const job = await this.repo.findExportJob(id);
    if (!job) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    return {
      id: job.id,
      status: job.state,
      downloadUrl: `/v1/admin/exports/${job.id}/download`,
      watermark: job.watermark,
      completedAt: job.completedAt,
    };
  }

  /**
   * ADM-C-76: CSV is generated from stored filters + report rows.
   * XLSX is the same CSV bytes with `text/csv` (no spreadsheet library).
   * PNG chart export is 501 until implemented.
   */
  async downloadExport(id: string, adminUserId: string) {
    const job = await this.repo.findExportJob(id);
    if (!job) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);

    if (job.state === 'QUEUED' || job.state === 'RUNNING') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.EXPORT_IN_PROGRESS);
    }
    if (job.state !== 'READY') {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    if (job.format === 'PNG') {
      throw new ApiException(HttpStatus.NOT_IMPLEMENTED, ErrorCode.VALIDATION_FAILED, [
        {
          path: 'format',
          code: 'PNG_EXPORT_UNSUPPORTED',
          message: 'PNG chart export is not implemented.',
        },
      ]);
    }

    const filters = asReportFilters(job.filters);
    const report = await this.repo.getReportData(job.reportName, filters);
    const csv = rowsToCsv(report.rows);
    const body = Buffer.from(csv, 'utf8');

    await this.audit.append(this.prisma, {
      actorUserId: adminUserId,
      action: 'EXPORT_DOWNLOADED',
      entityType: 'export_job',
      entityId: job.id,
    });

    return {
      body,
      contentType: 'text/csv; charset=utf-8',
      filename: `${job.reportName}-${job.id}.csv`,
    };
  }
}

type ReportFilters = { from?: string; to?: string; regionId?: string; categoryId?: string };

function asReportFilters(value: unknown): ReportFilters {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return {};
  const rec = value as Record<string, unknown>;
  return {
    ...(typeof rec.from === 'string' ? { from: rec.from } : {}),
    ...(typeof rec.to === 'string' ? { to: rec.to } : {}),
    ...(typeof rec.regionId === 'string' ? { regionId: rec.regionId } : {}),
    ...(typeof rec.categoryId === 'string' ? { categoryId: rec.categoryId } : {}),
  };
}

function rowsToCsv(rows: Array<Record<string, unknown>>): string {
  if (rows.length === 0) return '';
  const headers = Object.keys(rows[0]!);
  const escape = (value: unknown): string => {
    const text = value == null ? '' : String(value);
    if (/[",\n\r]/.test(text)) return `"${text.replace(/"/g, '""')}"`;
    return text;
  };
  const lines = [headers.join(',')];
  for (const row of rows) {
    lines.push(headers.map((header) => escape(row[header])).join(','));
  }
  return `${lines.join('\n')}\n`;
}
