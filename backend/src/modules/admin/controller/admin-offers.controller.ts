import {
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { OfferState, RequestType } from '@prisma/client';
import { z } from 'zod';
import { AdminOnly } from '../../../edge/auth/admin-only.decorator';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import {
  ZodValidationPipe,
  zodBody,
  zodQuery,
} from '../../../edge/validation/zod-validation.pipe';
import { AdminOffersService } from '../application/admin-offers.service';
import type {
  AdminOfferDetail,
  AdminOfferListPage,
} from '../presenter/admin-offers.presenter';
import type { AdminNoteView } from '../presenter/admin-vendor.presenter';

export const offerIdParam = new ZodValidationPipe(z.string().uuid());

export const adminOfferListQuerySchema = z.object({
  state: z.nativeEnum(OfferState).optional(),
  vendorId: z.string().uuid().optional(),
  requestType: z.nativeEnum(RequestType).optional(),
  priceMin: z.coerce.number().min(0).optional(),
  priceMax: z.coerce.number().min(0).optional(),
  cursor: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
  page: z.coerce.number().int().min(1).optional(),
});

export const addOfferNoteSchema = z.union([
  z.object({
    content: z.string().trim().min(1, 'content is required').max(4000),
  }),
  z
    .object({
      text: z.string().trim().min(1, 'text is required').max(4000),
    })
    .transform((val) => ({ content: val.text })),
]);

@Controller('v1/admin/offers')
@AdminOnly()
@RevealsIdentity()
export class AdminOffersController {
  constructor(private readonly service: AdminOffersService) {}

  @Get()
  listOffers(
    @Query(zodQuery(adminOfferListQuerySchema))
    query: z.infer<typeof adminOfferListQuerySchema>,
  ): Promise<AdminOfferListPage> {
    return this.service.listOffers(query, {
      cursor: query.cursor,
      limit: query.limit,
      page: query.page,
    });
  }

  @Get(':id')
  getOffer(
    @Param('id', offerIdParam) id: string,
  ): Promise<AdminOfferDetail> {
    return this.service.getOfferDetail(id);
  }

  @Post(':id/notes')
  @HttpCode(201)
  addNote(
    @Param('id', offerIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(addOfferNoteSchema))
    body: z.infer<typeof addOfferNoteSchema>,
  ): Promise<AdminNoteView> {
    return this.service.addNote(id, viewer.userId, body.content);
  }
}
