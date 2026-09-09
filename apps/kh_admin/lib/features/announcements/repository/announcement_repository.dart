import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/model/announcement_page.dart';
import 'package:kh_admin/features/announcements/model/create_announcement_dto.dart';
import 'package:kh_admin/core/api/json_parse.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AnnouncementRepository(client);
});

/// Typed repository for `/v1/admin/announcements` (ADM-S18 / FR-ADM-029).
class AnnouncementRepository {
  AnnouncementRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultLimit = 50;

  /// Fetches paginated announcements.
  Future<AnnouncementPage> fetchAnnouncements({
    AnnouncementFilters filters = const AnnouncementFilters(),
    String? cursor,
    int limit = defaultLimit,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      ...filters.toQueryParameters(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/announcements',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(AnnouncementItem.fromJson)
        .where((item) => _matchesClientFilters(item, filters))
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    final hasMore = hasMoreFromCursor(nextCursor);

    return AnnouncementPage(
      items: items,
      nextCursor: hasMore ? nextCursor : null,
      hasMore: hasMore,
    );
  }

  /// Creates and schedules or immediately dispatches an announcement.
  Future<AnnouncementItem> createAnnouncement(CreateAnnouncementDto dto) async {
    final response = await _apiClient.post(
      '/v1/admin/announcements',
      data: dto.toJson(),
    );
    return AnnouncementItem.fromJson(_unwrapEntity(response));
  }

  /// Cancels a scheduled announcement before dispatch.
  Future<AnnouncementItem> cancelAnnouncement(String id) async {
    final response = await _apiClient.post(
      '/v1/admin/announcements/$id/cancel',
    );
    if (response is Map<String, dynamic> ||
        (response is Map && response['data'] is Map<String, dynamic>)) {
      return AnnouncementItem.fromJson(_unwrapEntity(response));
    }
    return AnnouncementItem(
      id: id,
      titleEn: '',
      titleAr: '',
      bodyEn: '',
      bodyAr: '',
      audience: const {},
      channels: const AnnouncementChannels(),
      critical: false,
      cancelledAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  bool _matchesClientFilters(AnnouncementItem item, AnnouncementFilters filters) {
    if (filters.status != null && item.status != filters.status) {
      return false;
    }
    if (filters.audienceType != null && item.audienceType != filters.audienceType) {
      return false;
    }
    if (filters.query.isEmpty) return true;
    final q = filters.query.toLowerCase();
    return item.id.toLowerCase().contains(q) ||
        item.titleEn.toLowerCase().contains(q) ||
        item.titleAr.toLowerCase().contains(q) ||
        item.bodyEn.toLowerCase().contains(q) ||
        item.bodyAr.toLowerCase().contains(q) ||
        (item.createdByDisplayName?.toLowerCase().contains(q) ?? false);
  }
}

Map<String, dynamic> _unwrapEntity(dynamic response) {
  if (response is! Map<String, dynamic>) {
    throw Exception(
      'Unexpected response format when mutating announcement: $response',
    );
  }
  if (response['data'] is Map<String, dynamic> &&
      response['id'] == null &&
      response['titleEn'] == null &&
      response['title_en'] == null) {
    return Map<String, dynamic>.from(response['data'] as Map);
  }
  return response;
}
