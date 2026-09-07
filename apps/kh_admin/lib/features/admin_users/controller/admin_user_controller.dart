import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/admin_user_enums.dart';
import '../model/admin_user_filters.dart';
import '../model/admin_user_item.dart';
import '../repository/admin_user_repository.dart';

/// State for ADM-S23 Admin User Provisioning & Management.
class AdminUserState {
  const AdminUserState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.admins = const [],
    this.filters = const AdminUserFilters(),
    this.errorMessage,
    this.actionSuccessMessage,
  });

  /// True while initial or refreshed admins list is fetching.
  final bool isLoading;

  /// True while an asynchronous action (provision, suspend, revoke) is in flight.
  final bool isActionLoading;

  /// Complete list of fetched administrator accounts.
  final List<AdminUserItem> admins;

  /// Active filter criteria.
  final AdminUserFilters filters;

  /// Error message from the last failed operation, if any.
  final String? errorMessage;

  /// Success message from the last completed action, if any.
  final String? actionSuccessMessage;

  /// Filtered administrators according to [filters].
  List<AdminUserItem> get filteredAdmins =>
      admins.where(filters.matches).toList(growable: false);

  /// Total count of all admin accounts.
  int get totalCount => admins.length;

  /// Count of active administrators.
  int get activeCount =>
      admins.where((a) => a.accountState == AdminAccountState.active).length;

  /// Count of suspended administrators.
  int get suspendedCount =>
      admins.where((a) => a.accountState == AdminAccountState.suspended).length;

  /// Count of deactivated (revoked) administrators.
  int get revokedCount =>
      admins.where((a) => a.accountState == AdminAccountState.deactivated).length;

  AdminUserState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<AdminUserItem>? admins,
    AdminUserFilters? filters,
    String? errorMessage,
    bool clearError = false,
    String? actionSuccessMessage,
    bool clearSuccess = false,
  }) {
    return AdminUserState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      admins: admins ?? this.admins,
      filters: filters ?? this.filters,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionSuccessMessage: clearSuccess
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }
}

/// Controller managing ADM-S23 Admin User state and mutations.
class AdminUserController extends StateNotifier<AdminUserState> {
  AdminUserController(this._repository) : super(const AdminUserState()) {
    loadAdmins();
  }

  final AdminUserRepository _repository;

  /// Fetches all admin accounts from the backend repository.
  Future<void> loadAdmins() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.fetchAdmins();
      state = state.copyWith(
        isLoading: false,
        admins: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refreshes the admin user list.
  Future<void> refresh() => loadAdmins();

  /// Updates the free-text search query.
  void setSearchQuery(String query) {
    state = state.copyWith(
      filters: state.filters.copyWith(query: query),
    );
  }

  /// Updates the account state filter.
  void setStateFilter(AdminAccountState? accountState) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        state: accountState,
        clearState: accountState == null,
      ),
    );
  }

  /// Resets all filters to initial state.
  void resetFilters() {
    state = state.copyWith(
      filters: const AdminUserFilters(),
    );
  }

  /// Provisions a new admin user.
  Future<bool> provisionAdmin({
    required String email,
    required String displayName,
  }) async {
    state = state.copyWith(
      isActionLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await _repository.createAdmin(
        email: email,
        displayName: displayName,
      );
      state = state.copyWith(
        isActionLoading: false,
        actionSuccessMessage: 'Admin user provisioned successfully.',
      );
      await loadAdmins();
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to provision admin: $e',
      );
      return false;
    }
  }

  /// Suspends an administrator account.
  Future<bool> suspendAdmin(String id) async {
    state = state.copyWith(
      isActionLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await _repository.suspendAdmin(id);
      state = state.copyWith(
        isActionLoading: false,
        actionSuccessMessage: 'Admin account suspended.',
      );
      await loadAdmins();
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to suspend admin: $e',
      );
      return false;
    }
  }

  /// Revokes an administrator account.
  ///
  /// Backend enforces activeCount > 1 to protect the last remaining admin.
  Future<bool> revokeAdmin(String id) async {
    state = state.copyWith(
      isActionLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await _repository.revokeAdmin(id);
      state = state.copyWith(
        isActionLoading: false,
        actionSuccessMessage: 'Admin account revoked.',
      );
      await loadAdmins();
      return true;
    } catch (e) {
      final errStr = e.toString();
      final userMessage =
          errStr.contains('409') || errStr.toLowerCase().contains('conflict')
              ? 'Cannot revoke the last remaining active admin account.'
              : 'Failed to revoke admin: $e';

      state = state.copyWith(
        isActionLoading: false,
        errorMessage: userMessage,
      );
      return false;
    }
  }
}

/// Provider for [AdminUserController].
final adminUserControllerProvider =
    StateNotifierProvider<AdminUserController, AdminUserState>((ref) {
  final repository = ref.watch(adminUserRepositoryProvider);
  return AdminUserController(repository);
});
