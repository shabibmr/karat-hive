import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/connections_repository.dart';

class ConnectionsController
    extends AutoDisposeNotifier<PagedListController<ConnectionForVendor>> {
  @override
  PagedListController<ConnectionForVendor> build() {
    final repo = ref.watch(connectionsRepositoryProvider);

    final controller = PagedListController<ConnectionForVendor>(
      itemKey: (item) => item.id,
      fetcher: (cursor) async {
        final res = await repo.listMine(cursor: cursor);
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

final connectionsControllerProvider = AutoDisposeNotifierProvider<
    ConnectionsController, PagedListController<ConnectionForVendor>>(
  ConnectionsController.new,
);
