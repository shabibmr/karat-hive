import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { AdminNoteView } from '../presenter/admin-vendor.presenter';
import {
  presentAdminRequestDetail,
  presentAdminRequestListItem,
  type AdminRequestDetail,
  type AdminRequestListPage,
} from '../presenter/admin-requests.presenter';
import {
  AdminRequestsRepository,
  type AdminRequestListFilters,
  type PaginationOptions,
} from '../repository/admin-requests.repository';

export type RemoveRequestInput = {
  reasonCode?: string;
  reasonText: string;
  policyClause?: string;
};

@Injectable()
export class AdminRequestsService {
  constructor(private readonly repo: AdminRequestsRepository) {}

  async listRequests(
    filters: AdminRequestListFilters = {},
    pagination?: PaginationOptions,
  ): Promise<AdminRequestListPage> {
    if (
      filters.valueMin !== undefined &&
      filters.valueMax !== undefined &&
      filters.valueMin > filters.valueMax
    ) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ErrorCode.VALIDATION_FAILED,
        [{ path: 'valueMin', code: 'INVALID', message: 'valueMin cannot be greater than valueMax' }],
      );
    }

    const result = await this.repo.listRequests(filters, pagination);
    return {
      data: result.items.map(presentAdminRequestListItem),
      meta: {
        total: result.total,
        nextCursor: result.nextCursor,
        hasMore: result.hasMore,
      },
    };
  }

  async getRequestDetail(id: string): Promise<AdminRequestDetail> {
    const row = await this.repo.findRequestById(id);
    if (!row) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return presentAdminRequestDetail(row);
  }

  async removeRequest(
    id: string,
    adminId: string,
    input: RemoveRequestInput,
    ipAddress?: string,
  ): Promise<AdminRequestDetail> {
    if (!input.reasonText || input.reasonText.trim().length === 0) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ErrorCode.VALIDATION_FAILED,
        [{ path: 'reasonText', code: 'REQUIRED', message: 'reasonText is required' }],
      );
    }

    await this.repo.removeRequest(
      id,
      adminId,
      input.reasonCode,
      input.reasonText.trim(),
      input.policyClause?.trim(),
      ipAddress,
    );

    return this.getRequestDetail(id);
  }

  async addNote(
    requestId: string,
    adminId: string,
    content: string,
  ): Promise<AdminNoteView> {
    const trimmed = content?.trim();
    if (!trimmed || trimmed.length === 0) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ErrorCode.VALIDATION_FAILED,
        [{ path: 'content', code: 'REQUIRED', message: 'content is required' }],
      );
    }

    const note = await this.repo.addRequestNote(requestId, adminId, trimmed);
    return {
      id: note.id,
      text: note.text,
      authorAdminId: note.authorAdminId,
      authorDisplayName: note.author?.displayName,
      createdAt: note.createdAt.toISOString(),
    };
  }
}
