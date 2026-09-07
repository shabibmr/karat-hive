import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/connections_repository.dart';

class ConnectionDetailController
    extends AutoDisposeFamilyAsyncNotifier<ConnectionForVendor, String> {
  @override
  Future<ConnectionForVendor> build(String arg) async {
    final repo = ref.watch(connectionsRepositoryProvider);
    final res = await repo.get(arg);
    return res.when(ok: (item) => item, err: (f) => throw f);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(connectionsRepositoryProvider);
      final res = await repo.get(arg);
      return res.when(ok: (item) => item, err: (f) => throw f);
    });
  }

  Future<Result<ConnectionForVendor>> close() async {
    final repo = ref.read(connectionsRepositoryProvider);
    final res = await repo.close(arg);
    res.when(
      ok: (updated) => state = AsyncData(updated),
      err: (_) {},
    );
    return res;
  }

  Future<Result<void>> recordContactEvent(String channel) {
    final repo = ref.read(connectionsRepositoryProvider);
    return repo.recordContactEvent(connectionId: arg, channel: channel);
  }
}

final connectionDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ConnectionDetailController, ConnectionForVendor, String>(
  ConnectionDetailController.new,
);
