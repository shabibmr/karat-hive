import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/offers_vendor_repository.dart';

class MyOffersFilters {
  const MyOffersFilters({
    this.tab = 'PENDING',
    this.requestType,
    this.q,
  });

  final String tab; // PENDING | ACCEPTED | CLOSED
  final String? requestType;
  final String? q;

  MyOffersFilters copyWith({
    String? tab,
    String? requestType,
    bool clearRequestType = false,
    String? q,
    bool clearQ = false,
  }) {
    return MyOffersFilters(
      tab: tab ?? this.tab,
      requestType: clearRequestType ? null : (requestType ?? this.requestType),
      q: clearQ ? null : (q ?? this.q),
    );
  }
}

class MyOffersFiltersController extends AutoDisposeNotifier<MyOffersFilters> {
  @override
  MyOffersFilters build() => const MyOffersFilters();

  void setTab(String tab) => state = state.copyWith(tab: tab);

  void setRequestType(String? type) => state = type == null
      ? state.copyWith(clearRequestType: true)
      : state.copyWith(requestType: type);

  void setQuery(String? q) => state = (q == null || q.trim().isEmpty)
      ? state.copyWith(clearQ: true)
      : state.copyWith(q: q.trim());
}

final myOffersFiltersProvider =
    AutoDisposeNotifierProvider<MyOffersFiltersController, MyOffersFilters>(
  MyOffersFiltersController.new,
);

class MyOffersController
    extends AutoDisposeNotifier<PagedListController<OfferForVendor>> {
  @override
  PagedListController<OfferForVendor> build() {
    final filters = ref.watch(myOffersFiltersProvider);
    final repo = ref.watch(offersVendorRepositoryProvider);

    final controller = PagedListController<OfferForVendor>(
      itemKey: (item) => item.id,
      fetcher: (cursor) async {
        final res = await repo.listMyOffers(
          tab: filters.tab,
          requestType: filters.requestType,
          q: filters.q,
          cursor: cursor,
        );
        return res.when(
          ok: (page) => page,
          err: (failure) => throw failure,
        );
      },
    );

    ref.onDispose(controller.dispose);
    return controller;
  }

  Future<void> loadNextPage() => state.loadNextPage();

  Future<void> refresh() => state.refresh();

  Future<void> retry() => state.retry();
}

final myOffersControllerProvider = AutoDisposeNotifierProvider<
    MyOffersController, PagedListController<OfferForVendor>>(
  MyOffersController.new,
);
