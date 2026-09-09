import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/features/requests/model/request_list_filters.dart';
import 'package:kh_admin/features/requests/model/request_list_item.dart';
import 'package:kh_admin/features/requests/model/request_list_page.dart';
import 'package:kh_admin/core/api/json_parse.dart';

/// Typed repository for Admin Request management (ADM-S08, ADM-S09, API-Route-Inventory §21.5).
class RequestRepository {
  RequestRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultPageSize = 20;

  /// Fetches a paginated slice of requests matching [filters].
  Future<RequestListPage> fetchRequests({
    RequestListFilters filters = const RequestListFilters(),
    String? cursor,
    int limit = defaultPageSize,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (filters.query.trim().isNotEmpty) 'q': filters.query.trim(),
      if (filters.state != null) 'state': filters.state!.apiValue,
      if (filters.requestType != null) 'requestType': filters.requestType!.apiValue,
      if (filters.direction != null) 'direction': filters.direction!.apiValue,
      if (filters.categoryId != null && filters.categoryId!.isNotEmpty)
        'categoryId': filters.categoryId,
      if (filters.regionId != null && filters.regionId!.isNotEmpty)
        'regionId': filters.regionId,
      if (filters.zeroOffersOnly) 'zeroOffers': 'true',
      if (filters.minValue != null) 'minValue': filters.minValue.toString(),
      if (filters.maxValue != null) 'maxValue': filters.maxValue.toString(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/requests',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(RequestListItem.fromApiResponse)
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    final totalCount = (meta?['totalCount'] ?? meta?['total']) as int?;

    return Paginated<RequestListItem>(
      items: items,
      nextCursor: nextCursor,
      totalCount: totalCount,
    );
  }

  /// Fetches full request details for inspection on ADM-S09.
  Future<RequestDetail> fetchRequestDetail(String requestId) async {
    final response = await _apiClient.get('/v1/admin/requests/$requestId');
    final map = unwrapEntity(response);
    var detail = RequestDetail.fromApiResponse(map);

    // Internal admin notes live on a separate endpoint on origin/main
    // (`GET /v1/admin/requests/:id/notes`) and are merged into the detail here.
    // A failure fetching notes must not break the detail view.
    try {
      final notesResponse =
          await _apiClient.get('/v1/admin/requests/$requestId/notes');
      final list = notesResponse is List
          ? notesResponse
          : (notesResponse is Map ? notesResponse['data'] : null);
      if (list is List) {
        detail = detail.copyWith(
          internalNotes: list
              .whereType<Map<String, dynamic>>()
              .map(RequestInternalNoteItem.fromApiResponse)
              .toList(growable: false),
        );
      }
    } on Object {
      // Notes are supplementary context; ignore and keep the parsed detail.
    }

    return detail;
  }

  /// Admin moderation action: forcibly remove a request violating policy (FR-ADM-019).
  Future<void> removeRequest(
    String requestId, {
    required String reasonCode,
    required String reasonText,
    String? policyClause,
  }) async {
    await _apiClient.post(
      '/v1/admin/requests/$requestId/remove',
      data: {
        'reasonCode': reasonCode,
        'reasonText': reasonText,
        if (policyClause != null && policyClause.trim().isNotEmpty)
          'policyClause': policyClause.trim(),
      },
    );
  }

  /// Adds an internal admin note to the request.
  Future<void> addNote(
    String requestId, {
    required String text,
  }) async {
    await _apiClient.post(
      '/v1/admin/requests/$requestId/notes',
      data: {
        'text': text.trim(),
      },
    );
  }
}

final Provider<RequestRepository> requestRepositoryProvider =
    Provider<RequestRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RequestRepository(apiClient);
});
