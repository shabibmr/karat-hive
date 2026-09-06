import { Injectable } from '@nestjs/common';
import { Direction, Prisma, Request, RequestState, RequestType } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';
import type { CreateRequestDraftInput } from '../domain/requests.types';

@Injectable()
export class RequestsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string, tx?: DbTx): Promise<Request | null> {
    const client = tx ?? this.prisma;
    return client.request.findUnique({
      where: { id },
      include: {
        customerProfile: true,
        category: true,
        region: true,
        media: {
          include: { media: true },
          orderBy: { displayOrder: 'asc' },
        },
      },
    });
  }

  async findVendorMatch(requestId: string, vendorProfileId: string, tx?: DbTx) {
    const client = tx ?? this.prisma;
    return client.requestMatch.findUnique({
      where: {
        requestId_vendorProfileId: {
          requestId,
          vendorProfileId,
        },
      },
    });
  }

  async createDraft(input: CreateRequestDraftInput, tx?: DbTx): Promise<Request> {
    const client = tx ?? this.prisma;
    const direction = input.direction ?? (input.requestType === RequestType.SELL_OLD_GOLD ? Direction.SELL : Direction.BUY);

    return client.request.create({
      data: {
        customerProfileId: input.customerProfileId,
        requestType: input.requestType,
        direction,
        state: RequestState.DRAFT,
        categoryId: input.categoryId,
        regionId: input.regionId,
        notes: input.notes ?? null,
        weightGrams: input.weightGrams ? new Prisma.Decimal(input.weightGrams) : null,
        weightIsApproximate: input.weightIsApproximate ?? false,
        purityKarat: input.purityKarat ?? null,
        ornamentType: input.ornamentType ?? null,
        condition: input.condition ?? null,
        denominationGrams: input.denominationGrams ? new Prisma.Decimal(input.denominationGrams) : null,
        quantity: input.quantity ?? null,
        mintOrRefiner: input.mintOrRefiner ?? null,
        budgetMin: input.budgetMin ? new Prisma.Decimal(input.budgetMin) : null,
        budgetMax: input.budgetMax ? new Prisma.Decimal(input.budgetMax) : null,
        budgetIsFlexible: input.budgetIsFlexible ?? false,
        gemstones: input.gemstones ? (input.gemstones as Prisma.InputJsonValue) : Prisma.JsonNull,
      },
    });
  }

  async publish(
    requestId: string,
    reference: string,
    publishedAt: Date,
    expiresAt: Date,
    tx?: DbTx,
  ): Promise<Request> {
    const client = tx ?? this.prisma;
    return client.request.update({
      where: { id: requestId },
      data: {
        state: RequestState.PUBLISHED,
        reference,
        publishedAt,
        expiresAt,
      },
    });
  }
}
