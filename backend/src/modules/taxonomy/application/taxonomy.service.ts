import { HttpStatus, Injectable } from '@nestjs/common';
import type { Category, Region } from '@prisma/client';
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
  type TaxonomyKind,
  type UpdateTaxonomyInput,
} from '../repository/taxonomy.repository';
import {
  presentCategories,
  presentCategorySummary,
  presentRegions,
  presentRegionSummary,
  type CategorySummary,
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

  async listTree(
    kind: TaxonomyKind,
    options?: { includeInactive?: boolean },
  ): Promise<TaxonomyNode[]> {
    const rows = await this.repo.list(kind, options);
    return kind === 'category'
      ? presentCategories(rows as Category[])
      : presentRegions(rows as Region[]);
  }

  async createCategory(
    input: CreateTaxonomyInput & { icon?: string },
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<CategorySummary> {
    const result = await this.create('category', input, viewer, client);
    return result as CategorySummary;
  }

  async createRegion(
    input: CreateTaxonomyInput,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<RegionSummary> {
    const result = await this.create('region', input, viewer, client);
    return result as RegionSummary;
  }

  async updateCategory(
    id: string,
    input: UpdateTaxonomyInput & { icon?: string },
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<CategorySummary> {
    const result = await this.update('category', id, input, viewer, client);
    return result as CategorySummary;
  }

  async updateRegion(
    id: string,
    input: UpdateTaxonomyInput,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<RegionSummary> {
    const result = await this.update('region', id, input, viewer, client);
    return result as RegionSummary;
  }

  async deactivateCategory(
    id: string,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<CategorySummary> {
    const result = await this.deactivate('category', id, viewer, client);
    return result as CategorySummary;
  }

  async deactivateRegion(
    id: string,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<RegionSummary> {
    const result = await this.deactivate('region', id, viewer, client);
    return result as RegionSummary;
  }

  async create(
    kind: TaxonomyKind,
    input: CreateTaxonomyInput,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<CategorySummary | RegionSummary> {
    const nameEn = input.nameEn?.trim();
    const nameAr = input.nameAr?.trim();
    if (!nameEn || !nameAr) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        ...(!nameEn
          ? [
              {
                path: 'nameEn',
                code: 'REQUIRED',
                message: 'nameEn is mandatory and cannot be blank.',
              },
            ]
          : []),
        ...(!nameAr
          ? [
              {
                path: 'nameAr',
                code: 'REQUIRED',
                message: 'nameAr is mandatory and cannot be blank.',
              },
            ]
          : []),
      ]);
    }

    if (input.parentId) {
      const parent = await this.repo.findById(kind, input.parentId);
      if (!parent) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND, [
          { path: 'parentId', code: 'NOT_FOUND', message: 'Specified parent node does not exist.' },
        ]);
      }
      if (parent.parentId !== null) {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
          {
            path: 'parentId',
            code: 'HIERARCHY_DEPTH_EXCEEDED',
            message: 'Hierarchy cannot exceed 2 levels. Cannot nest under a child node.',
          },
        ]);
      }
    }

    return withTx(this.prisma, async (tx) => {
      const created = await this.repo.create(
        kind,
        {
          nameEn,
          nameAr,
          parentId: input.parentId ?? null,
          displayOrder: input.displayOrder,
          isActive: input.isActive ?? true,
          ...(kind === 'category' && input.icon !== undefined ? { icon: input.icon } : {}),
        },
        tx,
      );

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: kind === 'category' ? 'CATEGORY_CREATE' : 'REGION_CREATE',
        entityType: kind,
        entityId: created.id,
        beforeValue: null,
        afterValue: {
          id: created.id,
          nameEn: created.nameEn,
          nameAr: created.nameAr,
          parentId: created.parentId,
          displayOrder: created.displayOrder,
          isActive: created.isActive,
        },
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });

      return kind === 'category'
        ? presentCategorySummary(created as Category)
        : presentRegionSummary(created as Region);
    });
  }

  async update(
    kind: TaxonomyKind,
    id: string,
    input: UpdateTaxonomyInput,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<CategorySummary | RegionSummary> {
    const existing = await this.repo.findById(kind, id);
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

    if (input.parentId !== undefined && input.parentId !== null) {
      if (input.parentId === id) {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
          { path: 'parentId', code: 'SELF_PARENT', message: 'A node cannot be its own parent.' },
        ]);
      }
      const parent = await this.repo.findById(kind, input.parentId);
      if (!parent) {
        throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND, [
          { path: 'parentId', code: 'NOT_FOUND', message: 'Specified parent node does not exist.' },
        ]);
      }
      if (parent.parentId !== null) {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
          {
            path: 'parentId',
            code: 'HIERARCHY_DEPTH_EXCEEDED',
            message: 'Hierarchy cannot exceed 2 levels. Cannot nest under a child node.',
          },
        ]);
      }
      const childrenCount = await this.repo.countChildren(kind, id);
      if (childrenCount > 0) {
        throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
          {
            path: 'parentId',
            code: 'HIERARCHY_DEPTH_EXCEEDED',
            message: 'A node with existing children cannot become a child of another node.',
          },
        ]);
      }
    }

    return withTx(this.prisma, async (tx) => {
      const updated = await this.repo.update(kind, id, input, tx);

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: kind === 'category' ? 'CATEGORY_UPDATE' : 'REGION_UPDATE',
        entityType: kind,
        entityId: updated.id,
        beforeValue: {
          id: existing.id,
          nameEn: existing.nameEn,
          nameAr: existing.nameAr,
          parentId: existing.parentId,
          displayOrder: existing.displayOrder,
          isActive: existing.isActive,
        },
        afterValue: {
          id: updated.id,
          nameEn: updated.nameEn,
          nameAr: updated.nameAr,
          parentId: updated.parentId,
          displayOrder: updated.displayOrder,
          isActive: updated.isActive,
        },
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });

      return kind === 'category'
        ? presentCategorySummary(updated as Category)
        : presentRegionSummary(updated as Region);
    });
  }

  async deactivate(
    kind: TaxonomyKind,
    id: string,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<CategorySummary | RegionSummary> {
    const existing = await this.repo.findById(kind, id);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    return withTx(this.prisma, async (tx) => {
      const deactivated = await this.repo.deactivate(kind, id, tx);

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: kind === 'category' ? 'CATEGORY_DEACTIVATE' : 'REGION_DEACTIVATE',
        entityType: kind,
        entityId: deactivated.id,
        beforeValue: { isActive: existing.isActive },
        afterValue: { isActive: false },
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });

      return kind === 'category'
        ? presentCategorySummary(deactivated as Category)
        : presentRegionSummary(deactivated as Region);
    });
  }

  async delete(
    kind: TaxonomyKind,
    id: string,
    viewer: ViewerContext,
    client: ClientInfo,
  ): Promise<void> {
    const existing = await this.repo.findById(kind, id);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const refCount = await this.repo.countReferences(kind, id);
    if (refCount > 0) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.TAXONOMY_IN_USE);
    }

    await withTx(this.prisma, async (tx) => {
      await this.repo.delete(kind, id, tx);

      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: kind === 'category' ? 'CATEGORY_DELETE' : 'REGION_DELETE',
        entityType: kind,
        entityId: id,
        beforeValue: {
          id: existing.id,
          nameEn: existing.nameEn,
          nameAr: existing.nameAr,
          parentId: existing.parentId,
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
