import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/abuse_repository.dart';

/// Submit abuse report (CUS-S22 / VEN-S21). Form UI lands in CP5-B05.2.
class AbuseController extends AutoDisposeNotifier<AsyncValue<AbuseReport?>> {
  @override
  AsyncValue<AbuseReport?> build() => const AsyncData(null);

  Future<Result<AbuseReport>> submit({
    required AbuseEntityType entityType,
    required String entityId,
    required String category,
    required String description,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(abuseRepositoryProvider).submit(
          entityType: entityType,
          entityId: entityId,
          category: category,
          description: description,
        );
    res.when(
      ok: (report) => state = AsyncData(report),
      err: (failure) => state = AsyncError(failure, StackTrace.current),
    );
    return res;
  }
}

final abuseControllerProvider =
    AutoDisposeNotifierProvider<AbuseController, AsyncValue<AbuseReport?>>(
  AbuseController.new,
);
