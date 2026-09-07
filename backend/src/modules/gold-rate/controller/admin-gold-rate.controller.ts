import { Body, Controller, Get, HttpCode, HttpStatus, Post, Query, Req } from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import { z } from 'zod';
import { AdminOnly } from '../../../edge/auth/admin-only.decorator';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { clientInfoOf } from '../../../edge/client-ip';
import { zodBody, zodQuery } from '../../../edge/validation/zod-validation.pipe';
import { GoldRateService } from '../application/gold-rate.service';

const historyQuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(100).optional(),
  cursor: z.string().uuid().optional(),
  karat: z.enum(['24K', '22K', '21K', '18K', 'K24', 'K22', 'K21', 'K18']).optional(),
  source: z.enum(['FEED', 'MANUAL_OVERRIDE']).optional(),
});

const overrideSchema = z.object({
  karat: z.enum(['24K', '22K', '21K', '18K', 'K24', 'K22', 'K21', 'K18']),
  ratePerGramAed: z.union([z.string(), z.number()]),
  reason: z.string().trim().min(1).max(500),
  expiresAt: z.coerce.date(),
});

@Controller('v1/admin/gold-rates')
@AdminOnly()
export class AdminGoldRateController {
  constructor(private readonly goldRates: GoldRateService) {}

  @Get()
  async getCurrent() {
    const data = await this.goldRates.getAdminRates();
    return { data };
  }

  @Get('history')
  async getHistory(@Query(zodQuery(historyQuerySchema)) query: z.infer<typeof historyQuerySchema>) {
    const { items, nextCursor } = await this.goldRates.listHistory(query);
    return { data: items, nextCursor };
  }

  @Post('override')
  @HttpCode(HttpStatus.CREATED)
  async override(
    @Viewer() viewer: ViewerContext,
    @Req() request: FastifyRequest,
    @Body(zodBody(overrideSchema)) body: z.infer<typeof overrideSchema>,
  ) {
    const data = await this.goldRates.override(body, viewer, clientInfoOf(request));
    return { data };
  }
}
