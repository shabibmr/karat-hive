import { HttpStatus, Injectable } from '@nestjs/common';
import type { PreferredLanguage, User } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { VendorOnboardingService } from '../../vendor-onboarding';
import { presentMe, type Me } from '../presenter/me.presenter';
import { UserRepository } from '../repository/user.repository';

@Injectable()
export class MeService {
  constructor(
    private readonly users: UserRepository,
    private readonly vendors: VendorOnboardingService,
  ) {}

  async forUser(user: User): Promise<Me> {
    const vendor =
      user.userType === 'VENDOR'
        ? await this.vendors.vendorMeForUser(user.id, user.accountState)
        : null;
    return presentMe(user, vendor);
  }

  async get(viewer: ViewerContext): Promise<Me> {
    const user = await this.users.findById(viewer.userId);
    if (!user) throw new ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHENTICATED);
    return this.forUser(user);
  }

  async patch(viewer: ViewerContext, dto: { preferredLanguage?: PreferredLanguage }): Promise<Me> {
    if (dto.preferredLanguage) {
      await this.users.setPreferredLanguage(viewer.userId, dto.preferredLanguage);
    }
    return this.get(viewer);
  }
}
