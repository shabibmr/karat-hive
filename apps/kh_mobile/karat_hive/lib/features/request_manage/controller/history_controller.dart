import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/request_manage_repository.dart';

const kHistoryStates = [
  'ACCEPTED',
  'CLOSED',
  'EXPIRED',
  'CANCELLED',
  'REMOVED',
];

class HistoryQuery {
  const HistoryQuery({this.q, this.requestType, this.direction});

  final String? q;
  final String? requestType;
  final String? direction;

  HistoryQuery copyWith({
    String? q,
    bool clearQ = false,
    String? requestType,
    bool clearType = false,
    String? direction,
    bool clearDirection = false,
  }) =>
      HistoryQuery(
        q: clearQ ? null : (q ?? this.q),
        requestType: clearType ? null : (requestType ?? this.requestType),
        direction: clearDirection ? null : (direction ?? this.direction),
      );
}

class HistoryQueryController extends AutoDisposeNotifier<HistoryQuery> {
  @override
  HistoryQuery build() => const HistoryQuery();

  void update(HistoryQuery next) => state = next;
}

final historyQueryProvider =
    AutoDisposeNotifierProvider<HistoryQueryController, HistoryQuery>(
  HistoryQueryController.new,
);

class HistoryController
    extends AutoDisposeNotifier<PagedListController<RequestForCustomer>> {
  @override
  PagedListController<RequestForCustomer> build() {
    final repo = ref.watch(requestManageRepositoryProvider);
    final query = ref.watch(historyQueryProvider);
    final controller = PagedListController<RequestForCustomer>(
      itemKey: (item) => item.id,
      fetcher: (cursor) async {
        final res = await repo.listMine(
          cursor: cursor,
          state: kHistoryStates,
          q: query.q,
          requestType: query.requestType,
          direction: query.direction,
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

final historyControllerProvider = AutoDisposeNotifierProvider<HistoryController,
    PagedListController<RequestForCustomer>>(
  HistoryController.new,
);
