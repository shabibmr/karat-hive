import {
  Body,
  Controller,
  Get,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import type { AbuseReportState, ExportFormat, Prisma, RequestState, UserAccountState, VendorVerificationState } from '@prisma/client';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { RevealsIdentity } from '../../../edge/masking/reveals-identity.decorator';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { AdminService } from '../application/admin.service';
import { AdminGuard } from '../guard/admin.guard';

// Validation schemas
const suspendCustomerSchema = z.object({
  reasonCode: z.string().trim().min(1).max(50),
  reasonText: z.string().trim().min(1).max(500),
});

const reactivateCustomerSchema = z.object({
  reasonText: z.string().trim().min(1).max(500),
});

const erasureCustomerSchema = z.object({
  reasonText: z.string().trim().min(1).max(500),
});

const verifyVendorSchema = z.object({
  rationale: z.string().trim().min(1).max(500),
});

const rejectVendorSchema = z.object({
  rationale: z.string().trim().min(1).max(500),
});

const requestInfoVendorSchema = z.object({
  message: z.string().trim().min(1).max(1000),
});

const setVendorStateSchema = z.object({
  reasonCode: z.string().trim().max(50).optional(),
  reasonText: z.string().trim().max(500).optional(),
});

const removeRequestSchema = z.object({
  reasonCode: z.string().trim().min(1).max(50),
  reasonText: z.string().trim().min(1).max(500),
  policyClause: z.string().trim().max(100).optional(),
});

const closeConnectionSchema = z.object({
  reasonText: z.string().trim().min(1).max(500),
});

const rejectReviewSchema = z.object({
  rationale: z.string().trim().min(1).max(500),
});

const redactReviewSchema = z.object({
  rationale: z.string().trim().min(1).max(500),
  redactedComment: z.string().trim().min(1).max(2000),
});

const resolveAbuseSchema = z.object({
  resolution: z.string().trim().min(1).max(500),
});

const updateSettingSchema = z.object({
  value: z.unknown(),
  confirm: z.boolean().optional(),
});

const adminNoteSchema = z.object({
  text: z.string().trim().min(1).max(2000),
});

const createAdminSchema = z.object({
  email: z.string().email().max(255),
  displayName: z.string().trim().min(1).max(100),
});

const createAnnouncementSchema = z.object({
  titleEn: z.string().trim().min(1).max(200),
  titleAr: z.string().trim().min(1).max(200),
  bodyEn: z.string().trim().min(1).max(2000),
  bodyAr: z.string().trim().min(1).max(2000),
  audience: z.record(z.unknown()).default({}),
  channels: z.record(z.unknown()).default({ inApp: true }),
  critical: z.boolean().optional(),
  scheduledFor: z.coerce.date().optional(),
});

const createExportSchema = z.object({
  reportName: z.string().trim().min(1).max(64),
  format: z.enum(['CSV', 'XLSX', 'PNG']),
  filters: z.record(z.unknown()).default({}),
  purpose: z.string().trim().min(1).max(200),
});

@RevealsIdentity()
@UseGuards(AdminGuard)
@Controller('v1/admin')
export class AdminController {
  constructor(private readonly service: AdminService) {}

  private resolveAdminProfileId(viewer: ViewerContext): string {
    if (!viewer.adminProfileId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return viewer.adminProfileId;
  }

  // --- Dashboard ---
  @Get('dashboard')
  async getDashboard() {
    const data = await this.service.getDashboard();
    return { data };
  }

  // --- Customers ---
  @Get('customers')
  async listCustomers(
    @Query('q') q?: string,
    @Query('state') state?: UserAccountState,
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    const data = await this.service.listCustomers({
      q,
      state,
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }

  @Get('customers/:id')
  async getCustomer(@Param('id') id: string) {
    const data = await this.service.getCustomer(id);
    return { data };
  }

  @Post('customers/:id/suspend')
  async suspendCustomer(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(suspendCustomerSchema)) body: z.infer<typeof suspendCustomerSchema>,
  ) {
    const data = await this.service.suspendCustomer(id, body, viewer.userId);
    return { data };
  }

  @Post('customers/:id/reactivate')
  async reactivateCustomer(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(reactivateCustomerSchema)) body: z.infer<typeof reactivateCustomerSchema>,
  ) {
    const data = await this.service.reactivateCustomer(id, body, viewer.userId);
    return { data };
  }

  @Post('customers/:id/erasure')
  async erasureCustomer(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(erasureCustomerSchema)) body: z.infer<typeof erasureCustomerSchema>,
  ) {
    const data = await this.service.erasureCustomer(id, body, viewer.userId);
    return { data };
  }

  // --- Vendors ---
  @Get('vendors')
  async listVendors(
    @Query('q') q?: string,
    @Query('verificationState') verificationState?: VendorVerificationState,
    @Query('accountState') accountState?: UserAccountState,
    @Query('regionId') regionId?: string,
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    const data = await this.service.listVendors({
      q,
      verificationState,
      accountState,
      regionId,
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }

  @Get('vendors/:id')
  async getVendor(@Param('id') id: string) {
    const data = await this.service.getVendor(id);
    return { data };
  }

  @Get('vendors/:id/documents/:docId/url')
  async getVendorDocumentUrl(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Param('docId') docId: string,
  ) {
    const data = await this.service.getVendorDocumentUrl(id, docId, viewer.userId);
    return { data };
  }

  @Get('verification-queue')
  async getVerificationQueue() {
    const data = await this.service.getVerificationQueue();
    return { data };
  }

  @Post('vendors/:id/verify')
  async verifyVendor(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(verifyVendorSchema)) body: z.infer<typeof verifyVendorSchema>,
  ) {
    const data = await this.service.verifyVendor(id, body, viewer.userId);
    return { data };
  }

  @Post('vendors/:id/reject')
  async rejectVendor(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(rejectVendorSchema)) body: z.infer<typeof rejectVendorSchema>,
  ) {
    const data = await this.service.rejectVendor(id, body, viewer.userId);
    return { data };
  }

  @Post('vendors/:id/request-info')
  async requestVendorInfo(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(requestInfoVendorSchema)) body: z.infer<typeof requestInfoVendorSchema>,
  ) {
    const data = await this.service.requestVendorInfo(id, body, viewer.userId);
    return { data };
  }

  @Post('vendors/:id/activate')
  async activateVendor(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(setVendorStateSchema)) body: z.infer<typeof setVendorStateSchema>,
  ) {
    const data = await this.service.setVendorState(id, 'ACTIVE', body, viewer.userId);
    return { data };
  }

  @Post('vendors/:id/suspend')
  async suspendVendor(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(setVendorStateSchema)) body: z.infer<typeof setVendorStateSchema>,
  ) {
    const data = await this.service.setVendorState(id, 'SUSPENDED', body, viewer.userId);
    return { data };
  }

  @Post('vendors/:id/reactivate')
  async reactivateVendor(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(setVendorStateSchema)) body: z.infer<typeof setVendorStateSchema>,
  ) {
    const data = await this.service.setVendorState(id, 'ACTIVE', body, viewer.userId);
    return { data };
  }

  @Post('vendors/:id/deactivate')
  async deactivateVendor(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(setVendorStateSchema)) body: z.infer<typeof setVendorStateSchema>,
  ) {
    const data = await this.service.setVendorState(id, 'DEACTIVATED', body, viewer.userId);
    return { data };
  }

  // --- Requests ---
  @Get('requests')
  async listRequests(
    @Query('q') q?: string,
    @Query('state') state?: RequestState,
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    const data = await this.service.listRequests({
      q,
      state,
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }

  @Get('requests/:id')
  async getRequest(@Param('id') id: string) {
    const data = await this.service.getRequest(id);
    return { data };
  }

  @Post('requests/:id/remove')
  async removeRequest(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(removeRequestSchema)) body: z.infer<typeof removeRequestSchema>,
  ) {
    const data = await this.service.removeRequest(id, body, viewer.userId);
    return { data };
  }

  // --- Offers ---
  @Get('offers')
  async listOffers(
    @Query('state') state?: string,
    @Query('vendorId') vendorId?: string,
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    const data = await this.service.listOffers({
      state,
      vendorId,
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }

  @Get('offers/:id')
  async getOffer(@Param('id') id: string) {
    const data = await this.service.getOffer(id);
    return { data };
  }

  // --- Connections ---
  @Get('connections')
  async listConnections(
    @Query('state') state?: string,
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    const data = await this.service.listConnections({
      state,
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }

  @Get('connections/:id')
  async getConnection(@Param('id') id: string) {
    const data = await this.service.getConnection(id);
    return { data };
  }

  @Post('connections/:id/close')
  async closeConnection(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(closeConnectionSchema)) body: z.infer<typeof closeConnectionSchema>,
  ) {
    const data = await this.service.closeConnection(id, body, viewer.userId);
    return { data };
  }

  // --- Review Moderation ---
  @Get('reviews')
  async listReviews(
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    const data = await this.service.listRequests({
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }

  @Post('reviews/:id/approve')
  async approveReview(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ) {
    const data = await this.service.approveReview(id, viewer.userId);
    return { data };
  }

  @Post('reviews/:id/reject')
  async rejectReview(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(rejectReviewSchema)) body: z.infer<typeof rejectReviewSchema>,
  ) {
    const data = await this.service.rejectReview(id, body, viewer.userId);
    return { data };
  }

  @Post('reviews/:id/redact')
  async redactReview(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(redactReviewSchema)) body: z.infer<typeof redactReviewSchema>,
  ) {
    const data = await this.service.redactReview(id, body, viewer.userId);
    return { data };
  }

  // --- Abuse Reports ---
  @Get('abuse-reports')
  async listAbuseReports(
    @Query('state') state?: AbuseReportState,
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    const data = await this.service.listAbuseReports({
      state,
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }

  @Get('abuse-reports/:id')
  async getAbuseReport(@Param('id') id: string) {
    const data = await this.service.getAbuseReport(id);
    return { data };
  }

  @Post('abuse-reports/:id/resolve')
  async resolveAbuseReport(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(resolveAbuseSchema)) body: z.infer<typeof resolveAbuseSchema>,
  ) {
    const data = await this.service.resolveAbuseReport(id, body, viewer.userId);
    return { data };
  }

  @Post('abuse-reports/:id/dismiss')
  async dismissAbuseReport(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
    @Body(zodBody(resolveAbuseSchema)) body: z.infer<typeof resolveAbuseSchema>,
  ) {
    const data = await this.service.dismissAbuseReport(id, body, viewer.userId);
    return { data };
  }

  // --- Settings ---
  @Get('settings')
  async getSettings() {
    const data = await this.service.getSettings();
    return { data };
  }

  @Patch('settings/:key')
  async updateSetting(
    @Viewer() viewer: ViewerContext,
    @Param('key') key: string,
    @Body(zodBody(updateSettingSchema)) body: z.infer<typeof updateSettingSchema>,
  ) {
    const data = await this.service.updateSetting(key, body.value, viewer.userId);
    return { data };
  }

  // --- Audit Log ---
  @Get('audit-log')
  async listAuditLogs(
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
    @Query('actorUserId') actorUserId?: string,
    @Query('action') action?: string,
    @Query('entityType') entityType?: string,
    @Query('entityId') entityId?: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
    @Query('ip') ip?: string,
  ) {
    const data = await this.service.listAuditLogs({
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
      actorUserId,
      action,
      entityType,
      entityId,
      from,
      to,
      ip,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }

  // --- Admin Notes ---
  @Post(':collection/:id/notes')
  async createAdminNote(
    @Viewer() viewer: ViewerContext,
    @Param('collection') collection: string,
    @Param('id') id: string,
    @Body(zodBody(adminNoteSchema)) body: z.infer<typeof adminNoteSchema>,
  ) {
    const adminProfileId = this.resolveAdminProfileId(viewer);
    const data = await this.service.createAdminNote(
      collection,
      id,
      body.text,
      adminProfileId,
    );
    return { data };
  }

  @Get(':collection/:id/notes')
  async listAdminNotes(
    @Param('collection') collection: string,
    @Param('id') id: string,
  ) {
    const data = await this.service.listAdminNotes(collection, id);
    return { data };
  }

  // --- Admin User Provisioning ---
  @Get('admins')
  async listAdmins() {
    const data = await this.service.listAdmins();
    return { data };
  }

  @Post('admins')
  async createAdmin(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(createAdminSchema)) body: z.infer<typeof createAdminSchema>,
  ) {
    const data = await this.service.createAdmin(body, viewer.userId);
    return { data };
  }

  @Post('admins/:id/suspend')
  async suspendAdmin(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ) {
    const data = await this.service.suspendAdmin(id, viewer.userId);
    return { data };
  }

  @Post('admins/:id/revoke')
  async revokeAdmin(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ) {
    const data = await this.service.revokeAdmin(id, viewer.userId);
    return { data };
  }

  // --- Announcements ---
  @Get('announcements')
  async listAnnouncements(
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    const data = await this.service.listAnnouncements({
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }

  @Post('announcements')
  async createAnnouncement(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(createAnnouncementSchema)) body: z.infer<typeof createAnnouncementSchema>,
  ) {
    const adminProfileId = this.resolveAdminProfileId(viewer);
    const data = await this.service.createAnnouncement(
      {
        titleEn: body.titleEn,
        titleAr: body.titleAr,
        bodyEn: body.bodyEn,
        bodyAr: body.bodyAr,
        audience: body.audience as Prisma.InputJsonValue,
        channels: body.channels as Prisma.InputJsonValue,
        critical: body.critical,
        scheduledFor: body.scheduledFor,
      },
      adminProfileId,
      viewer.userId,
    );
    return { data };
  }

  @Post('announcements/:id/cancel')
  async cancelAnnouncement(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ) {
    const data = await this.service.cancelAnnouncement(id, viewer.userId);
    return { data };
  }

  // --- Reports & Exports ---
  @Get('reports/:name')
  async getReport(
    @Param('name') name: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
    @Query('regionId') regionId?: string,
    @Query('categoryId') categoryId?: string,
  ) {
    const data = await this.service.getReport(name, { from, to, regionId, categoryId });
    return { data };
  }

  @Post('exports')
  async createExport(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(createExportSchema)) body: z.infer<typeof createExportSchema>,
  ) {
    const adminProfileId = this.resolveAdminProfileId(viewer);
    const data = await this.service.createExportJob(
      {
        reportName: body.reportName,
        format: body.format as ExportFormat,
        filters: body.filters as Prisma.InputJsonValue,
        purpose: body.purpose,
      },
      adminProfileId,
      viewer.userId,
    );
    return { data };
  }

  @Get('exports/:id')
  async getExport(
    @Viewer() viewer: ViewerContext,
    @Param('id') id: string,
  ) {
    const data = await this.service.getExportJob(id, viewer.userId);
    return { data };
  }
}
