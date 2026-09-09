import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/reviews_repository.dart';

/// Paged reviews about this Vendor (VEN-S20). List UI lands in CP5-B04.
class MyReviewsController
    extends AutoDisposeNotifier<PagedListController<Review>> {
  @override
  PagedListController<Review> build() {
    final repo = ref.watch(reviewsRepositoryProvider);

    final controller = PagedListController<Review>(
      itemKey: (item) => item.id,
      fetcher: (cursor) async {
        final res = await repo.list(role: 'SUBJECT', cursor: cursor);
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

final myReviewsControllerProvider = AutoDisposeNotifierProvider<
    MyReviewsController, PagedListController<Review>>(
  MyReviewsController.new,
);

final reviewsPerformanceProvider =
    FutureProvider.autoDispose<VendorPerformanceDto?>((ref) async {
  final repo = ref.watch(reviewsRepositoryProvider);
  final res = await repo.getPerformance();
  return res.when(ok: (d) => d, err: (_) => null);
});

