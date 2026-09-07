import { Body, Controller, Get, HttpCode, Param, Post, Query, Req } from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import { UserAccountState, VendorVerificationState } from '@prisma/client';
import { z } from 'zod';
import { AdminOnly } from '../../../edge/auth/admin-only.decorator';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { clientInfoOf } from '../../../edge/client-ip';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { ZodValidationPipe, zodBody, zodQuery } from '../../../edge/validation/zod-validation.pipe';
import { AdminVendorService } from '../application/admin-vendor.service';
import type {
  AdminNoteView,
  DocumentUrlView,
  VendorListPage,
  VendorVerificationDetail,
  VerificationQueueItem,
} from '../presenter/admin-vendor.presenter';

const vendorIdParam = new ZodValidationPipe(z.string().uuid());
const documentIdParam = new ZodValidationPipe(z.string().uuid());

const vendorListQuerySchema = z.object({
  verificationState: z.nativeEnum(VendorVerificationState).optional(),
  accountState: z.nativeEnum(UserAccountState).optional(),
  regionId: z.string().uuid().optional(),
  categoryId: z.string().uuid().optional(),
  q: z.string().max(200).optional(),
  cursor: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
  page: z.coerce.number().int().min(1).optional(),
});

const rationaleSchema = z.object({
  rationale: z.string().trim().min(1, 'rationale is required').max(2000),
});

const requestInfoSchema = z.object({
  message: z.string().trim().min(1, 'message is required').max(2000),
});

const lifecycleActionSchema = z.object({
  reasonCode: z.string().trim().max(100).optional(),
  reasonText: z.string().trim().min(1, 'reasonText is required').max(2000),
});

const addNoteSchema = z.object({
  text: z.string().trim().min(1, 'text is required').max(4000),
});

@Controller('v1/admin')
@AdminOnly()
@RevealsIdentity()
export class AdminVendorController {
  constructor(private readonly vendors: AdminVendorService) {}

  @Get('verification-queue')
  getVerificationQueue(): Promise<VerificationQueueItem[]> {
    return this.vendors.getVerificationQueue();
  }

  @Get('vendors')
  listVendors(
    @Query(zodQuery(vendorListQuerySchema)) query: z.infer<typeof vendorListQuerySchema>,
  ): Promise<VendorListPage> {
    return this.vendors.getVendors(query, {
      cursor: query.cursor,
      limit: query.limit,
      page: query.page,
    });
  }

  @Get('vendors/:id')
  getVendor(
    @Param('id', vendorIdParam) id: string,
  ): Promise<VendorVerificationDetail> {
    return this.vendors.getVendorDetail(id);
  }

  @Get('vendors/:id/documents/:docId/url')
  getDocumentUrl(
    @Param('id', vendorIdParam) vendorId: string,
    @Param('docId', documentIdParam) docId: string,
    @Viewer() viewer: ViewerContext,
    @Req() request: FastifyRequest,
  ): Promise<DocumentUrlView> {
    return this.vendors.getDocumentSignedUrl(viewer, clientInfoOf(request), vendorId, docId);
  }

  @Post('vendors/:id/verify')
  @HttpCode(200)
  verifyVendor(
    @Param('id', vendorIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(rationaleSchema)) body: z.infer<typeof rationaleSchema>,
  ): Promise<{ lifecycle: string }> {
    return this.vendors.verifyVendor(viewer, id, body.rationale);
  }

  @Post('vendors/:id/reject')
  @HttpCode(200)
  rejectVendor(
    @Param('id', vendorIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(rationaleSchema)) body: z.infer<typeof rationaleSchema>,
  ): Promise<{ lifecycle: string }> {
    return this.vendors.rejectVendor(viewer, id, body.rationale);
  }

  @Post('vendors/:id/request-info')
  @HttpCode(200)
  requestInfo(
    @Param('id', vendorIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(requestInfoSchema)) body: z.infer<typeof requestInfoSchema>,
  ): Promise<{ lifecycle: string }> {
    return this.vendors.requestInfo(viewer, id, body.message);
  }

  @Post('vendors/:id/activate')
  @HttpCode(200)
  activateVendor(
    @Param('id', vendorIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(lifecycleActionSchema)) body: z.infer<typeof lifecycleActionSchema>,
  ): Promise<{ accountState: UserAccountState; lifecycle: string }> {
    return this.vendors.activateVendor(viewer, id, body);
  }

  @Post('vendors/:id/suspend')
  @HttpCode(200)
  suspendVendor(
    @Param('id', vendorIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(lifecycleActionSchema)) body: z.infer<typeof lifecycleActionSchema>,
  ): Promise<{ accountState: UserAccountState; lifecycle: string }> {
    return this.vendors.suspendVendor(viewer, id, body);
  }

  @Post('vendors/:id/reactivate')
  @HttpCode(200)
  reactivateVendor(
    @Param('id', vendorIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(lifecycleActionSchema)) body: z.infer<typeof lifecycleActionSchema>,
  ): Promise<{ accountState: UserAccountState; lifecycle: string }> {
    return this.vendors.reactivateVendor(viewer, id, body);
  }

  @Post('vendors/:id/deactivate')
  @HttpCode(200)
  deactivateVendor(
    @Param('id', vendorIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(lifecycleActionSchema)) body: z.infer<typeof lifecycleActionSchema>,
  ): Promise<{ accountState: UserAccountState; lifecycle: string }> {
    return this.vendors.deactivateVendor(viewer, id, body);
  }

  @Post('vendors/:id/notes')
  @HttpCode(201)
  addNote(
    @Param('id', vendorIdParam) id: string,
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(addNoteSchema)) body: z.infer<typeof addNoteSchema>,
  ): Promise<AdminNoteView> {
    return this.vendors.addNote(viewer, id, body.text);
  }
}
