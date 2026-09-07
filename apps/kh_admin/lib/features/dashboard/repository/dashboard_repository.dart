import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/dashboard_stats.dart';

/// Repository for `GET /v1/admin/dashboard` (ADM-S02).
class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches platform statistics from `GET /v1/admin/dashboard`.
  Future<DashboardStats> fetchStats() async {
    final response = await _apiClient.get('/v1/admin/dashboard');
    final map = response is Map<String, dynamic>
        ? response
        : <String, dynamic>{};
    return DashboardStats.fromJson(map);
  }
}

final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRepository(apiClient);
});
