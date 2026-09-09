import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/connections/model/connection_enums.dart';
import 'package:kh_admin/features/connections/model/connection_list_filters.dart';
import 'package:kh_admin/features/connections/model/connection_list_item.dart';
import 'package:kh_admin/features/connections/repository/connection_repository.dart';

typedef ConnectionListState
    = CursorListState<ConnectionListItem, ConnectionListFilters>;

/// Controller managing ADM-S12 connections list, filters, and pagination (TR-S1-17e).
class ConnectionListController
    extends CursorPaginatedNotifier<ConnectionListItem, ConnectionListFilters> {
  @override
  ConnectionListFilters get initialFilters => const ConnectionListFilters();

  @override
  Object? Function(ConnectionListItem item)? get itemKey => (item) => item.id;

  @override
  Future<Paginated<ConnectionListItem>> fetchPage({
    required ConnectionListFilters filters,
    String? cursor,
    int limit = 20,
  }) {
    return ref.read(connectionRepositoryProvider).fetchConnections(
          filters: filters,
          cursor: cursor,
          limit: limit,
        );
  }

  Future<void> setStateFilter(ConnectionState? stateFilter) async {
    final newFilters = state.filters.copyWith(
      state: stateFilter,
      clearState: stateFilter == null,
    );
    await applyFilters(newFilters);
  }

  void setSearchQuery(String query) {
    final newFilters = state.filters.copyWith(query: query);
    final s = state;
    if (s is CursorListLoaded<ConnectionListItem, ConnectionListFilters>) {
      state = s.copyWith(filters: newFilters);
    } else if (s is CursorListError<ConnectionListItem, ConnectionListFilters>) {
      state = CursorListError<ConnectionListItem, ConnectionListFilters>(
        filters: newFilters,
        errorMessage: s.errorMessage,
        rawError: s.rawError,
        items: s.items,
        page: s.page,
        nextCursor: s.nextCursor,
        totalCount: s.totalCount,
        cursorHistory: s.cursorHistory,
      );
    } else if (s is CursorListLoading<ConnectionListItem, ConnectionListFilters>) {
      state = CursorListLoading<ConnectionListItem, ConnectionListFilters>(
        filters: newFilters,
      );
    }
  }

  Future<void> submitSearch() => refresh();
}

final connectionListControllerProvider =
    NotifierProvider<ConnectionListController, ConnectionListState>(
  ConnectionListController.new,
);
