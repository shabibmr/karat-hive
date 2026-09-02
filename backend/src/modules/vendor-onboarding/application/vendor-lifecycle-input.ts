import type { UserAccountState, VendorProfile } from '@prisma/client';
import { MANDATORY_DOCUMENT_TYPES } from '../domain/vendor-state-machine';
import type { VendorLifecycleInput } from '../domain/vendor-lifecycle';
import { VendorOnboardingRepository } from '../repository/vendor-onboarding.repository';

/** Gathers the counts the lifecycle composition needs for one profile. */
export async function buildLifecycleInput(
  repo: VendorOnboardingRepository,
  profile: VendorProfile,
  accountState: UserAccountState,
): Promise<{ input: VendorLifecycleInput; categoryCount: number; regionCount: number }> {
  const [docTypes, categoryCount, regionCount] = await Promise.all([
    repo.distinctDocumentTypes(profile.id),
    repo.countCategories(profile.id),
    repo.countRegions(profile.id),
  ]);
  const hasMandatoryDocuments = MANDATORY_DOCUMENT_TYPES.every((t) => docTypes.includes(t));
  return {
    input: {
      accountState,
      verificationState: profile.verificationState,
      activatedAt: profile.activatedAt,
      hasMandatoryDocuments,
      hasCategories: categoryCount > 0,
      hasRegions: regionCount > 0,
    },
    categoryCount,
    regionCount,
  };
}
