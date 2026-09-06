import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { OutboxDispatcher } from '../../../platform/outbox/outbox.dispatcher';
import type { ClaimedOutboxEvent } from '../../../platform/outbox/outbox.claimer';
import { MatchingService } from './matching.service';

@Injectable()
export class MatchingConsumerService implements OnModuleInit {
  private readonly logger = new Logger(MatchingConsumerService.name);

  constructor(
    private readonly dispatcher: OutboxDispatcher,
    private readonly matchingService: MatchingService,
  ) {}

  onModuleInit(): void {
    // Closes D-1 / T45: First real producer + consumer in codebase
    this.dispatcher.register(
      'request.published',
      'matching:fan-out',
      this.handleRequestPublished.bind(this),
    );
    this.logger.log('Registered consumer matching:fan-out for request.published');

    // Closes T37 / CP2-A12: Recomputes match set on vendor.eligibility.changed
    this.dispatcher.register(
      'vendor.eligibility.changed',
      'matching:eligibility-recompute',
      this.handleVendorEligibilityChanged.bind(this),
    );
    this.logger.log('Registered consumer matching:eligibility-recompute for vendor.eligibility.changed');
  }

  async handleRequestPublished(event: ClaimedOutboxEvent): Promise<void> {
    const payload = event.payload as { requestId?: string } | null;
    const requestId = payload?.requestId ?? event.aggregateId;

    if (!requestId) {
      this.logger.warn(`request.published event ${event.id} missing requestId`);
      return;
    }

    const matchedCount = await this.matchingService.fanOutRequest(requestId);
    this.logger.log(`matching:fan-out completed for request=${requestId} matched=${matchedCount}`);
  }

  async handleVendorEligibilityChanged(event: ClaimedOutboxEvent): Promise<void> {
    const payload = event.payload as { vendorProfileId?: string } | null;
    const vendorProfileId = payload?.vendorProfileId ?? event.aggregateId;

    if (!vendorProfileId) {
      this.logger.warn(`vendor.eligibility.changed event ${event.id} missing vendorProfileId`);
      return;
    }

    const result = await this.matchingService.recomputeVendorEligibility(vendorProfileId);
    this.logger.log(
      `matching:eligibility-recompute completed for vendor=${vendorProfileId} added=${result.addedRequestIds.length} removed=${result.removedCount}`,
    );
  }
}
