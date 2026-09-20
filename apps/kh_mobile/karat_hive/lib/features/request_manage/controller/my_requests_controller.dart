import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/request_manage_repository.dart';

/// Open/live Requests for the My Requests tab (CUS-S24 working ID).
class MyRequestsController
    extends AutoDisposeNotifier<PagedListController<RequestForCustomer>> {
  @override
  PagedListController<RequestForCustomer> build() {
    final repo = ref.watch(requestManageRepositoryProvider);
    final controller = PagedListController<RequestForCustomer>(
      itemKey: (item) => item.id,
      fetcher: (cursor) async {
        final res = await repo.listMine(cursor: cursor);
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
