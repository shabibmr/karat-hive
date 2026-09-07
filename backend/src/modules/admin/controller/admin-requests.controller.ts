import {
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  Post,
  Query,
  Req,
} from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import { Direction, RequestState, RequestType } from '@prisma/client';
import { z } from 'zod';
import { AdminOnly } from '../../../edge/auth/admin-only.decorator';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { clientInfoOf } from '../../../edge/client-ip';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import {
  ZodValidationPipe,
  zodBody,
  zodQuery,
} from '../../../edge/validation/zod-validation.pipe';
import { AdminRequestsService } from '../application/admin-requests.service';
import type {
  AdminRequestDetail,
  AdminRequestListPage,
} from '../presenter/admin-requests.presenter';
import type { AdminNoteView } from '../presenter/admin-vendor.presenter';

export const requestIdParam = new ZodValidationPipe(z.string().uuid());

export const adminRequestListQuerySchema = z.object({
  requestType: z.nativeEnum(RequestType).optional(),
  direction: z.nativeEnum(Direction).optional(),
  state: z.nativeEnum(RequestState).optional(),
  categoryId: z.string().uuid().optional(),
  regionId: z.string().uuid().optional(),
  valueMin: z.coerce.number().min(0).optional(),
  valueMax: z.coerce.number().min(0).optional(),
  zeroOffers: z
    .union([z.boolean(), z.enum(['true', 'false'])])
    .transform((val) => (typeof val === 'boolean' ? val : val === 'true'))
    .optional(),
  q: z.string().max(200).optional(),
  cursor: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
  page: z.coerce.number().int().min(1).optional(),
});

export const removeRequestSchema = z.object({
  reasonCode: z.string().trim().max(100).optional(),
  reasonText: z.string().trim().min(1, 'reasonText is required').max(2000),
  policyClause: z.string().trim().max(500).optional(),
});

export const addRequestNoteSchema = z.union([
  z.object({
    content: z.string().trim().min(1, 'content is required').max(4000),
  }),
  z
    .object({
      text: z.string().trim().min(1, 'text is required').max(4000),
    })
    .transform((val) => ({ content: val.text })),
]);

@Controller('v1/admin/requests')
@AdminOnly()
@RevealsIdentity()
export class AdminRequestsController {
  constructor(private readonly service: AdminRequestsService) {}

  @Get()
  listRequests(
    @Query(zodQuery(adminRequestListQuerySchema))
    query: z.infer<typeof adminRequestListQuerySchema>,
  ): Promise<AdminRequestListPage> {
    return this.service.listRequests(query, {
      cursor: query.cursor,
      limit: query.limit,
      page: query.page,
    });
  }

  @Get(':id')
  getRequest(
    @Param('id', requestIdParam) id: string,
  ): Promise<AdminRequestDetail> {
    return this.service.getRequestDetail(id);
  }

  @Post(':id/remove')
  @HttpCode(200)
  removeRequest(
    @Param('id', requestIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Req() request: FastifyRequest,
    @Body(zodBody(removeRequestSchema))
    body: z.infer<typeof removeRequestSchema>,
  ): Promise<AdminRequestDetail> {
    const client = clientInfoOf(request);
    return this.service.removeRequest(
      id,
      viewer.userId,
      body,
      client.ip ?? undefined,
    );
  }

  @Post(':id/notes')
  @HttpCode(201)
  addNote(
    @Param('id', requestIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(addRequestNoteSchema))
    body: z.infer<typeof addRequestNoteSchema>,
  ): Promise<AdminNoteView> {
    return this.service.addNote(id, viewer.userId, body.content);
  }
}
