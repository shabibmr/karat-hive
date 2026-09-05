import type { User } from '@prisma/client';
import type { VendorMe } from '../../vendor-onboarding';

export type AdminMe = {
  displayName: string;
};

export type Me = {
  id?: string;
  userId: string;
  userType: User['userType'];
  accountState: User['accountState'];
  mobileNumber: string;
  email: string | null;
  preferredLanguage: User['preferredLanguage'];
  vendor?: VendorMe;
  admin?: AdminMe;
};

export function presentMe(user: User, vendor?: VendorMe | null, admin?: AdminMe | null): Me {
  return {
    id: user.id,
    userId: user.id,
    userType: user.userType,
    accountState: user.accountState,
    mobileNumber: user.mobileNumber,
    email: user.email,
    preferredLanguage: user.preferredLanguage,
    ...(vendor ? { vendor } : {}),
    ...(admin ? { admin } : {}),
  };
}
