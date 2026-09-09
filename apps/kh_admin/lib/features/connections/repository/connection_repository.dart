import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/connections/model/connection_detail.dart';
import 'package:kh_admin/features/connections/model/connection_list_filters.dart';
import 'package:kh_admin/features/connections/model/connection_list_item.dart';
import 'package:kh_admin/features/connections/model/connection_list_page.dart';
import 'package:kh_admin/core/api/json_parse.dart';

/// Typed repository for `/v1/admin/connections` (ADM-S12, ADM-S13).
class ConnectionRepository {
  ConnectionRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultPageSize = 20;

  /// Fetches paginated connections list with server & client-side filtering.
  Future<ConnectionListPage> fetchConnections({
    ConnectionListFilters filters = const ConnectionListFilters(),
    String? cursor,
    int limit = defaultPageSize,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      ...filters.toQueryParameters(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/connections',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(_normalizeConnectionListRow)
        .map(ConnectionListItem.fromJson)
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();

    return ConnectionListPage(
      items: items,
      nextCursor: nextCursor,
      totalCount:
          meta?['total'] is num ? (meta!['total'] as num).toInt() : null,
    );
  }

  /// Fetches full connection details including request, offer, unmasked parties,
  /// contact events, and merges internal admin notes.
  Future<ConnectionDetail> fetchConnectionDetail(String connectionId) async {
    final response = await _apiClient.get('/v1/admin/connections/$connectionId');
    final raw = unwrapEntity(response);

    List<ConnectionAdminNote> notes = const [];
    try {
      notes = await listAdminNotes(connectionId);
    } on Object {
      // Notes are supplementary; failure must not break the detail view.
      notes = const [];
    }

    final detail = ConnectionDetail.fromJson(raw);
    if (notes.isNotEmpty) {
      return detail.copyWith(adminNotes: notes);
    }
    return detail;
  }

  /// Closes a connection with a mandatory reason.
  Future<void> closeConnection(
    String connectionId, {
    required String reasonText,
  }) async {
    await _apiClient.post(
      '/v1/admin/connections/$connectionId/close',
      data: {'reasonText': reasonText},
    );
  }

  /// Creates an internal admin note on the connection.
  Future<ConnectionAdminNote> createAdminNote(
    String connectionId,
    String text,
  ) async {
    final response = await _apiClient.post(
      '/v1/admin/connections/$connectionId/notes',
      data: {'text': text},
    );

    final map = unwrapEntity(response);
    if (map.isNotEmpty) {
      return ConnectionAdminNote.fromJson(map);
    }

    return ConnectionAdminNote(
      id: 'note-${DateTime.now().millisecondsSinceEpoch}',
      author: 'Admin',
      text: text,
      createdAt: DateTime.now(),
    );
  }

  /// Lists internal admin notes for the connection.
  Future<List<ConnectionAdminNote>> listAdminNotes(String connectionId) async {
    final response = await _apiClient.getCollection('/v1/admin/connections/$connectionId/notes');
    return response.items
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => ConnectionAdminNote.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // Normalization Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _normalizeConnectionListRow(Map<String, dynamic> raw) {
    final request = asMap(raw['request']);
    final customerProfile = asMap(request['customerProfile']);
    final customerUser = asMap(customerProfile['user']);

    final offer = asMap(raw['offer']);
    final vendorProfile = asMap(offer['vendorProfile']);

    final contactEventsRaw = raw['contactEvents'];
    final contactEvents = contactEventsRaw is List
        ? contactEventsRaw
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false)
        : const <Map<String, dynamic>>[];

    DateTime? latestContactAt;
    for (final event in contactEvents) {
      final dateStr = event['occurredAt'] ?? event['createdAt'];
      if (dateStr != null) {
        final dt = DateTime.tryParse(dateStr.toString());
        if (dt != null) {
          if (latestContactAt == null || dt.isAfter(latestContactAt)) {
            latestContactAt = dt;
          }
        }
      }
    }

    final countRaw = raw['_count'] is Map
        ? asMap(raw['_count'])['contactEvents']
        : null;
    final countFromCountObj = countRaw is num
        ? countRaw.toInt()
        : int.tryParse(countRaw?.toString() ?? '');

    final listedEventCount = contactEvents.length;
    final contactEventsCount = countFromCountObj ??
        (raw['contactEventsCount'] is num
            ? (raw['contactEventsCount'] as num).toInt()
            : (int.tryParse(raw['contactEventsCount']?.toString() ?? '') ??
                listedEventCount));

    final lastContactStr = latestContactAt?.toIso8601String() ??
        raw['lastContactAt']?.toString();

    return <String, dynamic>{
      'id': raw['id'],
      'requestId': raw['requestId'] ?? request['id'],
      'offerId': raw['offerId'] ?? offer['id'],
      'requestType': request['requestType'] ?? raw['requestType'],
      'customerName': _customerName(customerProfile, customerUser, raw),
      'vendorName': _vendorName(vendorProfile, raw),
      'agreedPriceAed': toDouble(offer['offeredPrice'] ?? raw['agreedPriceAed']),
      'state': raw['state'],
      'contactEventsCount': contactEventsCount,
      'lastContactAt': lastContactStr,
      'createdAt': raw['createdAt'],
      'hasNoContact48h': raw['hasNoContact48h'],
    };
  }

  String _customerName(
    Map<String, dynamic> customerProfile,
    Map<String, dynamic> customerUser,
    Map<String, dynamic> raw,
  ) {
    final display = customerProfile['displayName']?.toString();
    if (display != null && display.isNotEmpty) return display;
    final email = customerUser['email']?.toString();
    if (email != null && email.isNotEmpty) return email;
    final mobile = customerUser['mobileNumber']?.toString();
    if (mobile != null && mobile.isNotEmpty) return mobile;
    final rawName = raw['customerName']?.toString();
    if (rawName != null && rawName.isNotEmpty) return rawName;
    return 'Customer';
  }

  String _vendorName(
    Map<String, dynamic> vendorProfile,
    Map<String, dynamic> raw,
  ) {
    final legal = vendorProfile['legalBusinessName']?.toString();
    if (legal != null && legal.isNotEmpty) return legal;
    final trading = vendorProfile['tradingName']?.toString();
    if (trading != null && trading.isNotEmpty) return trading;
    final rawName = raw['vendorName']?.toString();
    if (rawName != null && rawName.isNotEmpty) return rawName;
    return 'Vendor';
  }




}

final Provider<ConnectionRepository> connectionRepositoryProvider =
    Provider<ConnectionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ConnectionRepository(apiClient);
});
