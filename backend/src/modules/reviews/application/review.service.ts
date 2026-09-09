import { HttpStatus, Injectable } from '@nestjs/common';
import type { AuthorType, Prisma } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { Clock } from '../../../shared/clock';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { PrismaService } from '../../../platform/db/prisma.service';
import { AuditWriter } from '../../audit';
import { presentReview, type ReviewView } from '../presenter/review.presenter';
import { ReviewRepository } from '../repository/review.repository';

@Injectable()
export class ReviewService {
  constructor(
    private readonly repo: ReviewRepository,
    private readonly prisma: PrismaService,
    private readonly audit: AuditWriter,
    private readonly clock: Clock,
  ) {}

  async createReview(
    viewer: ViewerContext,
    connectionId: string,
    rating: number,
    comment?: string,
  ): Promise<ReviewView> {
    const connection = await this.repo.findConnection(connectionId);
    if (!connection) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const customerUserId = connection.request.customerProfile.userId;
    const vendorUserId = connection.offer.vendorProfile.userId;

    let authorType: AuthorType;
    let subjectUserId: string;

    if (viewer.userId === customerUserId) {
      authorType = 'CUSTOMER';
      subjectUserId = vendorUserId;
    } else if (viewer.userId === vendorUserId) {
      authorType = 'VENDOR';
      subjectUserId = customerUserId;
    } else {
      // Author must be a party (BR-016)
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.NOT_A_PARTY);
    }

    // At most one per party (BR-017)
    const existing = await this.repo.findReviewByConnectionAndAuthorType(
      connectionId,
      authorType,
    );
    if (existing) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.REVIEW_ALREADY_EXISTS);
    }

    const now = this.clock.now();
    const editableUntil = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000); // 14 days (FR-CUS-030)

    const review = await this.prisma.$transaction(
      async (tx: Prisma.TransactionClient) => {
        const created = await this.repo.createReview(tx, {
          connectionId,
          authorType,
          authorUserId: viewer.userId,
          subjectUserId,
          rating,
          comment: comment ?? null,
          state: 'PENDING_MODERATION',
          editableUntil,
        });

        await this.audit.append(tx, {
          actorUserId: viewer.userId,
          action: 'REVIEW_CREATED',
          entityType: 'review',
          entityId: created.id,
          afterValue: {
            rating,
            connectionId,
            authorType,
          },
        });

        return created;
      },
    );

    const presented = presentReview(review, viewer.userId);
    return presented!;
  }

  async listMyReviews(
    viewer: ViewerContext,
    options: {
      role?: 'AUTHOR' | 'SUBJECT';
      limit?: number;
      cursor?: string;
    },
  ) {
    const { reviews, nextCursor } = await this.repo.listReviewsForUser(
      viewer.userId,
      options,
    );

    const data = reviews
      .map((r) => presentReview(r, viewer.userId))
      .filter((r): r is ReviewView => r !== null);

    return {
      data,
      pagination: {
        nextCursor,
      },
    };
  }

  async updateReview(
    viewer: ViewerContext,
    reviewId: string,
    dto: { rating?: number; comment?: string },
  ): Promise<ReviewView> {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (review.authorUserId !== viewer.userId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    const now = this.clock.now();
    if (now > review.editableUntil) {
      throw new ApiException(
        HttpStatus.CONFLICT,
        ErrorCode.REVIEW_EDIT_WINDOW_CLOSED,
      );
    }

    const updated = await this.prisma.$transaction(
      async (tx: Prisma.TransactionClient) => {
        return this.repo.updateReview(tx, reviewId, {
          rating: dto.rating,
          comment: dto.comment,
          state: 'PENDING_MODERATION',
        });
      },
    );

    return presentReview(updated, viewer.userId)!;
  }

  async withdrawReview(
    viewer: ViewerContext,
    reviewId: string,
  ): Promise<ReviewView> {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (review.authorUserId !== viewer.userId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    const withdrawn = await this.prisma.$transaction(
      async (tx: Prisma.TransactionClient) => {
        return this.repo.withdrawReview(tx, reviewId);
      },
    );

    // Recompute subject rating
    await this.repo.recalculateRatings(review.subjectUserId, this.clock.now());

    return presentReview(withdrawn, viewer.userId)!;
  }

  async respondToReview(
    viewer: ViewerContext,
    reviewId: string,
    response: string,
  ): Promise<ReviewView> {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (review.subjectUserId !== viewer.userId || viewer.role !== 'VENDOR') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    if (review.state !== 'PUBLISHED') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT);
    }

    if (review.vendorResponse != null || review.vendorResponseState != null) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT);
    }

    const updated = await this.prisma.$transaction(
      async (tx: Prisma.TransactionClient) => {
        return this.repo.addVendorResponse(tx, reviewId, response);
      },
    );

    return presentReview(updated, viewer.userId)!;
  }

  async flagReview(viewer: ViewerContext, reviewId: string) {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (
      review.subjectUserId !== viewer.userId &&
      review.authorUserId !== viewer.userId
    ) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.NOT_A_PARTY);
    }

    await this.prisma.abuseReport.create({
      data: {
        reporterUserId: viewer.userId,
        reportedUserId: review.authorUserId,
        entityType: 'REVIEW',
        entityId: reviewId,
        category: 'FLAGGED_REVIEW',
        description: 'Review flagged by party for admin review.',
        state: 'OPEN',
      },
    });

    return { flagged: true };
  }

  async approveReviewByAdmin(reviewId: string, adminUserId: string) {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const now = this.clock.now();
    const updated = await this.prisma.$transaction(
      async (tx: Prisma.TransactionClient) => {
        const res = await this.repo.moderateReview(tx, reviewId, {
          state: 'PUBLISHED',
          publishedAt: now,
          moderatedByAdminId: adminUserId,
        });

        await enqueueOutbox(tx, {
          eventType: 'review.moderated',
          aggregateType: 'review',
          aggregateId: reviewId,
          payload: {
            reviewId,
            decision: 'APPROVED',
          },
        });

        await enqueueOutbox(tx, {
          eventType: 'review.published',
          aggregateType: 'review',
          aggregateId: reviewId,
          payload: {
            reviewId,
            connectionId: review.connectionId,
            subjectUserId: review.subjectUserId,
            authorType: review.authorType,
            rating: review.rating,
          },
        });

        await this.audit.append(tx, {
          actorUserId: adminUserId,
          action: 'REVIEW_APPROVED',
          entityType: 'review',
          entityId: reviewId,
          afterValue: { state: 'PUBLISHED' },
        });

        return res;
      },
    );

    await this.repo.recalculateRatings(review.subjectUserId, this.clock.now());
    return presentReview(updated)!;
  }

  async rejectReviewByAdmin(
    reviewId: string,
    rationale: string,
    adminUserId: string,
  ) {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const updated = await this.prisma.$transaction(
      async (tx: Prisma.TransactionClient) => {
        const res = await this.repo.moderateReview(tx, reviewId, {
          state: 'REJECTED',
          moderatedByAdminId: adminUserId,
        });

        await enqueueOutbox(tx, {
          eventType: 'review.moderated',
          aggregateType: 'review',
          aggregateId: reviewId,
          payload: {
            reviewId,
            decision: 'REJECTED',
            rationale,
          },
        });

        await this.audit.append(tx, {
          actorUserId: adminUserId,
          action: 'REVIEW_REJECTED',
          entityType: 'review',
          entityId: reviewId,
          afterValue: { state: 'REJECTED', rationale },
        });

        return res;
      },
    );

    await this.repo.recalculateRatings(review.subjectUserId, this.clock.now());
    return presentReview(updated)!;
  }

  async redactReviewByAdmin(
    reviewId: string,
    rationale: string,
    redactedComment: string,
    adminUserId: string,
  ) {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const updated = await this.prisma.$transaction(
      async (tx: Prisma.TransactionClient) => {
        const res = await this.repo.moderateReview(tx, reviewId, {
          state: 'REDACTED',
          comment: redactedComment,
          moderatedByAdminId: adminUserId,
        });

        await enqueueOutbox(tx, {
          eventType: 'review.moderated',
          aggregateType: 'review',
          aggregateId: reviewId,
          payload: {
            reviewId,
            decision: 'REDACTED',
            rationale,
          },
        });

        await this.audit.append(tx, {
          actorUserId: adminUserId,
          action: 'REVIEW_REDACTED',
          entityType: 'review',
          entityId: reviewId,
          afterValue: { state: 'REDACTED', rationale, redactedComment },
        });

        return res;
      },
    );

    return presentReview(updated)!;
  }

  async recalculateRatings(subjectUserId: string): Promise<void> {
    await this.repo.recalculateRatings(subjectUserId, this.clock.now());
  }

  /**
   * G2-F03 / `rating-reconcile`: full recompute safety net every 5 min.
   * Idempotent — aggregates always derived from PUBLISHED reviews (FR-SYS-012.3).
   */
  async reconcileRatings(): Promise<number> {
    const subjects = await this.repo.listSubjectsForReconcile();
    const now = this.clock.now();
    for (const subjectUserId of subjects) {
      await this.repo.recalculateRatings(subjectUserId, now);
    }
    return subjects.length;
  }
}
