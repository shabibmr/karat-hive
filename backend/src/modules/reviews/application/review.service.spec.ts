import { describe, expect, it, vi } from 'vitest';
import type { Connection, Review } from '@prisma/client';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';
import { Clock } from '../../../shared/clock';
import { ReviewService } from './review.service';
import { ReviewRepository } from '../repository/review.repository';

describe('ReviewService', () => {
  const mockRepo = {
    findConnection: vi.fn(),
    findReviewById: vi.fn(),
    findReviewByConnectionAndAuthorType: vi.fn(),
    createReview: vi.fn(),
    listReviewsForUser: vi.fn(),
    updateReview: vi.fn(),
    withdrawReview: vi.fn(),
    addVendorResponse: vi.fn(),
    moderateReview: vi.fn(),
    recalculateRatings: vi.fn(),
    listSubjectsForReconcile: vi.fn(),
  } as unknown as ReviewRepository;

  const mockPrisma = {
    $transaction: vi.fn().mockImplementation((cb) => cb(mockPrisma)),
    outboxEvent: {
      create: vi.fn().mockResolvedValue({ id: 'outbox-1' }),
    },
    abuseReport: {
      create: vi.fn().mockResolvedValue({ id: 'abuse-1' }),
    },
  } as unknown as PrismaService;

  const mockAudit = {
    append: vi.fn().mockResolvedValue(undefined),
  } as unknown as AuditWriter;

  const mockClock = {
    now: () => new Date('2026-03-01T12:00:00Z'),
  } as Clock;

  const service = new ReviewService(mockRepo, mockPrisma, mockAudit, mockClock);

  it('rejects if viewer is not a party to connection', async () => {
    vi.mocked(mockRepo.findConnection).mockResolvedValueOnce({
      id: 'conn-1',
      request: { customerProfile: { userId: 'cust-1' } },
      offer: { vendorProfile: { userId: 'vend-1' } },
    } as unknown as Connection & {
      request: { customerProfile: { userId: string } };
      offer: { vendorProfile: { userId: string } };
    });

    await expect(
      service.createReview(
        { userId: 'stranger', role: 'CUSTOMER', accountState: 'ACTIVE' },
        'conn-1',
        5,
      ),
    ).rejects.toMatchObject({
      errorCode: 'NOT_A_PARTY',
      status: 403,
    });
  });

  it('rejects duplicate review on same connection by same party (BR-017)', async () => {
    vi.mocked(mockRepo.findConnection).mockResolvedValueOnce({
      id: 'conn-1',
      request: { customerProfile: { userId: 'cust-1' } },
      offer: { vendorProfile: { userId: 'vend-1' } },
    } as unknown as Connection & {
      request: { customerProfile: { userId: string } };
      offer: { vendorProfile: { userId: string } };
    });
    vi.mocked(mockRepo.findReviewByConnectionAndAuthorType).mockResolvedValueOnce({
      id: 'rev-1',
    } as unknown as Review);

    await expect(
      service.createReview(
        { userId: 'cust-1', role: 'CUSTOMER', accountState: 'ACTIVE' },
        'conn-1',
        5,
      ),
    ).rejects.toMatchObject({
      errorCode: 'REVIEW_ALREADY_EXISTS',
      status: 409,
    });
  });

  it('creates review with 14-day edit window and audit', async () => {
    vi.mocked(mockRepo.findConnection).mockResolvedValueOnce({
      id: 'conn-1',
      request: { customerProfile: { userId: 'cust-1' } },
      offer: { vendorProfile: { userId: 'vend-1' } },
    } as unknown as Connection & {
      request: { customerProfile: { userId: string } };
      offer: { vendorProfile: { userId: string } };
    });
    vi.mocked(mockRepo.findReviewByConnectionAndAuthorType).mockResolvedValueOnce(null);
    vi.mocked(mockRepo.createReview).mockResolvedValueOnce({
      id: 'rev-1',
      connectionId: 'conn-1',
      authorType: 'CUSTOMER',
      authorUserId: 'cust-1',
      subjectUserId: 'vend-1',
      rating: 5,
      comment: 'Great craftsmanship!',
      state: 'PENDING_MODERATION',
      editableUntil: new Date('2026-03-15T12:00:00Z'),
      createdAt: new Date('2026-03-01T12:00:00Z'),
      author: { customerProfile: { displayName: 'Alice' } },
    } as unknown as Review);

    const result = await service.createReview(
      { userId: 'cust-1', role: 'CUSTOMER', accountState: 'ACTIVE' },
      'conn-1',
      5,
      'Great craftsmanship!',
    );

    expect(result.id).toBe('rev-1');
    expect(result.state).toBe('PENDING_MODERATION');
    expect(result.editableUntil).toBe('2026-03-15T12:00:00.000Z');
    expect(mockAudit.append).toHaveBeenCalled();
  });

  it('rejects editing after 14 days (FR-CUS-030)', async () => {
    vi.mocked(mockRepo.findReviewById).mockResolvedValueOnce({
      id: 'rev-1',
      authorUserId: 'cust-1',
      editableUntil: new Date('2026-02-01T00:00:00Z'),
    } as unknown as Review);

    await expect(
      service.updateReview(
        { userId: 'cust-1', role: 'CUSTOMER', accountState: 'ACTIVE' },
        'rev-1',
        { rating: 4 },
      ),
    ).rejects.toMatchObject({
      errorCode: 'REVIEW_EDIT_WINDOW_CLOSED',
      status: 409,
    });
  });

  it('approves review by admin, emitting review.published and review.moderated', async () => {
    vi.mocked(mockRepo.findReviewById).mockResolvedValueOnce({
      id: 'rev-1',
      connectionId: 'conn-1',
      subjectUserId: 'vend-1',
      authorType: 'CUSTOMER',
      rating: 5,
    } as unknown as Review);

    vi.mocked(mockRepo.moderateReview).mockResolvedValueOnce({
      id: 'rev-1',
      connectionId: 'conn-1',
      authorType: 'CUSTOMER',
      authorUserId: 'cust-1',
      subjectUserId: 'vend-1',
      rating: 5,
      state: 'PUBLISHED',
      editableUntil: new Date('2026-03-15T12:00:00Z'),
      createdAt: new Date('2026-03-01T12:00:00Z'),
      publishedAt: new Date('2026-03-01T12:00:00Z'),
    } as unknown as Review);

    const result = await service.approveReviewByAdmin('rev-1', 'admin-1');

    expect(result.state).toBe('PUBLISHED');
    expect(mockPrisma.outboxEvent.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          eventType: 'review.published',
        }),
      }),
    );
    expect(mockRepo.recalculateRatings).toHaveBeenCalledWith(
      'vend-1',
      new Date('2026-03-01T12:00:00Z'),
    );
  });

  it('reconcileRatings recomputes every listed subject (G2-F03)', async () => {
    vi.mocked(mockRepo.listSubjectsForReconcile).mockResolvedValueOnce([
      'vend-1',
      'cust-1',
    ]);
    vi.mocked(mockRepo.recalculateRatings).mockResolvedValue(undefined);

    const count = await service.reconcileRatings();

    expect(count).toBe(2);
    expect(mockRepo.recalculateRatings).toHaveBeenCalledWith(
      'vend-1',
      new Date('2026-03-01T12:00:00Z'),
    );
    expect(mockRepo.recalculateRatings).toHaveBeenCalledWith(
      'cust-1',
      new Date('2026-03-01T12:00:00Z'),
    );
  });

  it('first vendor response is held PENDING_MODERATION (CP5-A04)', async () => {
    vi.mocked(mockRepo.findReviewById).mockResolvedValueOnce({
      id: 'rev-1',
      subjectUserId: 'vend-1',
      authorUserId: 'cust-1',
      state: 'PUBLISHED',
      vendorResponse: null,
      vendorResponseState: null,
    } as unknown as Review);

    vi.mocked(mockRepo.addVendorResponse).mockResolvedValueOnce({
      id: 'rev-1',
      connectionId: 'conn-1',
      authorType: 'CUSTOMER',
      authorUserId: 'cust-1',
      subjectUserId: 'vend-1',
      rating: 5,
      state: 'PUBLISHED',
      vendorResponse: 'Thank you for your feedback.',
      vendorResponseState: 'PENDING_MODERATION',
      editableUntil: new Date('2026-03-15T12:00:00Z'),
      createdAt: new Date('2026-03-01T12:00:00Z'),
      publishedAt: new Date('2026-03-01T12:00:00Z'),
    } as unknown as Review);

    const result = await service.respondToReview(
      { userId: 'vend-1', role: 'VENDOR', accountState: 'ACTIVE' },
      'rev-1',
      'Thank you for your feedback.',
    );

    expect(result.id).toBe('rev-1');
    expect(mockRepo.addVendorResponse).toHaveBeenCalledWith(
      mockPrisma,
      'rev-1',
      'Thank you for your feedback.',
    );
  });

  it('second vendor response attempt returns CONFLICT (CP5-A04)', async () => {
    vi.mocked(mockRepo.addVendorResponse).mockClear();
    vi.mocked(mockRepo.findReviewById).mockResolvedValueOnce({
      id: 'rev-1',
      subjectUserId: 'vend-1',
      authorUserId: 'cust-1',
      state: 'PUBLISHED',
      vendorResponse: 'Already replied.',
      vendorResponseState: 'PENDING_MODERATION',
    } as unknown as Review);

    await expect(
      service.respondToReview(
        { userId: 'vend-1', role: 'VENDOR', accountState: 'ACTIVE' },
        'rev-1',
        'Trying again.',
      ),
    ).rejects.toMatchObject({
      errorCode: 'CONFLICT',
      status: 409,
    });
    expect(mockRepo.addVendorResponse).not.toHaveBeenCalled();
  });
});
