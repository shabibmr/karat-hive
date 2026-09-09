import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import type { ClaimedOutboxEvent } from '../../../platform/outbox/outbox.claimer';
import { OutboxDispatcher } from '../../../platform/outbox/outbox.dispatcher';
import { ReviewRepository } from '../repository/review.repository';
import { ReviewService } from './review.service';

const CONSUMER = 'reviews:rating-recompute';
const EVENT_TYPES = ['review.published', 'review.moderated'] as const;

/**
 * Async-Contract §4.15–4.16 / FR-SYS-012: recompute subject aggregates on
 * publish and moderation. Full recompute is naturally idempotent; the
 * `rating-reconcile` job remains the 5-minute safety net.
 */
@Injectable()
export class ReviewConsumer implements OnModuleInit {
  private readonly logger = new Logger(ReviewConsumer.name);

  constructor(
    private readonly dispatcher: OutboxDispatcher,
    private readonly reviews: ReviewService,
    private readonly repo: ReviewRepository,
  ) {}

  onModuleInit(): void {
    for (const eventType of EVENT_TYPES) {
      this.dispatcher.register(eventType, CONSUMER, (event) => this.handle(event));
    }
    this.logger.log(
      `Registered consumer ${CONSUMER} for ${EVENT_TYPES.join(', ')}`,
    );
  }

  async handle(event: ClaimedOutboxEvent): Promise<void> {
    const subjectUserId = await this.resolveSubjectUserId(event);
    if (!subjectUserId) {
      this.logger.warn(
        `Incomplete payload for ${event.eventType}: eventId=${event.id}`,
      );
      return;
    }

    await this.reviews.recalculateRatings(subjectUserId);
    this.logger.log(
      `${CONSUMER} completed for subject=${subjectUserId} eventType=${event.eventType}`,
    );
  }

  private async resolveSubjectUserId(
    event: ClaimedOutboxEvent,
  ): Promise<string | null> {
    const payload = event.payload as {
      subjectUserId?: string;
      subjectCustomerUserId?: string;
      reviewId?: string;
    } | null;

    if (payload?.subjectUserId) return payload.subjectUserId;
    if (payload?.subjectCustomerUserId) return payload.subjectCustomerUserId;

    const reviewId = payload?.reviewId ?? event.aggregateId;
    if (!reviewId) return null;

    const review = await this.repo.findReviewById(reviewId);
    return review?.subjectUserId ?? null;
  }
}
