import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { TaxonomyRepository } from '../repository/taxonomy.repository';
import {
  presentCategories,
  presentRegions,
  type TaxonomyNode,
} from '../presenter/taxonomy.presenter';

@Injectable()
export class TaxonomyQuery {
  constructor(private readonly repo: TaxonomyRepository) {}

  async categories(): Promise<TaxonomyNode[]> {
    return presentCategories(await this.repo.listCategories());
  }

  async regions(): Promise<TaxonomyNode[]> {
    return presentRegions(await this.repo.listRegions());
  }

  /** Throws VALIDATION_FAILED unless every id is a distinct active row of its kind. */
  async assertActive(input: { categoryIds?: string[]; regionIds?: string[] }): Promise<void> {
    const details: Array<{ path: string; code: string; message: string }> = [];

    if (input.categoryIds !== undefined) {
      const ids = unique(input.categoryIds);
      const found = await this.repo.countActiveCategories(ids);
      if (found !== ids.length) {
        details.push({
          path: 'categoryIds',
          code: 'UNKNOWN_OR_INACTIVE',
          message: 'One or more categories are unknown or inactive.',
        });
      }
    }
    if (input.regionIds !== undefined) {
      const ids = unique(input.regionIds);
      const found = await this.repo.countActiveRegions(ids);
      if (found !== ids.length) {
        details.push({
          path: 'regionIds',
          code: 'UNKNOWN_OR_INACTIVE',
          message: 'One or more regions are unknown or inactive.',
        });
      }
    }
    if (details.length > 0) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, details);
    }
  }
}

function unique(ids: string[]): string[] {
  return [...new Set(ids)];
}
