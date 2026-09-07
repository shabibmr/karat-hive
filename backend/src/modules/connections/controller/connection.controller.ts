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
import { ConnectionService } from '../application/connection.service';

const acceptOfferSchema = z.object({
  confirmation: z.literal('REVEAL_AND_CONNECT'),
});

const listConnectionsQuerySchema = z.object({
  state: z.enum(['ACTIVE', 'CLOSED']).optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
  cursor: z.string().uuid().optional(),
});

const closeConnectionSchema = z.object({
  reason: z.string().max(500).optional(),
});

const contactEventSchema = z.object({
  channel: z.enum(['WHATSAPP', 'PHONE']),
});

@Controller('v1')
export class ConnectionController {
  constructor(private readonly connectionService: ConnectionService) {}

  @Post('offers/:id/accept')
  @HttpCode(HttpStatus.OK)
  async acceptOffer(
    @Viewer() viewer: ViewerContext,
    @Param('id') offerId: string,
    @Body(zodBody(acceptOfferSchema)) body: z.infer<typeof acceptOfferSchema>,
  ) {
    const data = await this.connectionService.acceptOffer(
      viewer,
      offerId,
      body.confirmation,
    );
    return { data };
  }

  @Get('me/connections')
  async listMyConnections(
    @Viewer() viewer: ViewerContext,
    @Query(zodQuery(listConnectionsQuerySchema)) query: z.infer<typeof listConnectionsQuerySchema>,
  ) {
    return this.connectionService.listMyConnections(
      viewer,
      query.state,
      query.cursor,
      query.limit,
    );
  }

  @Get('connections/:id')
  async getConnectionById(
    @Viewer() viewer: ViewerContext,
    @Param('id') connectionId: string,
  ) {
    const data = await this.connectionService.getConnectionById(viewer, connectionId);
    return { data };
  }

  @Post('connections/:id/close')
  @HttpCode(HttpStatus.OK)
  async closeConnection(
    @Viewer() viewer: ViewerContext,
    @Param('id') connectionId: string,
    @Body(zodBody(closeConnectionSchema)) body: z.infer<typeof closeConnectionSchema>,
  ) {
    const data = await this.connectionService.closeConnection(
      viewer,
      connectionId,
      body.reason,
    );
    return { data };
  }

  @Post('connections/:id/contact-events')
  @HttpCode(HttpStatus.CREATED)
  async recordContactEvent(
    @Viewer() viewer: ViewerContext,
    @Param('id') connectionId: string,
    @Body(zodBody(contactEventSchema)) body: z.infer<typeof contactEventSchema>,
  ) {
    await this.connectionService.recordContactEvent(
      viewer,
      connectionId,
      body.channel,
    );
    return { data: { success: true } };
  }
}
