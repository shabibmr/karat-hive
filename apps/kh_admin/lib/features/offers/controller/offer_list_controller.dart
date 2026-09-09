import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/offers/model/offer_list_filters.dart';
import 'package:kh_admin/features/offers/model/offer_list_item.dart';
import 'package:kh_admin/features/offers/repository/offer_repository.dart';

typedef OfferListState = CursorListState<OfferListItem, OfferListFilters>;

/// Controller for the ADM-S10 offers table (filters + cursor pagination)
/// built on the shared list kernel (TR-S1-17c).
class OfferListController
    extends CursorPaginatedNotifier<OfferListItem, OfferListFilters> {
  @override
  OfferListFilters get initialFilters => const OfferListFilters();

  @override
  Object? Function(OfferListItem item)? get itemKey => (item) => item.id;

  @override
  Future<Paginated<OfferListItem>> fetchPage({
    required OfferListFilters filters,
    String? cursor,
    int limit = 20,
  }) {
    return ref.read(offerRepositoryProvider).fetchOffers(
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

final NotifierProvider<OfferListController, OfferListState>
    offerListControllerProvider =
    NotifierProvider<OfferListController, OfferListState>(
  OfferListController.new,
);
