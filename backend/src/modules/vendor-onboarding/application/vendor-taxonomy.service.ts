import { Injectable } from '@nestjs/common';
import { Prisma, type VendorProfile } from '@prisma/client';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx, type DbTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { AuditWriter } from '../../audit';
import { TaxonomyQuery } from '../../taxonomy';
import { shouldActivate } from '../domain/vendor-lifecycle';
import type { VendorMe } from '../presenter/vendor-me.presenter';
import { VendorOnboardingRepository } from '../repository/vendor-onboarding.repository';
import { VendorOnboardingService } from './vendor-onboarding.service';

@Injectable()
export class VendorTaxonomyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
    private readonly repo: VendorOnboardingRepository,
    private readonly onboarding: VendorOnboardingService,
    private readonly taxonomy: TaxonomyQuery,
    private readonly audit: AuditWriter,
  ) {}

  async setCategories(viewer: ViewerContext, categoryIds: string[]): Promise<VendorMe> {
    const profile = await this.onboarding.requireProfile(viewer);
    await this.taxonomy.assertActive({ categoryIds });
    await withTx(this.prisma, async (tx) => {
      await this.repo.replaceCategories(tx, profile.id, [...new Set(categoryIds)]);
      await this.maybeActivate(tx, viewer, profile);
    });
    return this.onboarding.getVendorMe(viewer);
  }

  async setRegions(viewer: ViewerContext, regionIds: string[]): Promise<VendorMe> {
    const profile = await this.onboarding.requireProfile(viewer);
    await this.taxonomy.assertActive({ regionIds });
    await withTx(this.prisma, async (tx) => {
      await this.repo.replaceRegions(tx, profile.id, [...new Set(regionIds)]);
      await this.maybeActivate(tx, viewer, profile);
    });
    return this.onboarding.getVendorMe(viewer);
  }

  async setAvailability(
    viewer: ViewerContext,
    dto: { awayMode?: boolean; businessHours?: unknown },
  ): Promise<VendorMe> {
    const profile = await this.onboarding.requireProfile(viewer);
    const data: Prisma.VendorProfileUncheckedUpdateInput = {};
    if (dto.awayMode !== undefined) data.awayMode = dto.awayMode;
    if (dto.businessHours !== undefined) {
      data.businessHours =
        dto.businessHours === null ? Prisma.JsonNull : (dto.businessHours as Prisma.InputJsonValue);
    }
    await withTx(this.prisma, (tx) => this.repo.update(tx, profile.id, data));
    return this.onboarding.getVendorMe(viewer);
  }

  private async maybeActivate(
    tx: DbTx,
    viewer: ViewerContext,
    profile: VendorProfile,
  ): Promise<void> {
    const [categoryCount, regionCount] = await Promise.all([
      tx.vendorCategory.count({ where: { vendorProfileId: profile.id } }),
      tx.vendorRegion.count({ where: { vendorProfileId: profile.id } }),
    ]);
    if (
      !shouldActivate({
        verificationState: profile.verificationState,
        activatedAt: profile.activatedAt,
        hasCategories: categoryCount > 0,
        hasRegions: regionCount > 0,
      })
    ) {
      return;
    }
    await this.repo.update(tx, profile.id, { activatedAt: this.clock.now() });
    await enqueueOutbox(tx, {
      eventType: 'vendor.eligibility.changed',
      aggregateType: 'vendor_profile',
      aggregateId: profile.id,
      payload: {
        vendorProfileId: profile.id,
        vendorUserId: viewer.userId,
        reason: 'CATEGORIES_REGIONS_DECLARED',
      },
    });
    await this.audit.append(tx, {
      actorUserId: viewer.userId,
      action: 'VENDOR_ACTIVATED',
      entityType: 'vendor_profile',
      entityId: profile.id,
      afterValue: { activatedAt: this.clock.nowIso() },
    });
  }
}
