import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { Clock } from '../../../shared/clock';
import type { MatchFilters } from '../domain/matching.types';
import {
  MatchesListView,
  presentMatch,
} from '../presenter/matching.presenter';
import { MatchingRepository } from '../repository/matching.repository';

@Injectable()
export class MatchingService {
  private readonly logger = new Logger(MatchingService.name);

  constructor(
    private readonly repository: MatchingRepository,
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
  ) {}

  /**
   * Fan-out consumer for request.published (T21, AD-ASYNC-02).
   * Emits one request.matched per matched vendor.
   */
  async fanOutRequest(requestId: string): Promise<number> {
    const now = this.clock.now();
    const vendorProfileIds = await this.repository.findEligibleVendorProfileIds(requestId, now);
    this.logger.log(`Fan-out request=${requestId} eligibleVendors=${vendorProfileIds.length}`);

    let count = 0;
    for (const vendorProfileId of vendorProfileIds) {
      await withTx(this.prisma, async (tx) => {
        const match = await this.repository.createMatch(requestId, vendorProfileId, now, tx);
        if (match) {
          count++;
          // Emits one request.matched per matched vendor (AD-ASYNC-02)
          await enqueueOutbox(tx, {
            eventType: 'request.matched',
            aggregateType: 'request_match',
            aggregateId: match.id,
            payload: {
              matchId: match.id,
              requestId,
              vendorProfileId,
              matchedAt: now.toISOString(),
            },
          });
        }
      });
    }

    return count;
  }

  async listMatches(vendorProfileId: string, filters: MatchFilters): Promise<MatchesListView> {
    const now = this.clock.now();
    const result = await this.repository.listMatches(vendorProfileId, filters, now);

    return {
      data: result.items.map((m) => presentMatch(m as Parameters<typeof presentMatch>[0])),
      meta: {
        nextCursor: result.nextCursor,
      },
    };
  }

  async markViewed(vendorProfileId: string, requestId: string): Promise<boolean> {
    const now = this.clock.now();
    return this.repository.markViewed(vendorProfileId, requestId, now);
  }

  /**
   * Recomputes vendor eligibility upon vendor.eligibility.changed (T37, CP2-A12).
   */
  async recomputeVendorEligibility(
    vendorProfileId: string,
  ): Promise<{ addedRequestIds: string[]; removedCount: number }> {
    const now = this.clock.now();
    return withTx(this.prisma, async (tx) => {
      const result = await this.repository.recomputeVendorEligibility(vendorProfileId, now, tx);
      for (const requestId of result.addedRequestIds) {
        await enqueueOutbox(tx, {
          eventType: 'request.matched',
          aggregateType: 'request_match',
          aggregateId: `${requestId}_${vendorProfileId}`,
          payload: {
            requestId,
            vendorProfileId,
            matchedAt: now.toISOString(),
          },
        });
      }
      this.logger.log(
        `Eligibility recompute vendor=${vendorProfileId} added=${result.addedRequestIds.length} removed=${result.removedCount}`,
      );
      return result;
    });
  }
}
