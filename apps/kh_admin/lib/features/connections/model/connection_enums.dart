import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';

/// Connection state machine (`ConnectionState` in Prisma).
///
/// ADM-S12 & ADM-S13: Platform-wide connection tracking.
enum ConnectionState {
  active,
  closed,
  completed,
  cancelled;

  String get apiValue {
    switch (this) {
      case ConnectionState.active:
        return 'ACTIVE';
      case ConnectionState.closed:
        return 'CLOSED';
      case ConnectionState.completed:
        return 'COMPLETED';
      case ConnectionState.cancelled:
        return 'CANCELLED';
    }
  }

  static ConnectionState? fromApi(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().toUpperCase();
    for (final state in ConnectionState.values) {
      if (state.apiValue == normalized) return state;
    }
    return null;
  }

  String get displayName {
    switch (this) {
      case ConnectionState.active:
        return 'Active';
      case ConnectionState.closed:
        return 'Closed';
      case ConnectionState.completed:
        return 'Completed';
      case ConnectionState.cancelled:
        return 'Cancelled';
    }
  }

  KhStatusTone get statusTone {
    switch (this) {
      case ConnectionState.active:
        return KhStatusTone.success;
      case ConnectionState.closed:
        return KhStatusTone.neutral;
      case ConnectionState.completed:
        return KhStatusTone.success;
      case ConnectionState.cancelled:
        return KhStatusTone.error;
    }
  }
}
