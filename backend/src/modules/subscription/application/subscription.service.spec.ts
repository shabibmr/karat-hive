import { describe, expect, it, vi } from 'vitest';
import type { VendorProfile, VendorTypeSubscription } from '@prisma/client';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';
import { SubscriptionService } from './subscription.service';
import { SubscriptionRepository } from '../repository/subscription.repository';

describe('SubscriptionService', () => {
  const mockRepo = {
    findVendorProfileByUserId: vi.fn(),
    findVendorProfileById: vi.fn(),
    listSubscriptionsForVendor: vi.fn(),
    findActiveOrGraceByVendorAndType: vi.fn(),
    createSubscription: vi.fn(),
    updateSubscription: vi.fn(),
    getVendorPerformance: vi.fn(),
  } as unknown as SubscriptionRepository;

  const mockPrisma = {
    $transaction: vi.fn().mockImplementation((cb) => cb(mockPrisma)),
    outboxEvent: {
      create: vi.fn().mockResolvedValue({ id: 'outbox-1' }),
    },
  } as unknown as PrismaService;

  const mockAudit = {
    append: vi.fn().mockResolvedValue(undefined),
  } as unknown as AuditWriter;

  const service = new SubscriptionService(mockRepo, mockPrisma, mockAudit);

  it('rejects non-vendor for getMySubscriptions', async () => {
    await expect(
      service.getMySubscriptions({
        userId: 'cust-1',
        role: 'CUSTOMER',
        accountState: 'ACTIVE',
      }),
    ).rejects.toMatchObject({
      errorCode: 'FORBIDDEN',
      status: 403,
    });
  });

  it('returns empty array when vendor has no subscriptions', async () => {
    vi.mocked(mockRepo.findVendorProfileByUserId).mockResolvedValueOnce({
      id: 'vendor-prof-1',
    } as unknown as VendorProfile);
    vi.mocked(mockRepo.listSubscriptionsForVendor).mockResolvedValueOnce([]);

    const result = await service.getMySubscriptions({
      userId: 'user-1',
      role: 'VENDOR',
      accountState: 'ACTIVE',
    });

    expect(result).toEqual([]);
  });

  it('grants subscription by admin and emits outbox + audit', async () => {
    vi.mocked(mockRepo.findVendorProfileById).mockResolvedValueOnce({
      id: 'vendor-prof-1',
    } as unknown as VendorProfile);
    vi.mocked(mockRepo.createSubscription).mockResolvedValueOnce({
      id: 'sub-1',
      vendorProfileId: 'vendor-prof-1',
      requestType: 'FIND_ORNAMENT',
      state: 'ACTIVE',
      periodStart: new Date('2026-01-01T00:00:00Z'),
      periodEnd: new Date('2026-02-01T00:00:00Z'),
      priceAed: 500,
      paymentReference: 'INV-123',
      graceEndsAt: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    } as unknown as VendorTypeSubscription);

    const result = await service.grantSubscriptionByAdmin(
      'vendor-prof-1',
      {
        requestType: 'FIND_ORNAMENT',
        periodStart: new Date('2026-01-01T00:00:00Z'),
        periodEnd: new Date('2026-02-01T00:00:00Z'),
        priceAed: '500.00',
        paymentReference: 'INV-123',
      },
      'admin-1',
    );

    expect(result.id).toBe('sub-1');
    expect(result.state).toBe('ACTIVE');
    expect(mockPrisma.outboxEvent.create).toHaveBeenCalled();
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        action: 'VENDOR_SUBSCRIPTION_GRANTED',
      }),
    );
  });

  it('patches subscription by admin and emits outbox + audit', async () => {
    vi.mocked(mockRepo.findActiveOrGraceByVendorAndType).mockResolvedValueOnce({
      id: 'sub-1',
      vendorProfileId: 'vendor-prof-1',
      requestType: 'FIND_ORNAMENT',
      state: 'ACTIVE',
      periodStart: new Date('2026-01-01T00:00:00Z'),
      periodEnd: new Date('2026-02-01T00:00:00Z'),
      priceAed: 500,
      graceEndsAt: null,
    } as unknown as VendorTypeSubscription);

    vi.mocked(mockRepo.updateSubscription).mockResolvedValueOnce({
      id: 'sub-1',
      vendorProfileId: 'vendor-prof-1',
      requestType: 'FIND_ORNAMENT',
      state: 'CANCELLED',
      periodStart: new Date('2026-01-01T00:00:00Z'),
      periodEnd: new Date('2026-02-01T00:00:00Z'),
      priceAed: 500,
      graceEndsAt: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    } as unknown as VendorTypeSubscription);

    const result = await service.patchSubscriptionByAdmin(
      'vendor-prof-1',
      'FIND_ORNAMENT',
      {
        state: 'CANCELLED',
        reasonText: 'Vendor requested cancellation',
      },
      'admin-1',
    );

    expect(result.state).toBe('CANCELLED');
    expect(mockPrisma.outboxEvent.create).toHaveBeenCalled();
    expect(mockAudit.append).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        action: 'VENDOR_SUBSCRIPTION_PATCHED',
      }),
    );
  });
});
