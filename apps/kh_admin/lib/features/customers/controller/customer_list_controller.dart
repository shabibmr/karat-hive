import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';
import 'package:kh_admin/features/customers/model/customer_list_item.dart';
import 'package:kh_admin/features/customers/repository/customer_repository.dart';

typedef CustomerListState
    = CursorListState<CustomerListItem, CustomerListFilters>;

/// Controller managing customer list state, filters, and pagination (TR-S1-17d).
class CustomerListController
    extends CursorPaginatedNotifier<CustomerListItem, CustomerListFilters> {
  @override
  CustomerListFilters get initialFilters => const CustomerListFilters();

  @override
  Object? Function(CustomerListItem item)? get itemKey => (item) => item.id;

  @override
  Future<Paginated<CustomerListItem>> fetchPage({
    required CustomerListFilters filters,
    String? cursor,
    int limit = 20,
  }) {
    return ref.read(customerRepositoryProvider).fetchCustomers(
          filters: filters,
          cursor: cursor,
          limit: limit,
        );
  }

  /// Alias for loading the next page of items.
  Future<void> fetchNextPage() => nextPage();

  /// Helper to toggle or set the account state filter.
  Future<void> setAccountStateFilter(CustomerAccountState? accountState) async {
    await applyFilters(
      state.filters.copyWith(
        accountState: accountState,
        clearAccountState: accountState == null,
      ),
    );
  }

  /// Updates the query without submitting an API call immediately (used with debounce).
  void setSearchQuery(String query) {
    final newFilters = state.filters.copyWith(query: query);
    final s = state;
    if (s is CursorListLoaded<CustomerListItem, CustomerListFilters>) {
      state = s.copyWith(filters: newFilters);
    } else if (s is CursorListError<CustomerListItem, CustomerListFilters>) {
      state = CursorListError<CustomerListItem, CustomerListFilters>(
        filters: newFilters,
        errorMessage: s.errorMessage,
        rawError: s.rawError,
        items: s.items,
        page: s.page,
        nextCursor: s.nextCursor,
        totalCount: s.totalCount,
        cursorHistory: s.cursorHistory,
      );
    } else if (s is CursorListLoading<CustomerListItem, CustomerListFilters>) {
      state = CursorListLoading<CustomerListItem, CustomerListFilters>(
        filters: newFilters,
      );
    }
  }

  /// Triggers a refresh using the current search query.
  Future<void> submitSearch() => refresh();
}

/// Provider for [CustomerListController].
final customerListControllerProvider =
    NotifierProvider<CustomerListController, CustomerListState>(
  CustomerListController.new,
);
