import type { Request } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { HttpStatus } from '@nestjs/common';

export type RequestPublishCheckInput = {
  request: Request;
  mediaCount: number;
};

export function validateRequestForPublish(input: RequestPublishCheckInput): void {
  const { request, mediaCount } = input;
  const errors: Array<{ path?: string; code: string; message: string }> = [];

  if (!request.categoryId) {
    errors.push({ path: 'categoryId', code: 'REQUIRED', message: 'Category is required.' });
  }
  if (!request.regionId) {
    errors.push({ path: 'regionId', code: 'REQUIRED', message: 'Region is required.' });
  }

  switch (request.requestType) {
    case 'FIND_ORNAMENT': {
      if (!request.ornamentType) {
        errors.push({ path: 'ornamentType', code: 'REQUIRED', message: 'Ornament type is required.' });
      }
      if (!request.purityKarat) {
        errors.push({ path: 'purityKarat', code: 'REQUIRED', message: 'Purity karat is required.' });
      }
      if (mediaCount < 1) {
        errors.push({ path: 'mediaKeys', code: 'REQUIRED', message: 'At least one reference image is required.' });
      }
      break;
    }
    case 'SELL_OLD_GOLD': {
      if (!request.weightGrams || Number(request.weightGrams) <= 0) {
        errors.push({ path: 'weightGrams', code: 'REQUIRED', message: 'Weight in grams is required.' });
      }
      if (!request.purityKarat) {
        errors.push({ path: 'purityKarat', code: 'REQUIRED', message: 'Purity karat is required.' });
      }
      break;
    }
    case 'GOLD_COIN': {
      if (!request.direction) {
        errors.push({ path: 'direction', code: 'REQUIRED', message: 'Direction (BUY/SELL) is required.' });
      }
      if (!request.purityKarat) {
        errors.push({ path: 'purityKarat', code: 'REQUIRED', message: 'Purity karat is required.' });
      }
      if (!request.denominationGrams || Number(request.denominationGrams) <= 0) {
        errors.push({ path: 'denominationGrams', code: 'REQUIRED', message: 'Denomination in grams is required.' });
      }
      if (!request.quantity || request.quantity < 1) {
        errors.push({ path: 'quantity', code: 'REQUIRED', message: 'Quantity is required and must be at least 1.' });
      }
      break;
    }
    case 'GOLD_BULLION': {
      if (!request.direction) {
        errors.push({ path: 'direction', code: 'REQUIRED', message: 'Direction (BUY/SELL) is required.' });
      }
      if (!request.purityKarat) {
        errors.push({ path: 'purityKarat', code: 'REQUIRED', message: 'Purity karat is required.' });
      }
      const weight = request.weightGrams ?? request.denominationGrams;
      if (!weight || Number(weight) <= 0) {
        errors.push({ path: 'weightGrams', code: 'REQUIRED', message: 'Weight in grams is required.' });
      }
      break;
    }
  }

  if (errors.length > 0) {
    throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.REQUEST_NOT_PUBLISHABLE, errors);
  }
}
