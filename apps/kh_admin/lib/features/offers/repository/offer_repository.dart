import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/offer_detail.dart';
import '../model/offer_list_filters.dart';
import '../model/offer_list_item.dart';
import '../model/offer_list_page.dart';

/// Typed repository for `GET /v1/admin/offers` and `/v1/admin/offers/:id` (ADM-S10, ADM-S11).
class OfferRepository {
  OfferRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultPageSize = 20;

  Future<OfferListPage> fetchOffers({
    OfferListFilters filters = const OfferListFilters(),
    String? cursor,
    int limit = defaultPageSize,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (filters.state != null) 'state': filters.state!.apiValue,
      if (filters.requestType != null)
        'requestType': filters.requestType!.apiValue,
      if (filters.query.trim().isNotEmpty) 'q': filters.query.trim(),
      if (filters.vendorId != null && filters.vendorId!.isNotEmpty)
        'vendorId': filters.vendorId,
      if (filters.minPrice != null) 'minPrice': filters.minPrice.toString(),
      if (filters.maxPrice != null) 'maxPrice': filters.maxPrice.toString(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/offers',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(OfferListItem.fromJson)
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    final hasMore = meta?['hasMore'] as bool?;
    final totalCount = meta?['totalCount'] as int?;

    return OfferListPage(
      items: items,
      nextCursor: nextCursor,
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }

  Future<OfferDetail> fetchOfferDetail(String offerId) async {
    final response = await _apiClient.get('/v1/admin/offers/$offerId');
    final map = Map<String, dynamic>.from(response as Map<String, dynamic>);
    return OfferDetail.fromJson(map);
  }

  Future<OfferInternalNoteItem> addNote(
    String offerId, {
    required String note,
  }) async {
    final response = await _apiClient.post(
      '/v1/admin/offers/$offerId/notes',
      data: {
        'note': note,
        'text': note,
      },
    );

    if (response is Map<String, dynamic>) {
      return OfferInternalNoteItem.fromJson(response);
    }

    return OfferInternalNoteItem(
      id: 'note-${DateTime.now().millisecondsSinceEpoch}',
      author: 'Admin',
      text: note,
      createdAt: DateTime.now(),
    );
  }
}

final Provider<OfferRepository> offerRepositoryProvider =
    Provider<OfferRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OfferRepository(apiClient);
});
