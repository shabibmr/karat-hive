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
  VendorProfile,
} from '@prisma/client';
import type { PrismaService } from '../../../platform/db/prisma.service';
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

  const service = new AdminService(
    mockRepo,
    mockPrisma,
    mockAudit,
    mockReviews,
    mockSettings,
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
});
