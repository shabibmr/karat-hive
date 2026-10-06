import type { UserType } from '@prisma/client';

export const AuthAudience = {
  CUSTOMER_APP: 'CUSTOMER_APP',
  VENDOR_APP: 'VENDOR_APP',
  MOBILE_RESTORE: 'MOBILE_RESTORE',
  ADMIN_PORTAL: 'ADMIN_PORTAL',
} as const;

export type AuthAudience =
  (typeof AuthAudience)[keyof typeof AuthAudience];

export function allowedRolesForAudience(audience: AuthAudience): readonly UserType[] {
  switch (audience) {
    case AuthAudience.CUSTOMER_APP:
      return ['CUSTOMER'];
    case AuthAudience.VENDOR_APP:
      return ['VENDOR'];
    case AuthAudience.MOBILE_RESTORE:
      return ['CUSTOMER', 'VENDOR'];
    case AuthAudience.ADMIN_PORTAL:
      return ['ADMIN'];
  }
}

export function audienceMatchesRole(audience: AuthAudience, role: UserType): boolean {
  return allowedRolesForAudience(audience).includes(role);
}
