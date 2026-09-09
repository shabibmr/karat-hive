import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_enums.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_filters.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_item.dart';
import 'package:kh_admin/features/admin_users/repository/admin_user_repository.dart';

typedef AdminUserState = CursorListState<AdminUserItem, AdminUserFilters>;

extension AdminUserListStateX
    on CursorListState<AdminUserItem, AdminUserFilters> {
  List<AdminUserItem> get admins => items;
  List<AdminUserItem> get filteredAdmins => items;
  bool get isActionLoading => isPaging;
  int get activeCount =>
      items.where((a) => a.accountState == AdminAccountState.active).length;
  int get suspendedCount =>
      items.where((a) => a.accountState == AdminAccountState.suspended).length;
  int get revokedCount =>
      items.where((a) => a.accountState == AdminAccountState.deactivated).length;
  String? get actionSuccessMessage => null;
}

/// Controller managing ADM-S23 Admin User state and mutations on the list kernel (TR-S1-17j).
class AdminUserController
    extends CursorPaginatedNotifier<AdminUserItem, AdminUserFilters> {
  @override
  AdminUserFilters get initialFilters => const AdminUserFilters();

  @override
  Object? Function(AdminUserItem item)? get itemKey => (item) => item.id;

  @override
  int get pageSize => 20;

  @override
  Future<Paginated<AdminUserItem>> fetchPage({
    required AdminUserFilters filters,
    String? cursor,
    int limit = 20,
  }) {
    return ref.read(adminUserRepositoryProvider).fetchAdmins(
          filters: filters,
          cursor: cursor,
          limit: limit,
        );
  }

  /// Alias for initial/refresh load
  Future<void> loadAdmins() => refresh();

  void setSearchQuery(String query) {
    applyFilters(state.filters.copyWith(query: query));
  }

  void setStateFilter(AdminAccountState? accountState) {
    applyFilters(
      state.filters.copyWith(
        state: accountState,
        clearState: accountState == null,
      ),
    );
  }

  void resetFilters() {
    applyFilters(const AdminUserFilters());
  }

  Future<bool> provisionAdmin({
    required String email,
    required String displayName,
  }) async {
    try {
      await ref.read(adminUserRepositoryProvider).createAdmin(
            email: email,
            displayName: displayName,
          );
      await refresh();
      return true;
    } on Object catch (e) {
      state = CursorListError<AdminUserItem, AdminUserFilters>(
        filters: state.filters,
        errorMessage: 'Failed to provision admin: $e',
        rawError: e,
        items: state.items,
        page: state.page,
        nextCursor: state.nextCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
      return false;
    }
  }

  Future<bool> suspendAdmin(String id) async {
    try {
      await ref.read(adminUserRepositoryProvider).suspendAdmin(id);
      await refresh();
      return true;
    } on Object catch (e) {
      state = CursorListError<AdminUserItem, AdminUserFilters>(
        filters: state.filters,
        errorMessage: 'Failed to suspend admin: $e',
        rawError: e,
        items: state.items,
        page: state.page,
        nextCursor: state.nextCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
      return false;
    }
  }

  Future<bool> revokeAdmin(String id) async {
    try {
      await ref.read(adminUserRepositoryProvider).revokeAdmin(id);
      await refresh();
      return true;
    } on Object catch (e) {
      final errStr = e.toString();
      final userMessage =
          errStr.contains('409') || errStr.toLowerCase().contains('conflict')
              ? 'Cannot revoke the last remaining active admin account.'
              : 'Failed to revoke admin: $e';

      state = CursorListError<AdminUserItem, AdminUserFilters>(
        filters: state.filters,
        errorMessage: userMessage,
        rawError: e,
        items: state.items,
        page: state.page,
        nextCursor: state.nextCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
      return false;
    }
  }
}

/// Provider for [AdminUserController].
final adminUserControllerProvider =
    NotifierProvider<AdminUserController, AdminUserState>(
  AdminUserController.new,
);
