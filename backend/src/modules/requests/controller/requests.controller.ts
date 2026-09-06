import { Body, Controller, Get, Param, ParseUUIDPipe, Post, UseGuards } from '@nestjs/common';
import { Direction, ItemCondition, Karat, OrnamentType, RequestType } from '@prisma/client';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { RequestsService } from '../application/requests.service';
import type { CustomerRequestView } from '../presenter/request-customer.presenter';
import type { VendorRequestView } from '../presenter/request-vendor.presenter';

const createRequestSchema = z.object({
  requestType: z.nativeEnum(RequestType),
  direction: z.nativeEnum(Direction).optional(),
  categoryId: z.string().uuid(),
  regionId: z.string().uuid(),
  notes: z.string().max(2000).optional().nullable(),
  weightGrams: z.union([z.number(), z.string()]).optional().nullable(),
  weightIsApproximate: z.boolean().optional(),
  purityKarat: z.nativeEnum(Karat).optional().nullable(),
  ornamentType: z.nativeEnum(OrnamentType).optional().nullable(),
  condition: z.nativeEnum(ItemCondition).optional().nullable(),
  denominationGrams: z.union([z.number(), z.string()]).optional().nullable(),
  quantity: z.number().int().positive().optional().nullable(),
  mintOrRefiner: z.string().max(100).optional().nullable(),
  budgetMin: z.union([z.number(), z.string()]).optional().nullable(),
  budgetMax: z.union([z.number(), z.string()]).optional().nullable(),
  budgetIsFlexible: z.boolean().optional(),
  gemstones: z.unknown().optional(),
});

@Controller('v1/requests')
export class RequestsController {
  constructor(private readonly requestsService: RequestsService) {}

  @Post()
  @RevealsIdentity()
  createDraft(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(createRequestSchema)) body: z.infer<typeof createRequestSchema>,
  ): Promise<CustomerRequestView> {
    const customerProfileId = viewer.customerProfileId ?? viewer.userId;
    return this.requestsService.createDraft({
      ...body,
      customerProfileId,
    });
  }

  @Post(':id/publish')
  @RevealsIdentity()
  publish(
    @Viewer() viewer: ViewerContext,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<CustomerRequestView> {
    const customerProfileId = viewer.customerProfileId ?? viewer.userId;
    return this.requestsService.publishRequest(id, customerProfileId);
  }

  @Get(':id')
  async getRequest(
    @Viewer() viewer: ViewerContext,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<CustomerRequestView | VendorRequestView> {
    if (viewer.vendorProfileId) {
      return this.requestsService.getRequestForVendor(id, viewer.vendorProfileId);
    }
    const customerProfileId = viewer.customerProfileId ?? viewer.userId;
    return this.requestsService.getRequestForCustomer(id, customerProfileId);
  }
}
