import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/audit_log_filters.dart';
import '../model/audit_log_item.dart';
import '../model/audit_log_page.dart';

/// Typed repository for `GET /v1/admin/audit-log` (ADM-S22).
///
/// Fetches cursor-paginated audit trail events and normalizes raw Prisma
/// `AuditLog` rows (timestamps, JSON payloads for beforeValue/afterValue, and
/// IP metadata).
class AuditRepository {
  AuditRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultLimit = 50;

  Future<AuditLogPage> fetchAuditLogs({
    AuditLogFilters filters = const AuditLogFilters(),
    String? cursor,
    int limit = defaultLimit,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      ...filters.toQueryParameters(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/audit-log',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(_normalizeAuditLogRow)
        .map(AuditLogItem.fromJson)
        .where((item) => _matchesClientFilters(item, filters))
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    final hasMore = nextCursor != null && nextCursor.isNotEmpty;

    return AuditLogPage(
      items: items,
      nextCursor: hasMore ? nextCursor : null,
      hasMore: hasMore,
    );
  }

  Map<String, dynamic> _normalizeAuditLogRow(Map<String, dynamic> raw) {
    dynamic parsePayload(dynamic value) {
      if (value == null) return null;
      if (value is Map || value is List) return value;
      if (value is String) {
        try {
          return jsonDecode(value);
        } catch (_) {
          return value;
        }
      }
      return value;
    }

    return <String, dynamic>{
      'id': raw['id']?.toString() ?? '',
      'actorUserId': raw['actorUserId']?.toString(),
      'action': raw['action']?.toString() ?? '',
      'entityType': raw['entityType']?.toString() ?? '',
      'entityId': raw['entityId']?.toString(),
      'beforeValue': parsePayload(raw['beforeValue']),
      'afterValue': parsePayload(raw['afterValue']),
      'ip': raw['ip']?.toString() ?? raw['ipAddress']?.toString(),
      'userAgent': raw['userAgent']?.toString(),
      'occurredAt': raw['occurredAt'],
    };
  }

  bool _matchesClientFilters(AuditLogItem item, AuditLogFilters filters) {
    if (filters.actorUserId != null &&
        filters.actorUserId!.isNotEmpty &&
        item.actorUserId != filters.actorUserId) {
      return false;
    }
    if (filters.action != null &&
        filters.action!.isNotEmpty &&
        !item.action.toLowerCase().contains(filters.action!.toLowerCase())) {
      return false;
    }
    if (filters.entityType != null &&
        filters.entityType!.isNotEmpty &&
        item.entityType.toLowerCase() != filters.entityType!.toLowerCase()) {
      return false;
    }
    if (filters.entityId != null &&
        filters.entityId!.isNotEmpty &&
        item.entityId != filters.entityId) {
      return false;
    }
    if (filters.from != null && item.occurredAt.isBefore(filters.from!)) {
      return false;
    }
    if (filters.to != null && item.occurredAt.isAfter(filters.to!)) {
      return false;
    }
    if (filters.ip != null &&
        filters.ip!.isNotEmpty &&
        !(item.ip ?? '').toLowerCase().contains(filters.ip!.toLowerCase())) {
      return false;
    }
    return true;
  }
}

final Provider<AuditRepository> auditRepositoryProvider =
    Provider<AuditRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuditRepository(apiClient);
});
