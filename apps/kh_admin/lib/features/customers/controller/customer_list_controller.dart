import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/customers/model/customer_enums.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';
import 'package:kh_admin/features/customers/model/customer_list_item.dart';
import 'package:kh_admin/features/customers/repository/customer_repository.dart';

/// State for the customer list screen (ADM-S03).
class CustomerListState {
  const CustomerListState({
    this.items = const [],
    this.filters = const CustomerListFilters(),
    this.nextCursor,
    this.hasMore,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.cursorHistory = const [null],
  });

  final List<CustomerListItem> items;
  final CustomerListFilters filters;
  final String? nextCursor;
  final bool? hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final List<String?> cursorHistory;

  bool get canLoadMore {
    if (hasMore == false) return false;
    final cursor = nextCursor;
    return cursor != null && cursor.isNotEmpty;
  }

  bool get canGoNext => canLoadMore && !isLoading && !isLoadingMore;
  bool get canGoPrevious => page > 1 && !isLoading && !isLoadingMore;

  CustomerListState copyWith({
    List<CustomerListItem>? items,
    CustomerListFilters? filters,
    String? nextCursor,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    List<String?>? cursorHistory,
  }) {
    return CustomerListState(
      items: items ?? this.items,
      filters: filters ?? this.filters,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      page: page ?? this.page,
      cursorHistory: cursorHistory ?? this.cursorHistory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerListState &&
          runtimeType == other.runtimeType &&
          listEquals(items, other.items) &&
          filters == other.filters &&
          nextCursor == other.nextCursor &&
          hasMore == other.hasMore &&
          isLoading == other.isLoading &&
          isLoadingMore == other.isLoadingMore &&
          error == other.error &&
          page == other.page &&
          listEquals(cursorHistory, other.cursorHistory);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        filters,
        nextCursor,
        hasMore,
        isLoading,
        isLoadingMore,
        error,
        page,
        Object.hashAll(cursorHistory),
      );

  @override
  String toString() =>
      'CustomerListState(items: ${items.length}, page: $page, isLoading: $isLoading, error: $error)';
}

/// Controller managing customer list state, filters, and pagination.
class CustomerListController extends Notifier<CustomerListState> {
  @override
  CustomerListState build() {
    Future.microtask(refresh);
    return const CustomerListState(isLoading: true);
  }

  CustomerRepository get _repository => ref.read(customerRepositoryProvider);

  /// Refreshes the first page with current filters.
  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      error: null,
      items: const [],
      nextCursor: null,
      hasMore: null,
      page: 1,
      cursorHistory: const [null],
    );

    try {
      final page = await _repository.fetchCustomers(filters: state.filters);
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        page: 1,
        cursorHistory: const [null],
      );
    } on Object catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      state = state.copyWith(
        isLoading: false,
        error: msg,
      );
    }
  }

  /// Appends the next cursor page to current items (infinite scrolling).
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.canLoadMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final page = await _repository.fetchCustomers(
        filters: state.filters,
        cursor: state.nextCursor,
      );
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } on Object catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Alias for loading the next page of items.
  Future<void> fetchNextPage() => nextPage();

  /// Advances to the next page replacing current table items (paginated table mode).
  Future<void> nextPage() async {
    if (!state.canGoNext) return;
    final currentCursor = state.nextCursor;
    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final page = await _repository.fetchCustomers(
        filters: state.filters,
        cursor: currentCursor,
      );
      final newHistory = [...state.cursorHistory, currentCursor];
      state = state.copyWith(
        isLoadingMore: false,
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        page: state.page + 1,
        cursorHistory: newHistory,
      );
    } on Object catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Navigates to the previous page in paginated table mode.
  Future<void> previousPage() async {
    if (!state.canGoPrevious) return;
    final targetPage = state.page - 1;
    final targetCursor = state.cursorHistory[targetPage - 1];
    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final page = await _repository.fetchCustomers(
        filters: state.filters,
        cursor: targetCursor,
      );
      state = state.copyWith(
        isLoadingMore: false,
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        page: targetPage,
      );
    } on Object catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Replaces the active filters and refreshes the list from page 1.
  Future<void> applyFilters(CustomerListFilters filters) async {
    state = state.copyWith(filters: filters);
    await refresh();
  }

  /// Helper to toggle or set the account state filter.
  Future<void> setAccountStateFilter(CustomerAccountState? accountState) async {
    await applyFilters(
      state.filters.copyWith(
        accountState: () => accountState,
      ),
    );
  }

  /// Updates the query without submitting an API call immediately (used with debounce).
  void setSearchQuery(String query) {
    state = state.copyWith(
      filters: state.filters.copyWith(query: query),
    );
  }

  /// Triggers a refresh using the current search query.
  Future<void> submitSearch() => refresh();
}

/// Provider for [CustomerListController].
final NotifierProvider<CustomerListController, CustomerListState>
    customerListControllerProvider =
    NotifierProvider<CustomerListController, CustomerListState>(
  CustomerListController.new,
);
