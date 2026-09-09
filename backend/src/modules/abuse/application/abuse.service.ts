import { HttpStatus, Injectable } from '@nestjs/common';
import type { AbuseEntityType, Prisma } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { PrismaService } from '../../../platform/db/prisma.service';
import { AuditWriter } from '../../audit';
import { AbuseRepository } from '../repository/abuse.repository';

export interface CreateAbuseReportDto {
  entityType: AbuseEntityType;
  entityId: string;
  category: string;
  description: string;
}

export interface AbuseReportAcknowledgment {
  id: string;
  state: 'OPEN';
  acknowledged: true;
}

@Injectable()
export class AbuseService {
  constructor(
    private readonly repo: AbuseRepository,
    private readonly prisma: PrismaService,
    private readonly audit: AuditWriter,
  ) {}

  async submitReport(
    viewer: ViewerContext,
    dto: CreateAbuseReportDto,
  ): Promise<AbuseReportAcknowledgment> {
    // Customer/Vendor: max 5 reports / 24h (FR-CUS-033 AC4)
    const recentCount = await this.repo.countReportsFromUserInPast24h(viewer.userId);
    if (recentCount >= 5) {
      throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, ErrorCode.RATE_LIMITED);
    }

    const reportedUserId = await this.repo.resolveReportedUserId(
      dto.entityType,
      dto.entityId,
      viewer.userId,
    );

    if (!reportedUserId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const report = await this.prisma.$transaction(
      async (tx: Prisma.TransactionClient) => {
        const created = await this.repo.createReport(tx, {
          reporterUserId: viewer.userId,
          reportedUserId,
          entityType: dto.entityType,
          entityId: dto.entityId,
          category: dto.category,
          description: dto.description,
        });

        await this.audit.append(tx, {
          actorUserId: viewer.userId,
          action: 'ABUSE_REPORTED',
          entityType: 'abuse_report',
          entityId: created.id,
          afterValue: {
            entityType: dto.entityType,
            entityId: dto.entityId,
            category: dto.category,
          },
        });

        // FR-VEN-030 AC4: 3 distinct Vendor reporters on one Request → priority.
        // updateMany is idempotent; AUTO_FLAGGED audit fires only on first raise.
        if (dto.entityType === 'REQUEST') {
          await this.repo.lockRequest(tx, dto.entityId);
          const vendorReporterIds = await this.repo.listDistinctVendorReporterIds(
            tx,
            'REQUEST',
            dto.entityId,
          );
          if (vendorReporterIds.length >= 3) {
            const alreadyFlagged = await this.repo.isEntityFlagged(tx, 'REQUEST', dto.entityId);
            await this.repo.flagAllReportsForEntity(tx, 'REQUEST', dto.entityId);
            if (!alreadyFlagged) {
              await this.audit.append(tx, {
                actorUserId: viewer.userId,
                action: 'ABUSE_REPORT_AUTO_FLAGGED',
                entityType: 'abuse_report',
                entityId: created.id,
                afterValue: {
                  entityType: dto.entityType,
                  entityId: dto.entityId,
                  vendorReporterCount: vendorReporterIds.length,
                },
              });
            }
          }
        }

        return created;
      },
    );

    // Reporter identity is withheld (G2-F04)
    return {
      id: report.id,
      state: 'OPEN',
      acknowledged: true,
    };
  }
}
