import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import type { ClientInfo } from '../../../edge/client-ip';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { AuditWriter } from '../../audit';
import {
  TaxonomyRepository,
  type CreateTaxonomyInput,
  type UpdateTaxonomyInput,
} from '../repository/taxonomy.repository';
import {
  presentRegions,
  presentRegionSummary,
  type RegionSummary,
  type TaxonomyNode,
} from '../presenter/taxonomy.presenter';

@Injectable()
export class TaxonomyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly repo: TaxonomyRepository,
    private readonly audit: AuditWriter,
  ) {}

  async listRegions(options?: { includeInactive?: boolean }): Promise<TaxonomyNode[]> {
    return presentRegions(await this.repo.listRegions(options));
  }

  async createRegion(
    input: CreateTaxonomyInput,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<RegionSummary> {
    const nameEn = input.nameEn?.trim();
    const nameAr = input.nameAr?.trim();
    if (!nameEn || !nameAr) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        ...(!nameEn
          ? [{ path: 'nameEn', code: 'REQUIRED', message: 'nameEn is mandatory and cannot be blank.' }]
          : []),
        ...(!nameAr
          ? [{ path: 'nameAr', code: 'REQUIRED', message: 'nameAr is mandatory and cannot be blank.' }]
          : []),
      ]);
    }

    return withTx(this.prisma, async (tx) => {
      const created = await this.repo.createRegion(
        { nameEn, nameAr, displayOrder: input.displayOrder, isActive: input.isActive ?? true },
        tx,
      );

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'REGION_CREATE',
        entityType: 'region',
        entityId: created.id,
        beforeValue: null,
        afterValue: {
          id: created.id,
          nameEn: created.nameEn,
          nameAr: created.nameAr,
          displayOrder: created.displayOrder,
          isActive: created.isActive,
        },
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });

      return presentRegionSummary(created);
    });
  }

  async updateRegion(
    id: string,
    input: UpdateTaxonomyInput,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<RegionSummary> {
    const existing = await this.repo.findRegionById(id);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    if (input.nameEn !== undefined) {
      const trimmed = input.nameEn.trim();
      if (!trimmed) {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
          { path: 'nameEn', code: 'NON_BLANK', message: 'nameEn cannot be blank.' },
        ]);
      }
      input.nameEn = trimmed;
    }

    if (input.nameAr !== undefined) {
      const trimmed = input.nameAr.trim();
      if (!trimmed) {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
          { path: 'nameAr', code: 'NON_BLANK', message: 'nameAr cannot be blank.' },
        ]);
      }
      input.nameAr = trimmed;
    }

    return withTx(this.prisma, async (tx) => {
      const updated = await this.repo.updateRegion(id, input, tx);

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'REGION_UPDATE',
        entityType: 'region',
        entityId: updated.id,
        beforeValue: {
          id: existing.id,
          nameEn: existing.nameEn,
          nameAr: existing.nameAr,
          displayOrder: existing.displayOrder,
          isActive: existing.isActive,
        },
        afterValue: {
          id: updated.id,
          nameEn: updated.nameEn,
          nameAr: updated.nameAr,
          displayOrder: updated.displayOrder,
          isActive: updated.isActive,
        },
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });

      return presentRegionSummary(updated);
    });
  }

  async deactivateRegion(
    id: string,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<RegionSummary> {
    const existing = await this.repo.findRegionById(id);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    return withTx(this.prisma, async (tx) => {
      const deactivated = await this.repo.deactivateRegion(id, tx);

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'REGION_DEACTIVATE',
        entityType: 'region',
        entityId: deactivated.id,
        beforeValue: { isActive: existing.isActive },
        afterValue: { isActive: false },
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });

      return presentRegionSummary(deactivated);
    });
  }

  async deleteRegion(id: string, viewer: ViewerContext, client: ClientInfo): Promise<void> {
    const existing = await this.repo.findRegionById(id);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const refCount = await this.repo.countReferences(id);
    if (refCount > 0) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.TAXONOMY_IN_USE);
    }

    await withTx(this.prisma, async (tx) => {
      await this.repo.deleteRegion(id, tx);

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'REGION_DELETE',
        entityType: 'region',
        entityId: id,
        beforeValue: {
          id: existing.id,
          nameEn: existing.nameEn,
          nameAr: existing.nameAr,
          displayOrder: existing.displayOrder,
          isActive: existing.isActive,
        },
        afterValue: null,
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });
    });
  }
}
