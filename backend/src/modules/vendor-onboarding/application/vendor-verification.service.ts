import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { AuditWriter } from '../../audit';
import { canApplyDecision, type VerificationDecision } from '../domain/vendor-state-machine';
import { composeVendorLifecycle } from '../domain/vendor-lifecycle';
import { VendorOnboardingRepository } from '../repository/vendor-onboarding.repository';

export type ApplyDecisionInput = {
  decision: VerificationDecision;
  rationale?: string;
  message?: string;
};

@Injectable()
export class VendorVerificationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
    private readonly repo: VendorOnboardingRepository,
    private readonly audit: AuditWriter,
  ) {}

  async applyDecision(
    actorUserId: string | null,
    vendorProfileId: string,
    input: ApplyDecisionInput,
  ): Promise<{ lifecycle: ReturnType<typeof composeVendorLifecycle> }> {
    const profile = await this.repo.findById(vendorProfileId);
    if (!profile) throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    if (!canApplyDecision(profile.verificationState, input.decision)) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.ILLEGAL_VENDOR_TRANSITION);
    }

    const now = this.clock.now();
    const updated = await withTx(this.prisma, async (tx) => {
      if (input.decision === 'VERIFY') {
        const [categoryCount, regionCount] = await Promise.all([
          tx.vendorCategory.count({ where: { vendorProfileId } }),
          tx.vendorRegion.count({ where: { vendorProfileId } }),
        ]);
        const activate = categoryCount > 0 && regionCount > 0;
        const row = await this.repo.update(tx, vendorProfileId, {
          verificationState: 'VERIFIED',
          verifiedAt: now,
          verificationMessage: null,
          verificationNotes: input.rationale ?? profile.verificationNotes,
          ...(activate ? { activatedAt: now } : {}),
        });
        await enqueueOutbox(tx, {
          eventType: 'vendor.verification.decided',
          aggregateType: 'vendor_profile',
          aggregateId: vendorProfileId,
          payload: { vendorProfileId, vendorUserId: profile.userId, decision: 'VERIFY' },
        });
        await this.audit.append(tx, {
          actorUserId,
          action: 'VENDOR_VERIFIED',
          entityType: 'vendor_profile',
          entityId: vendorProfileId,
          beforeValue: { verificationState: profile.verificationState },
          afterValue: { verificationState: 'VERIFIED', activated: activate },
        });
        if (activate) {
          await enqueueOutbox(tx, {
            eventType: 'vendor.eligibility.changed',
            aggregateType: 'vendor_profile',
            aggregateId: vendorProfileId,
            payload: {
              vendorProfileId,
              vendorUserId: profile.userId,
              reason: 'VERIFIED_WITH_TAXONOMY',
            },
          });
          await this.audit.append(tx, {
            actorUserId,
            action: 'VENDOR_ACTIVATED',
            entityType: 'vendor_profile',
            entityId: vendorProfileId,
            afterValue: { activatedAt: now.toISOString() },
          });
        }
        return row;
      }

      if (input.decision === 'REJECT') {
        const row = await this.repo.update(tx, vendorProfileId, {
          verificationState: 'REJECTED',
          verificationNotes: input.rationale ?? null,
          verificationMessage: input.message ?? input.rationale ?? null,
        });
        await enqueueOutbox(tx, {
          eventType: 'vendor.verification.decided',
          aggregateType: 'vendor_profile',
          aggregateId: vendorProfileId,
          payload: { vendorProfileId, vendorUserId: profile.userId, decision: 'REJECT' },
        });
        await this.audit.append(tx, {
          actorUserId,
          action: 'VENDOR_REJECTED',
          entityType: 'vendor_profile',
          entityId: vendorProfileId,
          afterValue: { verificationState: 'REJECTED' },
        });
        return row;
      }

      // REQUEST_INFO
      const row = await this.repo.update(tx, vendorProfileId, {
        verificationMessage: input.message ?? null,
      });
      await enqueueOutbox(tx, {
        eventType: 'vendor.verification.decided',
        aggregateType: 'vendor_profile',
        aggregateId: vendorProfileId,
        payload: { vendorProfileId, vendorUserId: profile.userId, decision: 'REQUEST_INFO' },
      });
      await this.audit.append(tx, {
        actorUserId,
        action: 'VENDOR_INFO_REQUESTED',
        entityType: 'vendor_profile',
        entityId: vendorProfileId,
      });
      return row;
    });

    return {
      lifecycle: composeVendorLifecycle({
        accountState: 'ACTIVE',
        verificationState: updated.verificationState,
        activatedAt: updated.activatedAt,
        hasMandatoryDocuments: true,
        hasCategories: true,
        hasRegions: true,
      }),
    };
  }
}
