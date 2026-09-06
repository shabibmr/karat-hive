import { describe, expect, it, vi } from 'vitest';
import { Direction, Karat, Prisma, RequestState, RequestType, type Request } from '@prisma/client';
import { Clock } from '../../../shared/clock';
import { RequestsService } from './requests.service';
import type { RequestsRepository } from '../repository/requests.repository';
import type { PrismaService } from '../../../platform/db/prisma.service';

describe('RequestsService', () => {
  const fakeRepo = {
    createDraft: vi.fn(),
    findById: vi.fn(),
    publish: vi.fn(),
  } as unknown as RequestsRepository;

  const fakePrisma = {
    $transaction: vi.fn((cb) => cb({})),
  } as unknown as PrismaService;

  const clock = new Clock();
  const service = new RequestsService(fakeRepo, fakePrisma, clock);

  it('creates draft with Customer presenter', async () => {
    const now = new Date();
    const fakeRequest: Request = {
      id: 'req-1',
      reference: null,
      customerProfileId: 'cust-1',
      requestType: RequestType.FIND_ORNAMENT,
      direction: Direction.BUY,
      state: RequestState.DRAFT,
      categoryId: 'cat-1',
      regionId: 'reg-1',
      notes: 'Looking for a ring',
      weightGrams: new Prisma.Decimal('10.00'),
      weightIsApproximate: false,
      purityKarat: Karat.K22,
      ornamentType: null,
      condition: null,
      denominationGrams: null,
      quantity: null,
      mintOrRefiner: null,
      budgetMin: new Prisma.Decimal('2000.00'),
      budgetMax: new Prisma.Decimal('2500.00'),
      budgetIsFlexible: false,
      indicativeValue: null,
      goldRateId: null,
      gemstones: null,
      publishedAt: null,
      expiresAt: null,
      expiryWarnedAt: null,
      draftPurgeWarnedAt: null,
      offerCount: 0,
      acceptedOfferId: null,
      cancellationReason: null,
      createdAt: now,
      updatedAt: now,
    };

    vi.mocked(fakeRepo.createDraft).mockResolvedValue(fakeRequest);

    const result = await service.createDraft({
      customerProfileId: 'cust-1',
      requestType: RequestType.FIND_ORNAMENT,
      categoryId: 'cat-1',
      regionId: 'reg-1',
      notes: 'Looking for a ring',
    });

    expect(result.id).toBe('req-1');
    expect(result.state).toBe(RequestState.DRAFT);
    expect(result.weightGrams).toBe('10.00');
  });

  it('enforces customer ownership when publishing', async () => {
    const now = new Date();
    const fakeRequest: Request = {
      id: 'req-2',
      reference: null,
      customerProfileId: 'cust-2',
      requestType: RequestType.FIND_ORNAMENT,
      direction: Direction.BUY,
      state: RequestState.DRAFT,
      categoryId: 'cat-1',
      regionId: 'reg-1',
      notes: null,
      weightGrams: null,
      weightIsApproximate: false,
      purityKarat: null,
      ornamentType: null,
      condition: null,
      denominationGrams: null,
      quantity: null,
      mintOrRefiner: null,
      budgetMin: null,
      budgetMax: null,
      budgetIsFlexible: false,
      indicativeValue: null,
      goldRateId: null,
      gemstones: null,
      publishedAt: null,
      expiresAt: null,
      expiryWarnedAt: null,
      draftPurgeWarnedAt: null,
      offerCount: 0,
      acceptedOfferId: null,
      cancellationReason: null,
      createdAt: now,
      updatedAt: now,
    };

    vi.mocked(fakeRepo.findById).mockResolvedValue(fakeRequest);

    await expect(service.publishRequest('req-2', 'wrong-cust')).rejects.toThrow();
  });

  it('rejects vendor request view with 404 if not in match set (CP2-A10)', async () => {
    const fakeRequest = {
      id: 'req-3',
      state: RequestState.PUBLISHED,
      customerProfileId: 'cust-1',
    } as unknown as Request;

    vi.mocked(fakeRepo.findById).mockResolvedValue(fakeRequest);
    fakeRepo.findVendorMatch = vi.fn().mockResolvedValue(null);

    await expect(service.getRequestForVendor('req-3', 'vendor-not-matched')).rejects.toMatchObject({
      status: 404,
    });
  });

  it('serves vendor request view without customer identity when matched', async () => {
    const fakeRequest = {
      id: 'req-4',
      reference: 'REQ-4',
      requestType: RequestType.FIND_ORNAMENT,
      direction: Direction.BUY,
      state: RequestState.PUBLISHED,
      categoryId: 'cat-1',
      regionId: 'reg-1',
      weightGrams: new Prisma.Decimal('12.50'),
      weightIsApproximate: false,
      purityKarat: Karat.K22,
      budgetMin: null,
      budgetMax: null,
      budgetIsFlexible: true,
      indicativeValue: null,
      notes: 'Test request',
      gemstones: null,
      publishedAt: new Date(),
      expiresAt: new Date(Date.now() + 1000000),
      offerCount: 1,
      createdAt: new Date(),
      updatedAt: new Date(),
      region: { nameEn: 'Dubai' },
    } as unknown as Request;

    vi.mocked(fakeRepo.findById).mockResolvedValue(fakeRequest);
    fakeRepo.findVendorMatch = vi.fn().mockResolvedValue({
      id: 'match-1',
      requestId: 'req-4',
      vendorProfileId: 'vendor-1',
      isEligible: true,
      viewedAt: null,
    });

    const result = await service.getRequestForVendor('req-4', 'vendor-1');
    expect(result.id).toBe('req-4');
    expect(result.offerCount).toBe(1);
    expect(result.customer.label).toBe('Customer in Dubai');
    // Ensure identity keys are absent
    expect((result as Record<string, unknown>).mobileNumber).toBeUndefined();
    expect((result as Record<string, unknown>).customerName).toBeUndefined();
    expect((result as Record<string, unknown>).customerProfileId).toBeUndefined();
  });
});
