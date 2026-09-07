import { HttpStatus, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { PrismaService } from '../../../platform/db/prisma.service';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { Clock } from '../../../shared/clock';
import {
  assertNoContactDetails,
  calculateClampedExpiry,
  type DeclineOfferInput,
  type ReviseOfferInput,
  type SubmitOfferInput,
} from '../domain/offer-validator';
import {
  presentOfferForCustomer,
  presentOfferForVendor,
  type OfferForCustomer,
  type OfferForVendor,
  type VendorRatingSummary,
} from '../presenter/offer.presenter';
import {
  OfferRepository,
  type ListRequestOffersFilter,
  type ListVendorOffersFilter,
} from '../repository/offer.repository';

@Injectable()
export class OfferService {
  constructor(
    private readonly repo: OfferRepository,
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
  ) {}

  private assertActiveVendor(viewer: ViewerContext): string {
    if (viewer.role !== 'VENDOR' || !viewer.vendorProfileId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
    return viewer.vendorProfileId;
  }

  private assertCustomer(viewer: ViewerContext): string {
    if (viewer.role !== 'CUSTOMER' || !viewer.customerProfileId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
    return viewer.customerProfileId;
  }

  async submitOffer(
    viewer: ViewerContext,
    requestId: string,
    input: SubmitOfferInput,
  ): Promise<OfferForVendor> {
    const vendorProfileId = this.assertActiveVendor(viewer);
    const now = this.clock.now();

    // 1. Fetch request
    const request = await this.repo.findRequestForOffer(requestId);
    if (!request) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // 2. Validate request state: must be PUBLISHED or OFFERS_RECEIVED, and unexpired
    if (
      (request.state !== 'PUBLISHED' && request.state !== 'OFFERS_RECEIVED') ||
      !request.expiresAt ||
      request.expiresAt <= now
    ) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_NOT_OPEN);
    }

    // 3. Check vendor eligibility: VERIFIED + ACTIVE + live Type Subscription
    const eligibility = await this.repo.checkVendorEligibility(
      vendorProfileId,
      request.requestType,
    );
    if (!eligibility.isFound || !eligibility.isActive) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.VENDOR_NOT_ACTIVE);
    }
    if (!eligibility.hasSubscription) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.SUBSCRIPTION_REQUIRED);
    }

    // 4. Check if vendor is in the match set
    const inMatchSet = await this.repo.isInMatchSet(vendorProfileId, requestId);
    if (!inMatchSet) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.NOT_IN_MATCH_SET);
    }

    // 5. BR-009: At most one PENDING offer per vendor per request
    const existingPending = await this.repo.findPendingOfferByVendor(
      vendorProfileId,
      requestId,
    );
    if (existingPending) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_ALREADY_PENDING);
    }

    // 6. Scan vendor note for forbidden contact details (BR-022)
    assertNoContactDetails(input.vendorNote);

    // 7. Clamp expiry to request expiry (FR-VEN-013)
    const expiresAt = calculateClampedExpiry(now, input.validityHours, request.expiresAt);

    // 8. Execute in atomic transaction
    const createdOffer = await this.prisma.$transaction(async (tx) => {
      const offer = await this.repo.createOffer(
        {
          requestId,
          vendorProfileId,
          terms: input,
          expiresAt,
          now,
        },
        tx,
      );

      // Enqueue outbox event: offer.submitted
      await enqueueOutbox(tx, {
        eventType: 'offer.submitted',
        aggregateType: 'offer',
        aggregateId: offer.id,
        payload: {
          offerId: offer.id,
          requestId: request.id,
          customerUserId: request.customerProfile.userId,
          vendorProfileId,
          isFirstOfferOnRequest: request.state === 'PUBLISHED',
          submittedAt: now.toISOString(),
        },
      });

      return offer;
    });

    return presentOfferForVendor(createdOffer, { request });
  }

  async reviseOffer(
    viewer: ViewerContext,
    offerId: string,
    input: ReviseOfferInput,
  ): Promise<OfferForVendor> {
    const vendorProfileId = this.assertActiveVendor(viewer);
    const now = this.clock.now();

    const offer = await this.repo.findOfferById(offerId);
    if (!offer || offer.vendorProfileId !== vendorProfileId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (offer.state !== 'PENDING') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_NOT_PENDING);
    }

    if (offer.expiresAt <= now) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_EXPIRED);
    }

    if (offer.revisionCount >= 3) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_REVISION_LIMIT);
    }

    const request = await this.repo.findRequestForOffer(offer.requestId);
    if (
      !request ||
      (request.state !== 'PUBLISHED' && request.state !== 'OFFERS_RECEIVED') ||
      !request.expiresAt ||
      request.expiresAt <= now
    ) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_NOT_OPEN);
    }

    assertNoContactDetails(input.vendorNote);

    const newExpiresAt = calculateClampedExpiry(now, input.validityHours, request.expiresAt);

    const previousTerms = {
      offeredPrice: offer.offeredPrice.toString(),
      makingCharges: offer.makingCharges ? offer.makingCharges.toString() : null,
      ratePerGram: offer.ratePerGram ? offer.ratePerGram.toString() : null,
      deliveryTimeframe: offer.deliveryTimeframe,
      warrantyTerms: offer.warrantyTerms,
      vendorNote: offer.vendorNote,
      validityHours: offer.validityHours,
    };

    const revisedOffer = await this.prisma.$transaction(async (tx) => {
      const revised = await this.repo.createRevision(
        {
          offerId: offer.id,
          previousTerms,
          newPrice: new Prisma.Decimal(input.offeredPrice),
          newMakingCharges: input.makingCharges !== undefined
            ? new Prisma.Decimal(input.makingCharges)
            : null,
          newRatePerGram: input.ratePerGram !== undefined
            ? new Prisma.Decimal(input.ratePerGram)
            : null,
          newDeliveryTimeframe: input.deliveryTimeframe ?? null,
          newWarrantyTerms: input.warrantyTerms ?? null,
          newVendorNote: input.vendorNote ?? null,
          newValidityHours: input.validityHours,
          newExpiresAt,
          newRevisionCount: offer.revisionCount + 1,
          now,
        },
        tx,
      );

      await enqueueOutbox(tx, {
        eventType: 'offer.revised',
        aggregateType: 'offer',
        aggregateId: offer.id,
        payload: {
          offerId: offer.id,
          requestId: offer.requestId,
          customerUserId: request.customerProfile.userId,
          previousPrice: offer.offeredPrice.toString(),
          newPrice: input.offeredPrice.toString(),
          newExpiresAt: newExpiresAt.toISOString(),
          revisedAt: now.toISOString(),
        },
      });

      return revised;
    });

    return presentOfferForVendor(revisedOffer, { request });
  }

  async withdrawOffer(viewer: ViewerContext, offerId: string): Promise<OfferForVendor> {
    const vendorProfileId = this.assertActiveVendor(viewer);
    const now = this.clock.now();

    const offer = await this.repo.findOfferById(offerId);
    if (!offer || offer.vendorProfileId !== vendorProfileId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (offer.state !== 'PENDING') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_NOT_PENDING);
    }

    const request = await this.repo.findRequestForOffer(offer.requestId);
    if (!request) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const withdrawn = await this.prisma.$transaction(async (tx) => {
      const updated = await this.repo.updateOfferState(
        offer.id,
        'WITHDRAWN',
        { decidedAt: now },
        tx,
      );

      // If no other PENDING offers remain, revert request from OFFERS_RECEIVED to PUBLISHED
      const remainingPending = await this.repo.countPendingOffersOnRequest(request.id, tx);
      if (remainingPending === 0 && request.state === 'OFFERS_RECEIVED') {
        await tx.request.update({
          where: { id: request.id },
          data: { state: 'PUBLISHED' },
        });
      }

      await enqueueOutbox(tx, {
        eventType: 'offer.withdrawn',
        aggregateType: 'offer',
        aggregateId: offer.id,
        payload: {
          offerId: offer.id,
          requestId: offer.requestId,
          customerUserId: request.customerProfile.userId,
          withdrawnAt: now.toISOString(),
        },
      });

      return updated;
    });

    return presentOfferForVendor(withdrawn, { request });
  }

  async declineOffer(
    viewer: ViewerContext,
    offerId: string,
    input: DeclineOfferInput,
  ): Promise<OfferForCustomer> {
    const customerProfileId = this.assertCustomer(viewer);
    const now = this.clock.now();

    const offer = await this.repo.findOfferById(offerId);
    if (!offer) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const request = await this.repo.findRequestForOffer(offer.requestId);
    if (!request || request.customerProfileId !== customerProfileId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (offer.state !== 'PENDING') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_NOT_PENDING);
    }

    const declined = await this.prisma.$transaction(async (tx) => {
      const updated = await this.repo.updateOfferState(
        offer.id,
        'REJECTED',
        {
          declineReason: input.reason ?? null,
          decidedAt: now,
        },
        tx,
      );

      // If no other PENDING offers remain, revert request to PUBLISHED
      const remainingPending = await this.repo.countPendingOffersOnRequest(request.id, tx);
      if (remainingPending === 0 && request.state === 'OFFERS_RECEIVED') {
        await tx.request.update({
          where: { id: request.id },
          data: { state: 'PUBLISHED' },
        });
      }

      return updated;
    });

    return presentOfferForCustomer(declined);
  }

  async listOffersForRequest(
    viewer: ViewerContext,
    requestId: string,
    filter: ListRequestOffersFilter,
  ): Promise<{ data: OfferForCustomer[]; meta: { nextCursor?: string } }> {
    const customerProfileId = this.assertCustomer(viewer);
    const request = await this.repo.findRequestForOffer(requestId);
    if (!request || request.customerProfileId !== customerProfileId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // Default sort: PRICE_ASC for BUY, PRICE_DESC for SELL (FR-CUS-021 AC3)
    const effectiveFilter: ListRequestOffersFilter = {
      ...filter,
      sort: filter.sort ?? (request.direction === 'SELL' ? 'PRICE_DESC' : 'PRICE_ASC'),
    };

    const { items, nextCursor } = await this.repo.listOffersForRequest(
      requestId,
      effectiveFilter,
      this.clock.now(),
    );

    return {
      data: items.map(presentOfferForCustomer),
      meta: { nextCursor },
    };
  }

  async listMyOffers(
    viewer: ViewerContext,
    filter: ListVendorOffersFilter,
  ): Promise<{ data: OfferForVendor[]; meta: { nextCursor?: string } }> {
    const vendorProfileId = this.assertActiveVendor(viewer);
    const { items, nextCursor } = await this.repo.listOffersForVendor(
      vendorProfileId,
      filter,
    );

    return {
      data: items.map((o) => presentOfferForVendor(o)),
      meta: { nextCursor },
    };
  }

  async getOfferById(
    viewer: ViewerContext,
    offerId: string,
  ): Promise<OfferForCustomer | OfferForVendor> {
    const offer = await this.repo.findOfferById(offerId);
    if (!offer) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const request = await this.repo.findRequestForOffer(offer.requestId);
    if (!request) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // 1. Customer view
    if (viewer.role === 'CUSTOMER' && viewer.customerProfileId === request.customerProfileId) {
      await this.repo.markOfferViewedByCustomer(offerId, this.clock.now());
      return presentOfferForCustomer(offer);
    }

    // 2. Vendor view
    if (viewer.role === 'VENDOR' && viewer.vendorProfileId === offer.vendorProfileId) {
      const awardedElsewhere =
        request.state === 'ACCEPTED' && request.acceptedOfferId !== offer.id;
      return presentOfferForVendor(offer, { request, awardedElsewhere });
    }

    // 3. Admin view
    if (viewer.role === 'ADMIN') {
      return presentOfferForCustomer(offer);
    }

    throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
  }

  async markOfferViewed(viewer: ViewerContext, offerId: string): Promise<void> {
    const customerProfileId = this.assertCustomer(viewer);
    const offer = await this.repo.findOfferById(offerId);
    if (!offer) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const request = await this.repo.findRequestForOffer(offer.requestId);
    if (!request || request.customerProfileId !== customerProfileId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    await this.repo.markOfferViewedByCustomer(offerId, this.clock.now());
  }

  async getVendorRating(
    viewer: ViewerContext,
    offerId: string,
  ): Promise<VendorRatingSummary> {
    this.assertCustomer(viewer);
    const offer = await this.repo.findOfferById(offerId);
    if (!offer) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const vp = offer.vendorProfile;
    const primaryVendorRegion = vp?.regions && vp.regions.length > 0 ? vp.regions[0]?.region : undefined;
    const reviewCount = vp?.reviewCount ?? 0;
    const ratingAvg = vp?.aggregateRating ? vp.aggregateRating.toString() : '0.0';

    // Top 10 published reviews
    const publishedReviews = await this.prisma.review.findMany({
      where: {
        connection: { vendorProfileId: offer.vendorProfileId },
        state: 'PUBLISHED',
      },
      take: 10,
      orderBy: { publishedAt: 'desc' },
      select: {
        id: true,
        rating: true,
        comment: true,
        publishedAt: true,
      },
    });

    return {
      vendor: {
        label: `Vendor · ${primaryVendorRegion?.nameEn ?? 'UAE'}`,
        region: primaryVendorRegion
          ? {
              id: primaryVendorRegion.id,
              nameEn: primaryVendorRegion.nameEn,
              nameAr: primaryVendorRegion.nameAr,
              isActive: primaryVendorRegion.isActive,
              displayOrder: primaryVendorRegion.displayOrder,
            }
          : undefined,
        connectionCount: vp?.offersAcceptedCount ?? 0,
        rating: {
          average: ratingAvg,
          count: reviewCount,
          distribution: {},
          limitedHistory: reviewCount < 3,
        },
      },
      reviews: publishedReviews.map((r, idx) => ({
        id: r.id,
        rating: r.rating,
        comment: r.comment ?? undefined,
        publishedAt: r.publishedAt?.toISOString(),
        reviewerLabel: `Customer ${String.fromCharCode(65 + (idx % 26))}.`,
      })),
    };
  }

  // Offer Expiry Sweeper (FR-SYS-004 / 1 min job)
  async sweepExpiredOffers(now: Date = this.clock.now()): Promise<number> {
    const expiredOffers = await this.repo.findExpiredPendingOffers(now);
    if (expiredOffers.length === 0) return 0;

    for (const offer of expiredOffers) {
      await this.prisma.$transaction(async (tx) => {
        await this.repo.updateOfferState(offer.id, 'EXPIRED', { decidedAt: now }, tx);

        // Check if last pending offer
        const remaining = await this.repo.countPendingOffersOnRequest(offer.requestId, tx);
        const req = offer.request;
        if (remaining === 0 && req.state === 'OFFERS_RECEIVED') {
          await tx.request.update({
            where: { id: req.id },
            data: { state: 'PUBLISHED' },
          });
        }

        await enqueueOutbox(tx, {
          eventType: 'offer.expired',
          aggregateType: 'offer',
          aggregateId: offer.id,
          payload: {
            offerId: offer.id,
            requestId: offer.requestId,
            customerUserId: req.customerProfile.userId,
            vendorUserId: offer.vendorProfile.userId,
            expiredAt: now.toISOString(),
            wasLastNonTerminalOffer: remaining === 0,
          },
        });
      });
    }

    return expiredOffers.length;
  }

  // Offer Expiry Warning (FR-VEN-013 AC4 / 5 min job)
  async sweepExpiryWarnings(now: Date = this.clock.now()): Promise<number> {
    const sixHoursLater = new Date(now.getTime() + 6 * 60 * 60 * 1000);
    const warningOffers = await this.repo.findExpiringPendingOffersWarning(sixHoursLater);
    if (warningOffers.length === 0) return 0;

    for (const offer of warningOffers) {
      await this.prisma.$transaction(async (tx) => {
        await tx.offer.update({
          where: { id: offer.id },
          data: { expiryWarnedAt: now },
        });

        await enqueueOutbox(tx, {
          eventType: 'offer.expiry.warning',
          aggregateType: 'offer',
          aggregateId: offer.id,
          payload: {
            offerId: offer.id,
            requestId: offer.requestId,
            vendorUserId: offer.vendorProfile.userId,
            expiresAt: offer.expiresAt.toISOString(),
            hoursRemaining: 6,
          },
        });
      });
    }

    return warningOffers.length;
  }
}
