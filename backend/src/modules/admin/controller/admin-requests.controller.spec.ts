import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { FastifyRequest } from 'fastify';
import { RequestState, RequestType } from '@prisma/client';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { AdminRequestsController } from './admin-requests.controller';
import type { AdminRequestsService } from '../application/admin-requests.service';

describe('AdminRequestsController', () => {
  let controller: AdminRequestsController;
  let service: AdminRequestsService;

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
    headers: { 'user-agent': 'admin-web' },
  } as unknown as FastifyRequest;

  beforeEach(() => {
    service = {
      listRequests: vi.fn(),
      getRequestDetail: vi.fn(),
      removeRequest: vi.fn(),
      addNote: vi.fn(),
    } as unknown as AdminRequestsService;

    controller = new AdminRequestsController(service);
  });

  it('listRequests delegates query and pagination to service', async () => {
    vi.mocked(service.listRequests).mockResolvedValue({
      data: [],
      meta: { total: 0, nextCursor: null, hasMore: false },
    });

    const query = {
      state: RequestState.PUBLISHED,
      requestType: RequestType.FIND_ORNAMENT,
      limit: 10,
      page: 1,
    };

    const result = await controller.listRequests(query);

    expect(service.listRequests).toHaveBeenCalledWith(query, {
      cursor: undefined,
      limit: 10,
      page: 1,
    });
    expect(result.data).toEqual([]);
  });

  it('getRequest delegates id to service', async () => {
    vi.mocked(service.getRequestDetail).mockResolvedValue({
      id: 'req-1',
    } as any);

    const result = await controller.getRequest('req-1');

    expect(service.getRequestDetail).toHaveBeenCalledWith('req-1');
    expect(result.id).toBe('req-1');
  });

  it('removeRequest passes viewer, body, and client IP', async () => {
    vi.mocked(service.removeRequest).mockResolvedValue({
      id: 'req-1',
      state: RequestState.REMOVED,
    } as any);

    const body = {
      reasonCode: 'POLICY_VIOLATION',
      reasonText: 'Inappropriate content',
      policyClause: 'Section 4',
    };

    const result = await controller.removeRequest('req-1', mockAdminViewer, mockRequest, body);

    expect(service.removeRequest).toHaveBeenCalledWith(
      'req-1',
      'admin-user-1',
      body,
      '127.0.0.1',
    );
    expect(result.state).toBe(RequestState.REMOVED);
  });

  it('addNote passes viewer and content', async () => {
    vi.mocked(service.addNote).mockResolvedValue({
      id: 'note-1',
      text: 'Verified manually',
      authorAdminId: 'admin-prof-1',
      createdAt: '2026-09-01T10:00:00.000Z',
    });

    const result = await controller.addNote('req-1', mockAdminViewer, { content: 'Verified manually' });

    expect(service.addNote).toHaveBeenCalledWith('req-1', 'admin-user-1', 'Verified manually');
    expect(result.text).toBe('Verified manually');
  });
});
