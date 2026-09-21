import 'package:flutter/foundation.dart';

/// Privilege level assigned to a Platform Admin by the backend.
enum AdminRole {
  superAdmin,
  operationsAdmin,
  readOnlyAnalyst,
}

extension AdminRoleWire on AdminRole {
  String get wireValue {
    switch (this) {
      case AdminRole.superAdmin:
        return 'SUPER_ADMIN';
      case AdminRole.operationsAdmin:
        return 'OPERATIONS_ADMIN';
      case AdminRole.readOnlyAnalyst:
        return 'READ_ONLY_ANALYST';
    }
  }

  String get label {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.operationsAdmin:
        return 'Operations Admin';
      case AdminRole.readOnlyAnalyst:
        return 'Read-only Analyst';
    }
  }

  static AdminRole? fromWire(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'SUPER_ADMIN':
        return AdminRole.superAdmin;
      case 'OPERATIONS_ADMIN':
        return AdminRole.operationsAdmin;
      case 'READ_ONLY_ANALYST':
        return AdminRole.readOnlyAnalyst;
      // Legacy backend userType=ADMIN is intentionally handled by the
      // authenticated session only after the RBAC migration has assigned a role.
      default:
        return null;
    }
  }
}

enum AdminPermission {
  dashboardRead,
  reportsRead,
  reportsExport,
  auditRead,
  customersRead,
  customersWrite,
  vendorsRead,
  vendorsWrite,
  verificationWrite,
  requestsRead,
  requestsWrite,
  offersRead,
  connectionsRead,
  connectionsWrite,
  taxonomyWrite,
  moderationWrite,
  abuseWrite,
  announcementsWrite,
  settingsWrite,
  goldRatesWrite,
  subscriptionsWrite,
  adminUsersWrite,
}

@immutable
class AdminAccess {
  const AdminAccess(this.role);

  final AdminRole role;

  bool can(AdminPermission permission) {
    if (role == AdminRole.superAdmin) return true;
    if (role == AdminRole.readOnlyAnalyst) {
      return const {
        AdminPermission.dashboardRead,
        AdminPermission.reportsRead,
        AdminPermission.reportsExport,
      }.contains(permission);
    }
    return const {
      AdminPermission.dashboardRead,
      AdminPermission.reportsRead,
      AdminPermission.reportsExport,
      AdminPermission.customersRead,
      AdminPermission.customersWrite,
      AdminPermission.vendorsRead,
      AdminPermission.vendorsWrite,
      AdminPermission.verificationWrite,
      AdminPermission.requestsRead,
      AdminPermission.requestsWrite,
      AdminPermission.offersRead,
      AdminPermission.connectionsRead,
      AdminPermission.connectionsWrite,
      AdminPermission.taxonomyWrite,
      AdminPermission.moderationWrite,
      AdminPermission.abuseWrite,
      AdminPermission.announcementsWrite,
      AdminPermission.goldRatesWrite,
      AdminPermission.subscriptionsWrite,
    }.contains(permission);
  }
}
