import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_filters.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_item.dart';
import 'package:kh_admin/features/vendors/repository/vendor_repository.dart';

typedef VendorListState = CursorListState<VendorListItem, VendorListFilters>;

/// Controller for the ADM-S05 vendor table (filters + cursor pagination)
/// built on the shared list kernel (TR-S1-17a).
class VendorListController
    extends CursorPaginatedNotifier<VendorListItem, VendorListFilters> {
  @override
  VendorListFilters get initialFilters => const VendorListFilters();

  @override
  Object? Function(VendorListItem item)? get itemKey => (item) => item.id;

  @override
  Future<Paginated<VendorListItem>> fetchPage({
    required VendorListFilters filters,
    String? cursor,
    int limit = 20,
  }) {
    return ref.read(vendorRepositoryProvider).fetchVendors(
          filters: filters,
          cursor: cursor,
          limit: limit,
        );
  }

  void setSearchQuery(String query) {
    applyFilters(state.filters.copyWith(query: query));
  }

  Future<void> submitSearch() => refresh();
}

final vendorListControllerProvider =
    NotifierProvider<VendorListController, VendorListState>(
  VendorListController.new,
);
