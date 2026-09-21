import { describe, expect, it } from 'vitest';
import { hasAdminPermission, permissionForAdminRequest } from './admin-permissions';

describe('admin permissions', () => {
  it('limits read-only analysts to dashboards and reports', () => {
    expect(hasAdminPermission('READ_ONLY_ANALYST', 'dashboard.read')).toBe(true);
    expect(hasAdminPermission('READ_ONLY_ANALYST', 'reports.read')).toBe(true);
    expect(hasAdminPermission('READ_ONLY_ANALYST', 'reports.export')).toBe(true);
    expect(hasAdminPermission('READ_ONLY_ANALYST', 'customers.read')).toBe(false);
    expect(hasAdminPermission('READ_ONLY_ANALYST', 'moderation.write')).toBe(false);
  });

  it('allows operations mutations but not platform administration', () => {
    expect(hasAdminPermission('OPERATIONS_ADMIN', 'vendors.write')).toBe(true);
    expect(hasAdminPermission('OPERATIONS_ADMIN', 'moderation.write')).toBe(true);
    expect(hasAdminPermission('OPERATIONS_ADMIN', 'settings.write')).toBe(false);
    expect(hasAdminPermission('OPERATIONS_ADMIN', 'admin_users.write')).toBe(false);
  });

  it('maps nested admin URLs to their domain permission', () => {
    expect(permissionForAdminRequest('GET', '/v1/admin/reports/request-volume')).toBe('reports.read');
    expect(permissionForAdminRequest('POST', '/v1/admin/exports')).toBe('reports.export');
    expect(permissionForAdminRequest('POST', '/v1/admin/admins')).toBe('admin_users.write');
    expect(permissionForAdminRequest('GET', '/v1/admin/customers/123')).toBe('customers.read');
    expect(permissionForAdminRequest('POST', '/v1/admin/customers/123/suspend')).toBe('customers.write');
  });
});
