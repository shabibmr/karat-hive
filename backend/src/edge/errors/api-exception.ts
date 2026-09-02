import { HttpException, HttpStatus } from '@nestjs/common';
import { ErrorCode } from './error-codes';

export type ErrorDetail = { path?: string; code: string; message: string };

export class ApiException extends HttpException {
  readonly errorCode: ErrorCode;
  readonly details: ErrorDetail[];

  constructor(status: HttpStatus, code: ErrorCode, details: ErrorDetail[] = []) {
    super({ code, details }, status);
    this.errorCode = code;
    this.details = details;
  }
}
