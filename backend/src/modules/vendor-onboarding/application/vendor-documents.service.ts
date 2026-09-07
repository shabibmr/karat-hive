import { HttpStatus, Injectable } from '@nestjs/common';
import type { DocumentType } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { Clock } from '../../../shared/clock';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { AuditWriter } from '../../audit';
import { MediaService } from '../../media';
import { canTransition, MANDATORY_DOCUMENT_TYPES } from '../domain/vendor-state-machine';
import { presentVendorDocument, type VendorDocumentView } from '../presenter/vendor-me.presenter';
import { VendorOnboardingRepository } from '../repository/vendor-onboarding.repository';
import { VendorOnboardingService } from './vendor-onboarding.service';

export type DocTypeInput = DocumentType;

@Injectable()
export class VendorDocumentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
    private readonly repo: VendorOnboardingRepository,
    private readonly onboarding: VendorOnboardingService,
    private readonly media: MediaService,
    private readonly audit: AuditWriter,
  ) {}

  async list(viewer: ViewerContext): Promise<VendorDocumentView[]> {
    const profile = await this.onboarding.requireProfile(viewer);
    return (await this.repo.listDocuments(profile.id)).map(presentVendorDocument);
  }

  async attach(
    viewer: ViewerContext,
    dto: { documentType: DocTypeInput; mediaKey: string; expiryDate?: string },
  ): Promise<VendorDocumentView[]> {
    const profile = await this.onboarding.requireProfile(viewer);
    const media = await this.media.getAttachable(dto.mediaKey, viewer.userId);
    if (media.purpose !== 'KYC_DOCUMENT') {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.MEDIA_TYPE_REJECTED, [
        { path: 'mediaKey', code: 'WRONG_PURPOSE', message: 'That upload is not a KYC document.' },
      ]);
    }

    await withTx(this.prisma, async (tx) => {
      await this.repo.addDocument(tx, {
        vendorProfileId: profile.id,
        documentType: dto.documentType,
        mediaId: media.id,
        expiryDate: dto.expiryDate ? new Date(`${dto.expiryDate}T00:00:00Z`) : null,
        uploadedAt: this.clock.now(),
      });

      const present = await tx.vendorDocument.findMany({
        where: { vendorProfileId: profile.id },
        distinct: ['documentType'],
        select: { documentType: true },
      });
      const types = present.map((r) => r.documentType);
      const mandatoryComplete = MANDATORY_DOCUMENT_TYPES.every((t) => types.includes(t));

      if (mandatoryComplete && canTransition(profile.verificationState, 'PENDING_VERIFICATION')) {
        await this.repo.update(tx, profile.id, { verificationState: 'PENDING_VERIFICATION' });
      }
      if (mandatoryComplete) {
        await enqueueOutbox(tx, {
          eventType: 'vendor.documents.submitted',
          aggregateType: 'vendor_profile',
          aggregateId: profile.id,
          payload: { vendorProfileId: profile.id, vendorUserId: viewer.userId },
        });
      }
      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'VENDOR_DOCUMENT_ADDED',
        entityType: 'vendor_profile',
        entityId: profile.id,
        afterValue: { documentType: dto.documentType, mediaKey: dto.mediaKey },
      });
    });

    return (await this.repo.listDocuments(profile.id)).map(presentVendorDocument);
  }

  async resubmit(viewer: ViewerContext): Promise<void> {
    const profile = await this.onboarding.requireProfile(viewer);
    if (profile.verificationState !== 'REJECTED') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.ILLEGAL_VENDOR_TRANSITION);
    }
    await withTx(this.prisma, async (tx) => {
      await this.repo.update(tx, profile.id, {
        verificationState: 'PENDING_VERIFICATION',
        verificationMessage: null,
      });
      await enqueueOutbox(tx, {
        eventType: 'vendor.eligibility.changed',
        aggregateType: 'vendor_profile',
        aggregateId: profile.id,
        payload: {
          vendorProfileId: profile.id,
          vendorUserId: viewer.userId,
          reason: 'RESUBMITTED',
        },
      });
      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'VENDOR_RESUBMIT',
        entityType: 'vendor_profile',
        entityId: profile.id,
      });
    });
  }

  async sweepExpiringDocuments(): Promise<number> {
    const now = this.clock.now();
    const threshold = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

    const expiring = await this.prisma.vendorDocument.findMany({
      where: {
        expiryDate: {
          not: null,
          lte: threshold,
        },
        reminderSentAt: null,
      },
      include: {
        vendorProfile: {
          select: {
            userId: true,
          },
        },
      },
    });

    for (const doc of expiring) {
      await withTx(this.prisma, async (tx) => {
        await tx.vendorDocument.update({
          where: { id: doc.id },
          data: { reminderSentAt: now },
        });

        await enqueueOutbox(tx, {
          eventType: 'vendor.document.expiring',
          aggregateType: 'vendor_document',
          aggregateId: doc.id,
          payload: {
            vendorProfileId: doc.vendorProfileId,
            vendorUserId: doc.vendorProfile.userId,
            documentId: doc.id,
            documentType: doc.documentType,
            expiryDate: doc.expiryDate?.toISOString(),
          },
        });
      });
    }

    return expiring.length;
  }
}
