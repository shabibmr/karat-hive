import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/request_manage_repository.dart';

/// Live Requests for CUS-S02. Default states come from the inventory, not a
/// client-side eligibility check.
class CustomerHomeController
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

final customerHomeControllerProvider = AutoDisposeNotifierProvider<
    CustomerHomeController, PagedListController<RequestForCustomer>>(
  CustomerHomeController.new,
);
