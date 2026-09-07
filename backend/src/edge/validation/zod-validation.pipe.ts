import { HttpStatus, PipeTransform } from '@nestjs/common';
import type { ZodTypeAny, infer as ZodInfer } from 'zod';
import { ApiException } from '../errors/api-exception';
import { ErrorCode } from '../errors/error-codes';

/** Validates a request part against a Zod schema; failures become 422 VALIDATION_FAILED. */
export class ZodValidationPipe<S extends ZodTypeAny> implements PipeTransform {
  /** Public so OpenAPI generation can read the same Zod schema Nest validates with. */
  constructor(readonly schema: S) {}

  transform(value: unknown): ZodInfer<S> {
    const result = this.schema.safeParse(value);
    if (result.success) return result.data;
    const details = result.error.issues.map((issue) => ({
      path: issue.path.join('.') || undefined,
      code: issue.code.toUpperCase(),
      message: issue.message,
    }));
    throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, ErrorCode.VALIDATION_FAILED, details);
  }
}

export function zodBody<S extends ZodTypeAny>(schema: S): ZodValidationPipe<S> {
  return new ZodValidationPipe(schema);
}

export function zodQuery<S extends ZodTypeAny>(schema: S): ZodValidationPipe<S> {
  return new ZodValidationPipe(schema);
}
