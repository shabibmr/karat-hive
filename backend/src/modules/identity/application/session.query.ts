import { Injectable } from '@nestjs/common';
import type { UserAccountState, UserType, VendorVerificationState } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { FirebaseClaims } from './firebase-token.service';
import { hashToken } from './token.service';

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

  async findUserByFirebaseClaims(claims: FirebaseClaims): Promise<UserForViewer | null> {
    const subjectHash = hashToken(claims.uid);

    // 1. Check existing OauthBinding
    const existingBinding = await this.prisma.oauthBinding.findUnique({
      where: { subjectHash },
    });
    if (existingBinding) {
      return this.findUserForViewer(existingBinding.userId);
    }

    // 2. If not bound, match existing User by verified email
    if (claims.email && claims.emailVerified === true) {
      const email = claims.email.trim();
      const matchedUser = await this.prisma.user.findUnique({
        where: { email },
      });
      if (matchedUser) {
        return this.findUserForViewer(matchedUser.id);
      }
    }

    // 3. Match by verified E.164 phone
    const phoneRegex = /^\+[1-9]\d{6,14}$/;
    if (claims.phoneNumber && phoneRegex.test(claims.phoneNumber)) {
      const matchedUser = await this.prisma.user.findUnique({
        where: { mobileNumber: claims.phoneNumber },
      });
      if (matchedUser) {
        return this.findUserForViewer(matchedUser.id);
      }
    }

    return null;
  }
}

