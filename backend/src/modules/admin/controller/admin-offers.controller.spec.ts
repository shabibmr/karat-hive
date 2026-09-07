import { beforeEach, describe, expect, it, vi } from 'vitest';
import { OfferState, RequestType } from '@prisma/client';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { AdminOffersController } from './admin-offers.controller';
import type { AdminOffersService } from '../application/admin-offers.service';

describe('AdminOffersController', () => {
  let controller: AdminOffersController;
  let service: AdminOffersService;

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
      listOffers: vi.fn(),
      getOfferDetail: vi.fn(),
      addNote: vi.fn(),
    } as unknown as AdminOffersService;

    controller = new AdminOffersController(service);
  });

  it('listOffers delegates query and pagination to service', async () => {
    vi.mocked(service.listOffers).mockResolvedValue({
      data: [],
      meta: { total: 0, nextCursor: null, hasMore: false },
    });

    const query = {
      state: OfferState.PENDING,
      requestType: RequestType.FIND_ORNAMENT,
      limit: 20,
      page: 1,
    };

    const result = await controller.listOffers(query);

    expect(service.listOffers).toHaveBeenCalledWith(query, {
      cursor: undefined,
      limit: 20,
      page: 1,
    });
    expect(result.data).toEqual([]);
  });

  it('getOffer delegates id to service', async () => {
    vi.mocked(service.getOfferDetail).mockResolvedValue({
      id: 'off-1',
    } as any);

    const result = await controller.getOffer('off-1');

    expect(service.getOfferDetail).toHaveBeenCalledWith('off-1');
    expect(result.id).toBe('off-1');
  });

  it('addNote passes viewer and content to service', async () => {
    vi.mocked(service.addNote).mockResolvedValue({
      id: 'note-1',
      text: 'Inspected offer pricing',
      authorAdminId: 'admin-prof-1',
      createdAt: '2026-09-01T10:00:00.000Z',
    });

    const result = await controller.addNote('off-1', mockAdminViewer, { content: 'Inspected offer pricing' });

    expect(service.addNote).toHaveBeenCalledWith('off-1', 'admin-user-1', 'Inspected offer pricing');
    expect(result.text).toBe('Inspected offer pricing');
  });
});
