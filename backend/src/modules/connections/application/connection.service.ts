import { HttpStatus, Injectable } from '@nestjs/common';
import type { ClosedBy, ConnectionState, ContactChannel, RequestState } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { AuditWriter } from '../../audit';
import { PrismaService } from '../../../platform/db/prisma.service';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { Clock } from '../../../shared/clock';
import {
  presentOfferForCustomer,
  type OfferForCustomer,
  type PrismaOfferWithDetails,
} from '../../offers/presenter/offer.presenter';
import {
  presentConnectionForCustomer,
  presentConnectionForVendor,
  type ConnectionForCustomer,
  type ConnectionForVendor,
} from '../presenter/connection.presenter';
import { ConnectionRepository } from '../repository/connection.repository';

@Injectable()
export class ConnectionService {
  constructor(
    private readonly repo: ConnectionRepository,
    private readonly prisma: PrismaService,
    private readonly auditWriter: AuditWriter,
    private readonly clock: Clock,
  ) {}

  private assertCustomer(viewer: ViewerContext): string {
    if (viewer.role !== 'CUSTOMER' || !viewer.customerProfileId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
    return viewer.customerProfileId;
  }

  async acceptOffer(
    viewer: ViewerContext,
    offerId: string,
    confirmation: string,
  ): Promise<{ offer: OfferForCustomer; connection: ConnectionForCustomer }> {
    const customerProfileId = this.assertCustomer(viewer);

    if (confirmation !== 'REVEAL_AND_CONNECT') {
      throw new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.VALIDATION_FAILED);
    }

    const now = this.clock.now();

    // 1. Single PostgreSQL transaction with row-level locking on Request (AD-BE-09)
    const { connectionId } = await this.prisma.$transaction(async (tx) => {
      // Find offer basic info first to get requestId
      const targetOffer = await tx.offer.findUnique({
        where: { id: offerId },
        select: { id: true, requestId: true, state: true, expiresAt: true, vendorProfileId: true },
      });

      if (!targetOffer) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      // SELECT ... FOR UPDATE on parent Request to prevent concurrent accepts
      const [lockedRequest] = await tx.$queryRaw<
        Array<{
          id: string;
          state: RequestState;
          customer_profile_id: string;
          expires_at: Date | null;
        }>
      >`SELECT id, state, customer_profile_id, expires_at FROM request WHERE id = ${targetOffer.requestId}::uuid FOR UPDATE`;

      if (!lockedRequest) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      if (lockedRequest.customer_profile_id !== customerProfileId) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }

      if (lockedRequest.state === 'ACCEPTED') {
        throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_ALREADY_ACCEPTED);
      }

      if (lockedRequest.state !== 'PUBLISHED' && lockedRequest.state !== 'OFFERS_RECEIVED') {
        throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_NOT_OPEN);
      }

      // Re-check target offer state and expiry inside locked transaction
      if (targetOffer.state !== 'PENDING') {
        throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_NOT_PENDING);
      }

      if (targetOffer.expiresAt <= now) {
        throw new ApiException(HttpStatus.CONFLICT, ErrorCode.OFFER_EXPIRED);
      }

      // 2. Transition target offer to ACCEPTED
      await tx.offer.update({
        where: { id: targetOffer.id },
        data: {
          state: 'ACCEPTED',
          decidedAt: now,
        },
      });

      // 3. Transition request to ACCEPTED with acceptedOfferId
      await tx.request.update({
        where: { id: lockedRequest.id },
        data: {
          state: 'ACCEPTED',
          acceptedOfferId: targetOffer.id,
        },
      });

      // 4. Reject all other PENDING offers on this request
      const losers = await tx.offer.findMany({
        where: {
          requestId: lockedRequest.id,
          state: 'PENDING',
          id: { not: targetOffer.id },
        },
        select: { id: true },
      });

      if (losers.length > 0) {
        await tx.offer.updateMany({
          where: {
            requestId: lockedRequest.id,
            state: 'PENDING',
            id: { not: targetOffer.id },
          },
          data: {
            state: 'REJECTED',
            decidedAt: now,
          },
        });
      }

      // 5. Insert exactly one Connection row
      const connection = await tx.connection.create({
        data: {
          offerId: targetOffer.id,
          requestId: lockedRequest.id,
          customerProfileId,
          vendorProfileId: targetOffer.vendorProfileId,
          state: 'ACTIVE',
          identityRevealedAt: now,
        },
      });

      // 6. Update counts
      await tx.customerProfile.update({
        where: { id: customerProfileId },
        data: { connectionCount: { increment: 1 } },
      });

      await tx.vendorProfile.update({
        where: { id: targetOffer.vendorProfileId },
        data: { offersAcceptedCount: { increment: 1 } },
      });

      // 7. Audit log IDENTITY_REVEALED (NFR-021)
      await this.auditWriter.append(tx, {
        actorUserId: viewer.userId,
        action: 'IDENTITY_REVEALED',
        entityType: 'connection',
        entityId: connection.id,
        afterValue: {
          connectionId: connection.id,
          requestId: lockedRequest.id,
          offerId: targetOffer.id,
          customerProfileId,
          vendorProfileId: targetOffer.vendorProfileId,
          identityRevealedAt: now.toISOString(),
        },
      });

      // 8. Fetch winning vendor's userId for outbox payload
      const winnerVendor = await tx.vendorProfile.findUnique({
        where: { id: targetOffer.vendorProfileId },
        select: { userId: true },
      });

      // 9. Enqueue outbox event: offer.accepted
      await enqueueOutbox(tx, {
        eventType: 'offer.accepted',
        aggregateType: 'connection',
        aggregateId: connection.id,
        payload: {
          requestId: lockedRequest.id,
          acceptedOfferId: targetOffer.id,
          connectionId: connection.id,
          customerUserId: viewer.userId,
          winnerVendorUserId: winnerVendor?.userId ?? '',
          rejectedOfferIds: losers.map((l) => l.id),
          acceptedAt: now.toISOString(),
        },
      });

      return { connectionId: connection.id };
    });

    // Fetch full presented objects
    const conn = await this.repo.findConnectionById(connectionId);
    if (!conn) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const offerWithDetails = (await this.prisma.offer.findUnique({
      where: { id: offerId },
      include: {
        media: { include: { media: true } },
        vendorProfile: {
          include: {
            regions: { include: { region: true } },
          },
        },
      },
    })) as PrismaOfferWithDetails;

    return {
      offer: presentOfferForCustomer(offerWithDetails),
      connection: presentConnectionForCustomer(conn),
    };
  }

  async listMyConnections(
    viewer: ViewerContext,
    state?: ConnectionState,
    cursor?: string,
    limit?: number,
  ): Promise<{
    data: ConnectionForCustomer[] | ConnectionForVendor[];
    meta: { nextCursor?: string };
  }> {
    if (viewer.role === 'CUSTOMER' && viewer.customerProfileId) {
      const { items, nextCursor } = await this.repo.listConnectionsForCustomer(
        viewer.customerProfileId,
        state,
        cursor,
        limit,
      );
      return {
        data: items.map((c) => presentConnectionForCustomer(c)),
        meta: { nextCursor },
      };
    }

    if (viewer.role === 'VENDOR' && viewer.vendorProfileId) {
      const { items, nextCursor } = await this.repo.listConnectionsForVendor(
        viewer.vendorProfileId,
        state,
        cursor,
        limit,
      );
      return {
        data: items.map((c) => presentConnectionForVendor(c)),
        meta: { nextCursor },
      };
    }

    throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
  }

  async getConnectionById(
    viewer: ViewerContext,
    connectionId: string,
  ): Promise<ConnectionForCustomer | ConnectionForVendor> {
    const conn = await this.repo.findConnectionById(connectionId);
    if (!conn) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // Party authorization check
    if (viewer.role === 'CUSTOMER') {
      if (conn.customerProfileId !== viewer.customerProfileId) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }
      return presentConnectionForCustomer(conn);
    }

    if (viewer.role === 'VENDOR') {
      if (conn.vendorProfileId !== viewer.vendorProfileId) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
      }
      return presentConnectionForVendor(conn);
    }

    if (viewer.role === 'ADMIN') {
      return presentConnectionForCustomer(conn);
    }

    throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
  }

  async closeConnection(
    viewer: ViewerContext,
    connectionId: string,
    _reason?: string,
  ): Promise<ConnectionForCustomer | ConnectionForVendor> {
    const conn = await this.repo.findConnectionById(connectionId);
    if (!conn) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const isCustomer = viewer.role === 'CUSTOMER' && conn.customerProfileId === viewer.customerProfileId;
    const isVendor = viewer.role === 'VENDOR' && conn.vendorProfileId === viewer.vendorProfileId;
    const isAdmin = viewer.role === 'ADMIN';

    if (!isCustomer && !isVendor && !isAdmin) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (conn.state === 'CLOSED') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONNECTION_CLOSED);
    }

    const now = this.clock.now();
    const closedBy: ClosedBy = isCustomer
      ? 'CUSTOMER'
      : isVendor
      ? 'VENDOR'
      : 'ADMIN';

    const updated = await this.prisma.$transaction(async (tx) => {
      const closed = await this.repo.closeConnection(conn.id, closedBy, now, tx);

      await enqueueOutbox(tx, {
        eventType: 'connection.closed',
        aggregateType: 'connection',
        aggregateId: conn.id,
        payload: {
          connectionId: conn.id,
          requestId: conn.requestId,
          customerUserId: conn.customerProfile.userId,
          vendorUserId: conn.vendorProfile.userId,
          closedBy,
          closedAt: now.toISOString(),
        },
      });

      return closed;
    });

    if (isVendor) {
      return presentConnectionForVendor(updated);
    }
    return presentConnectionForCustomer(updated);
  }

  async recordContactEvent(
    viewer: ViewerContext,
    connectionId: string,
    channel: ContactChannel,
  ): Promise<void> {
    const conn = await this.repo.findConnectionById(connectionId);
    if (!conn) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const isCustomer = viewer.role === 'CUSTOMER' && conn.customerProfileId === viewer.customerProfileId;
    const isVendor = viewer.role === 'VENDOR' && conn.vendorProfileId === viewer.vendorProfileId;

    if (!isCustomer && !isVendor) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.NOT_A_PARTY);
    }

    if (conn.state !== 'ACTIVE') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONNECTION_CLOSED);
    }

    await this.repo.recordContactEvent(
      conn.id,
      isCustomer ? 'CUSTOMER' : 'VENDOR',
      channel,
      this.clock.now(),
    );
  }
}
