import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { AdminNoteView } from '../presenter/admin-vendor.presenter';
import {
  presentAdminOfferDetail,
  presentAdminOfferListItem,
  type AdminOfferDetail,
  type AdminOfferListPage,
} from '../presenter/admin-offers.presenter';
import {
  AdminOffersRepository,
  type AdminOfferListFilters,
  type PaginationOptions,
} from '../repository/admin-offers.repository';

@Injectable()
export class AdminOffersService {
  constructor(private readonly repo: AdminOffersRepository) {}

  async listOffers(
    filters: AdminOfferListFilters = {},
    pagination?: PaginationOptions,
  ): Promise<AdminOfferListPage> {
    if (
      filters.priceMin !== undefined &&
      filters.priceMax !== undefined &&
      filters.priceMin > filters.priceMax
    ) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ErrorCode.VALIDATION_FAILED,
        [{ path: 'priceMin', code: 'INVALID', message: 'priceMin cannot be greater than priceMax' }],
      );
    }

    const result = await this.repo.listOffers(filters, pagination);
    return {
      data: result.items.map(presentAdminOfferListItem),
      meta: {
        total: result.total,
        nextCursor: result.nextCursor,
        hasMore: result.hasMore,
      },
    };
  }

  async getOfferDetail(id: string): Promise<AdminOfferDetail> {
    const row = await this.repo.findOfferById(id);
    if (!row) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    return presentAdminOfferDetail(row);
  }

  async addNote(
    offerId: string,
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

    const note = await this.repo.addOfferNote(offerId, adminId, trimmed);
    return {
      id: note.id,
      text: note.text,
      authorAdminId: note.authorAdminId,
      authorDisplayName: note.author?.displayName,
      createdAt: note.createdAt.toISOString(),
    };
  }
}
