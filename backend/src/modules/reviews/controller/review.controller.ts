import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodBody, zodQuery } from '../../../edge/validation/zod-validation.pipe';
import { ReviewService } from '../application/review.service';

const createReviewSchema = z.object({
  rating: z.number().int().min(1).max(5),
  comment: z.string().trim().max(1000).optional(),
});

const listReviewsQuerySchema = z.object({
  role: z.enum(['AUTHOR', 'SUBJECT']).optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
  cursor: z.string().uuid().optional(),
});

const patchReviewSchema = z
  .object({
    rating: z.number().int().min(1).max(5).optional(),
    comment: z.string().trim().max(1000).optional(),
  })
  .refine((v) => Object.keys(v).length > 0, {
    message: 'At least one field is required to update.',
  });

const respondReviewSchema = z.object({
  response: z.string().trim().min(1).max(500),
});

@Controller('v1')
export class ReviewController {
  constructor(private readonly reviewService: ReviewService) {}

  @Post('connections/:id/reviews')
  @HttpCode(HttpStatus.CREATED)
  async createReview(
    @Viewer() viewer: ViewerContext,
    @Param('id') connectionId: string,
    @Body(zodBody(createReviewSchema)) body: z.infer<typeof createReviewSchema>,
  ) {
    const data = await this.reviewService.createReview(
      viewer,
      connectionId,
      body.rating,
      body.comment,
    );
    return { data };
  }

  @Get('me/reviews')
  async listMyReviews(
    @Viewer() viewer: ViewerContext,
    @Query(zodQuery(listReviewsQuerySchema))
    query: z.infer<typeof listReviewsQuerySchema>,
  ) {
    return this.reviewService.listMyReviews(viewer, query);
  }

  @Patch('reviews/:id')
  async updateReview(
    @Viewer() viewer: ViewerContext,
    @Param('id') reviewId: string,
    @Body(zodBody(patchReviewSchema)) body: z.infer<typeof patchReviewSchema>,
  ) {
    const data = await this.reviewService.updateReview(viewer, reviewId, body);
    return { data };
  }

  @Post('reviews/:id/withdraw')
  async withdrawReview(
    @Viewer() viewer: ViewerContext,
    @Param('id') reviewId: string,
  ) {
    const data = await this.reviewService.withdrawReview(viewer, reviewId);
    return { data };
  }

  @Post('reviews/:id/response')
  async respondToReview(
    @Viewer() viewer: ViewerContext,
    @Param('id') reviewId: string,
    @Body(zodBody(respondReviewSchema)) body: z.infer<typeof respondReviewSchema>,
  ) {
    const data = await this.reviewService.respondToReview(
      viewer,
      reviewId,
      body.response,
    );
    return { data };
  }

  @Post('reviews/:id/flag')
  async flagReview(
    @Viewer() viewer: ViewerContext,
    @Param('id') reviewId: string,
  ) {
    const data = await this.reviewService.flagReview(viewer, reviewId);
    return { data };
  }
}
