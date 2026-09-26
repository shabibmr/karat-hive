import { HttpStatus, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { TaxonomyRepository } from '../repository/taxonomy.repository';
import { presentRegions, type TaxonomyNode } from '../presenter/taxonomy.presenter';

@Injectable()
export class TaxonomyQuery {
  constructor(private readonly repo: TaxonomyRepository) {}

  async regions(): Promise<TaxonomyNode[]> {
    return presentRegions(await this.repo.listRegions());
  }

  /** Throws VALIDATION_FAILED unless every id is a distinct active Region. */
  async assertActive(input: { regionIds?: string[] }): Promise<void> {
    if (input.regionIds === undefined) return;
    const ids = unique(input.regionIds);
    const found = await this.repo.countActiveRegions(ids);
    if (found !== ids.length) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, [
        {
          path: 'regionIds',
          code: 'UNKNOWN_OR_INACTIVE',
          message: 'One or more regions are unknown or inactive.',
        },
      ]);
    }
  }
}

function unique(ids: string[]): string[] {
  return [...new Set(ids)];
}
