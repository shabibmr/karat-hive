import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/connections_repository.dart';

class ConnectionsListController
    extends AutoDisposeAsyncNotifier<List<ConnectionForCustomer>> {
  @override
  Future<List<ConnectionForCustomer>> build() async {
    final repo = ref.watch(connectionsRepositoryProvider);
    return _fetch(repo);
  }

  Future<List<ConnectionForCustomer>> _fetch(ConnectionsRepository repo) async {
    final first = await repo.listMine();
    return first.when(
      ok: (page) => _sort(page.items),
      err: (f) => throw f,
    );
  }

  List<ConnectionForCustomer> _sort(List<ConnectionForCustomer> items) {
    final copy = [...items];
    copy.sort((a, b) {
      final aActive = a.state == ConnectionState.active ? 0 : 1;
      final bActive = b.state == ConnectionState.active ? 0 : 1;
      if (aActive != bActive) return aActive - bActive;
      final at = a.identityRevealedAt;
      final bt = b.identityRevealedAt;
      return bt.compareTo(at);
    });
    return copy;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(ref.read(connectionsRepositoryProvider)),
    );
  }
}

final connectionsListProvider = AsyncNotifierProvider.autoDispose<
    ConnectionsListController, List<ConnectionForCustomer>>(
  ConnectionsListController.new,
);

class ConnectionDetailController
    extends AutoDisposeFamilyAsyncNotifier<ConnectionForCustomer, String> {
  @override
  Future<ConnectionForCustomer> build(String arg) async {
    final repo = ref.watch(connectionsRepositoryProvider);
    final r = await repo.getById(arg);
    return r.when(ok: (c) => c, err: (f) => throw f);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(connectionsRepositoryProvider);
      final r = await repo.getById(arg);
      return r.when(ok: (c) => c, err: (f) => throw f);
    });
  }

  Future<Result<void>> talkOpened() {
    return ref.read(connectionsRepositoryProvider).recordContactEvent(
          arg,
          channel: 'WHATSAPP',
        );
  }

  Future<Result<void>> numberCopied() {
    return ref.read(connectionsRepositoryProvider).recordContactEvent(
          arg,
          channel: 'PHONE',
        );
  }

  Future<Result<ConnectionForCustomer>> close({String? reason}) async {
    final r = await ref.read(connectionsRepositoryProvider).close(
          arg,
          reason: reason,
        );
    r.when(
      ok: (c) => state = AsyncData(c),
      err: (_) {},
    );
    return r;
  }
}

final connectionDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ConnectionDetailController, ConnectionForCustomer, String>(
  ConnectionDetailController.new,
);
