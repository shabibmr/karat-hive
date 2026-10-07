import type { ErrorDetail } from '../../../edge/errors/api-exception';

/** Lets the client tell ADMIN from VENDOR on role-mismatch errors. */
export function userTypeDetail(userType: string): ErrorDetail[] {
  return [{ path: 'userType', code: userType, message: userType }];
}
