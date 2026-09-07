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
import type { Direction, ItemCondition, Karat, OrnamentType, RequestState, RequestType } from '@prisma/client';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodBody, zodQuery } from '../../../edge/validation/zod-validation.pipe';
import { RequestService } from '../application/request.service';
import type { RequestForCustomer, RequestForVendor } from '../presenter/request.presenter';

function toKarat(k?: string | null): Karat | undefined {
  if (!k) return undefined;
  if (k === '24K' || k === 'K24') return 'K24';
  if (k === '22K' || k === 'K22') return 'K22';
  if (k === '21K' || k === 'K21') return 'K21';
  if (k === '18K' || k === 'K18') return 'K18';
  return undefined;
}

const karatEnum = z.enum(['24K', '22K', '21K', '18K', 'K24', 'K22', 'K21', 'K18']);

const createRequestSchema = z.object({
  requestType: z.enum(['FIND_ORNAMENT', 'SELL_OLD_GOLD', 'GOLD_COIN', 'GOLD_BULLION']),
  direction: z.enum(['BUY', 'SELL']).optional(),
  categoryId: z.string().uuid().optional(),
  regionId: z.string().uuid().optional(),
  notes: z.string().max(2000).optional(),
  weightGrams: z.union([z.number().positive(), z.string()]).optional(),
  weightIsApproximate: z.boolean().optional(),
  purityKarat: karatEnum.optional(),
  ornamentType: z
    .enum(['RING', 'CHAIN', 'BANGLE', 'NECKLACE', 'EARRING', 'BRACELET', 'PENDANT', 'OTHER'])
    .optional(),
  condition: z.enum(['NEW', 'LIKE_NEW', 'USED', 'DAMAGED']).optional(),
  denominationGrams: z.union([z.number().positive(), z.string()]).optional(),
  quantity: z.number().int().positive().optional(),
  mintOrRefiner: z.string().max(100).optional(),
  budgetMin: z.union([z.number().nonnegative(), z.string()]).optional(),
  budgetMax: z.union([z.number().positive(), z.string()]).optional(),
  budgetIsFlexible: z.boolean().optional(),
  gemstones: z.record(z.unknown()).optional(),
  mediaKeys: z.array(z.string()).max(5).optional(),
});

const updateRequestSchema = createRequestSchema.partial();

const cancelRequestSchema = z.object({
  reason: z.string().max(500).optional(),
});

const listCustomerRequestsQuerySchema = z.object({
  state: z.union([z.string(), z.array(z.string())]).optional(),
  requestType: z.enum(['FIND_ORNAMENT', 'SELL_OLD_GOLD', 'GOLD_COIN', 'GOLD_BULLION']).optional(),
  direction: z.enum(['BUY', 'SELL']).optional(),
  q: z.string().optional(),
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20).optional(),
  cursor: z.string().uuid().optional(),
});

@Controller('v1')
export class RequestController {
  constructor(private readonly requests: RequestService) {}

  @Post('requests')
  @HttpCode(HttpStatus.CREATED)
  async createDraft(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(createRequestSchema)) body: z.infer<typeof createRequestSchema>,
  ) {
    const res = await this.requests.createDraft(viewer, {
      ...body,
      direction: body.direction as Direction | undefined,
      purityKarat: toKarat(body.purityKarat),
      ornamentType: body.ornamentType as OrnamentType | undefined,
      condition: body.condition as ItemCondition | undefined,
      requestType: body.requestType as RequestType,
    });

    return {
      data: res.data,
      meta: {
        warnings: res.warnings,
      },
    };
  }

  @Get('me/requests')
  async listMyRequests(
    @Viewer() viewer: ViewerContext,
    @Query(zodQuery(listCustomerRequestsQuerySchema))
    query: z.infer<typeof listCustomerRequestsQuerySchema>,
  ) {
    let states: RequestState[] | undefined = undefined;
    if (query.state) {
      const raw = Array.isArray(query.state) ? query.state : query.state.split(',');
      states = raw.map((s) => s.trim()) as RequestState[];
    }

    const { items, nextCursor } = await this.requests.listCustomerRequests(viewer, {
      state: states,
      requestType: query.requestType as RequestType | undefined,
      direction: query.direction as Direction | undefined,
      q: query.q,
      from: query.from ? new Date(query.from) : undefined,
      to: query.to ? new Date(query.to) : undefined,
      limit: query.limit,
      cursor: query.cursor,
    });

    return {
      data: items,
      meta: {
        nextCursor,
      },
    };
  }

  @Get('requests/:id')
  async getById(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ): Promise<RequestForCustomer | RequestForVendor> {
    return this.requests.getById(viewer, id);
  }

  @Patch('requests/:id')
  async update(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(updateRequestSchema)) body: z.infer<typeof updateRequestSchema>,
  ) {
    const res = await this.requests.update(viewer, id, {
      ...body,
      direction: body.direction as Direction | undefined,
      purityKarat: toKarat(body.purityKarat),
      ornamentType: body.ornamentType as OrnamentType | undefined,
      condition: body.condition as ItemCondition | undefined,
      requestType: body.requestType as RequestType | undefined,
    });

    return {
      data: res.data,
      meta: {
        warnings: res.warnings,
      },
    };
  }

  @Post('requests/:id/publish')
  @HttpCode(HttpStatus.OK)
  async publish(@Viewer() viewer: ViewerContext, @Param('id') id: string) {
    const res = await this.requests.publish(viewer, id);
    return {
      data: res.data,
      meta: {
        matchCount: res.matchCount,
      },
    };
  }

  @Post('requests/:id/cancel')
  @HttpCode(HttpStatus.OK)
  async cancel(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(cancelRequestSchema)) body: z.infer<typeof cancelRequestSchema>,
  ): Promise<RequestForCustomer> {
    return this.requests.cancel(viewer, id, body.reason);
  }

  @Post('requests/:id/duplicate')
  @HttpCode(HttpStatus.CREATED)
  async duplicate(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ): Promise<RequestForCustomer> {
    return this.requests.duplicate(viewer, id);
  }
}
