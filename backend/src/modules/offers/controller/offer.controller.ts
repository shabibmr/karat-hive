import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodBody, zodQuery } from '../../../edge/validation/zod-validation.pipe';
import { OfferService } from '../application/offer.service';
import {
  declineOfferSchema,
  reviseOfferSchema,
  submitOfferSchema,
  type DeclineOfferInput,
  type ReviseOfferInput,
  type SubmitOfferInput,
} from '../domain/offer-validator';

const listRequestOffersQuerySchema = z.object({
  sort: z.enum(['PRICE_ASC', 'PRICE_DESC', 'RATING', 'NEWEST', 'OLDEST', 'EXPIRING']).optional(),
  minRating: z.coerce.number().optional(),
  priceMin: z.coerce.number().optional(),
  priceMax: z.coerce.number().optional(),
  excludeExpiringWithinHours: z.coerce.number().int().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
  cursor: z.string().uuid().optional(),
});

const listVendorOffersQuerySchema = z.object({
  tab: z.enum(['PENDING', 'ACCEPTED', 'CLOSED']).optional(),
  requestType: z.enum(['FIND_ORNAMENT', 'SELL_OLD_GOLD', 'GOLD_COIN', 'GOLD_BULLION']).optional(),
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
  q: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
  cursor: z.string().uuid().optional(),
});

@Controller('v1')
export class OfferController {
  constructor(private readonly offerService: OfferService) {}

  @Post('requests/:id/offers')
  @HttpCode(HttpStatus.CREATED)
  async submitOffer(
    @Viewer() viewer: ViewerContext,
    @Param('id') requestId: string,
    @Body(zodBody(submitOfferSchema)) body: SubmitOfferInput,
  ) {
    const data = await this.offerService.submitOffer(viewer, requestId, body);
    return { data };
  }

  @Get('requests/:id/offers')
  async listOffersForRequest(
    @Viewer() viewer: ViewerContext,
    @Param('id') requestId: string,
    @Query(zodQuery(listRequestOffersQuerySchema)) query: z.infer<typeof listRequestOffersQuerySchema>,
  ) {
    return this.offerService.listOffersForRequest(viewer, requestId, query);
  }

  @Get('me/offers')
  async listMyOffers(
    @Viewer() viewer: ViewerContext,
    @Query(zodQuery(listVendorOffersQuerySchema)) query: z.infer<typeof listVendorOffersQuerySchema>,
  ) {
    return this.offerService.listMyOffers(viewer, query);
  }

  @Get('offers/:id')
  async getOfferById(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ) {
    const data = await this.offerService.getOfferById(viewer, id);
    return { data };
  }

  @Get('offers/:id/vendor-rating')
  async getVendorRating(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ) {
    const data = await this.offerService.getVendorRating(viewer, id);
    return { data };
  }

  @Post('offers/:id/revise')
  @HttpCode(HttpStatus.OK)
  async reviseOffer(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(reviseOfferSchema)) body: ReviseOfferInput,
  ) {
    const data = await this.offerService.reviseOffer(viewer, id, body);
    return { data };
  }

  @Post('offers/:id/withdraw')
  @HttpCode(HttpStatus.OK)
  async withdrawOffer(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ) {
    const data = await this.offerService.withdrawOffer(viewer, id);
    return { data };
  }

  @Post('offers/:id/decline')
  @HttpCode(HttpStatus.OK)
  async declineOffer(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(declineOfferSchema)) body: DeclineOfferInput,
  ) {
    const data = await this.offerService.declineOffer(viewer, id, body);
    return { data };
  }

  @Post('offers/:id/viewed')
  @HttpCode(HttpStatus.NO_CONTENT)
  async markOfferViewed(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ) {
    await this.offerService.markOfferViewed(viewer, id);
  }
}
