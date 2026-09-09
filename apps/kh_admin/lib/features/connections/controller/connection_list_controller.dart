import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/connections/model/connection_enums.dart';
import 'package:kh_admin/features/connections/model/connection_list_filters.dart';
import 'package:kh_admin/features/connections/model/connection_list_item.dart';
import 'package:kh_admin/features/connections/repository/connection_repository.dart';

/// State of the ADM-S12 Connection List table.
class ConnectionListState {
  const ConnectionListState({
    this.items = const [],
    this.filters = const ConnectionListFilters(),
    this.nextCursor,
    this.hasMore,
    this.totalCount,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.cursorHistory = const [null],
  });

  final List<ConnectionListItem> items;
  final ConnectionListFilters filters;
  final String? nextCursor;
  final bool? hasMore;
  final int? totalCount;
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

  ConnectionListState copyWith({
    List<ConnectionListItem>? items,
    ConnectionListFilters? filters,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? page,
    List<String?>? cursorHistory,
  }) {
    return ConnectionListState(
      items: items ?? this.items,
      filters: filters ?? this.filters,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      cursorHistory: cursorHistory ?? this.cursorHistory,
    );
  }
}

/// Controller managing ADM-S12 connections list, filters, and pagination.
class ConnectionListController extends Notifier<ConnectionListState> {
  @override
  ConnectionListState build() {
    Future.microtask(refresh);
    return const ConnectionListState(isLoading: true);
  }

  ConnectionRepository get _repository => ref.read(connectionRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      clearError: true,
      items: const [],
      nextCursor: null,
      hasMore: null,
      page: 1,
      cursorHistory: const [null],
    );

    try {
      final page = await _repository.fetchConnections(filters: state.filters);
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        totalCount: page.totalCount,
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

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.canLoadMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await _repository.fetchConnections(
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

  Future<void> nextPage() async {
    if (!state.canGoNext) return;
    final currentCursor = state.nextCursor;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await _repository.fetchConnections(
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

  Future<void> previousPage() async {
    if (!state.canGoPrevious) return;
    final targetPage = state.page - 1;
    final targetCursor = state.cursorHistory[targetPage - 1];
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await _repository.fetchConnections(
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

  Future<void> applyFilters(ConnectionListFilters filters) async {
    state = state.copyWith(filters: filters);
    await refresh();
  }

  Future<void> setStateFilter(ConnectionState? stateFilter) async {
    final newFilters = state.filters.copyWith(
      state: stateFilter,
      clearState: stateFilter == null,
    );
    await applyFilters(newFilters);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      filters: state.filters.copyWith(query: query),
    );
  }

  Future<void> submitSearch() => refresh();
}

final NotifierProvider<ConnectionListController, ConnectionListState>
    connectionListControllerProvider =
    NotifierProvider<ConnectionListController, ConnectionListState>(
  ConnectionListController.new,
);
