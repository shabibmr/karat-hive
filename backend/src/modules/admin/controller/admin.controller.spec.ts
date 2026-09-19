import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { FastifyReply } from 'fastify';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { AdminController } from './admin.controller';
import type { AdminService } from '../application/admin.service';

describe('AdminController', () => {
  let controller: AdminController;
  let service: AdminService;

  const mockAdminViewer: ViewerContext = {
    userId: 'admin-user-1',
    role: 'ADMIN',
    tokenVersion: 1,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    vendorProfileId: null,
    vendorVerificationState: null,
    vendorActivatedAt: null,
    customerProfileId: null,
    adminProfileId: 'admin-prof-1',
  };

  beforeEach(() => {
    service = {
      getVendorDocumentUrl: vi.fn(),
      createAdminNote: vi.fn(),
      getExportJob: vi.fn(),
      downloadExport: vi.fn(),
    } as unknown as AdminService;

    controller = new AdminController(service);
  });

  it('getVendorDocumentUrl returns the signed URL payload', async () => {
    vi.mocked(service.getVendorDocumentUrl).mockResolvedValue({
      url: 'https://storage.example/signed-kyc.pdf',
      expiresAt: '2026-09-08T12:15:00.000Z',
    });

    const result = await controller.getVendorDocumentUrl(
      mockAdminViewer,
      'ven-1',
      'doc-1',
    );

    expect(service.getVendorDocumentUrl).toHaveBeenCalledWith(
      'ven-1',
      'doc-1',
      'admin-user-1',
    );
    expect(result).toEqual({
      data: {
        url: 'https://storage.example/signed-kyc.pdf',
        expiresAt: '2026-09-08T12:15:00.000Z',
      },
    });
  });

  it('createAdminNote returns the created note including author', async () => {
    vi.mocked(service.createAdminNote).mockResolvedValue({
      id: 'note-1',
      text: 'Called vendor',
      author: { displayName: 'Admin Sarah' },
    } as Awaited<ReturnType<AdminService['createAdminNote']>>);

    const result = await controller.createAdminNote(mockAdminViewer, 'vendors', 'ven-1', {
      text: 'Called vendor',
    });

    expect(service.createAdminNote).toHaveBeenCalledWith(
      'vendors',
      'ven-1',
      'Called vendor',
      'admin-prof-1',
    );
    expect(result).toEqual({
      data: {
        id: 'note-1',
        text: 'Called vendor',
        author: { displayName: 'Admin Sarah' },
      },
    });
  });

  it('downloadExport sends CSV bytes without wrapping the envelope', async () => {
    vi.mocked(service.downloadExport).mockResolvedValue({
      body: Buffer.from('stage,count\nrequests,10\n', 'utf8'),
      contentType: 'text/csv; charset=utf-8',
      filename: 'funnel-exp-1.csv',
    });
    const reply = {
      header: vi.fn().mockReturnThis(),
      send: vi.fn().mockReturnThis(),
    } as unknown as FastifyReply;

    await controller.downloadExport(mockAdminViewer, 'exp-1', reply);

    expect(service.downloadExport).toHaveBeenCalledWith('exp-1', 'admin-user-1');
    expect(reply.header).toHaveBeenCalledWith('Content-Type', 'text/csv; charset=utf-8');
    expect(reply.header).toHaveBeenCalledWith(
      'Content-Disposition',
      'attachment; filename="funnel-exp-1.csv"',
    );
    expect(reply.send).toHaveBeenCalledWith(expect.any(Buffer));
  });

  it('listReviews calls service.listReviews with query parameters (ADM-API-GAP-01)', async () => {
    service.listReviews = vi.fn().mockResolvedValue({
      items: [{ id: 'rev-1', rating: 5 }],
      nextCursor: 'rev-2',
    });

    const res = await controller.listReviews('PENDING_MODERATION', 'CUSTOMER', 'keyword', '20', 'cursor-1');

    expect(service.listReviews).toHaveBeenCalledWith({
      state: 'PENDING_MODERATION',
      authorType: 'CUSTOMER',
      q: 'keyword',
      limit: 20,
      cursor: 'cursor-1',
    });
    expect(res).toEqual({
      data: [{ id: 'rev-1', rating: 5 }],
      meta: { nextCursor: 'rev-2' },
    });
  });

  it('recordAuditLog records customer list access and returns recorded: true (ADM-API-GAP-02)', async () => {
    service.recordAuditLog = vi.fn().mockResolvedValue({ recorded: true });

    const res = await controller.recordAuditLog(mockAdminViewer, {
      action: 'CUSTOMER_LIST_VIEWED',
      entityType: 'customer_list',
      occurredAt: new Date('2026-09-20T02:00:00Z'),
    });

    expect(service.recordAuditLog).toHaveBeenCalledWith(
      {
        action: 'CUSTOMER_LIST_VIEWED',
        entityType: 'customer_list',
        occurredAt: new Date('2026-09-20T02:00:00Z'),
      },
      'admin-user-1',
    );
    expect(res).toEqual({ data: { recorded: true } });
  });

  it('listAbuseReports accepts status as an alias for state (ADM-API-GAP-07)', async () => {
    service.listAbuseReports = vi.fn().mockResolvedValue({
      items: [{ id: 'ab-1' }],
      nextCursor: null,
    });

    const res = await controller.listAbuseReports(undefined, 'OPEN', '10', undefined);

    expect(service.listAbuseReports).toHaveBeenCalledWith({
      state: 'OPEN',
      limit: 10,
      cursor: undefined,
    });
    expect(res).toEqual({ data: [{ id: 'ab-1' }], meta: { nextCursor: null } });
  });

  it('getDashboard forwards from and to query params (ADM-API-GAP-08)', async () => {
    service.getDashboard = vi.fn().mockResolvedValue({ totalCustomers: 5 });

    const res = await controller.getDashboard('2026-09-01', '2026-09-20');

    expect(service.getDashboard).toHaveBeenCalledWith({
      from: '2026-09-01',
      to: '2026-09-20',
    });
    expect(res).toEqual({ data: { totalCustomers: 5 } });
  });

  it('getReport forwards groupBy parameter (ADM-API-GAP-09)', async () => {
    service.getReport = vi.fn().mockResolvedValue({ name: 'request-volume', series: [] });

    const res = await controller.getReport('request-volume', '2026-09-01', '2026-09-20', undefined, undefined, 'week');

    expect(service.getReport).toHaveBeenCalledWith('request-volume', {
      from: '2026-09-01',
      to: '2026-09-20',
      regionId: undefined,
      categoryId: undefined,
      groupBy: 'week',
    });
    expect(res).toEqual({ data: { name: 'request-volume', series: [] } });
  });
});
