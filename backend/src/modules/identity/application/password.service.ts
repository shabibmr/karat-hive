import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { PASSWORD_HASHER, type PasswordHasher } from './password-hasher';
import { meetsPasswordPolicy } from '../domain/password-policy';
import { UserRepository } from '../repository/user.repository';

@Injectable()
export class PasswordService {
  constructor(
    @Inject(PASSWORD_HASHER) private readonly hasher: PasswordHasher,
    private readonly users: UserRepository,
  ) {}

  /**
   * Set or change the caller's email password (inventory `POST /v1/auth/password`).
   * First-time set omits `currentPassword`; change requires it.
   * Vendor and Admin only — not a login path (`adr/0010`).
   */
  async setOrChange(
    viewer: ViewerContext,
    input: { currentPassword?: string; newPassword: string },
  ): Promise<void> {
    if (viewer.role !== 'VENDOR' && viewer.role !== 'ADMIN') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }

    if (!meetsPasswordPolicy(input.newPassword)) {
      throw new ApiException(HttpStatus.BAD_REQUEST, ErrorCode.PASSWORD_POLICY);
    }

    const user = await this.users.findById(viewer.userId);
    if (!user || user.deletedAt) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    }

    if (user.passwordHash) {
      if (!input.currentPassword) {
        throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
      }
      const ok = await this.hasher.verify(input.currentPassword, user.passwordHash);
      if (!ok) {
        throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
      }
    }

    const passwordHash = await this.hasher.hash(input.newPassword);
    await this.users.setPasswordHash(user.id, passwordHash);
  }
}
