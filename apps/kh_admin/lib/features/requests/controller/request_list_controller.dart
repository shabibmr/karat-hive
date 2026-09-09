import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/requests/model/request_list_filters.dart';
import 'package:kh_admin/features/requests/model/request_list_item.dart';
import 'package:kh_admin/features/requests/repository/request_repository.dart';

typedef RequestListState = CursorListState<RequestListItem, RequestListFilters>;

/// Controller for the ADM-S08 request table (filters + cursor pagination)
/// built on the shared list kernel (TR-S1-17b).
class RequestListController
    extends CursorPaginatedNotifier<RequestListItem, RequestListFilters> {
  @override
  RequestListFilters get initialFilters => const RequestListFilters();

  @override
  Object? Function(RequestListItem item)? get itemKey => (item) => item.id;

  @override
  Future<Paginated<RequestListItem>> fetchPage({
    required RequestListFilters filters,
    String? cursor,
    int limit = 20,
  }) {
    return ref.read(requestRepositoryProvider).fetchRequests(
          filters: filters,
          cursor: cursor,
          limit: limit,
        );
  }

  void setSearchQuery(String query) {
    applyFilters(state.filters.copyWith(query: query));
  }

  Future<void> submitSearch() => refresh();

  Future<void> toggleZeroOffers(bool? value) async {
    await applyFilters(
      state.filters.copyWith(zeroOffersOnly: value ?? false),
    );
  }
}

final requestListControllerProvider =
    NotifierProvider<RequestListController, RequestListState>(
  RequestListController.new,
);
