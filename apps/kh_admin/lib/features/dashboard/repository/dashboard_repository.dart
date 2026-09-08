import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/dashboard_queue_item.dart';
import '../model/dashboard_stats.dart';

/// Repository for ADM-S02 dashboard stats and queue snapshots.
class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int snapshotLimit = 2;

  /// Fetches platform statistics from `GET /v1/admin/dashboard`.
  Future<DashboardStats> fetchStats() async {
    final response = await _apiClient.get('/v1/admin/dashboard');
    final map = response is Map<String, dynamic>
        ? response
        : <String, dynamic>{};
    return DashboardStats.fromJson(map);
  }

  /// First 1–2 pending vendors from `GET /v1/admin/verification-queue`.
  Future<List<DashboardQueueItem>> fetchVerificationSnapshot() async {
    final response = await _apiClient.get('/v1/admin/verification-queue');
    return _mapsFrom(response)
        .take(snapshotLimit)
        .map(DashboardQueueItem.fromVerificationJson)
        .toList(growable: false);
  }

  /// First 1–2 abuse reports from `GET /v1/admin/abuse-reports`.
  Future<List<DashboardQueueItem>> fetchAbuseSnapshot() async {
    final response = await _apiClient.getCollection(
      '/v1/admin/abuse-reports',
      queryParameters: {'limit': snapshotLimit.toString()},
    );
    return response.items
        .whereType<Map<String, dynamic>>()
        .take(snapshotLimit)
        .map(DashboardQueueItem.fromAbuseJson)
        .toList(growable: false);
  }

  /// First 1–2 pending reviews from `GET /v1/admin/reviews`.
  Future<List<DashboardQueueItem>> fetchPendingReviewsSnapshot() async {
    final response = await _apiClient.getCollection(
      '/v1/admin/reviews',
      queryParameters: {
        'limit': snapshotLimit.toString(),
        'state': 'PENDING_MODERATION',
      },
    );
    return response.items
        .whereType<Map<String, dynamic>>()
        .take(snapshotLimit)
        .map(DashboardQueueItem.fromReviewJson)
        .toList(growable: false);
  }

  static List<Map<String, dynamic>> _mapsFrom(dynamic response) {
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}

final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRepository(apiClient);
});
