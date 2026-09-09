import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/json_parse.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_queue_item.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';

/// Repository for ADM-S02 dashboard stats and queue snapshots.
class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int snapshotLimit = 2;

  /// Fetches platform statistics from `GET /v1/admin/dashboard`.
  ///
  /// [from]/[to] are sent as `yyyy-MM-dd` query params for the ADM-S02 date-range
  /// selector (`TR-S6-03`). The endpoint currently ignores them and returns
  /// all-time counts — see GAP-ADM-09 in `docs/admin-backend-api-gaps.md`.
  Future<DashboardStats> fetchStats({DateTime? from, DateTime? to}) async {
    final query = <String, dynamic>{
      if (from != null) 'from': ReportFilters.toIsoDate(from),
      if (to != null) 'to': ReportFilters.toIsoDate(to),
    };
    final response = await _apiClient.get(
      '/v1/admin/dashboard',
      queryParameters: query.isEmpty ? null : query,
    );
    return DashboardStats.fromJson(unwrapEntity(response));
  }

  /// Range-scoped trend series for ADM-S02 (`TR-S6-04`).
  ///
  /// Reuses `GET /v1/admin/reports/request-volume` (counts by request state over
  /// [filters]) — the only range-scoped figures the backend exposes today. A
  /// true daily time-series endpoint is GAP-ADM-10.
  Future<ReportResult> fetchTrend(ReportFilters filters) async {
    final response = await _apiClient.get(
      '/v1/admin/reports/request-volume',
      queryParameters: filters.toQueryParameters(),
    );
    final map = unwrapEntity(response);
    map['name'] ??= 'request-volume';
    return ReportResult.fromJson(map);
  }

  /// First 1–2 pending vendors from `GET /v1/admin/verification-queue`.
  Future<List<DashboardQueueItem>> fetchVerificationSnapshot() async {
    final response = await _apiClient.getCollection('/v1/admin/verification-queue');
    return response.items
        .whereType<Map<String, dynamic>>()
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
}

final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRepository(apiClient);
});
