import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/dashboard_queue_item.dart';
import '../model/dashboard_stats.dart';
import '../repository/dashboard_repository.dart';

/// AsyncNotifier controller for ADM-S02 Dashboard statistics.
class DashboardController extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    return ref.read(dashboardRepositoryProvider).fetchStats();
  }

  /// Forces a reload of dashboard stats from `GET /v1/admin/dashboard`.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidate(dashboardQueueProvider);
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).fetchStats(),
    );
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardStats>(
  DashboardController.new,
);

/// Quick Action Queues snapshot. Each source is omitted independently so one
/// failing list endpoint cannot take down the dashboard.
final dashboardQueueProvider =
    FutureProvider<List<DashboardQueueItem>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final chunks = await Future.wait([
    _omitQueueSource(repo.fetchVerificationSnapshot),
    _omitQueueSource(repo.fetchAbuseSnapshot),
    _omitQueueSource(repo.fetchPendingReviewsSnapshot),
  ]);
  return [for (final chunk in chunks) ...chunk];
});

Future<List<DashboardQueueItem>> _omitQueueSource(
  Future<List<DashboardQueueItem>> Function() fetch,
) async {
  try {
    return await fetch();
  } catch (_) {
    return const [];
  }
}
