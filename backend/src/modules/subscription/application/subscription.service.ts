import { Injectable } from '@nestjs/common';
import { RequestType, SubscriptionState, type VendorTypeSubscription } from '@prisma/client';
import { Clock } from '../../../shared/clock';
import { ALL_REQUEST_TYPES, computeSubscriptionState } from '../domain/subscription.types';
import { presentSubscription, type SubscriptionView } from '../presenter/subscription.presenter';
import { SubscriptionRepository } from '../repository/subscription.repository';

export type GrantSubscriptionInput = {
  vendorProfileId: string;
  requestType: RequestType;
  periodStart: Date;
  periodEnd: Date;
  priceAed: string | number;
  graceEndsAt?: Date | null;
  paymentReference?: string | null;
};

@Injectable()
export class SubscriptionService {
  constructor(
    private readonly repository: SubscriptionRepository,
    private readonly clock: Clock,
  ) {}

  /**
   * Returns entitlements for all four request types for the given vendor (BR-002, FR-VEN-031).
   */
  async getSubscriptions(vendorProfileId: string): Promise<SubscriptionView[]> {
    const now = this.clock.now();
    const rows = await this.repository.listByVendor(vendorProfileId);

    // Index rows by requestType, taking the latest row per type
    const byType = new Map<RequestType, VendorTypeSubscription>();
    for (const row of rows) {
      if (!byType.has(row.requestType)) {
        byType.set(row.requestType, row);
      }
    }

    return ALL_REQUEST_TYPES.map((type) => {
      const sub = byType.get(type) ?? null;
      return presentSubscription(type, sub, now);
    });
  }

  /**
   * Admin grant or seed path to grant/renew a vendor type subscription (AD-API-04).
   */
  async grantSubscription(input: GrantSubscriptionInput): Promise<SubscriptionView> {
    const now = this.clock.now();
    const saved = await this.repository.upsert({
      vendorProfileId: input.vendorProfileId,
      requestType: input.requestType,
      periodStart: input.periodStart,
      periodEnd: input.periodEnd,
      priceAed: input.priceAed,
      state: SubscriptionState.ACTIVE,
      graceEndsAt: input.graceEndsAt ?? null,
      paymentReference: input.paymentReference ?? null,
    });

    return presentSubscription(input.requestType, saved, now);
  }

  /**
   * Checks whether a vendor holds a currently active or grace entitlement for a request type (BR-002).
   */
  async hasActiveSubscription(
    vendorProfileId: string,
    requestType: RequestType,
  ): Promise<boolean> {
    const now = this.clock.now();
    const sub = await this.repository.findActiveByVendorAndType(vendorProfileId, requestType);
    if (!sub) return false;
    const effective = computeSubscriptionState(sub, now);
    return effective === 'ACTIVE' || effective === 'GRACE';
  }
}
