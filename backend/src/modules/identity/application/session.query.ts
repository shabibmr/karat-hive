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

  async findOrCreateUserForFirebase(claims: FirebaseClaims): Promise<UserForViewer> {
    const subjectHash = hashToken(claims.uid);
    const now = new Date();

    // a) Check OauthBinding (provider: GOOGLE, subjectHash: hashToken(claims.uid))
    const existingBinding = await this.prisma.oauthBinding.findUnique({
      where: { subjectHash },
    });
    if (existingBinding) {
      const viewer = await this.findUserForViewer(existingBinding.userId);
      if (viewer) return viewer;
    }

    // b) If not bound, match existing User by email or mobileNumber, and insert OauthBinding
    const email = claims.email?.trim() || null;
    const phone = claims.phoneNumber?.trim() || null;
    let matchedUser = null;

    if (email) {
      matchedUser = await this.prisma.user.findUnique({
        where: { email },
      });
    }
    if (!matchedUser && phone) {
      matchedUser = await this.prisma.user.findUnique({
        where: { mobileNumber: phone },
      });
    }

    if (matchedUser) {
      await this.prisma.oauthBinding.upsert({
        where: {
          userId_provider: {
            userId: matchedUser.id,
            provider: 'GOOGLE',
          },
        },
        create: {
          userId: matchedUser.id,
          provider: 'GOOGLE',
          subjectHash,
          boundAt: now,
        },
        update: {
          subjectHash,
          boundAt: now,
        },
      });

      const viewer = await this.findUserForViewer(matchedUser.id);
      if (!viewer) {
        throw new Error(`User not found after oauth binding: ${matchedUser.id}`);
      }
      return viewer;
    }

    // c) If no existing user, provision User, VendorProfile, and OauthBinding
    const fallbackMobile = phone ?? `+fb_${claims.uid.slice(0, 15)}`;
    const uniqueSuffix = claims.uid.slice(0, 30);
    const displayName = claims.name?.trim() || 'Pending Onboarding';

    const newUser = await this.prisma.$transaction(async (tx) => {
      const createdUser = await tx.user.create({
        data: {
          mobileNumber: fallbackMobile,
          mobileVerifiedAt: phone ? now : null,
          email,
          emailVerifiedAt: claims.emailVerified ? now : null,
          userType: 'VENDOR',
          accountState: 'ACTIVE',
          preferredLanguage: 'en',
        },
      });

      await tx.vendorProfile.create({
        data: {
          userId: createdUser.id,
          legalBusinessName: displayName,
          tradingName: displayName,
          tradeLicenceNumber: `PENDING_${uniqueSuffix}`,
          licenceExpiryDate: new Date(now.getTime() + 365 * 24 * 60 * 60 * 1000),
          businessAddress: 'Pending Onboarding',
          contactPersonName: claims.name?.trim() || 'Firebase User',
          businessEmail: email ?? `${claims.uid}@karathive.local`,
          verificationState: 'REGISTERED',
        },
      });

      await tx.oauthBinding.create({
        data: {
          userId: createdUser.id,
          provider: 'GOOGLE',
          subjectHash,
          boundAt: now,
        },
      });

      return createdUser;
    });

    const viewer = await this.findUserForViewer(newUser.id);
    if (!viewer) {
      throw new Error(`Failed to find viewer for newly created user: ${newUser.id}`);
    }
    return viewer;
  }
}

