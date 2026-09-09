import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';
import 'package:kh_admin/features/moderation/model/moderation_page.dart';
import 'package:kh_admin/features/moderation/model/moderation_review_item.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ModerationRepository(client);
});

/// Typed repository for `/v1/admin/reviews` (ADM-S16).
class ModerationRepository {
  ModerationRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultLimit = 50;

  Future<ModerationPage> fetchReviews({
    ModerationFilters filters = const ModerationFilters(),
    String? cursor,
    int limit = defaultLimit,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      ...filters.toQueryParameters(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/reviews',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(ModerationReviewItem.fromJson)
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();

    return ModerationPage(
      items: items,
      nextCursor: nextCursor,
      totalCount:
          meta?['total'] is num ? (meta!['total'] as num).toInt() : null,
    );
  }

  Future<void> approveReview(String id) async {
    await _apiClient.post('/v1/admin/reviews/$id/approve');
  }

  Future<void> rejectReview(
    String id, {
    required String rationale,
  }) async {
    await _apiClient.post(
      '/v1/admin/reviews/$id/reject',
      data: <String, dynamic>{
        'rationale': rationale,
      },
    );
  }

  Future<void> redactReview(
    String id, {
    required String rationale,
    required String redactedComment,
  }) async {
    await _apiClient.post(
      '/v1/admin/reviews/$id/redact',
      data: <String, dynamic>{
        'rationale': rationale,
        'redactedComment': redactedComment,
      },
    );
  }

}
