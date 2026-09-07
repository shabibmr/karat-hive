import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import type { RequestType } from '@prisma/client';
import { OutboxDispatcher } from '../../../platform/outbox/outbox.dispatcher';
import { MatchingService } from './matching.service';

@Injectable()
export class MatchingConsumer implements OnModuleInit {
  private readonly logger = new Logger(MatchingConsumer.name);

  constructor(
    private readonly dispatcher: OutboxDispatcher,
    private readonly matching: MatchingService,
  ) {}

  onModuleInit(): void {
    this.dispatcher.register('request.published', 'matching.fan_out', async (event) => {
      const payload = event.payload as {
        requestId?: string;
        requestType?: RequestType;
        categoryId?: string;
        regionId?: string;
      };

      if (!payload.requestId || !payload.requestType || !payload.categoryId || !payload.regionId) {
        this.logger.warn(`Incomplete payload for request.published: eventId=${event.id}`);
        return;
      }

      const matchCount = await this.matching.fanOutForRequest(
        payload.requestId,
        payload.requestType,
        payload.categoryId,
        payload.regionId,
      );

      this.logger.log(`Materialised ${matchCount} matches for request ${payload.requestId}`);
    });

    this.dispatcher.register('vendor.eligibility.changed', 'matching.recompute_vendor', async (event) => {
      const payload = event.payload as {
        vendorProfileId?: string;
      };

      if (!payload.vendorProfileId) {
        this.logger.warn(`Incomplete payload for vendor.eligibility.changed: eventId=${event.id}`);
        return;
      }

      const count = await this.matching.recomputeForVendor(payload.vendorProfileId);
      this.logger.log(`Recomputed ${count} matches for vendor ${payload.vendorProfileId}`);
    });
  }
}
