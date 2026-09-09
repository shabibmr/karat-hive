import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/time/clock.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_queue_item.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_range.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/dashboard/repository/dashboard_repository.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';

/// Selected date-range window for ADM-S02 (`TR-S6-03`). Drives the stat cards
/// and the trend series; changing it refetches both.
final dashboardRangeProvider = StateProvider<DashboardRange>(
  (ref) => DashboardRange.last30Days,
);

/// AsyncNotifier controller for ADM-S02 Dashboard statistics.
class DashboardController extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    final filters =
        ref.watch(dashboardRangeProvider).toFilters(ref.read(clockProvider));
    return ref
        .read(dashboardRepositoryProvider)
        .fetchStats(from: filters.from, to: filters.to);
  }

  /// Forces a reload of dashboard stats, queue snapshots, and the trend series.
  Future<void> refresh() async {
    ref.invalidate(dashboardQueueSourceProvider);
    ref.invalidate(dashboardTrendProvider);
    final filters =
        ref.read(dashboardRangeProvider).toFilters(ref.read(clockProvider));
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(dashboardRepositoryProvider)
          .fetchStats(from: filters.from, to: filters.to),
    );
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardStats>(
  DashboardController.new,
);

/// One Quick Action Queues source, fetched independently so a single failing
/// list endpoint surfaces as an error chip on that queue — not a vanished
/// section or a silent "0 pending" (`TR-S6-01`, `ADM-INS-61`).
///
/// No `catch` here: Riverpod captures a throw as [AsyncError], which the screen
/// renders with a retry.
final dashboardQueueSourceProvider = FutureProvider.family<
    List<DashboardQueueItem>, DashboardQueueKind>((ref, kind) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  switch (kind) {
    case DashboardQueueKind.verification:
      return repo.fetchVerificationSnapshot();
    case DashboardQueueKind.abuse:
      return repo.fetchAbuseSnapshot();
    case DashboardQueueKind.review:
      return repo.fetchPendingReviewsSnapshot();
  }
});

/// Range-scoped trend series for ADM-S02 (`TR-S6-04`).
final dashboardTrendProvider = FutureProvider<ReportResult>((ref) async {
  final filters =
      ref.watch(dashboardRangeProvider).toFilters(ref.read(clockProvider));
  return ref.watch(dashboardRepositoryProvider).fetchTrend(filters);
});
