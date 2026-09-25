import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/request_manage_repository.dart';

/// Live open Requests (published / accepted).
const kMyRequestsOpenStates = ['PUBLISHED', 'ACCEPTED'];

/// Unfinished drafts.
const kMyRequestsDraftStates = ['DRAFT'];

class MyRequestsFilters {
  const MyRequestsFilters({this.tab = 'OPEN'});

  /// `OPEN` | `DRAFTS`
  final String tab;

  List<String> get states =>
      tab == 'DRAFTS' ? kMyRequestsDraftStates : kMyRequestsOpenStates;

  MyRequestsFilters copyWith({String? tab}) =>
      MyRequestsFilters(tab: tab ?? this.tab);
}

class MyRequestsFiltersController
    extends AutoDisposeNotifier<MyRequestsFilters> {
  @override
  MyRequestsFilters build() => const MyRequestsFilters();

  void setTab(String tab) {
    if (tab != 'OPEN' && tab != 'DRAFTS') return;
    if (state.tab == tab) return;
    state = state.copyWith(tab: tab);
  }
}

final myRequestsFiltersProvider = AutoDisposeNotifierProvider<
    MyRequestsFiltersController, MyRequestsFilters>(
  MyRequestsFiltersController.new,
);

/// Open/live and draft Requests for the My Requests tab.
class MyRequestsController
    extends AutoDisposeNotifier<PagedListController<RequestForCustomer>> {
  @override
  PagedListController<RequestForCustomer> build() {
    final repo = ref.watch(requestManageRepositoryProvider);
    final filters = ref.watch(myRequestsFiltersProvider);
    final controller = PagedListController<RequestForCustomer>(
      itemKey: (item) => item.id,
      fetcher: (cursor) async {
        final res = await repo.listMine(
          cursor: cursor,
          state: filters.states,
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

final myRequestsControllerProvider = AutoDisposeNotifierProvider<
    MyRequestsController, PagedListController<RequestForCustomer>>(
  MyRequestsController.new,
);
