export const ADMIN_ROLES = ['SUPER_ADMIN', 'OPERATIONS_ADMIN', 'READ_ONLY_ANALYST'] as const;

export type AdminRole = (typeof ADMIN_ROLES)[number];

export function isAdminRole(value: unknown): value is AdminRole {
  return typeof value === 'string' && (ADMIN_ROLES as readonly string[]).includes(value);
}
