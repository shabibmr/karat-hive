import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';

/// Account lifecycle state for Karat Hive administrator users.
///
/// Backend returns:
/// - `ACTIVE`: fully operational administrator
/// - `SUSPENDED`: temporarily blocked from admin console
/// - `DEACTIVATED`: access permanently revoked
enum AdminAccountState {
  active,
  suspended,
  deactivated;

  String get wireValue {
    switch (this) {
      case AdminAccountState.active:
        return 'ACTIVE';
      case AdminAccountState.suspended:
        return 'SUSPENDED';
      case AdminAccountState.deactivated:
        return 'DEACTIVATED';
    }
  }

  static AdminAccountState? fromWire(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase().trim()) {
      case 'ACTIVE':
        return AdminAccountState.active;
      case 'SUSPENDED':
        return AdminAccountState.suspended;
      case 'DEACTIVATED':
      case 'REVOKED':
        return AdminAccountState.deactivated;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case AdminAccountState.active:
        return 'Active';
      case AdminAccountState.suspended:
        return 'Suspended';
      case AdminAccountState.deactivated:
        return 'Revoked';
    }
  }

  String get displayName => label;

  KhStatusTone get tone {
    switch (this) {
      case AdminAccountState.active:
        return KhStatusTone.success;
      case AdminAccountState.suspended:
        return KhStatusTone.pending;
      case AdminAccountState.deactivated:
        return KhStatusTone.error;
    }
  }
}
