import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/abuse_report_filters.dart';
import '../model/abuse_report_item.dart';
import '../model/abuse_report_page.dart';

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
        .where((item) => _matchesClientFilters(item, filters))
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    final hasMore = nextCursor != null && nextCursor.isNotEmpty;

    return AbuseReportPage(
      items: items,
      nextCursor: hasMore ? nextCursor : null,
      hasMore: hasMore,
    );
  }

  Future<AbuseReportItem> getAbuseReport(String id) async {
    final response = await _apiClient.get('/v1/admin/abuse-reports/$id');
    if (response is Map<String, dynamic>) {
      return AbuseReportItem.fromJson(response);
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

  bool _matchesClientFilters(AbuseReportItem item, AbuseReportFilters filters) {
    if (filters.entityType != null && item.entityType != filters.entityType) {
      return false;
    }
    if (filters.query.isEmpty) return true;
    final q = filters.query.toLowerCase();
    return item.id.toLowerCase().contains(q) ||
        item.category.toLowerCase().contains(q) ||
        item.description.toLowerCase().contains(q) ||
        item.entityId.toLowerCase().contains(q) ||
        (item.reporterName?.toLowerCase().contains(q) ?? false) ||
        (item.reportedName?.toLowerCase().contains(q) ?? false) ||
        (item.reporterEmail?.toLowerCase().contains(q) ?? false) ||
        (item.reportedEmail?.toLowerCase().contains(q) ?? false);
  }
}
