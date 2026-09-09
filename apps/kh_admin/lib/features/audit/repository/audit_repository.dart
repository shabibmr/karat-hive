import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/audit/model/audit_log_filters.dart';
import 'package:kh_admin/features/audit/model/audit_log_item.dart';
import 'package:kh_admin/features/audit/model/audit_log_page.dart';

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
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();

    return AuditLogPage(
      items: items,
      nextCursor: nextCursor,
      totalCount:
          meta?['total'] is num ? (meta!['total'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> _normalizeAuditLogRow(Map<String, dynamic> raw) {
    dynamic parsePayload(dynamic value) {
      if (value == null) return null;
      if (value is Map || value is List) return value;
      if (value is String) {
        try {
          return jsonDecode(value);
        } on Object catch (_) {
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


}

final Provider<AuditRepository> auditRepositoryProvider =
    Provider<AuditRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuditRepository(apiClient);
});
