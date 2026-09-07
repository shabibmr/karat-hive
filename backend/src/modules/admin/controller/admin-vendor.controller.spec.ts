import { describe, expect, it, vi, beforeEach } from 'vitest';
import type { FastifyRequest } from 'fastify';
import { AdminVendorController } from './admin-vendor.controller';
import type { AdminVendorService } from '../application/admin-vendor.service';
import type { ViewerContext } from '../../../edge/auth/viewer-context';

describe('AdminVendorController', () => {
  let controller: AdminVendorController;
  let service: AdminVendorService;

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

  const mockRequest = {
    ip: '127.0.0.1',
    headers: { 'user-agent': 'admin-portal' },
  } as unknown as FastifyRequest;

  beforeEach(() => {
    service = {
      getVerificationQueue: vi.fn(),
      getVendors: vi.fn(),
      getVendorDetail: vi.fn(),
      getDocumentSignedUrl: vi.fn(),
      verifyVendor: vi.fn(),
      rejectVendor: vi.fn(),
      requestInfo: vi.fn(),
      activateVendor: vi.fn(),
      suspendVendor: vi.fn(),
      reactivateVendor: vi.fn(),
      deactivateVendor: vi.fn(),
      addNote: vi.fn(),
    } as unknown as AdminVendorService;

    controller = new AdminVendorController(service);
  });

  it('getVerificationQueue delegates to service', async () => {
    vi.mocked(service.getVerificationQueue).mockResolvedValue([
      {
        id: 'v-1',
        legalBusinessName: 'Jewellery LLC',
        tradeLicenceNumber: 'TL-123',
        oldestWaitingHours: 12,
      },
    ]);

    const result = await controller.getVerificationQueue();

    expect(result).toHaveLength(1);
    expect(service.getVerificationQueue).toHaveBeenCalled();
  });

  it('listVendors delegates query and pagination to service', async () => {
    vi.mocked(service.getVendors).mockResolvedValue({
      data: [],
      meta: { total: 0, nextCursor: null, hasMore: false },
    });

    const query = { verificationState: 'PENDING_VERIFICATION' as const, limit: 10, page: 1 };
    await controller.listVendors(query);

    expect(service.getVendors).toHaveBeenCalledWith(
      query,
      expect.objectContaining({ limit: 10, page: 1 }),
    );
  });

  it('getVendor delegates to service.getVendorDetail', async () => {
    vi.mocked(service.getVendorDetail).mockResolvedValue({
      id: 'v-1',
      legalBusinessName: 'Jewellery LLC',
    } as any);

    const result = await controller.getVendor('v-1');

    expect(result.id).toBe('v-1');
    expect(service.getVendorDetail).toHaveBeenCalledWith('v-1');
  });

  it('getDocumentUrl delegates to service.getDocumentSignedUrl with viewer and client info', async () => {
    vi.mocked(service.getDocumentSignedUrl).mockResolvedValue({
      url: 'https://storage/signed',
      expiresAt: '2026-09-07T12:15:00.000Z',
    });

    const result = await controller.getDocumentUrl('v-1', 'doc-1', mockAdminViewer, mockRequest);

    expect(result.url).toBe('https://storage/signed');
    expect(service.getDocumentSignedUrl).toHaveBeenCalledWith(
      mockAdminViewer,
      expect.objectContaining({ ip: '127.0.0.1' }),
      'v-1',
      'doc-1',
    );
  });

  it('verifyVendor delegates to service.verifyVendor', async () => {
    vi.mocked(service.verifyVendor).mockResolvedValue({ lifecycle: 'ACTIVE' });

    const result = await controller.verifyVendor('v-1', mockAdminViewer, {
      rationale: 'Documents approved',
    });

    expect(result.lifecycle).toBe('ACTIVE');
    expect(service.verifyVendor).toHaveBeenCalledWith(
      mockAdminViewer,
      'v-1',
      'Documents approved',
    );
  });

  it('rejectVendor delegates to service.rejectVendor', async () => {
    vi.mocked(service.rejectVendor).mockResolvedValue({ lifecycle: 'REJECTED' });

    const result = await controller.rejectVendor('v-1', mockAdminViewer, {
      rationale: 'Invalid licence',
    });

    expect(result.lifecycle).toBe('REJECTED');
    expect(service.rejectVendor).toHaveBeenCalledWith(
      mockAdminViewer,
      'v-1',
      'Invalid licence',
    );
  });

  it('requestInfo delegates to service.requestInfo', async () => {
    vi.mocked(service.requestInfo).mockResolvedValue({ lifecycle: 'PENDING_VERIFICATION' });

    const result = await controller.requestInfo('v-1', mockAdminViewer, {
      message: 'Please provide higher resolution scan',
    });

    expect(result.lifecycle).toBe('PENDING_VERIFICATION');
    expect(service.requestInfo).toHaveBeenCalledWith(
      mockAdminViewer,
      'v-1',
      'Please provide higher resolution scan',
    );
  });

  it('activateVendor delegates to service.activateVendor', async () => {
    vi.mocked(service.activateVendor).mockResolvedValue({
      accountState: 'ACTIVE',
      lifecycle: 'ACTIVE',
    });

    const result = await controller.activateVendor('v-1', mockAdminViewer, {
      reasonText: 'Compliance satisfied',
    });

    expect(result.accountState).toBe('ACTIVE');
    expect(service.activateVendor).toHaveBeenCalledWith(mockAdminViewer, 'v-1', {
      reasonText: 'Compliance satisfied',
    });
  });

  it('suspendVendor delegates to service.suspendVendor', async () => {
    vi.mocked(service.suspendVendor).mockResolvedValue({
      accountState: 'SUSPENDED',
      lifecycle: 'SUSPENDED',
    });

    const result = await controller.suspendVendor('v-1', mockAdminViewer, {
      reasonText: 'Compliance breach',
    });

    expect(result.accountState).toBe('SUSPENDED');
    expect(service.suspendVendor).toHaveBeenCalledWith(mockAdminViewer, 'v-1', {
      reasonText: 'Compliance breach',
    });
  });

  it('reactivateVendor delegates to service.reactivateVendor', async () => {
    vi.mocked(service.reactivateVendor).mockResolvedValue({
      accountState: 'ACTIVE',
      lifecycle: 'ACTIVE',
    });

    const result = await controller.reactivateVendor('v-1', mockAdminViewer, {
      reasonText: 'Suspension resolved',
    });

    expect(result.accountState).toBe('ACTIVE');
    expect(service.reactivateVendor).toHaveBeenCalledWith(mockAdminViewer, 'v-1', {
      reasonText: 'Suspension resolved',
    });
  });

  it('deactivateVendor delegates to service.deactivateVendor', async () => {
    vi.mocked(service.deactivateVendor).mockResolvedValue({
      accountState: 'DEACTIVATED',
      lifecycle: 'DEACTIVATED',
    });

    const result = await controller.deactivateVendor('v-1', mockAdminViewer, {
      reasonText: 'Account closed',
    });

    expect(result.accountState).toBe('DEACTIVATED');
    expect(service.deactivateVendor).toHaveBeenCalledWith(mockAdminViewer, 'v-1', {
      reasonText: 'Account closed',
    });
  });

  it('addNote delegates to service.addNote', async () => {
    vi.mocked(service.addNote).mockResolvedValue({
      id: 'n-1',
      text: 'Verified bank details',
      authorAdminId: 'admin-prof-1',
      createdAt: '2026-09-07T12:00:00.000Z',
    });

    const result = await controller.addNote('v-1', mockAdminViewer, {
      text: 'Verified bank details',
    });

    expect(result.id).toBe('n-1');
    expect(service.addNote).toHaveBeenCalledWith(mockAdminViewer, 'v-1', 'Verified bank details');
  });
});
