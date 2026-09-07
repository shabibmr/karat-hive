import type { User } from '@prisma/client';
import type { VendorMe } from '../../vendor-onboarding';

export type AdminMe = {
  displayName: string;
};

export type CustomerMe = {
  displayName: string;
  photoUrl?: string | null;
  defaultRegion?: {
    id: string;
    nameEn: string;
    nameAr: string;
  } | null;
  rating?: {
    average: number;
    count: number;
  } | null;
  reviewCount: number;
  connectionCount: number;
  liveRequestCount?: number;
  canCreateRequest?: boolean;
};

export type Me = {
  id?: string;
  userId: string;
  userType: User['userType'];
  accountState: User['accountState'];
  mobileNumber: string;
  email: string | null;
  preferredLanguage: User['preferredLanguage'];
  oauthBound?: boolean;
  customer?: CustomerMe;
  vendor?: VendorMe;
  admin?: AdminMe;
};

export type DeletionRequestView = {
  id: string;
  state: 'QUEUED' | 'RUNNING' | 'COMPLETED' | 'FAILED';
  createdAt: string;
  challengeId?: string;
  expiresAt?: string;
  retryAfterSeconds?: number;
};

export function presentMe(
  user: User,
  vendor?: VendorMe | null,
  admin?: AdminMe | null,
  customer?: CustomerMe | null,
  oauthBound?: boolean,
): Me {
  return {
    id: user.id,
    userId: user.id,
    userType: user.userType,
    accountState: user.accountState,
    mobileNumber: user.mobileNumber,
    email: user.email,
    preferredLanguage: user.preferredLanguage,
    ...(oauthBound !== undefined ? { oauthBound } : {}),
    ...(customer ? { customer } : {}),
    ...(vendor ? { vendor } : {}),
    ...(admin ? { admin } : {}),
  };
}
