import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/reviews_repository.dart';

/// Vendor respond / flag on a published review (VEN-S20). UI lands in CP5-B04.3.
class ReviewActionsController
    extends AutoDisposeNotifier<AsyncValue<Review?>> {
  @override
  AsyncValue<Review?> build() => const AsyncData(null);

  Future<Result<Review>> respond({
    required String id,
    required String response,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(reviewsRepositoryProvider).respond(
          id,
          response: response,
        );
    res.when(
      ok: (review) => state = AsyncData(review),
      err: (failure) => state = AsyncError(failure, StackTrace.current),
    );
    return res;
  }

  Future<Result<void>> flag(String id) async {
    state = const AsyncLoading();
    final res = await ref.read(reviewsRepositoryProvider).flag(id);
    res.when(
      ok: (_) => state = const AsyncData(null),
      err: (failure) => state = AsyncError(failure, StackTrace.current),
    );
    return res;
  }
}

final reviewActionsControllerProvider = AutoDisposeNotifierProvider<
    ReviewActionsController, AsyncValue<Review?>>(
  ReviewActionsController.new,
);
