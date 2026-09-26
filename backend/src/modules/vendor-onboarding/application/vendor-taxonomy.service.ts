import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { TaxonomyQuery } from '../../taxonomy';
import type { VendorMe } from '../presenter/vendor-me.presenter';
import { VendorOnboardingRepository } from '../repository/vendor-onboarding.repository';
import { VendorOnboardingService } from './vendor-onboarding.service';

@Injectable()
export class VendorTaxonomyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly repo: VendorOnboardingRepository,
    private readonly onboarding: VendorOnboardingService,
    private readonly taxonomy: TaxonomyQuery,
  ) {}

  async setRegions(viewer: ViewerContext, regionIds: string[]): Promise<VendorMe> {
    const profile = await this.onboarding.requireProfile(viewer);
    await this.taxonomy.assertActive({ regionIds });
    await withTx(this.prisma, (tx) => this.repo.replaceRegions(tx, profile.id, [...new Set(regionIds)]));
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
}
