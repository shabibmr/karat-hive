import { Injectable } from '@nestjs/common';
import type { AbuseEntityType, AbuseReport, Prisma } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';

@Injectable()
export class AbuseRepository {
  constructor(private readonly prisma: PrismaService) {}

  async resolveReportedUserId(
    entityType: AbuseEntityType,
    entityId: string,
    reporterUserId: string,
  ): Promise<string | null> {
    switch (entityType) {
      case 'VENDOR': {
        const vendor = await this.prisma.vendorProfile.findFirst({
          where: {
            OR: [{ id: entityId }, { userId: entityId }],
          },
          select: { userId: true },
        });
        return vendor ? vendor.userId : null;
      }
      case 'CUSTOMER': {
        const customer = await this.prisma.customerProfile.findFirst({
          where: {
            OR: [{ id: entityId }, { userId: entityId }],
          },
          select: { userId: true },
        });
        return customer ? customer.userId : null;
      }
      case 'REQUEST': {
        const req = await this.prisma.request.findUnique({
          where: { id: entityId },
          include: { customerProfile: { select: { userId: true } } },
        });
        return req ? req.customerProfile.userId : null;
      }
      case 'OFFER': {
        const offer = await this.prisma.offer.findUnique({
          where: { id: entityId },
          include: { vendorProfile: { select: { userId: true } } },
        });
        return offer ? offer.vendorProfile.userId : null;
      }
      case 'CONNECTION': {
        const conn = await this.prisma.connection.findUnique({
          where: { id: entityId },
          include: {
            request: { include: { customerProfile: { select: { userId: true } } } },
            offer: { include: { vendorProfile: { select: { userId: true } } } },
          },
        });
        if (!conn) return null;
        return conn.request.customerProfile.userId === reporterUserId
          ? conn.offer.vendorProfile.userId
          : conn.request.customerProfile.userId;
      }
      case 'REVIEW': {
        const review = await this.prisma.review.findUnique({
          where: { id: entityId },
          select: { authorUserId: true },
        });
        return review ? review.authorUserId : null;
      }
      default:
        return null;
    }
  }

  async createReport(
    tx: Prisma.TransactionClient,
    data: {
      reporterUserId: string;
      reportedUserId: string;
      entityType: AbuseEntityType;
      entityId: string;
      category: string;
      description: string;
    },
  ): Promise<AbuseReport> {
    return tx.abuseReport.create({
      data: {
        reporterUserId: data.reporterUserId,
        reportedUserId: data.reportedUserId,
        entityType: data.entityType,
        entityId: data.entityId,
        category: data.category,
        description: data.description,
        state: 'OPEN',
      },
    });
  }

  async countReportsFromUserInPast24h(userId: string): Promise<number> {
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
    return this.prisma.abuseReport.count({
      where: {
        reporterUserId: userId,
        createdAt: { gte: since },
      },
    });
  }
}
