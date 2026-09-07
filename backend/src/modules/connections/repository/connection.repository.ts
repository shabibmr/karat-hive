import { Injectable } from '@nestjs/common';
import type {
  AuthorType,
  ClosedBy,
  ConnectionState,
  ContactChannel,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';
import type { PrismaConnectionWithDetails } from '../presenter/connection.presenter';

@Injectable()
export class ConnectionRepository {
  constructor(private readonly prisma: PrismaService) {}

  private db(tx?: DbTx) {
    return tx ?? this.prisma;
  }

  async findConnectionById(
    id: string,
    tx?: DbTx,
  ): Promise<PrismaConnectionWithDetails | null> {
    return this.db(tx).connection.findUnique({
      where: { id },
      include: {
        offer: true,
        request: {
          include: {
            category: true,
            region: true,
          },
        },
        customerProfile: {
          include: {
            user: true,
          },
        },
        vendorProfile: {
          include: {
            user: true,
            regions: {
              include: { region: true },
            },
          },
        },
      },
    });
  }

  async findConnectionByOfferId(
    offerId: string,
    tx?: DbTx,
  ): Promise<PrismaConnectionWithDetails | null> {
    return this.db(tx).connection.findUnique({
      where: { offerId },
      include: {
        offer: true,
        request: {
          include: {
            category: true,
            region: true,
          },
        },
        customerProfile: {
          include: {
            user: true,
          },
        },
        vendorProfile: {
          include: {
            user: true,
            regions: {
              include: { region: true },
            },
          },
        },
      },
    });
  }

  async listConnectionsForCustomer(
    customerProfileId: string,
    state?: ConnectionState,
    cursor?: string,
    limit: number = 20,
  ): Promise<{ items: PrismaConnectionWithDetails[]; nextCursor?: string }> {
    const clampedLimit = Math.min(Math.max(limit, 1), 50);

    const where: Prisma.ConnectionWhereInput = {
      customerProfileId,
      ...(state ? { state } : {}),
    };

    const connections = await this.prisma.connection.findMany({
      where,
      take: clampedLimit + 1,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        offer: true,
        request: {
          include: {
            category: true,
            region: true,
          },
        },
        customerProfile: {
          include: {
            user: true,
          },
        },
        vendorProfile: {
          include: {
            user: true,
            regions: {
              include: { region: true },
            },
          },
        },
      },
    });

    let nextCursor: string | undefined = undefined;
    let items = connections;
    if (connections.length > clampedLimit) {
      const next = connections[clampedLimit];
      if (next) {
        nextCursor = next.id;
      }
      items = connections.slice(0, clampedLimit);
    }

    return { items, nextCursor };
  }

  async listConnectionsForVendor(
    vendorProfileId: string,
    state?: ConnectionState,
    cursor?: string,
    limit: number = 20,
  ): Promise<{ items: PrismaConnectionWithDetails[]; nextCursor?: string }> {
    const clampedLimit = Math.min(Math.max(limit, 1), 50);

    const where: Prisma.ConnectionWhereInput = {
      vendorProfileId,
      ...(state ? { state } : {}),
    };

    const connections = await this.prisma.connection.findMany({
      where,
      take: clampedLimit + 1,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        offer: true,
        request: {
          include: {
            category: true,
            region: true,
          },
        },
        customerProfile: {
          include: {
            user: true,
          },
        },
        vendorProfile: {
          include: {
            user: true,
            regions: {
              include: { region: true },
            },
          },
        },
      },
    });

    let nextCursor: string | undefined = undefined;
    let items = connections;
    if (connections.length > clampedLimit) {
      const next = connections[clampedLimit];
      if (next) {
        nextCursor = next.id;
      }
      items = connections.slice(0, clampedLimit);
    }

    return { items, nextCursor };
  }

  async closeConnection(
    id: string,
    closedBy: ClosedBy,
    now: Date,
    tx?: DbTx,
  ): Promise<PrismaConnectionWithDetails> {
    return this.db(tx).connection.update({
      where: { id },
      data: {
        state: 'CLOSED',
        closedAt: now,
        closedBy,
      },
      include: {
        offer: true,
        request: {
          include: {
            category: true,
            region: true,
          },
        },
        customerProfile: {
          include: {
            user: true,
          },
        },
        vendorProfile: {
          include: {
            user: true,
            regions: {
              include: { region: true },
            },
          },
        },
      },
    });
  }

  async recordContactEvent(
    connectionId: string,
    initiatedBy: AuthorType,
    channel: ContactChannel,
    now: Date,
    tx?: DbTx,
  ) {
    return this.db(tx).contactEvent.create({
      data: {
        connectionId,
        initiatedBy,
        channel,
        occurredAt: now,
      },
    });
  }
}
