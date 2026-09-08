import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/offers_customer_repository.dart';

class OfferListFilters {
  const OfferListFilters({
    this.sort,
    this.minRating,
    this.priceMin,
    this.priceMax,
    this.excludeExpiringWithinHours,
  });

  final String? sort;
  final String? minRating;
  final String? priceMin;
  final String? priceMax;
  final int? excludeExpiringWithinHours;

  OfferListFilters copyWith({
    String? sort,
    bool clearSort = false,
    String? minRating,
    bool clearMinRating = false,
    String? priceMin,
    bool clearPriceMin = false,
    String? priceMax,
    bool clearPriceMax = false,
    int? excludeExpiringWithinHours,
    bool clearExclude = false,
  }) =>
      OfferListFilters(
        sort: clearSort ? null : (sort ?? this.sort),
        minRating: clearMinRating ? null : (minRating ?? this.minRating),
        priceMin: clearPriceMin ? null : (priceMin ?? this.priceMin),
        priceMax: clearPriceMax ? null : (priceMax ?? this.priceMax),
        excludeExpiringWithinHours: clearExclude
            ? null
            : (excludeExpiringWithinHours ?? this.excludeExpiringWithinHours),
      );
}

class OfferListFiltersController extends AutoDisposeNotifier<OfferListFilters> {
  @override
  OfferListFilters build() => const OfferListFilters();

  void update(OfferListFilters next) => state = next;
}

final offerListFiltersProvider =
    AutoDisposeNotifierProvider<OfferListFiltersController, OfferListFilters>(
  OfferListFiltersController.new,
);

class OffersListController extends AutoDisposeFamilyNotifier<
    PagedListController<OfferForCustomer>, String> {
  @override
  PagedListController<OfferForCustomer> build(String arg) {
    final repo = ref.watch(offersCustomerRepositoryProvider);
    final filters = ref.watch(offerListFiltersProvider);
    final controller = PagedListController<OfferForCustomer>(
      itemKey: (item) => item.id,
      fetcher: (cursor) async {
        final res = await repo.listForRequest(
          arg,
          cursor: cursor,
          sort: filters.sort,
          minRating: filters.minRating,
          priceMin: filters.priceMin,
          priceMax: filters.priceMax,
          excludeExpiringWithinHours: filters.excludeExpiringWithinHours,
        );
        return res.when(ok: (page) => page, err: (f) => throw f);
      },
    );
    ref.onDispose(controller.dispose);
    return controller;
  }

  Future<void> loadNextPage() => state.loadNextPage();
  Future<void> refresh() => state.refresh();
  Future<void> retry() => state.retry();
}

final offersListControllerProvider = AutoDisposeNotifierProvider.family<
    OffersListController, PagedListController<OfferForCustomer>, String>(
  OffersListController.new,
);

class CompareSelectionController extends AutoDisposeNotifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String id) {
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else if (next.length < 4) {
      next.add(id);
    }
    state = next;
  }
}

final compareSelectionProvider =
    AutoDisposeNotifierProvider<CompareSelectionController, Set<String>>(
  CompareSelectionController.new,
);
