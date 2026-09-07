import { HttpStatus, Injectable } from '@nestjs/common';
import type { Prisma, RequestType, SubscriptionState } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { PrismaService } from '../../../platform/db/prisma.service';
import { AuditWriter } from '../../audit';
import {
  presentSubscription,
  type SubscriptionView,
} from '../presenter/subscription.presenter';
import {
  type PerformanceFilters,
  SubscriptionRepository,
  type VendorPerformanceData,
} from '../repository/subscription.repository';

export interface GrantSubscriptionDto {
  requestType: RequestType;
  periodStart: Date;
  periodEnd: Date;
  priceAed: string | number;
  paymentReference?: string;
}

export interface PatchSubscriptionDto {
  state?: 'GRACE' | 'EXPIRED' | 'CANCELLED';
  periodEnd?: Date;
  reasonText: string;
}

@Injectable()
export class SubscriptionService {
  constructor(
    private readonly repo: SubscriptionRepository,
    private readonly prisma: PrismaService,
    private readonly audit: AuditWriter,
  ) {}

  async getMySubscriptions(viewer: ViewerContext): Promise<SubscriptionView[]> {
    if (viewer.role !== 'VENDOR') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    const profile = await this.repo.findVendorProfileByUserId(viewer.userId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const subs = await this.repo.listSubscriptionsForVendor(profile.id);
    return subs.map(presentSubscription);
  }

  async grantSubscriptionByAdmin(
    vendorProfileId: string,
    dto: GrantSubscriptionDto,
    adminUserId: string,
  ): Promise<SubscriptionView> {
    const profile = await this.repo.findVendorProfileById(vendorProfileId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const sub = await this.prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      const created = await this.repo.createSubscription(tx, {
        vendorProfileId,
        requestType: dto.requestType,
        state: 'ACTIVE',
        periodStart: dto.periodStart,
        periodEnd: dto.periodEnd,
        priceAed: dto.priceAed,
        paymentReference: dto.paymentReference,
      });

      await enqueueOutbox(tx, {
        eventType: 'vendor.eligibility.changed',
        aggregateType: 'vendor_profile',
        aggregateId: vendorProfileId,
        payload: {
          vendorProfileId,
          requestType: dto.requestType,
          reason: 'SUBSCRIPTION_GRANTED',
        },
      });

      await this.audit.append(tx, {
        actorUserId: adminUserId,
        action: 'VENDOR_SUBSCRIPTION_GRANTED',
        entityType: 'vendor_type_subscription',
        entityId: created.id,
        afterValue: {
          requestType: created.requestType,
          state: created.state,
          periodStart: created.periodStart.toISOString(),
          periodEnd: created.periodEnd.toISOString(),
          priceAed: Number(created.priceAed).toFixed(2),
          paymentReference: created.paymentReference,
        },
      });

      return created;
    });

    return presentSubscription(sub);
  }

  async patchSubscriptionByAdmin(
    vendorProfileId: string,
    requestType: RequestType,
    dto: PatchSubscriptionDto,
    adminUserId: string,
  ): Promise<SubscriptionView> {
    const current = await this.repo.findActiveOrGraceByVendorAndType(
      vendorProfileId,
      requestType,
    );
    if (!current) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const sub = await this.prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      const updated = await this.repo.updateSubscription(tx, current.id, {
        state: dto.state as SubscriptionState | undefined,
        periodEnd: dto.periodEnd,
      });

      await enqueueOutbox(tx, {
        eventType: 'vendor.eligibility.changed',
        aggregateType: 'vendor_profile',
        aggregateId: vendorProfileId,
        payload: {
          vendorProfileId,
          requestType,
          reason: 'SUBSCRIPTION_PATCHED',
          reasonText: dto.reasonText,
        },
      });

      await this.audit.append(tx, {
        actorUserId: adminUserId,
        action: 'VENDOR_SUBSCRIPTION_PATCHED',
        entityType: 'vendor_type_subscription',
        entityId: updated.id,
        beforeValue: {
          state: current.state,
          periodEnd: current.periodEnd.toISOString(),
        },
        afterValue: {
          state: updated.state,
          periodEnd: updated.periodEnd.toISOString(),
          reasonText: dto.reasonText,
        },
      });

      return updated;
    });

    return presentSubscription(sub);
  }

  async getVendorPerformance(
    viewer: ViewerContext,
    filters: PerformanceFilters,
  ): Promise<VendorPerformanceData> {
    if (viewer.role !== 'VENDOR') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    const profile = await this.repo.findVendorProfileByUserId(viewer.userId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    return this.repo.getVendorPerformance(profile.id, filters);
  }
}
