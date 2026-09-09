import 'package:kh_admin/features/admin_users/model/admin_user_enums.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_item.dart';

/// Filters applied to the ADM-S23 admin users directory.
class AdminUserFilters {
  const AdminUserFilters({
    this.state,
    this.query = '',
  });

  /// Filter by account state (Active, Suspended, Deactivated).
  final AdminAccountState? state;

  /// Free-text search query across display name, email, or ID.
  final String query;

  AdminUserFilters copyWith({
    AdminAccountState? state,
    bool clearState = false,
    String? query,
  }) {
    return AdminUserFilters(
      state: clearState ? null : (state ?? this.state),
      query: query ?? this.query,
    );
  }

  /// Evaluates whether an [item] satisfies the filter criteria.
  bool matches(AdminUserItem item) {
    if (state != null && item.accountState != state) {
      return false;
    }
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isNotEmpty) {
      final matchesName = item.displayName.toLowerCase().contains(trimmedQuery);
      final matchesEmail = item.email.toLowerCase().contains(trimmedQuery);
      final matchesId = item.id.toLowerCase().contains(trimmedQuery) ||
          item.userId.toLowerCase().contains(trimmedQuery);
      if (!matchesName && !matchesEmail && !matchesId) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (state != null) 'state': state!.wireValue,
      if (query.trim().isNotEmpty) 'q': query.trim(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserFilters &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          query == other.query;

  @override
  int get hashCode => Object.hash(state, query);
}
