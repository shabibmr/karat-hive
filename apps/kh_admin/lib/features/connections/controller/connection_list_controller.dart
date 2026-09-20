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
    replaceFilters(state.filters.copyWith(query: query));
  }

  Future<void> submitSearch() => refresh();
}

final connectionListControllerProvider =
    NotifierProvider<ConnectionListController, ConnectionListState>(
  ConnectionListController.new,
);
