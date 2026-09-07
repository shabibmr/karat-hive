import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/request_feed_repository.dart';

class RequestDetailController
    extends AutoDisposeFamilyAsyncNotifier<VendorRequestItem, String> {
  @override
  Future<VendorRequestItem> build(String arg) async {
    final repo = ref.watch(requestFeedRepositoryProvider);
    // Mark viewed in background when detail opens (CP2-B05 / BR-006)
    repo.markViewed(arg);

    final res = await repo.getRequest(arg);
    return res.when(
      ok: (item) => item,
      err: (f) => throw f,
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(requestFeedRepositoryProvider);
      final res = await repo.getRequest(arg);
      return res.when(
        ok: (item) => item,
        err: (f) => throw f,
      );
    });
  }
}

final requestDetailProvider = AsyncNotifierProvider.autoDispose
    .family<RequestDetailController, VendorRequestItem, String>(
  RequestDetailController.new,
);
