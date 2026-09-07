import { HttpStatus, Injectable } from '@nestjs/common';
import type {
  Direction,
  ItemCondition,
  Karat,
  OrnamentType,
  Prisma,
  RequestState,
  RequestType,
} from '@prisma/client';
import { Prisma as PrismaNamespace } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { AuditWriter } from '../../audit';
import { MediaService } from '../../media/application/media.service';
import { PlatformConfigQuery } from '../../taxonomy/application/platform-config.query';
import { scanForContactDetails } from '../domain/contact-scanner';
import { generateRequestReference } from '../domain/reference-generator';
import {
  isTerminalRequestState,
  resolveRequestDirection,
} from '../domain/request-state-machine';
import { validateRequestForPublish } from '../domain/request-validator';
import {
  presentRequestForCustomer,
  presentRequestForVendor,
  type RequestForCustomer,
  type RequestForVendor,
} from '../presenter/request.presenter';
import { RequestRepository } from '../repository/request.repository';

export type CreateRequestDto = {
  requestType: RequestType;
  direction?: Direction;
  categoryId?: string;
  regionId?: string;
  notes?: string;
  weightGrams?: number | string;
  weightIsApproximate?: boolean;
  purityKarat?: Karat;
  ornamentType?: OrnamentType;
  condition?: ItemCondition;
  denominationGrams?: number | string;
  quantity?: number;
  mintOrRefiner?: string;
  budgetMin?: number | string;
  budgetMax?: number | string;
  budgetIsFlexible?: boolean;
  gemstones?: Record<string, unknown>;
  mediaKeys?: string[];
};

export type UpdateRequestDto = Partial<CreateRequestDto>;

export type ListCustomerRequestsDto = {
  state?: RequestState[];
  requestType?: RequestType;
  direction?: Direction;
  q?: string;
  from?: Date;
  to?: Date;
  limit?: number;
  cursor?: string;
};

@Injectable()
export class RequestService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly repo: RequestRepository,
    private readonly mediaService: MediaService,
    private readonly platformConfig: PlatformConfigQuery,
    private readonly audit: AuditWriter,
  ) {}

  private assertCustomer(viewer: ViewerContext): string {
    if (viewer.role !== 'CUSTOMER' || !viewer.customerProfileId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
    if (viewer.accountState === 'SUSPENDED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_SUSPENDED);
    }
    if (viewer.accountState === 'DEACTIVATED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_DEACTIVATED);
    }
    return viewer.customerProfileId;
  }

  async createDraft(
    viewer: ViewerContext,
    dto: CreateRequestDto,
  ): Promise<{ data: RequestForCustomer; warnings: string[] }> {
    const customerProfileId = this.assertCustomer(viewer);

    // Resolve category and region (or fallbacks for draft)
    let categoryId = dto.categoryId;
    if (!categoryId) {
      const firstCat = await this.prisma.category.findFirst({
        where: { isActive: true },
        orderBy: { displayOrder: 'asc' },
      });
      if (!firstCat) {
        throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, ErrorCode.INTERNAL);
      }
      categoryId = firstCat.id;
    }

    let regionId = dto.regionId;
    if (!regionId) {
      const customer = await this.prisma.customerProfile.findUnique({
        where: { id: customerProfileId },
        select: { defaultRegionId: true },
      });
      if (customer?.defaultRegionId) {
        regionId = customer.defaultRegionId;
      } else {
        const firstRegion = await this.prisma.region.findFirst({
          where: { isActive: true },
          orderBy: { displayOrder: 'asc' },
        });
        if (!firstRegion) {
          throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, ErrorCode.INTERNAL);
        }
        regionId = firstRegion.id;
      }
    }

    const direction = resolveRequestDirection(dto.requestType, dto.direction);

    // Contact scan check: generates warning for draft
    const contactScan = scanForContactDetails(dto.notes);

    // Resolve media keys if present
    const mediaIds: string[] = [];
    if (dto.mediaKeys && dto.mediaKeys.length > 0) {
      if (dto.mediaKeys.length > 5) {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
          { path: 'mediaKeys', code: 'TOO_MANY', message: 'Maximum 5 images allowed.' },
        ]);
      }
      for (const key of dto.mediaKeys) {
        const attachable = await this.mediaService.getAttachable(key, viewer.userId);
        mediaIds.push(attachable.id);
      }
    }

    const created = await withTx(this.prisma, async (tx) => {
      const row = await this.repo.createDraft(
        {
          customerProfileId,
          requestType: dto.requestType,
          direction,
          categoryId,
          regionId,
          notes: dto.notes,
          weightGrams: dto.weightGrams,
          weightIsApproximate: dto.weightIsApproximate,
          purityKarat: dto.purityKarat,
          ornamentType: dto.ornamentType,
          condition: dto.condition,
          denominationGrams: dto.denominationGrams,
          quantity: dto.quantity,
          mintOrRefiner: dto.mintOrRefiner,
          budgetMin: dto.budgetMin,
          budgetMax: dto.budgetMax,
          budgetIsFlexible: dto.budgetIsFlexible,
          gemstones: dto.gemstones as PrismaNamespace.InputJsonValue,
          mediaIds,
        },
        tx,
      );

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'REQUEST_DRAFT_CREATED',
        entityType: 'request',
        entityId: row.id,
        afterValue: {
          requestType: row.requestType,
          state: row.state,
        },
      });

      return row;
    });

    return {
      data: presentRequestForCustomer(created),
      warnings: contactScan.warnings,
    };
  }

  async update(
    viewer: ViewerContext,
    id: string,
    dto: UpdateRequestDto,
  ): Promise<{ data: RequestForCustomer; warnings: string[] }> {
    const customerProfileId = this.assertCustomer(viewer);
    const existing = await this.repo.findByIdForCustomer(id, customerProfileId);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (existing.state === 'ACCEPTED' || isTerminalRequestState(existing.state)) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT, [
        { path: 'state', code: 'NOT_EDITABLE', message: 'Request in current state cannot be edited.' },
      ]);
    }

    const isPublished = existing.state === 'PUBLISHED' || existing.state === 'OFFERS_RECEIVED';

    if (isPublished) {
      // BR-014: Structural attributes are immutable once published!
      const structuralFields = [
        'requestType',
        'direction',
        'categoryId',
        'regionId',
        'weightGrams',
        'weightIsApproximate',
        'purityKarat',
        'ornamentType',
        'condition',
        'denominationGrams',
        'quantity',
        'mintOrRefiner',
        'gemstones',
      ] as const;

      for (const field of structuralFields) {
        if (dto[field] !== undefined) {
          throw new ApiException(HttpStatus.CONFLICT, ErrorCode.STRUCTURAL_FIELD_IMMUTABLE, [
            {
              path: field,
              code: 'IMMUTABLE',
              message: `Field ${field} cannot be modified on a published request.`,
            },
          ]);
        }
      }

      // Hard block on contact details in notes for published edits (BR-022)
      if (dto.notes !== undefined) {
        const scan = scanForContactDetails(dto.notes);
        if (scan.hasContactInfo) {
          throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.CONTACT_DETAILS_IN_TEXT);
        }
      }
    }

    // Contact scan warning if in draft
    const contactScan = scanForContactDetails(dto.notes ?? existing.notes);

    // Prepare update data
    const updateData: Prisma.RequestUpdateInput = {};

    if (dto.notes !== undefined) updateData.notes = dto.notes;
    if (dto.budgetMin !== undefined) {
      updateData.budgetMin = dto.budgetMin ? new PrismaNamespace.Decimal(dto.budgetMin) : null;
    }
    if (dto.budgetMax !== undefined) {
      updateData.budgetMax = dto.budgetMax ? new PrismaNamespace.Decimal(dto.budgetMax) : null;
    }
    if (dto.budgetIsFlexible !== undefined) updateData.budgetIsFlexible = dto.budgetIsFlexible;

    // Media keys update
    let newMediaIds: string[] | undefined = undefined;
    if (dto.mediaKeys !== undefined) {
      if (dto.mediaKeys.length > 5) {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
          { path: 'mediaKeys', code: 'TOO_MANY', message: 'Maximum 5 images allowed.' },
        ]);
      }
      newMediaIds = [];
      for (const key of dto.mediaKeys) {
        const attachable = await this.mediaService.getAttachable(key, viewer.userId);
        newMediaIds.push(attachable.id);
      }
    }

    // For draft only: allow editing structural fields
    if (!isPublished) {
      if (dto.requestType !== undefined && dto.requestType !== existing.requestType) {
        updateData.requestType = dto.requestType;
        updateData.direction = resolveRequestDirection(dto.requestType, dto.direction);
        // Clear type-specific fields on type change (FR-CUS-005 AC1)
        updateData.weightGrams = null;
        updateData.weightIsApproximate = false;
        updateData.purityKarat = null;
        updateData.ornamentType = null;
        updateData.condition = null;
        updateData.denominationGrams = null;
        updateData.quantity = null;
        updateData.mintOrRefiner = null;
        updateData.gemstones = PrismaNamespace.DbNull;
      } else if (dto.direction !== undefined) {
        updateData.direction = resolveRequestDirection(existing.requestType, dto.direction);
      }

      if (dto.categoryId !== undefined) updateData.category = { connect: { id: dto.categoryId } };
      if (dto.regionId !== undefined) updateData.region = { connect: { id: dto.regionId } };
      if (dto.weightGrams !== undefined) {
        updateData.weightGrams = dto.weightGrams ? new PrismaNamespace.Decimal(dto.weightGrams) : null;
      }
      if (dto.weightIsApproximate !== undefined) {
        updateData.weightIsApproximate = dto.weightIsApproximate;
      }
      if (dto.purityKarat !== undefined) updateData.purityKarat = dto.purityKarat;
      if (dto.ornamentType !== undefined) updateData.ornamentType = dto.ornamentType;
      if (dto.condition !== undefined) updateData.condition = dto.condition;
      if (dto.denominationGrams !== undefined) {
        updateData.denominationGrams = dto.denominationGrams
          ? new PrismaNamespace.Decimal(dto.denominationGrams)
          : null;
      }
      if (dto.quantity !== undefined) updateData.quantity = dto.quantity;
      if (dto.mintOrRefiner !== undefined) updateData.mintOrRefiner = dto.mintOrRefiner;
      if (dto.gemstones !== undefined) {
        updateData.gemstones = dto.gemstones as PrismaNamespace.InputJsonValue;
      }
    }

    const updated = await withTx(this.prisma, async (tx) => {
      if (newMediaIds !== undefined) {
        await this.repo.syncMedia(existing.id, newMediaIds, tx);
      }

      const res = await this.repo.update(existing.id, updateData, tx);

      if (isPublished) {
        await enqueueOutbox(tx, {
          eventType: 'request.edited',
          aggregateType: 'request',
          aggregateId: res.id,
          payload: {
            requestId: res.id,
            notes: res.notes,
            budgetMin: res.budgetMin ? res.budgetMin.toString() : null,
            budgetMax: res.budgetMax ? res.budgetMax.toString() : null,
            budgetIsFlexible: res.budgetIsFlexible,
          },
        });
      }

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: isPublished ? 'REQUEST_PUBLISHED_EDITED' : 'REQUEST_DRAFT_UPDATED',
        entityType: 'request',
        entityId: res.id,
        beforeValue: {
          notes: existing.notes,
          budgetMin: existing.budgetMin?.toString(),
          budgetMax: existing.budgetMax?.toString(),
        },
        afterValue: {
          notes: res.notes,
          budgetMin: res.budgetMin?.toString(),
          budgetMax: res.budgetMax?.toString(),
        },
      });

      return res;
    });

    return {
      data: presentRequestForCustomer(updated),
      warnings: contactScan.warnings,
    };
  }

  async publish(
    viewer: ViewerContext,
    id: string,
  ): Promise<{ data: RequestForCustomer; matchCount: number }> {
    const customerProfileId = this.assertCustomer(viewer);
    const existing = await this.repo.findByIdForCustomer(id, customerProfileId);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // Idempotent success if already published
    if (existing.state === 'PUBLISHED' || existing.state === 'OFFERS_RECEIVED') {
      return {
        data: presentRequestForCustomer(existing),
        matchCount: 0,
      };
    }

    if (existing.state !== 'DRAFT') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT, [
        { path: 'state', code: 'CANNOT_PUBLISH', message: 'Only drafts can be published.' },
      ]);
    }

    // 1. Check OAuth gate (BR-001)
    const hasOauth = await this.repo.hasOauthBinding(viewer.userId);
    if (!hasOauth) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.OAUTH_REQUIRED);
    }

    // 2. Check concurrent live request limit (FR-CUS-005)
    const config = await this.platformConfig.getPlatformConfig();
    const liveCount = await this.repo.countLiveRequestsForCustomer(customerProfileId);
    if (liveCount >= config.maxConcurrentLiveRequests) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONCURRENT_REQUEST_LIMIT);
    }

    // 3. Contact details scan (BR-022)
    const contactScan = scanForContactDetails(existing.notes);
    if (contactScan.hasContactInfo) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.CONTACT_DETAILS_IN_TEXT);
    }

    // 4. Validate mandatory fields
    validateRequestForPublish({
      request: existing,
      mediaCount: existing.media.length,
    });

    // 5. Validate media state (must all be READY)
    for (const rm of existing.media) {
      if (rm.media.state === 'QUARANTINED') {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.MEDIA_QUARANTINED);
      }
      if (rm.media.state !== 'READY') {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.MEDIA_NOT_READY);
      }
    }

    // 6. Gold rate & indicative valuation
    let goldRateId: string | null = null;
    let indicativeValue: PrismaNamespace.Decimal | null = null;

    if (existing.purityKarat) {
      const latestRate = await this.repo.getLatestGoldRate(existing.purityKarat);
      if (!latestRate && existing.requestType === 'GOLD_BULLION') {
        throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, ErrorCode.GOLD_RATE_UNAVAILABLE);
      }

      if (latestRate) {
        goldRateId = latestRate.id;
        const weight = existing.weightGrams ?? existing.denominationGrams;
        if (weight) {
          const totalWeight = Number(weight) * (existing.quantity ?? 1);
          const computedValuation = totalWeight * Number(latestRate.ratePerGramAed);
          indicativeValue = new PrismaNamespace.Decimal(computedValuation.toFixed(2));
        }
      }
    }

    // Bullion minimum floor check (BR-010)
    if (existing.requestType === 'GOLD_BULLION') {
      const minFloor = Number(config.bullionMinimumAed);
      if (!indicativeValue || Number(indicativeValue) < minFloor) {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.BULLION_BELOW_MINIMUM, [
          {
            path: 'indicativeValue',
            code: 'BELOW_MINIMUM',
            message: `Bullion request indicative value must be at least ${config.bullionMinimumAed} AED.`,
          },
        ]);
      }
    }

    const now = new Date();
    const expiresAt = new Date(now.getTime() + config.requestLifetimeHours * 3600 * 1000);
    const reference = generateRequestReference(now.getUTCFullYear());

    const published = await withTx(this.prisma, async (tx) => {
      const row = await this.repo.update(
        existing.id,
        {
          state: 'PUBLISHED',
          reference,
          publishedAt: now,
          expiresAt,
          indicativeValue,
          goldRate: goldRateId ? { connect: { id: goldRateId } } : undefined,
        },
        tx,
      );

      // Outbox event for matching engine fan-out (FR-SYS-001)
      await enqueueOutbox(tx, {
        eventType: 'request.published',
        aggregateType: 'request',
        aggregateId: row.id,
        payload: {
          requestId: row.id,
          reference: row.reference,
          customerProfileId: row.customerProfileId,
          requestType: row.requestType,
          direction: row.direction,
          categoryId: row.categoryId,
          regionId: row.regionId,
          publishedAt: row.publishedAt?.toISOString(),
          expiresAt: row.expiresAt?.toISOString(),
        },
      });

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'REQUEST_PUBLISHED',
        entityType: 'request',
        entityId: row.id,
        afterValue: {
          reference: row.reference,
          state: row.state,
          publishedAt: row.publishedAt?.toISOString(),
          expiresAt: row.expiresAt?.toISOString(),
          indicativeValue: row.indicativeValue?.toString(),
        },
      });

      return row;
    });

    return {
      data: presentRequestForCustomer(published),
      matchCount: 0,
    };
  }

  async cancel(
    viewer: ViewerContext,
    id: string,
    reason?: string,
  ): Promise<RequestForCustomer> {
    const customerProfileId = this.assertCustomer(viewer);
    const existing = await this.repo.findByIdForCustomer(id, customerProfileId);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (existing.state === 'ACCEPTED') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.REQUEST_NOT_CANCELLABLE);
    }

    if (isTerminalRequestState(existing.state)) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.REQUEST_NOT_CANCELLABLE);
    }

    const cancelled = await withTx(this.prisma, async (tx) => {
      // Pending offers withdrawn by system (FR-CUS-017)
      await tx.offer.updateMany({
        where: { requestId: existing.id, state: 'PENDING' },
        data: { state: 'WITHDRAWN_BY_SYSTEM' },
      });

      const row = await this.repo.update(
        existing.id,
        {
          state: 'CANCELLED',
          cancellationReason: reason,
        },
        tx,
      );

      await enqueueOutbox(tx, {
        eventType: 'request.cancelled',
        aggregateType: 'request',
        aggregateId: row.id,
        payload: {
          requestId: row.id,
          cancellationReason: reason,
        },
      });

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'REQUEST_CANCELLED',
        entityType: 'request',
        entityId: row.id,
        afterValue: {
          state: 'CANCELLED',
          cancellationReason: reason,
        },
      });

      return row;
    });

    return presentRequestForCustomer(cancelled);
  }

  async duplicate(viewer: ViewerContext, id: string): Promise<RequestForCustomer> {
    const customerProfileId = this.assertCustomer(viewer);
    const existing = await this.repo.findByIdForCustomer(id, customerProfileId);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // FR-SYS-005 AC4: Duplicate is only allowed from EXPIRED or CANCELLED requests
    if (existing.state !== 'EXPIRED' && existing.state !== 'CANCELLED') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT, [
        { path: 'state', code: 'CANNOT_DUPLICATE', message: 'Only expired or cancelled requests can be duplicated.' },
      ]);
    }

    const mediaIds = existing.media
      .sort((a, b) => a.displayOrder - b.displayOrder)
      .map((rm) => rm.mediaId);

    const duplicated = await withTx(this.prisma, async (tx) => {
      const row = await this.repo.createDraft(
        {
          customerProfileId,
          requestType: existing.requestType,
          direction: existing.direction,
          categoryId: existing.categoryId,
          regionId: existing.regionId,
          notes: existing.notes ?? undefined,
          weightGrams: existing.weightGrams ?? undefined,
          weightIsApproximate: existing.weightIsApproximate,
          purityKarat: existing.purityKarat ?? undefined,
          ornamentType: existing.ornamentType ?? undefined,
          condition: existing.condition ?? undefined,
          denominationGrams: existing.denominationGrams ?? undefined,
          quantity: existing.quantity ?? undefined,
          mintOrRefiner: existing.mintOrRefiner ?? undefined,
          budgetMin: existing.budgetMin ?? undefined,
          budgetMax: existing.budgetMax ?? undefined,
          budgetIsFlexible: existing.budgetIsFlexible,
          gemstones: existing.gemstones as PrismaNamespace.InputJsonValue,
          mediaIds,
        },
        tx,
      );

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'REQUEST_DUPLICATED',
        entityType: 'request',
        entityId: row.id,
        afterValue: {
          duplicatedFromRequestId: existing.id,
          newRequestId: row.id,
        },
      });

      return row;
    });

    return presentRequestForCustomer(duplicated);
  }

  async getById(
    viewer: ViewerContext,
    id: string,
  ): Promise<RequestForCustomer | RequestForVendor> {
    const request = await this.repo.findById(id);
    if (!request) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // 1. Owning Customer
    if (viewer.role === 'CUSTOMER') {
      if (viewer.customerProfileId !== request.customerProfileId) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }
      return presentRequestForCustomer(request, { includeOffers: true });
    }

    // 2. Vendor
    if (viewer.role === 'VENDOR') {
      if (!viewer.vendorProfileId) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      // Check match set
      const match = await this.repo.findActiveMatch(request.id, viewer.vendorProfileId);
      if (!match || !match.isEligible) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      // Check terminal state to vendor
      if (isTerminalRequestState(request.state)) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      // If ACCEPTED, only winning vendor can see it
      if (request.state === 'ACCEPTED') {
        const winningOffer = request.offers?.find((o) => o.id === request.acceptedOfferId);
        if (!winningOffer || winningOffer.vendorProfileId !== viewer.vendorProfileId) {
          throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
        }
      }

      // Find vendor's own offer on this request if any
      const vendorOffer = request.offers?.find(
        (o) => o.vendorProfileId === viewer.vendorProfileId,
      );

      const customerProfile = await this.prisma.customerProfile.findUnique({
        where: { id: request.customerProfileId },
        select: { connectionCount: true },
      });

      return presentRequestForVendor(request, {
        customerConnectionCount: customerProfile?.connectionCount ?? 0,
        viewedAt: match.viewedAt,
        myOffer: vendorOffer
          ? {
              id: vendorOffer.id,
              state: vendorOffer.state,
              offeredPrice: vendorOffer.offeredPrice.toString(),
              submittedAt: vendorOffer.createdAt.toISOString(),
              expiresAt: vendorOffer.expiresAt.toISOString(),
            }
          : undefined,
      });
    }

    // 3. Admin
    if (viewer.role === 'ADMIN') {
      return presentRequestForCustomer(request, { includeOffers: true });
    }

    throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
  }

  async listCustomerRequests(
    viewer: ViewerContext,
    dto: ListCustomerRequestsDto,
  ): Promise<{ items: RequestForCustomer[]; nextCursor: string | null }> {
    const customerProfileId = this.assertCustomer(viewer);
    const limit = Math.min(Math.max(dto.limit ?? 20, 1), 50);

    const { items, nextCursor } = await this.repo.listForCustomer({
      customerProfileId,
      states: dto.state,
      requestType: dto.requestType,
      direction: dto.direction,
      q: dto.q,
      from: dto.from,
      to: dto.to,
      limit,
      cursor: dto.cursor,
    });

    return {
      items: items.map((r) => presentRequestForCustomer(r)),
      nextCursor,
    };
  }

  // Request Expiry Sweeper (1 min job, FR-SYS-005, C-07)
  async sweepExpiredRequests(now: Date = new Date()): Promise<number> {
    const expired = await this.prisma.request.findMany({
      where: {
        state: { in: ['PUBLISHED', 'OFFERS_RECEIVED'] },
        expiresAt: {
          not: null,
          lte: now,
        },
      },
      include: {
        customerProfile: { select: { userId: true } },
      },
    });

    if (expired.length === 0) return 0;

    for (const req of expired) {
      await this.prisma.$transaction(async (tx) => {
        await tx.request.update({
          where: { id: req.id },
          data: { state: 'EXPIRED' },
        });

        // Withdraw pending offers on this expired request
        await tx.offer.updateMany({
          where: { requestId: req.id, state: 'PENDING' },
          data: { state: 'WITHDRAWN_BY_SYSTEM' },
        });

        await enqueueOutbox(tx, {
          eventType: 'request.expired',
          aggregateType: 'request',
          aggregateId: req.id,
          payload: {
            requestId: req.id,
            customerUserId: req.customerProfile.userId,
            expiredAt: now.toISOString(),
          },
        });
      });
    }

    return expired.length;
  }

  // Request Expiry Warning (5 min job, T-6h, FR-SYS-005)
  async sweepRequestExpiryWarnings(now: Date = new Date()): Promise<number> {
    const sixHoursLater = new Date(now.getTime() + 6 * 60 * 60 * 1000);
    const warnings = await this.prisma.request.findMany({
      where: {
        state: { in: ['PUBLISHED', 'OFFERS_RECEIVED'] },
        expiresAt: {
          not: null,
          lte: sixHoursLater,
        },
        expiryWarnedAt: null,
      },
      include: {
        customerProfile: { select: { userId: true } },
      },
    });

    if (warnings.length === 0) return 0;

    for (const req of warnings) {
      await this.prisma.$transaction(async (tx) => {
        await tx.request.update({
          where: { id: req.id },
          data: { expiryWarnedAt: now },
        });

        await enqueueOutbox(tx, {
          eventType: 'request.expiry.warning',
          aggregateType: 'request',
          aggregateId: req.id,
          payload: {
            requestId: req.id,
            customerUserId: req.customerProfile.userId,
            expiresAt: req.expiresAt?.toISOString(),
            hoursRemaining: 6,
          },
        });
      });
    }

    return warnings.length;
  }

  // Draft Purge (Hourly job, FR-CUS-015 AC4)
  async purgeExpiredDrafts(now: Date = new Date()): Promise<{ warnedCount: number; purgedCount: number }> {
    const twentySevenDaysAgo = new Date(now.getTime() - 27 * 24 * 60 * 60 * 1000);
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    // 1. Warn drafts at 27 days
    const toWarn = await this.prisma.request.findMany({
      where: {
        state: 'DRAFT',
        createdAt: { lte: twentySevenDaysAgo },
        draftPurgeWarnedAt: null,
      },
      include: {
        customerProfile: { select: { userId: true } },
      },
    });

    for (const req of toWarn) {
      await this.prisma.$transaction(async (tx) => {
        await tx.request.update({
          where: { id: req.id },
          data: { draftPurgeWarnedAt: now },
        });

        await enqueueOutbox(tx, {
          eventType: 'request.draft.purge_warning',
          aggregateType: 'request',
          aggregateId: req.id,
          payload: {
            requestId: req.id,
            customerUserId: req.customerProfile.userId,
            daysRemaining: 3,
          },
        });
      });
    }

    // 2. Hard delete drafts at 30 days
    const toPurge = await this.prisma.request.findMany({
      where: {
        state: 'DRAFT',
        createdAt: { lte: thirtyDaysAgo },
      },
      select: { id: true },
    });

    for (const req of toPurge) {
      await this.prisma.$transaction(async (tx) => {
        await tx.requestMedia.deleteMany({ where: { requestId: req.id } });
        await tx.request.delete({ where: { id: req.id } });
      });
    }

    return {
      warnedCount: toWarn.length,
      purgedCount: toPurge.length,
    };
  }
}
