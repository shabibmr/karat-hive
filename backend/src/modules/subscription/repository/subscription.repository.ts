import { Injectable } from '@nestjs/common';
import { Prisma, RequestType, SubscriptionState, type VendorTypeSubscription } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';

export type UpsertSubscriptionInput = {
  vendorProfileId: string;
  requestType: RequestType;
  periodStart: Date;
  periodEnd: Date;
  priceAed: string | number | Prisma.Decimal;
  state?: SubscriptionState;
  graceEndsAt?: Date | null;
  paymentReference?: string | null;
};

@Injectable()
export class SubscriptionRepository {
  constructor(private readonly prisma: PrismaService) {}

  async listByVendor(
    vendorProfileId: string,
    tx?: DbTx,
  ): Promise<VendorTypeSubscription[]> {
    const client = tx ?? this.prisma;
    return client.vendorTypeSubscription.findMany({
      where: { vendorProfileId },
      orderBy: [{ periodEnd: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async findActiveByVendorAndType(
    vendorProfileId: string,
    requestType: RequestType,
    tx?: DbTx,
  ): Promise<VendorTypeSubscription | null> {
    const client = tx ?? this.prisma;
    return client.vendorTypeSubscription.findFirst({
      where: {
        vendorProfileId,
        requestType,
        state: { in: [SubscriptionState.ACTIVE, SubscriptionState.GRACE] },
      },
      orderBy: [{ periodEnd: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async upsert(
    input: UpsertSubscriptionInput,
    tx?: DbTx,
  ): Promise<VendorTypeSubscription> {
    const client = tx ?? this.prisma;
    const priceAed =
      typeof input.priceAed === 'number' || typeof input.priceAed === 'string'
        ? new Prisma.Decimal(input.priceAed)
        : input.priceAed;

    // Check if there is an existing non-cancelled subscription for this vendor and requestType
    const existing = await client.vendorTypeSubscription.findFirst({
      where: {
        vendorProfileId: input.vendorProfileId,
        requestType: input.requestType,
      },
      orderBy: [{ periodEnd: 'desc' }, { createdAt: 'desc' }],
    });

    if (existing) {
      return client.vendorTypeSubscription.update({
        where: { id: existing.id },
        data: {
          state: input.state ?? SubscriptionState.ACTIVE,
          periodStart: input.periodStart,
          periodEnd: input.periodEnd,
          priceAed,
          graceEndsAt: input.graceEndsAt ?? null,
          paymentReference: input.paymentReference ?? null,
        },
      });
    }

    return client.vendorTypeSubscription.create({
      data: {
        vendorProfileId: input.vendorProfileId,
        requestType: input.requestType,
        state: input.state ?? SubscriptionState.ACTIVE,
        periodStart: input.periodStart,
        periodEnd: input.periodEnd,
        priceAed,
        graceEndsAt: input.graceEndsAt ?? null,
        paymentReference: input.paymentReference ?? null,
      },
    });
  }
}
