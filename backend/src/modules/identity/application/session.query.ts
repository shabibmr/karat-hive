import { Injectable } from '@nestjs/common';
import type { UserAccountState, UserType, VendorVerificationState } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';

export type UserForViewer = {
  id: string;
  userType: UserType;
  tokenVersion: number;
  accountState: UserAccountState;
  preferredLanguage: 'en' | 'ar';
  deletedAt: Date | null;
  vendorProfileId: string | null;
  vendorVerificationState: VendorVerificationState | null;
  vendorActivatedAt: Date | null;
  customerProfileId: string | null;
  adminProfileId: string | null;
};

@Injectable()
export class SessionQuery {
  constructor(private readonly prisma: PrismaService) {}

  async findUserForViewer(id: string): Promise<UserForViewer | null> {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: { customerProfile: true, vendorProfile: true, adminProfile: true },
    });
    if (!user) return null;
    return {
      id: user.id,
      userType: user.userType,
      tokenVersion: user.tokenVersion,
      accountState: user.accountState,
      preferredLanguage: user.preferredLanguage,
      deletedAt: user.deletedAt,
      vendorProfileId: user.vendorProfile?.id ?? null,
      vendorVerificationState: user.vendorProfile?.verificationState ?? null,
      vendorActivatedAt: user.vendorProfile?.activatedAt ?? null,
      customerProfileId: user.customerProfile?.id ?? null,
      adminProfileId: user.adminProfile?.id ?? null,
    };
  }
}
