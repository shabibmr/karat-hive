import type { AdminRole } from '../domain/admin-role';

export type AdminPermission =
  | 'dashboard.read'
  | 'reports.read'
  | 'reports.export'
  | 'audit.read'
  | 'customers.read'
  | 'customers.write'
  | 'vendors.read'
  | 'vendors.write'
  | 'verification.write'
  | 'requests.read'
  | 'requests.write'
  | 'offers.read'
  | 'connections.read'
  | 'connections.write'
  | 'taxonomy.write'
  | 'moderation.write'
  | 'abuse.write'
  | 'announcements.write'
  | 'settings.write'
  | 'gold_rates.write'
  | 'subscriptions.write'
  | 'admin_users.write';

const READ_ONLY: ReadonlySet<AdminPermission> = new Set([
  'dashboard.read',
  'reports.read',
  'reports.export',
]);

const OPERATIONS: ReadonlySet<AdminPermission> = new Set([
  ...READ_ONLY,
  'customers.read', 'customers.write',
  'vendors.read', 'vendors.write',
  'verification.write',
  'requests.read', 'requests.write',
  'offers.read',
  'connections.read', 'connections.write',
  'taxonomy.write',
  'moderation.write',
  'abuse.write',
  'announcements.write',
  'gold_rates.write',
  'subscriptions.write',
]);

const SUPER_ADMIN: ReadonlySet<AdminPermission> = new Set([
  ...OPERATIONS,
  'audit.read',
  'settings.write',
  'admin_users.write',
]);

export function hasAdminPermission(role: AdminRole, permission: AdminPermission): boolean {
  switch (role) {
    case 'READ_ONLY_ANALYST': return READ_ONLY.has(permission);
    case 'OPERATIONS_ADMIN': return OPERATIONS.has(permission);
    case 'SUPER_ADMIN': return SUPER_ADMIN.has(permission);
  }
}

/**
 * Maps the Admin HTTP surface to the minimum permission required.
 * Read-only analysts are deliberately limited to dashboard/report endpoints.
 */
export function permissionForAdminRequest(method: string, url: string): AdminPermission | null {
  const path = url.split('?')[0];
  const isWrite = !['GET', 'HEAD', 'OPTIONS'].includes(method.toUpperCase());

  if (path === '/v1/admin/dashboard') return 'dashboard.read';
  if (path.startsWith('/v1/admin/reports') || path.startsWith('/v1/admin/exports')) {
    return isWrite ? 'reports.export' : 'reports.read';
  }
  if (path.startsWith('/v1/admin/audit-log')) return 'audit.read';
  if (path.startsWith('/v1/admin/admins')) return 'admin_users.write';
  if (path.startsWith('/v1/admin/settings')) return 'settings.write';
  if (path.startsWith('/v1/admin/categories') || path.startsWith('/v1/admin/regions') || path.startsWith('/v1/admin/taxonomy')) return 'taxonomy.write';
  if (path.startsWith('/v1/admin/customers')) return isWrite ? 'customers.write' : 'customers.read';
  if (path.startsWith('/v1/admin/vendors')) return isWrite ? 'vendors.write' : 'vendors.read';
  if (path.startsWith('/v1/admin/verification-queue')) return 'verification.write';
  if (path.startsWith('/v1/admin/requests')) return isWrite ? 'requests.write' : 'requests.read';
  if (path.startsWith('/v1/admin/offers')) return 'offers.read';
  if (path.startsWith('/v1/admin/connections')) return isWrite ? 'connections.write' : 'connections.read';
  if (path.startsWith('/v1/admin/reviews')) return 'moderation.write';
  if (path.startsWith('/v1/admin/abuse-reports')) return 'abuse.write';
  if (path.startsWith('/v1/admin/announcements')) return 'announcements.write';
  if (path.startsWith('/v1/admin/gold-rates')) return 'gold_rates.write';
  if (path.startsWith('/v1/admin/subscriptions')) return 'subscriptions.write';

  // New admin endpoints must opt in explicitly instead of accidentally becoming
  // available to a read-only analyst.
  return null;
}
