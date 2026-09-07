import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/request_feed_repository.dart';

final requestDetailProvider =
    FutureProvider.autoDispose.family<VendorRequestItem, String>((ref, id) async {
  final repo = ref.watch(requestFeedRepositoryProvider);
  // Mark viewed in background when detail opens (CP2-B05 / BR-006)
  repo.markViewed(id);

  final res = await repo.getRequest(id);
  return res.when(
    ok: (item) => item,
    err: (f) => throw f,
  );
});
