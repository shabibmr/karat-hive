import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).fetchStats(),
    );
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardStats>(
  DashboardController.new,
);
