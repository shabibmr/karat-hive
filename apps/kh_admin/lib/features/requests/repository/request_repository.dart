import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
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
      // backend: unsupported, client-side. origin/main `GET /v1/admin/requests`
      // accepts only q/state/limit/cursor. requestType, direction, categoryId,
      // regionId, zeroOffers, valueMin, valueMax are ignored server-side, so we
      // do not send them and instead filter the loaded page below where cheap.
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/requests',
      queryParameters: queryParameters,
    );

    var items = response.items
        .whereType<Map<String, dynamic>>()
        .map(RequestListItem.fromApiResponse)
        .toList(growable: false);

    // backend: unsupported, client-side — narrow the loaded page for filters the
    // API cannot honour. Fields needed for these are already on RequestListItem.
    if (filters.requestType != null ||
        filters.direction != null ||
        filters.zeroOffersOnly ||
        filters.minValue != null ||
        filters.maxValue != null) {
      items = items.where((item) {
        if (filters.requestType != null &&
            item.requestType != filters.requestType) {
          return false;
        }
        if (filters.direction != null && item.direction != filters.direction) {
          return false;
        }
        if (filters.zeroOffersOnly && item.offerCount != 0) {
          return false;
        }
        final value = item.indicativeValue ?? item.budgetMax;
        if (filters.minValue != null &&
            (value == null || value < filters.minValue!)) {
          return false;
        }
        if (filters.maxValue != null &&
            (value == null || value > filters.maxValue!)) {
          return false;
        }
        return true;
      }).toList(growable: false);
    }

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    // No totalCount/total in the admin envelope; hasMore is derived purely from
    // the presence of a next cursor.
    final hasMore = hasMoreFromCursor(nextCursor);
    final totalCount = (meta?['totalCount'] ?? meta?['total']) as int?;

    return RequestListPage(
      items: items,
      nextCursor: nextCursor,
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }

  /// Fetches full request details for inspection on ADM-S09.
  Future<RequestDetail> fetchRequestDetail(String requestId) async {
    final response = await _apiClient.get('/v1/admin/requests/$requestId');
    final map = Map<String, dynamic>.from(response as Map<String, dynamic>);
    var detail = RequestDetail.fromApiResponse(map);

    // Internal admin notes live on a separate endpoint on origin/main
    // (`GET /v1/admin/requests/:id/notes`) and are merged into the detail here.
    // A failure fetching notes must not break the detail view.
    try {
      final notesResponse =
          await _apiClient.get('/v1/admin/requests/$requestId/notes');
      final rawNotes = notesResponse is List
          ? notesResponse
          : (notesResponse is Map<String, dynamic>
              ? notesResponse['data']
              : null);
      if (rawNotes is List) {
        detail = detail.copyWith(
          internalNotes: rawNotes
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
