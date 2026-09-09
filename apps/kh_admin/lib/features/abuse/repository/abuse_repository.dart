import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_item.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_page.dart';
import 'package:kh_admin/core/api/json_parse.dart';

final abuseRepositoryProvider = Provider<AbuseRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AbuseRepository(client);
});

/// Typed repository for `/v1/admin/abuse-reports` (ADM-S21).
class AbuseRepository {
  AbuseRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultLimit = 50;

  Future<AbuseReportPage> fetchAbuseReports({
    AbuseReportFilters filters = const AbuseReportFilters(),
    String? cursor,
    int limit = defaultLimit,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      ...filters.toQueryParameters(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/abuse-reports',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(AbuseReportItem.fromJson)
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();

    return AbuseReportPage(
      items: items,
      nextCursor: nextCursor,
      totalCount:
          meta?['total'] is num ? (meta!['total'] as num).toInt() : null,
    );
  }

  Future<AbuseReportItem> getAbuseReport(String id) async {
    final response = await _apiClient.get('/v1/admin/abuse-reports/$id');
    final map = unwrapEntity(response);
    if (map.isNotEmpty) {
      return AbuseReportItem.fromJson(map);
    }
    throw Exception('Unexpected response format when fetching abuse report: $response');
  }

  Future<void> resolveAbuseReport(
    String id, {
    required String resolution,
  }) async {
    await _apiClient.post(
      '/v1/admin/abuse-reports/$id/resolve',
      data: <String, dynamic>{
        'resolution': resolution,
      },
    );
  }

  Future<void> dismissAbuseReport(
    String id, {
    required String resolution,
  }) async {
    await _apiClient.post(
      '/v1/admin/abuse-reports/$id/dismiss',
      data: <String, dynamic>{
        'resolution': resolution,
      },
    );
  }

}
