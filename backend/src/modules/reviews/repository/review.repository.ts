import { Injectable } from '@nestjs/common';
import type { AuthorType, Prisma, Review, ReviewState } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import {
  averageRating,
  buildSixMonthRatingTrend,
} from '../domain/rating-aggregates';

@Injectable()
export class ReviewRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findConnection(connectionId: string) {
    return this.prisma.connection.findUnique({
      where: { id: connectionId },
      include: {
        request: {
          include: {
            customerProfile: true,
          },
        },
        offer: {
          include: {
            vendorProfile: true,
          },
        },
      },
    });
  }

  async findReviewById(id: string) {
    return this.prisma.review.findUnique({
      where: { id },
      include: {
        author: {
          include: {
            customerProfile: { select: { displayName: true } },
            vendorProfile: { select: { tradingName: true } },
          },
        },
      },
    });
  }

  async findReviewByConnectionAndAuthorType(
    connectionId: string,
    authorType: AuthorType,
  ): Promise<Review | null> {
    return this.prisma.review.findUnique({
      where: {
        connectionId_authorType: {
          connectionId,
          authorType,
        },
      },
    });
  }

  async createReview(
    tx: Prisma.TransactionClient,
    data: {
      connectionId: string;
      authorType: AuthorType;
      authorUserId: string;
      subjectUserId: string;
      rating: number;
      comment?: string | null;
      state: ReviewState;
      editableUntil: Date;
    },
  ): Promise<Review> {
    return tx.review.create({
      data: {
        connectionId: data.connectionId,
        authorType: data.authorType,
        authorUserId: data.authorUserId,
        subjectUserId: data.subjectUserId,
        rating: data.rating,
        comment: data.comment,
        state: data.state,
        editableUntil: data.editableUntil,
      },
      include: {
        author: {
          include: {
            customerProfile: { select: { displayName: true } },
            vendorProfile: { select: { tradingName: true } },
          },
        },
      },
    });
  }

  async listReviewsForUser(
    userId: string,
    options: {
      role?: 'AUTHOR' | 'SUBJECT';
      limit?: number;
      cursor?: string;
    },
  ) {
    const limit = Math.min(options.limit ?? 20, 50);

    const where: Prisma.ReviewWhereInput =
      options.role === 'AUTHOR'
        ? { authorUserId: userId }
        : options.role === 'SUBJECT'
          ? { subjectUserId: userId, state: 'PUBLISHED' }
          : {
              OR: [
                { authorUserId: userId },
                { subjectUserId: userId, state: 'PUBLISHED' },
              ],
            };

    const reviews = await this.prisma.review.findMany({
      where,
      take: limit + 1,
      ...(options.cursor
        ? {
            cursor: { id: options.cursor },
            skip: 1,
          }
        : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        author: {
          include: {
            customerProfile: { select: { displayName: true } },
            vendorProfile: { select: { tradingName: true } },
          },
        },
      },
    });

    let nextCursor: string | undefined;
    if (reviews.length > limit) {
      const nextItem = reviews.pop();
      nextCursor = nextItem?.id;
    }

    return { reviews, nextCursor };
  }

  async updateReview(
    tx: Prisma.TransactionClient,
    id: string,
    data: {
      rating?: number;
      comment?: string | null;
      state?: ReviewState;
    },
  ) {
    return tx.review.update({
      where: { id },
      data: {
        ...(data.rating !== undefined ? { rating: data.rating } : {}),
        ...(data.comment !== undefined ? { comment: data.comment } : {}),
        ...(data.state ? { state: data.state } : {}),
      },
      include: {
        author: {
          include: {
            customerProfile: { select: { displayName: true } },
            vendorProfile: { select: { tradingName: true } },
          },
        },
      },
    });
  }

  async withdrawReview(tx: Prisma.TransactionClient, id: string) {
    return tx.review.update({
      where: { id },
      data: { state: 'WITHDRAWN' },
      include: {
        author: {
          include: {
            customerProfile: { select: { displayName: true } },
            vendorProfile: { select: { tradingName: true } },
          },
        },
      },
    });
  }

  async addVendorResponse(
    tx: Prisma.TransactionClient,
    id: string,
    vendorResponse: string,
  ) {
    return tx.review.update({
      where: { id },
      data: {
        vendorResponse,
        vendorResponseState: 'PENDING_MODERATION',
      },
      include: {
        author: {
          include: {
            customerProfile: { select: { displayName: true } },
            vendorProfile: { select: { tradingName: true } },
          },
        },
      },
    });
  }

  async moderateReview(
    tx: Prisma.TransactionClient,
    id: string,
    data: {
      state: ReviewState;
      comment?: string;
      moderatedByAdminId: string;
      publishedAt?: Date | null;
    },
  ) {
    return tx.review.update({
      where: { id },
      data: {
        state: data.state,
        ...(data.comment !== undefined ? { comment: data.comment } : {}),
        moderatedByAdminId: data.moderatedByAdminId,
        ...(data.publishedAt !== undefined ? { publishedAt: data.publishedAt } : {}),
      },
      include: {
        author: {
          include: {
            customerProfile: { select: { displayName: true } },
            vendorProfile: { select: { tradingName: true } },
          },
        },
      },
    });
  }

  async listReviewsForAdmin(options: {
    state?: ReviewState;
    limit?: number;
    cursor?: string;
  }) {
    const limit = Math.min(options.limit ?? 20, 100);
    const where: Prisma.ReviewWhereInput = options.state ? { state: options.state } : {};

    const reviews = await this.prisma.review.findMany({
      where,
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        author: {
          include: {
            customerProfile: { select: { displayName: true } },
            vendorProfile: { select: { tradingName: true } },
          },
        },
      },
    });

    let nextCursor: string | undefined;
    if (reviews.length > limit) {
      const nextItem = reviews.pop();
      nextCursor = nextItem?.id;
    }

    return { reviews, nextCursor };
  }

  /** Subjects with PUBLISHED reviews or non-zero denormalised aggregates (G2-F03). */
  async listSubjectsForReconcile(): Promise<string[]> {
    const [published, vendors, customers] = await Promise.all([
      this.prisma.review.findMany({
        where: { state: 'PUBLISHED' },
        select: { subjectUserId: true },
        distinct: ['subjectUserId'],
      }),
      this.prisma.vendorProfile.findMany({
        where: {
          OR: [{ reviewCount: { gt: 0 } }, { aggregateRating: { not: null } }],
        },
        select: { userId: true },
      }),
      this.prisma.customerProfile.findMany({
        where: {
          OR: [{ reviewCount: { gt: 0 } }, { aggregateRating: { not: null } }],
        },
        select: { userId: true },
      }),
    ]);

    return [
      ...new Set([
        ...published.map((r) => r.subjectUserId),
        ...vendors.map((v) => v.userId),
        ...customers.map((c) => c.userId),
      ]),
    ];
  }

  /**
   * Full recompute of denormalised aggregates + 6-month ratingTrend (FR-SYS-012).
   * Idempotent by construction — always derived from PUBLISHED reviews only.
   */
  async recalculateRatings(subjectUserId: string, now: Date = new Date()) {
    const publishedReviews = await this.prisma.review.findMany({
      where: {
        subjectUserId,
        state: 'PUBLISHED',
      },
      select: {
        rating: true,
        createdAt: true,
      },
    });

    const count = publishedReviews.length;
    const avg = averageRating(publishedReviews);

    const customer = await this.prisma.customerProfile.findUnique({
      where: { userId: subjectUserId },
    });
    if (customer) {
      await this.prisma.customerProfile.update({
        where: { id: customer.id },
        data: {
          aggregateRating: avg,
          reviewCount: count,
        },
      });
    }

    const vendor = await this.prisma.vendorProfile.findUnique({
      where: { userId: subjectUserId },
    });
    if (vendor) {
      const trend = buildSixMonthRatingTrend(publishedReviews, now);
      await this.prisma.vendorProfile.update({
        where: { id: vendor.id },
        data: {
          aggregateRating: avg,
          reviewCount: count,
          ratingTrend: trend,
        },
      });
    }
  }
}
