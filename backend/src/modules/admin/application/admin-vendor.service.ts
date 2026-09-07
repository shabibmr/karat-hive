import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import type { UserAccountState, VendorVerificationState } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import type { ClientInfo } from '../../../edge/client-ip';
import { ENV, type Env } from '../../../config/env';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { OBJECT_STORAGE, type ObjectStorage } from '../../../platform/ports/storage.port';
import { Clock } from '../../../shared/clock';
import { AuditWriter } from '../../audit';
import { storagePath } from '../../media/domain/media-rules';
import {
  canApplyDecision,
} from '../../vendor-onboarding/domain/vendor-state-machine';
import {
  composeVendorLifecycle,
  type VendorAccountState,
} from '../../vendor-onboarding/domain/vendor-lifecycle';
import {
  presentVendorDetail,
  presentVendorListItem,
  presentVerificationQueueItem,
  type AdminNoteView,
  type DocumentUrlView,
  type VendorListPage,
  type VerificationQueueItem,
  type VendorVerificationDetail,
} from '../presenter/admin-vendor.presenter';
import {
  AdminVendorRepository,
  type AdminVendorListFilters,
  type PaginationOptions,
} from '../repository/admin-vendor.repository';

const SIGNED_DOCUMENT_URL_TTL_SECONDS = 15 * 60;

export type LifecycleActionInput = {
  reasonCode?: string;
  reasonText: string;
};

@Injectable()
export class AdminVendorService {
  constructor(
    @Inject(ENV) private readonly env: Env,
    @Inject(OBJECT_STORAGE) private readonly storage: ObjectStorage,
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
    private readonly repo: AdminVendorRepository,
    private readonly audit: AuditWriter,
  ) {}

  async getVerificationQueue(): Promise<VerificationQueueItem[]> {
    const now = this.clock.now();
    const rows = await this.repo.findVerificationQueue();
    return rows.map((row) => presentVerificationQueueItem(row, now));
  }

  listVerificationQueue(): Promise<VerificationQueueItem[]> {
    return this.getVerificationQueue();
  }

  async getVendors(
    filters: AdminVendorListFilters = {},
    pagination?: PaginationOptions,
  ): Promise<VendorListPage> {
    const now = this.clock.now();
    const result = await this.repo.listVendors(filters, pagination);
    return {
      data: result.items.map((row) => presentVendorListItem(row, now)),
      meta: {
        total: result.total,
        nextCursor: result.nextCursor,
        hasMore: result.hasMore,
      },
    };
  }

  listVendors(
    filters: AdminVendorListFilters = {},
    pagination?: PaginationOptions,
  ): Promise<VendorListPage> {
    return this.getVendors(filters, pagination);
  }

  async getVendorDetail(vendorProfileId: string): Promise<VendorVerificationDetail> {
    const row = await this.repo.findVendorById(vendorProfileId);
    if (!row) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    const now = this.clock.now();
    return presentVendorDetail(row, now);
  }

  async getDocumentSignedUrl(
    viewer: ViewerContext,
    client: ClientInfo,
    vendorProfileId: string,
    documentId: string,
  ): Promise<DocumentUrlView> {
    const row = await this.repo.findVendorDocument(vendorProfileId, documentId);
    if (!row) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    if (row.media.state === 'QUARANTINED') {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.MEDIA_QUARANTINED);
    }
    if (row.media.state === 'PENDING_UPLOAD' || row.media.state === 'FAILED') {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.UPLOAD_NOT_COMPLETED);
    }

    const objectKey = storagePath({
      purpose: 'KYC_DOCUMENT',
      key: row.media.key,
      vendorProfileId: row.vendorProfileId,
      ownerUserId: row.vendorProfile.userId,
    });
    const bucket = this.env.SUPABASE_STORAGE_BUCKET_KYC;
    const signed = await this.storage.createSignedDownloadUrl(
      bucket,
      objectKey,
      SIGNED_DOCUMENT_URL_TTL_SECONDS,
    );

    await withTx(this.prisma, async (tx) => {
      await this.audit.append(tx, {
        actorUserId: viewer.userId,
        action: 'VENDOR_DOCUMENT_VIEWED',
        entityType: 'vendor_document',
        entityId: row.id,
        afterValue: {
          vendorProfileId,
          documentType: row.documentType,
          mediaId: row.mediaId,
        },
        ipAddress: client.ip ?? null,
        userAgent: client.userAgent ?? null,
      });
    });

    return {
      url: signed.url,
      expiresAt: signed.expiresAt.toISOString(),
    };
  }

  getDocumentUrl(
    viewer: ViewerContext,
    client: ClientInfo,
    vendorProfileId: string,
    documentId: string,
  ): Promise<DocumentUrlView> {
    return this.getDocumentSignedUrl(viewer, client, vendorProfileId, documentId);
  }

  async verifyVendor(
    viewer: ViewerContext,
    vendorProfileId: string,
    rationale: string,
  ): Promise<{ lifecycle: VendorAccountState }> {
    const profile = await this.repo.findVendorById(vendorProfileId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    if (!canApplyDecision(profile.verificationState, 'VERIFY')) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.ILLEGAL_VENDOR_TRANSITION);
    }

    const updated = await this.repo.updateVerificationState(
      vendorProfileId,
      'VERIFIED',
      viewer.userId,
      rationale,
    );

    const lifecycle = composeVendorLifecycle({
      accountState: updated.user.accountState,
      verificationState: updated.verificationState,
      activatedAt: updated.activatedAt,
      hasMandatoryDocuments: (profile.documents ?? []).length > 0,
      hasCategories: (profile.categories ?? []).length > 0,
      hasRegions: (profile.regions ?? []).length > 0,
    });

    return { lifecycle };
  }

  verify(
    viewer: ViewerContext,
    vendorProfileId: string,
    rationale: string,
  ): Promise<{ lifecycle: VendorAccountState }> {
    return this.verifyVendor(viewer, vendorProfileId, rationale);
  }

  async rejectVendor(
    viewer: ViewerContext,
    vendorProfileId: string,
    rationale: string,
  ): Promise<{ lifecycle: VendorAccountState }> {
    const profile = await this.repo.findVendorById(vendorProfileId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    if (!canApplyDecision(profile.verificationState, 'REJECT')) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.ILLEGAL_VENDOR_TRANSITION);
    }

    const updated = await this.repo.updateVerificationState(
      vendorProfileId,
      'REJECTED',
      viewer.userId,
      rationale,
      rationale,
    );

    const lifecycle = composeVendorLifecycle({
      accountState: updated.user.accountState,
      verificationState: updated.verificationState,
      activatedAt: updated.activatedAt,
      hasMandatoryDocuments: (profile.documents ?? []).length > 0,
      hasCategories: (profile.categories ?? []).length > 0,
      hasRegions: (profile.regions ?? []).length > 0,
    });

    return { lifecycle };
  }

  reject(
    viewer: ViewerContext,
    vendorProfileId: string,
    rationale: string,
  ): Promise<{ lifecycle: VendorAccountState }> {
    return this.rejectVendor(viewer, vendorProfileId, rationale);
  }

  async requestInfo(
    viewer: ViewerContext,
    vendorProfileId: string,
    message: string,
  ): Promise<{ lifecycle: VendorAccountState }> {
    const profile = await this.repo.findVendorById(vendorProfileId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    if (!canApplyDecision(profile.verificationState, 'REQUEST_INFO')) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.ILLEGAL_VENDOR_TRANSITION);
    }

    const updated = await this.repo.updateVerificationState(
      vendorProfileId,
      'PENDING_VERIFICATION',
      viewer.userId,
      undefined,
      message,
    );

    const lifecycle = composeVendorLifecycle({
      accountState: updated.user.accountState,
      verificationState: updated.verificationState,
      activatedAt: updated.activatedAt,
      hasMandatoryDocuments: (profile.documents ?? []).length > 0,
      hasCategories: (profile.categories ?? []).length > 0,
      hasRegions: (profile.regions ?? []).length > 0,
    });

    return { lifecycle };
  }

  async activateVendor(
    viewer: ViewerContext,
    vendorProfileId: string,
    input: LifecycleActionInput,
  ): Promise<{ accountState: UserAccountState; lifecycle: VendorAccountState }> {
    const profile = await this.repo.findVendorById(vendorProfileId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const result = await this.repo.updateAccountState(
      vendorProfileId,
      'ACTIVE',
      viewer.userId,
      input.reasonCode,
      input.reasonText,
    );

    const lifecycle = composeVendorLifecycle({
      accountState: result.accountState,
      verificationState: profile.verificationState,
      activatedAt: profile.activatedAt,
      hasMandatoryDocuments: (profile.documents ?? []).length > 0,
      hasCategories: (profile.categories ?? []).length > 0,
      hasRegions: (profile.regions ?? []).length > 0,
    });

    return {
      accountState: result.accountState,
      lifecycle,
    };
  }

  activate(
    viewer: ViewerContext,
    vendorProfileId: string,
    input: LifecycleActionInput,
  ): Promise<{ accountState: UserAccountState; lifecycle: VendorAccountState }> {
    return this.activateVendor(viewer, vendorProfileId, input);
  }

  async suspendVendor(
    viewer: ViewerContext,
    vendorProfileId: string,
    input: LifecycleActionInput,
  ): Promise<{ accountState: UserAccountState; lifecycle: VendorAccountState }> {
    const profile = await this.repo.findVendorById(vendorProfileId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const result = await this.repo.updateAccountState(
      vendorProfileId,
      'SUSPENDED',
      viewer.userId,
      input.reasonCode,
      input.reasonText,
    );

    return {
      accountState: result.accountState,
      lifecycle: 'SUSPENDED',
    };
  }

  suspend(
    viewer: ViewerContext,
    vendorProfileId: string,
    input: LifecycleActionInput,
  ): Promise<{ accountState: UserAccountState; lifecycle: VendorAccountState }> {
    return this.suspendVendor(viewer, vendorProfileId, input);
  }

  async reactivateVendor(
    viewer: ViewerContext,
    vendorProfileId: string,
    input: LifecycleActionInput,
  ): Promise<{ accountState: UserAccountState; lifecycle: VendorAccountState }> {
    const profile = await this.repo.findVendorById(vendorProfileId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const result = await this.repo.updateAccountState(
      vendorProfileId,
      'ACTIVE',
      viewer.userId,
      input.reasonCode,
      input.reasonText,
    );

    const lifecycle = composeVendorLifecycle({
      accountState: result.accountState,
      verificationState: profile.verificationState,
      activatedAt: profile.activatedAt,
      hasMandatoryDocuments: (profile.documents ?? []).length > 0,
      hasCategories: (profile.categories ?? []).length > 0,
      hasRegions: (profile.regions ?? []).length > 0,
    });

    return {
      accountState: result.accountState,
      lifecycle,
    };
  }

  reactivate(
    viewer: ViewerContext,
    vendorProfileId: string,
    input: LifecycleActionInput,
  ): Promise<{ accountState: UserAccountState; lifecycle: VendorAccountState }> {
    return this.reactivateVendor(viewer, vendorProfileId, input);
  }

  async deactivateVendor(
    viewer: ViewerContext,
    vendorProfileId: string,
    input: LifecycleActionInput,
  ): Promise<{ accountState: UserAccountState; lifecycle: VendorAccountState }> {
    const profile = await this.repo.findVendorById(vendorProfileId);
    if (!profile) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const result = await this.repo.updateAccountState(
      vendorProfileId,
      'DEACTIVATED',
      viewer.userId,
      input.reasonCode,
      input.reasonText,
    );

    return {
      accountState: result.accountState,
      lifecycle: 'DEACTIVATED',
    };
  }

  deactivate(
    viewer: ViewerContext,
    vendorProfileId: string,
    input: LifecycleActionInput,
  ): Promise<{ accountState: UserAccountState; lifecycle: VendorAccountState }> {
    return this.deactivateVendor(viewer, vendorProfileId, input);
  }

  async addNote(
    viewer: ViewerContext,
    vendorProfileId: string,
    text: string,
  ): Promise<AdminNoteView> {
    const note = await this.repo.addNote(vendorProfileId, viewer.userId, text);
    return {
      id: note.id,
      text: note.text,
      authorAdminId: note.authorAdminId,
      authorDisplayName: note.author?.displayName,
      createdAt: note.createdAt.toISOString(),
    };
  }
}
