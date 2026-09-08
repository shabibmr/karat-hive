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
});
