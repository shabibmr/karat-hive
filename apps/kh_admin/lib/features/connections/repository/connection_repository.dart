import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/connection_detail.dart';
import '../model/connection_list_filters.dart';
import '../model/connection_list_item.dart';
import '../model/connection_list_page.dart';

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
      if (filters.state != null) 'state': filters.state!.apiValue,
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/connections',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(_normalizeConnectionListRow)
        .map(ConnectionListItem.fromJson)
        .where((item) => _matchesClientFilters(item, filters))
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    final hasMore = nextCursor != null && nextCursor.isNotEmpty;

    return ConnectionListPage(
      items: items,
      nextCursor: hasMore ? nextCursor : null,
      hasMore: hasMore,
      totalCount: null,
    );
  }

  /// Fetches full connection details including request, offer, unmasked parties,
  /// contact events, and merges internal admin notes.
  Future<ConnectionDetail> fetchConnectionDetail(String connectionId) async {
    final response = await _apiClient.get('/v1/admin/connections/$connectionId');
    final raw = Map<String, dynamic>.from(response as Map<String, dynamic>);

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

    if (response is Map<String, dynamic>) {
      return ConnectionAdminNote.fromJson(response);
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
    final response = await _apiClient.get('/v1/admin/connections/$connectionId/notes');
    if (response is List) {
      return response
          .whereType<Map>()
          .map((e) => ConnectionAdminNote.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }
    return const [];
  }

  // ---------------------------------------------------------------------------
  // Normalization Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _normalizeConnectionListRow(Map<String, dynamic> raw) {
    final request = _asMap(raw['request']);
    final customerProfile = _asMap(request['customerProfile']);
    final customerUser = _asMap(customerProfile['user']);

    final offer = _asMap(raw['offer']);
    final vendorProfile = _asMap(offer['vendorProfile']);

    final contactEventsRaw = raw['contactEvents'];
    final contactEvents = contactEventsRaw is List
        ? contactEventsRaw
            .whereType<Map>()
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
        ? _asMap(raw['_count'])['contactEvents']
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
      'agreedPriceAed': _toDouble(offer['offeredPrice'] ?? raw['agreedPriceAed']),
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

  bool _matchesClientFilters(
    ConnectionListItem item,
    ConnectionListFilters filters,
  ) {
    if (filters.state != null && item.state != filters.state) {
      return false;
    }
    if (filters.hasNoContactOnly && !item.hasNoContact48h) {
      return false;
    }
    final q = filters.query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final haystack = [
        item.id,
        item.requestId,
        item.offerId,
        item.customerName,
        item.vendorName,
        item.requestType,
        item.agreedPriceAed.toString(),
        item.agreedPriceAed.toStringAsFixed(2),
      ].whereType<String>().map((s) => s.toLowerCase());
      if (!haystack.any((s) => s.contains(q))) return false;
    }
    return true;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  double _toDouble(dynamic value, [double fallback = 0.0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }
}

final Provider<ConnectionRepository> connectionRepositoryProvider =
    Provider<ConnectionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ConnectionRepository(apiClient);
});
