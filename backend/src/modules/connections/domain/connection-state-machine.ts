import { HttpStatus } from '@nestjs/common';
import type { ConnectionState } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';

export function transitionConnectionState(
  current: ConnectionState,
  next: ConnectionState,
): ConnectionState {
  if (current === next) return current;

  if (current === 'CLOSED') {
    throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONNECTION_CLOSED);
  }

  if (current === 'ACTIVE' && next === 'CLOSED') {
    return 'CLOSED';
  }

  throw new ApiException(HttpStatus.CONFLICT, ErrorCode.CONFLICT);
}
