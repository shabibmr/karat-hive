import { beforeEach, describe, expect, it, vi } from 'vitest';
import { Direction, RequestState, RequestType } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { AdminRequestsService } from './admin-requests.service';
import type { AdminRequestsRepository } from '../repository/admin-requests.repository';

describe('AdminRequestsService', () => {
  let service: AdminRequestsService;
  let repo: AdminRequestsRepository;

  const mockRequestRow = {
    id: 'req-1',
    reference: 'REQ-2026-0001',
    customerProfileId: 'cust-1',
    requestType: RequestType.FIND_ORNAMENT,
    direction: Direction.BUY,
    state: RequestState.PUBLISHED,
    categoryId: 'cat-1',
    regionId: 'reg-1',
    notes: 'Looking for gold ring',
    indicativeValue: '3500.00',
    budgetMin: '3000.00',
    budgetMax: '4000.00',
    budgetIsFlexible: true,
    offerCount: 1,
    publishedAt: new Date('2026-09-01T10:00:00.000Z'),
    expiresAt: new Date('2026-09-03T10:00:00.000Z'),
    createdAt: new Date('2026-09-01T09:00:00.000Z'),
    updatedAt: new Date('2026-09-01T10:00:00.000Z'),
    customerProfile: {
      id: 'cust-1',
      userId: 'user-c-1',
      displayName: 'Sara',
      user: {
        id: 'user-c-1',
        mobileNumber: '+971501234567',
        email: 'sara@example.com',
        accountState: 'ACTIVE',
      },
    },
    category: {
      id: 'cat-1',
      nameEn: 'Rings',
      nameAr: 'خواتم',
    },
    region: {
      id: 'reg-1',
      nameEn: 'Dubai',
      nameAr: 'دبي',
    },
  };

  beforeEach(() => {
    repo = {
      listRequests: vi.fn(),
      findRequestById: vi.fn(),
      removeRequest: vi.fn(),
      addRequestNote: vi.fn(),
    } as unknown as AdminRequestsRepository;

    service = new AdminRequestsService(repo);
  });

  describe('listRequests', () => {
    it('returns formatted list and pagination metadata', async () => {
      vi.mocked(repo.listRequests).mockResolvedValue({
        items: [mockRequestRow as any],
        total: 1,
        nextCursor: null,
        hasMore: false,
      });

      const result = await service.listRequests({ state: RequestState.PUBLISHED });

      expect(result.data).toHaveLength(1);
      expect(result.data[0]!.id).toBe('req-1');
      expect(result.data[0]!.customer.mobileNumber).toBe('+971501234567');
      expect(result.meta.total).toBe(1);
    });

    it('throws 400 VALIDATION_FAILED when valueMin > valueMax', async () => {
      await expect(
        service.listRequests({ valueMin: 5000, valueMax: 2000 }),
      ).rejects.toMatchObject({
        errorCode: ErrorCode.VALIDATION_FAILED,
      });
    });
  });

  describe('getRequestDetail', () => {
    it('returns formatted detail when request exists', async () => {
      vi.mocked(repo.findRequestById).mockResolvedValue({
        ...mockRequestRow,
        media: [],
        matches: [],
        offers: [],
        connections: [],
        acceptedOffer: null,
        notes: [],
        transitions: [],
      } as any);

      const result = await service.getRequestDetail('req-1');

      expect(result.id).toBe('req-1');
      expect(result.customer.displayName).toBe('Sara');
      expect(result.transitions).toBeDefined();
    });

    it('throws 404 NOT_FOUND when request does not exist', async () => {
      vi.mocked(repo.findRequestById).mockResolvedValue(null);

      await expect(service.getRequestDetail('unknown-id')).rejects.toMatchObject({
        errorCode: ErrorCode.NOT_FOUND,
      });
    });
  });

  describe('removeRequest', () => {
    it('validates reasonText and calls repo.removeRequest', async () => {
      vi.mocked(repo.removeRequest).mockResolvedValue({
        ...mockRequestRow,
        state: RequestState.REMOVED,
        cancellationReason: 'Abusive content',
      } as any);

      vi.mocked(repo.findRequestById).mockResolvedValue({
        ...mockRequestRow,
        state: RequestState.REMOVED,
        cancellationReason: 'Abusive content',
        media: [],
        matches: [],
        offers: [],
        connections: [],
        acceptedOffer: null,
        notes: [],
        transitions: [],
      } as any);

      const result = await service.removeRequest(
        'req-1',
        'admin-user-1',
        { reasonText: 'Abusive content', policyClause: 'Clause 7' },
        '10.0.0.1',
      );

      expect(repo.removeRequest).toHaveBeenCalledWith(
        'req-1',
        'admin-user-1',
        undefined,
        'Abusive content',
        'Clause 7',
        '10.0.0.1',
      );
      expect(result.state).toBe(RequestState.REMOVED);
    });

    it('throws 400 VALIDATION_FAILED when reasonText is blank', async () => {
      await expect(
        service.removeRequest('req-1', 'admin-user-1', { reasonText: '   ' }),
      ).rejects.toMatchObject({
        errorCode: ErrorCode.VALIDATION_FAILED,
      });
    });
  });

  describe('addNote', () => {
    it('validates content and calls repo.addRequestNote', async () => {
      vi.mocked(repo.addRequestNote).mockResolvedValue({
        id: 'note-1',
        text: 'Admin note content',
        authorAdminId: 'admin-prof-1',
        createdAt: new Date('2026-09-01T12:00:00.000Z'),
        author: { displayName: 'Support Lead' },
      } as any);

      const note = await service.addNote('req-1', 'admin-user-1', 'Admin note content');

      expect(repo.addRequestNote).toHaveBeenCalledWith('req-1', 'admin-user-1', 'Admin note content');
      expect(note.id).toBe('note-1');
      expect(note.text).toBe('Admin note content');
    });

    it('throws 400 VALIDATION_FAILED when content is empty', async () => {
      await expect(service.addNote('req-1', 'admin-user-1', '')).rejects.toMatchObject({
        errorCode: ErrorCode.VALIDATION_FAILED,
      });
    });
  });
});
