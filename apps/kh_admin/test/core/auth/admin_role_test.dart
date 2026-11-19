import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/auth/admin_role.dart';

void main() {
  group('AdminAccess', () {
    test('Super Admin can access every permission', () {
      final access = AdminAccess(AdminRole.superAdmin);
      for (final permission in AdminPermission.values) {
        expect(access.can(permission), isTrue, reason: permission.name);
      }
    });

    test('Operations Admin cannot manage Admin accounts or settings', () {
      final access = AdminAccess(AdminRole.operationsAdmin);
      expect(access.can(AdminPermission.customersWrite), isTrue);
      expect(access.can(AdminPermission.moderationWrite), isTrue);
      expect(access.can(AdminPermission.adminUsersWrite), isFalse);
      expect(access.can(AdminPermission.settingsWrite), isFalse);
      expect(access.can(AdminPermission.auditRead), isFalse);
    });

    test('Read-only Analyst is limited to dashboards and reports', () {
      final access = AdminAccess(AdminRole.readOnlyAnalyst);
      expect(access.can(AdminPermission.dashboardRead), isTrue);
      expect(access.can(AdminPermission.reportsRead), isTrue);
      expect(access.can(AdminPermission.reportsExport), isTrue);
      expect(access.can(AdminPermission.customersRead), isFalse);
      expect(access.can(AdminPermission.customersWrite), isFalse);
      expect(access.can(AdminPermission.moderationWrite), isFalse);
    });

    test('route checks protect nested routes', () {
      final analyst = AdminAccess(AdminRole.readOnlyAnalyst);
      expect(analyst.canRoute('/'), isTrue);
      expect(analyst.canRoute('/reports'), isTrue);
      expect(analyst.canRoute('/customers'), isFalse);
      expect(analyst.canRoute('/customers/123'), isFalse);
    });
  });
}
