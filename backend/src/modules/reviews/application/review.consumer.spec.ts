import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { OutboxDispatcher } from '../../../platform/outbox/outbox.dispatcher';
import type { ReviewRepository } from '../repository/review.repository';
import { ReviewConsumer } from './review.consumer';
import type { ReviewService } from './review.service';

describe('ReviewConsumer', () => {
  const register = vi.fn();
  const recalculateRatings = vi.fn();
  const findReviewById = vi.fn();

  let consumer: ReviewConsumer;

  beforeEach(() => {
    register.mockReset();
    recalculateRatings.mockReset();
    findReviewById.mockReset();
    consumer = new ReviewConsumer(
      { register } as unknown as OutboxDispatcher,
      { recalculateRatings } as unknown as ReviewService,
      { findReviewById } as unknown as ReviewRepository,
    );
  });

  it('registers reviews:rating-recompute on review.published and review.moderated', () => {
    consumer.onModuleInit();

    expect(register).toHaveBeenCalledWith(
      'review.published',
      'reviews:rating-recompute',
      expect.any(Function),
    );
    expect(register).toHaveBeenCalledWith(
      'review.moderated',
      'reviews:rating-recompute',
      expect.any(Function),
    );
  });

  it('recomputes from subjectUserId on review.published', async () => {
    await consumer.handle({
      id: 'evt-1',
      eventType: 'review.published',
      aggregateType: 'review',
      aggregateId: 'rev-1',
      payload: { reviewId: 'rev-1', subjectUserId: 'vend-1' },
      attempts: 0,
    });

    expect(recalculateRatings).toHaveBeenCalledWith('vend-1');
    expect(findReviewById).not.toHaveBeenCalled();
  });

  it('loads review for review.moderated when subjectUserId absent', async () => {
    findReviewById.mockResolvedValueOnce({ subjectUserId: 'vend-1' });

    await consumer.handle({
      id: 'evt-2',
      eventType: 'review.moderated',
      aggregateType: 'review',
      aggregateId: 'rev-1',
      payload: { reviewId: 'rev-1', decision: 'REJECTED' },
      attempts: 0,
    });

    expect(findReviewById).toHaveBeenCalledWith('rev-1');
    expect(recalculateRatings).toHaveBeenCalledWith('vend-1');
  });
});
