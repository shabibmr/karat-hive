import { HttpStatus, Injectable } from '@nestjs/common';
import type { Prisma, RequestType } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { Clock } from '../../../shared/clock';
import {
  presentRequestForVendor,
  type RequestForVendor,
} from '../../requests';
import type { MatchesFilterDto } from '../domain/matching-engine';
import { MatchingRepository } from '../repository/matching.repository';

@Injectable()
export class MatchingService {
  constructor(
    private readonly repo: MatchingRepository,
    private readonly clock: Clock,
  ) {}

  private assertActiveVendor(viewer: ViewerContext): string {
    if (viewer.role !== 'VENDOR' || !viewer.vendorProfileId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.VENDOR_NOT_ACTIVE);
    }
    if (viewer.accountState === 'SUSPENDED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_SUSPENDED);
    }
    if (viewer.accountState === 'DEACTIVATED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_DEACTIVATED);
    }
    return viewer.vendorProfileId;
  }

  async fanOutForRequest(
    requestId: string,
    requestType: RequestType,
    categoryId: string,
    regionId: string,
  ): Promise<number> {
    return this.repo.fanOutMatches(requestId, requestType, categoryId, regionId, this.clock.now());
  }

  async recomputeForVendor(vendorProfileId: string): Promise<number> {
    return this.repo.recomputeForVendor(vendorProfileId, this.clock.now());
  }

  async listMatches(
    viewer: ViewerContext,
    filter: MatchesFilterDto,
  ): Promise<{ data: RequestForVendor[]; meta: { nextCursor?: string } }> {
    const vendorProfileId = this.assertActiveVendor(viewer);

    let effectiveFilter = { ...filter };
    if (filter.presetId) {
      const preset = await this.repo.findFilterPreset(vendorProfileId, filter.presetId);
      if (preset && typeof preset.filters === 'object' && preset.filters !== null) {
        effectiveFilter = {
          ...(preset.filters as MatchesFilterDto),
          ...filter,
        };
      }
    }

    const { items, nextCursor } = await this.repo.listMatchesForVendor(
      vendorProfileId,
      effectiveFilter,
      this.clock.now(),
    );

    const presented = items.map((m) => {
      const r = m.request;
      const myOfferPrisma = r.offers && r.offers.length > 0 ? r.offers[0] : undefined;
      const myOffer = myOfferPrisma
        ? {
            id: myOfferPrisma.id,
            state: myOfferPrisma.state,
            offeredPrice: myOfferPrisma.offeredPrice.toString(),
            submittedAt: myOfferPrisma.submittedAt.toISOString(),
            expiresAt: myOfferPrisma.expiresAt.toISOString(),
          }
        : undefined;

      const custProfile = r.customerProfile;
      const customerRating = custProfile?.aggregateRating
        ? {
            average: custProfile.aggregateRating.toString(),
            count: custProfile.reviewCount,
            distribution: {},
            limitedHistory: custProfile.reviewCount < 3,
          }
        : undefined;

      return presentRequestForVendor(r, {
        customerConnectionCount: custProfile?.connectionCount ?? 0,
        customerRating,
        viewedAt: m.viewedAt,
        myOffer,
      });
    });

    return {
      data: presented,
      meta: { nextCursor },
    };
  }

  async markViewed(viewer: ViewerContext, requestId: string): Promise<void> {
    const vendorProfileId = this.assertActiveVendor(viewer);
    await this.repo.markMatchViewed(vendorProfileId, requestId, this.clock.now());
  }

  // Filter Presets (FR-VEN-009, VEN-S07)
  async listPresets(viewer: ViewerContext) {
    const vendorProfileId = this.assertActiveVendor(viewer);
    return this.repo.listFilterPresets(vendorProfileId);
  }

  async createPreset(viewer: ViewerContext, name: string, filters: Prisma.InputJsonValue) {
    const vendorProfileId = this.assertActiveVendor(viewer);
    return this.repo.createFilterPreset(vendorProfileId, name, filters);
  }

  async updatePreset(
    viewer: ViewerContext,
    id: string,
    name?: string,
    filters?: Prisma.InputJsonValue,
  ) {
    const vendorProfileId = this.assertActiveVendor(viewer);
    const existing = await this.repo.findFilterPreset(vendorProfileId, id);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return this.repo.updateFilterPreset(vendorProfileId, id, name, filters);
  }

  async deletePreset(viewer: ViewerContext, id: string): Promise<void> {
    const vendorProfileId = this.assertActiveVendor(viewer);
    const existing = await this.repo.findFilterPreset(vendorProfileId, id);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    await this.repo.deleteFilterPreset(vendorProfileId, id);
  }
}
