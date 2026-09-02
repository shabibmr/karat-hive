import type { User } from '@prisma/client';
import type { VendorMe } from '../../vendor-onboarding';

export type Me = {
  userId: string;
  userType: User['userType'];
  accountState: User['accountState'];
  mobileNumber: string;
  email: string | null;
  preferredLanguage: User['preferredLanguage'];
  vendor?: VendorMe;
};

export function presentMe(user: User, vendor?: VendorMe | null): Me {
  return {
    userId: user.id,
    userType: user.userType,
    accountState: user.accountState,
    mobileNumber: user.mobileNumber,
    email: user.email,
    preferredLanguage: user.preferredLanguage,
    ...(vendor ? { vendor } : {}),
  };
}
