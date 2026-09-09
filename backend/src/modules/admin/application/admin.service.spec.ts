import { describe, expect, it, vi } from 'vitest';
import type {
  AbuseReport,
  AdminProfile,
  Announcement,
  Connection,
  CustomerProfile,
  ExportJob,
  Request,
  Review,
  User,
  VendorDocument,
  VendorProfile,
} from '@prisma/client';
import type { Env } from '../../../config/env';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { ObjectStorage } from '../../../platform/ports/storage.port';
import type { AuditWriter } from '../../audit';
import type { ReviewService } from '../../reviews';
import type { SettingsService } from '../../settings';
import { AdminService } from './admin.service';
import { AdminRepository } from '../repository/admin.repository';

describe('AdminService', () => {
  const mockRepo = {
    getDashboardStats: vi.fn(),
    listCustomers: vi.fn(),
    findCustomer: vi.fn(),
    updateCustomerState: vi.fn(),
    anonymizeCustomer: vi.fn(),
    listVendors: vi.fn(),
    findVendor: vi.fn(),
    updateVendorVerification: vi.fn(),
    updateVendorAccountState: vi.fn(),
    findVendorDocument: vi.fn(),
    listRequests: vi.fn(),
    findRequest: vi.fn(),
    removeRequest: vi.fn(),
    listOffers: vi.fn(),
    findOffer: vi.fn(),
    listConnections: vi.fn(),
    findConnection: vi.fn(),
    closeConnection: vi.fn(),
    listAbuseReports: vi.fn(),
    findAbuseReport: vi.fn(),
    resolveAbuseReport: vi.fn(),
    updateUserAccountState: vi.fn(),
    listAuditLogs: vi.fn(),
    createAdminNote: vi.fn(),
    listAdminNotes: vi.fn(),
    listAdmins: vi.fn(),
    createAdmin: vi.fn(),
    findAdmin: vi.fn(),
    countActiveAdmins: vi.fn(),
    updateAdminAccountState: vi.fn(),
    listAnnouncements: vi.fn(),
    findAnnouncement: vi.fn(),
    createAnnouncement: vi.fn(),
    cancelAnnouncement: vi.fn(),
    findDueAnnouncements: vi.fn(),
    recordAnnouncementDispatched: vi.fn(),
    getReportData: vi.fn(),
    createExportJob: vi.fn(),
    findExportJob: vi.fn(),
  } as unknown as AdminRepository;

  const mockPrisma = {
    $transaction: vi.fn().mockImplementation((cb) => cb(mockPrisma)),
    outboxEvent: {
      create: vi.fn().mockResolvedValue({ id: 'outbox-1' }),
    },
    user: {
      count: vi.fn().mockResolvedValue(10),
    },
  } as unknown as PrismaService;

  const mockAudit = {
    append: vi.fn().mockResolvedValue(undefined),
  } as unknown as AuditWriter;

  const mockReviews = {
    approveReviewByAdmin: vi.fn(),
    rejectReviewByAdmin: vi.fn(),
    redactReviewByAdmin: vi.fn(),
  } as unknown as ReviewService;

  const mockSettings = {
    getAllAdminSettings: vi.fn(),
    updateAdminSetting: vi.fn(),
  } as unknown as SettingsService;

  const mockStorage = {
    createSignedDownloadUrl: vi.fn(),
  } as unknown as ObjectStorage;

  const mockEnv = {
    SUPABASE_STORAGE_BUCKET_KYC: 'kyc',
  } as unknown as Env;

  const service = new AdminService(
    mockRepo,
    mockPrisma,
    mockAudit,
    mockReviews,
    mockSettings,
    mockStorage,
    mockEnv,
  );

  it('fetches dashboard stats', async () => {
    vi.mocked(mockRepo.getDashboardStats).mockResolvedValueOnce({
      totalCustomers: 50,
      totalVendors: 20,
      pendingVerificationVendors: 3,
      activeRequests: 10,
      activeOffers: 15,
      activeConnections: 5,
    });

    const result = await service.getDashboard();
    expect(result.totalCustomers).toBe(50);
    expect(result.totalVendors).toBe(20);
  });

  it('suspends and reactivates a customer', async () => {
    vi.mocked(mockRepo.findCustomer).mockResolvedValue({
      id: 'cust-1',
      userId: 'user-cust-1',
    } as unknown as CustomerProfile);
    vi.mocked(mockRepo.updateCustomerState).mockResolvedValueOnce({
      id: 'user-cust-1',
      accountState: 'SUSPENDED',
    } as unknown as User);

    await service.suspendCustomer('cust-1', { reasonCode: 'FRAUD', reasonText: 'Fake activity' }, 'admin-1');
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'CUSTOMER_SUSPENDED' }),
    );

    vi.mocked(mockRepo.updateCustomerState).mockResolvedValueOnce({
      id: 'user-cust-1',
      accountState: 'ACTIVE',
    } as unknown as User);

    await service.reactivateCustomer('cust-1', { reasonText: 'Cleared' }, 'admin-1');
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'CUSTOMER_REACTIVATED' }),
    );
  });

  it('verifies a vendor and sets state to ACTIVE when taxonomy exists', async () => {
    vi.mocked(mockRepo.findVendor).mockResolvedValueOnce({
      id: 'ven-1',
      categories: [{ id: 'cat-1' }],
      regions: [{ id: 'reg-1' }],
    } as unknown as VendorProfile & { categories: { id: string }[]; regions: { id: string }[] });
    vi.mocked(mockRepo.updateVendorVerification).mockResolvedValueOnce({
      id: 'ven-1',
      verificationState: 'VERIFIED',
      accountState: 'ACTIVE',
    } as unknown as VendorProfile);

    const res = await service.verifyVendor('ven-1', { rationale: 'Documents checked' }, 'admin-1');
    expect(res.verificationState).toBe('VERIFIED');
    expect(res.accountState).toBe('ACTIVE');
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'VENDOR_VERIFIED' }),
    );
  });

  it('rejects vendor with rationale', async () => {
    vi.mocked(mockRepo.findVendor).mockResolvedValueOnce({
      id: 'ven-1',
    } as unknown as VendorProfile);
    vi.mocked(mockRepo.updateVendorVerification).mockResolvedValueOnce({
      id: 'ven-1',
      verificationState: 'REJECTED',
      accountState: 'REJECTED',
    } as unknown as VendorProfile);

    await service.rejectVendor('ven-1', { rationale: 'Trade licence expired' }, 'admin-1');
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'VENDOR_VERIFICATION_REJECTED' }),
    );
  });

  it('returns request detail with matchedVendors and transitions', async () => {
    vi.mocked(mockRepo.findRequest).mockResolvedValueOnce({
      id: 'req-1',
      notes: 'Customer brief',
      matchedVendors: [
        {
          vendorProfileId: 'v-1',
          isEligible: true,
          matchedAt: '2026-09-01T10:05:00.000Z',
          viewedAt: null,
          vendor: { id: 'v-1', legalBusinessName: 'Gold Star LLC', tradingName: 'Gold Star' },
        },
      ],
      transitions: [
        {
          fromState: 'DRAFT',
          toState: 'PUBLISHED',
          transition: 'PUBLISH_REQUEST',
          timestamp: '2026-09-01T10:00:00.000Z',
        },
      ],
      timeline: [
        {
          fromState: 'DRAFT',
          toState: 'PUBLISHED',
          transition: 'PUBLISH_REQUEST',
          timestamp: '2026-09-01T10:00:00.000Z',
        },
      ],
      connections: [
        {
          id: 'conn-1',
          vendorProfile: { id: 'v-1', legalBusinessName: 'Gold Star LLC' },
          customerProfile: { id: 'cust-1', displayName: 'Fatima Al-Nuaimi' },
        },
      ],
    } as unknown as Request);

    const result = await service.getRequest('req-1');
    expect(result).toMatchObject({
      id: 'req-1',
      matchedVendors: [expect.objectContaining({ vendorProfileId: 'v-1' })],
      transitions: [expect.objectContaining({ toState: 'PUBLISHED' })],
      timeline: [expect.objectContaining({ toState: 'PUBLISHED' })],
    });
    expect(
      (result as unknown as { connections: Array<{ vendorProfile: { id: string } }> }).connections[0]
        .vendorProfile.id,
    ).toBe('v-1');
  });

  it('returns offer detail with transitions and typed revision columns', async () => {
    vi.mocked(mockRepo.findOffer).mockResolvedValueOnce({
      id: 'off-1',
      revisions: [
        {
          id: 'rev-1',
          revisionNumber: 1,
          revisedAt: new Date('2026-09-01T14:00:00.000Z'),
          previousTerms: { offeredPrice: '15450.00' },
          offeredPrice: 15450,
          makingCharges: 600,
          ratePerGram: 270,
        },
      ],
      transitions: [
        {
          fromState: null,
          toState: 'PENDING',
          transition: 'OFFER_SUBMITTED',
          timestamp: '2026-09-01T12:00:00.000Z',
        },
      ],
      stateTransitions: [
        {
          fromState: null,
          toState: 'PENDING',
          transition: 'OFFER_SUBMITTED',
          timestamp: '2026-09-01T12:00:00.000Z',
        },
      ],
    } as never);

    const result = await service.getOffer('off-1');
    expect(result).toMatchObject({
      id: 'off-1',
      revisions: [expect.objectContaining({ id: 'rev-1', offeredPrice: 15450, ratePerGram: 270 })],
      transitions: [expect.objectContaining({ transition: 'OFFER_SUBMITTED' })],
      stateTransitions: [expect.objectContaining({ toState: 'PENDING' })],
    });
  });

  it('removes a request and audits action', async () => {
    vi.mocked(mockRepo.findRequest).mockResolvedValueOnce({
      id: 'req-1',
    } as unknown as Request);
    vi.mocked(mockRepo.removeRequest).mockResolvedValueOnce({
      id: 'req-1',
      state: 'REMOVED',
    } as unknown as Request);

    await service.removeRequest(
      'req-1',
      { reasonCode: 'PROHIBITED_ITEM', reasonText: 'Violates policy', policyClause: '4.2' },
      'admin-1',
    );
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'REQUEST_REMOVED_BY_ADMIN' }),
    );
  });

  it('closes a connection and audits action', async () => {
    vi.mocked(mockRepo.findConnection).mockResolvedValueOnce({
      id: 'conn-1',
      requestId: 'req-1',
    } as unknown as Connection);
    vi.mocked(mockRepo.closeConnection).mockResolvedValueOnce({
      id: 'conn-1',
      state: 'CLOSED',
    } as unknown as Connection);

    await service.closeConnection('conn-1', { reasonText: 'Inactivity' }, 'admin-1');
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'CONNECTION_CLOSED_BY_ADMIN' }),
    );
  });

  it('delegates review moderation calls to ReviewService', async () => {
    vi.mocked(mockReviews.approveReviewByAdmin).mockResolvedValueOnce({ id: 'rev-1', state: 'PUBLISHED' } as unknown as Review);
    await service.approveReview('rev-1', 'admin-1');
    expect(mockReviews.approveReviewByAdmin).toHaveBeenCalledWith('rev-1', 'admin-1');

    vi.mocked(mockReviews.rejectReviewByAdmin).mockResolvedValueOnce({ id: 'rev-1', state: 'REJECTED' } as unknown as Review);
    await service.rejectReview('rev-1', { rationale: 'Inappropriate' }, 'admin-1');
    expect(mockReviews.rejectReviewByAdmin).toHaveBeenCalledWith('rev-1', 'Inappropriate', 'admin-1');
  });

  it('resolves and dismisses abuse reports', async () => {
    vi.mocked(mockRepo.resolveAbuseReport).mockResolvedValueOnce({ id: 'ab-1', state: 'RESOLVED' } as unknown as AbuseReport);
    await service.resolveAbuseReport('ab-1', { resolution: 'Suspended offender' }, 'admin-1');
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'ABUSE_REPORT_RESOLVED' }),
    );

    vi.mocked(mockRepo.resolveAbuseReport).mockResolvedValueOnce({ id: 'ab-1', state: 'DISMISSED' } as unknown as AbuseReport);
    await service.dismissAbuseReport('ab-1', { resolution: 'No violation found' }, 'admin-1');
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'ABUSE_REPORT_DISMISSED' }),
    );
  });

  it('actions abuse reports against the reported party (FR-ADM-032 AC3)', async () => {
    vi.mocked(mockRepo.findAbuseReport).mockResolvedValue({ id: 'ab-1', reportedUserId: 'u-9' } as unknown as AbuseReport);
    vi.mocked(mockRepo.resolveAbuseReport).mockResolvedValue({ id: 'ab-1', state: 'RESOLVED' } as unknown as AbuseReport);

    await service.actionAbuseReport('ab-1', { action: 'SUSPEND', rationale: 'Repeated abuse' }, 'admin-1');
    expect(mockRepo.updateUserAccountState).toHaveBeenCalledWith(expect.anything(), 'u-9', 'SUSPENDED');
    expect(mockRepo.resolveAbuseReport).toHaveBeenLastCalledWith(expect.anything(), 'ab-1', 'RESOLVED', 'Repeated abuse', 'admin-1');
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'ABUSE_PARTY_SUSPENDED' }),
    );

    vi.mocked(mockRepo.updateUserAccountState).mockClear();
    await service.actionAbuseReport('ab-1', { action: 'WARN', rationale: 'First warning' }, 'admin-1');
    expect(mockRepo.updateUserAccountState).not.toHaveBeenCalled();

    await service.actionAbuseReport('ab-1', { action: 'DEACTIVATE', rationale: 'Severe' }, 'admin-1');
    expect(mockRepo.updateUserAccountState).toHaveBeenCalledWith(expect.anything(), 'u-9', 'DEACTIVATED');

    await service.actionAbuseReport('ab-1', { action: 'DISMISS', rationale: 'No violation' }, 'admin-1');
    expect(mockRepo.resolveAbuseReport).toHaveBeenLastCalledWith(expect.anything(), 'ab-1', 'DISMISSED', 'No violation', 'admin-1');
  });

  it('rejects actioning a missing abuse report', async () => {
    vi.mocked(mockRepo.findAbuseReport).mockResolvedValueOnce(null);
    await expect(
      service.actionAbuseReport('nope', { action: 'WARN', rationale: 'x' }, 'admin-1'),
    ).rejects.toMatchObject({ errorCode: ErrorCode.NOT_FOUND });
  });

  it('prevents revoking the last remaining active admin', async () => {
    vi.mocked(mockRepo.findAdmin).mockResolvedValueOnce({
      id: 'admin-prof-1',
      userId: 'user-admin-1',
      user: { accountState: 'ACTIVE' },
    } as unknown as AdminProfile & { user: User });
    vi.mocked(mockRepo.countActiveAdmins).mockResolvedValueOnce(1);

    await expect(service.revokeAdmin('admin-prof-1', 'admin-prof-1')).rejects.toMatchObject({
      status: 409,
      errorCode: 'CONFLICT',
    });
  });

  it('creates and cancels announcements, and sweeps due announcements', async () => {
    vi.mocked(mockRepo.createAnnouncement).mockResolvedValueOnce({
      id: 'ann-1',
      titleEn: 'Notice',
    } as unknown as Announcement);

    const ann = await service.createAnnouncement(
      {
        titleEn: 'Notice',
        titleAr: 'إشعار',
        bodyEn: 'Maintenance scheduled',
        bodyAr: 'صيانة مجدولة',
        audience: {},
        channels: { inApp: true },
      },
      'admin-prof-1',
      'admin-user-1',
    );
    expect(ann.id).toBe('ann-1');

    vi.mocked(mockRepo.findAnnouncement).mockResolvedValueOnce({
      id: 'ann-1',
      cancelledAt: null,
      dispatchStats: null,
    } as unknown as Announcement);
    vi.mocked(mockRepo.cancelAnnouncement).mockResolvedValueOnce({
      id: 'ann-1',
      cancelledAt: new Date(),
    } as unknown as Announcement);

    await service.cancelAnnouncement('ann-1', 'admin-user-1');
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'ANNOUNCEMENT_CANCELLED' }),
    );

    // Sweeper
    vi.mocked(mockRepo.findDueAnnouncements).mockResolvedValueOnce([
      { id: 'ann-2', titleEn: 'Sale', titleAr: 'خصم' },
    ] as unknown as Announcement[]);
    const swept = await service.sweepAnnouncementDispatch();
    expect(swept).toBe(1);
    expect(mockRepo.recordAnnouncementDispatched).toHaveBeenCalled();
  });

  it('forwards ADM-C-71 request list filters to the repository', async () => {
    vi.mocked(mockRepo.listRequests).mockResolvedValueOnce({ items: [], nextCursor: undefined });
    const query = {
      q: 'necklace',
      state: 'PUBLISHED' as const,
      requestType: 'FIND_ORNAMENT',
      direction: 'BUY',
      categoryId: 'cat-1',
      regionId: 'reg-1',
      zeroOffers: true,
      minValue: 1000,
      maxValue: 5000,
      limit: 20,
    };

    await service.listRequests(query);

    expect(mockRepo.listRequests).toHaveBeenCalledWith(query);
  });

  it('forwards ADM-C-71 offer list filters to the repository', async () => {
    vi.mocked(mockRepo.listOffers).mockResolvedValueOnce({ items: [], nextCursor: undefined });
    const query = {
      state: 'PENDING',
      vendorId: 'v-1',
      requestType: 'GOLD_COIN',
      minPrice: 4000,
      maxPrice: 9000,
      dateFrom: '2026-09-01',
      dateTo: '2026-09-08',
      limit: 20,
    };

    await service.listOffers(query);

    expect(mockRepo.listOffers).toHaveBeenCalledWith(query);
  });

  it('handles report queries and export jobs with watermark', async () => {
    vi.mocked(mockRepo.getReportData).mockResolvedValueOnce({
      name: 'funnel',
      generatedAt: new Date().toISOString(),
      rows: [{ stage: 'requests', count: 10 }],
      series: [],
    });

    const report = await service.getReport('funnel', {});
    expect(report.name).toBe('funnel');
    expect(report.rows).toHaveLength(1);

    vi.mocked(mockRepo.createExportJob).mockResolvedValueOnce({
      id: 'exp-1',
      state: 'READY',
      reportName: 'funnel',
    } as unknown as ExportJob);

    const job = await service.createExportJob(
      {
        reportName: 'funnel',
        format: 'CSV',
        filters: {},
        purpose: 'Monthly audit',
      },
      'admin-prof-1',
      'admin-user-1',
    );
    expect(job.id).toBe('exp-1');

    vi.mocked(mockRepo.findExportJob).mockResolvedValueOnce({
      id: 'exp-1',
      state: 'READY',
      watermark: { generatedByAdminId: 'admin-user-1' },
      completedAt: new Date(),
    } as unknown as ExportJob);

    const retrieved = await service.getExportJob('exp-1', 'admin-user-1');
    expect(retrieved.downloadUrl).toBe('/v1/admin/exports/exp-1/download');
    expect(retrieved.watermark).toEqual({ generatedByAdminId: 'admin-user-1' });
  });

  it('issues a 15-minute signed KYC download URL and audits access (NFR-015)', async () => {
    vi.mocked(mockRepo.findVendorDocument).mockResolvedValueOnce({
      id: 'doc-1',
      vendorProfileId: 'ven-1',
      media: {
        id: 'media-1',
        key: 'tl-doc-key',
        state: 'READY',
        uploadedByUserId: 'user-vendor-1',
      },
    } as unknown as VendorDocument & {
      media: { id: string; key: string; state: string; uploadedByUserId: string };
    });
    vi.mocked(mockStorage.createSignedDownloadUrl).mockResolvedValueOnce({
      url: 'https://storage.example/signed-kyc.pdf',
      expiresAt: new Date('2026-09-08T12:15:00.000Z'),
    });

    const result = await service.getVendorDocumentUrl('ven-1', 'doc-1', 'admin-user-1');

    expect(mockStorage.createSignedDownloadUrl).toHaveBeenCalledWith(
      'kyc',
      'vendor/ven-1/KYC_DOCUMENT/tl-doc-key',
      900,
    );
    expect(result).toEqual({
      url: 'https://storage.example/signed-kyc.pdf',
      expiresAt: '2026-09-08T12:15:00.000Z',
    });
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        action: 'KYC_DOCUMENT_ACCESSED',
        entityType: 'vendor_document',
        entityId: 'doc-1',
        actorUserId: 'admin-user-1',
      }),
    );
  });

  it('rejects quarantined and incomplete KYC documents', async () => {
    vi.mocked(mockRepo.findVendorDocument).mockResolvedValueOnce({
      id: 'doc-1',
      vendorProfileId: 'ven-1',
      media: { state: 'QUARANTINED', key: 'k' },
    } as unknown as VendorDocument & { media: { state: string; key: string } });

    await expect(
      service.getVendorDocumentUrl('ven-1', 'doc-1', 'admin-user-1'),
    ).rejects.toMatchObject({ errorCode: ErrorCode.MEDIA_QUARANTINED });

    vi.mocked(mockRepo.findVendorDocument).mockResolvedValueOnce({
      id: 'doc-1',
      vendorProfileId: 'ven-1',
      media: { state: 'PENDING_UPLOAD', key: 'k' },
    } as unknown as VendorDocument & { media: { state: string; key: string } });

    await expect(
      service.getVendorDocumentUrl('ven-1', 'doc-1', 'admin-user-1'),
    ).rejects.toMatchObject({ errorCode: ErrorCode.UPLOAD_NOT_COMPLETED });
  });

  it('returns author displayName on createAdminNote to match list items', async () => {
    vi.mocked(mockRepo.createAdminNote).mockResolvedValueOnce({
      id: 'note-1',
      entityType: 'vendors',
      entityId: 'ven-1',
      text: 'Called vendor',
      authorAdminId: 'admin-prof-1',
      author: { displayName: 'Admin Sarah' },
      createdAt: new Date('2026-09-08T10:00:00.000Z'),
    });

    const result = await service.createAdminNote(
      'vendors',
      'ven-1',
      'Called vendor',
      'admin-prof-1',
    );

    expect(mockRepo.createAdminNote).toHaveBeenCalledWith({
      entityType: 'vendors',
      entityId: 'ven-1',
      text: 'Called vendor',
      authorAdminId: 'admin-prof-1',
    });
    expect(result.author).toEqual({ displayName: 'Admin Sarah' });
  });

  it('audits export download once and streams CSV from report rows', async () => {
    const job = {
      id: 'exp-1',
      state: 'READY',
      format: 'CSV',
      reportName: 'funnel',
      filters: { from: '2026-08-01', to: '2026-08-31' },
      watermark: { generatedByAdminId: 'admin-user-1' },
      completedAt: new Date(),
    } as unknown as ExportJob;
    vi.mocked(mockRepo.findExportJob).mockResolvedValue(job);
    vi.mocked(mockRepo.getReportData).mockResolvedValueOnce({
      name: 'funnel',
      generatedAt: new Date().toISOString(),
      rows: [
        { stage: 'requests', count: 10 },
        { stage: 'offers', count: 4 },
      ],
      series: [],
    });
    vi.mocked(mockAudit.append).mockClear();

    const polled = await service.getExportJob('exp-1', 'admin-user-1');
    expect(polled.downloadUrl).toBe('/v1/admin/exports/exp-1/download');
    expect(mockAudit.append).not.toHaveBeenCalled();

    const file = await service.downloadExport('exp-1', 'admin-user-1');
    expect(mockRepo.getReportData).toHaveBeenCalledWith('funnel', {
      from: '2026-08-01',
      to: '2026-08-31',
    });
    expect(file.contentType).toBe('text/csv; charset=utf-8');
    expect(file.filename).toBe('funnel-exp-1.csv');
    expect(file.body.toString('utf8')).toBe(
      'stage,count\nrequests,10\noffers,4\n',
    );
    expect(mockAudit.append).toHaveBeenCalledTimes(1);
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        action: 'EXPORT_DOWNLOADED',
        entityType: 'export_job',
        entityId: 'exp-1',
        actorUserId: 'admin-user-1',
      }),
    );
  });

  it('serves XLSX jobs as CSV bytes and rejects PNG chart export with 501', async () => {
    vi.mocked(mockRepo.findExportJob).mockResolvedValueOnce({
      id: 'exp-xlsx',
      state: 'READY',
      format: 'XLSX',
      reportName: 'request-volume',
      filters: {},
      watermark: {},
    } as unknown as ExportJob);
    vi.mocked(mockRepo.getReportData).mockResolvedValueOnce({
      name: 'request-volume',
      generatedAt: new Date().toISOString(),
      rows: [{ state: 'OPEN', count: 2 }],
      series: [],
    });

    const xlsx = await service.downloadExport('exp-xlsx', 'admin-user-1');
    expect(xlsx.contentType).toBe('text/csv; charset=utf-8');
    expect(xlsx.body.toString('utf8')).toContain('state,count');

    vi.mocked(mockRepo.findExportJob).mockResolvedValueOnce({
      id: 'exp-png',
      state: 'READY',
      format: 'PNG',
      reportName: 'funnel',
      filters: {},
    } as unknown as ExportJob);

    await expect(service.downloadExport('exp-png', 'admin-user-1')).rejects.toMatchObject({
      status: 501,
      errorCode: ErrorCode.VALIDATION_FAILED,
    });
  });
});
