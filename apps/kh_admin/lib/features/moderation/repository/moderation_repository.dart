import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/moderation_filters.dart';
import '../model/moderation_page.dart';
import '../model/moderation_review_item.dart';

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
        .where((item) => _matchesClientFilters(item, filters))
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    final hasMore = nextCursor != null && nextCursor.isNotEmpty;

    return ModerationPage(
      items: items,
      nextCursor: hasMore ? nextCursor : null,
      hasMore: hasMore,
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

  bool _matchesClientFilters(ModerationReviewItem item, ModerationFilters filters) {
    if (filters.authorType != null && item.authorType != filters.authorType) {
      return false;
    }
    if (filters.query.isEmpty) return true;
    final q = filters.query.toLowerCase();
    return item.id.toLowerCase().contains(q) ||
        (item.comment?.toLowerCase().contains(q) ?? false) ||
        (item.vendorResponse?.toLowerCase().contains(q) ?? false) ||
        item.connectionId.toLowerCase().contains(q) ||
        (item.authorName?.toLowerCase().contains(q) ?? false) ||
        (item.subjectName?.toLowerCase().contains(q) ?? false);
  }
}
