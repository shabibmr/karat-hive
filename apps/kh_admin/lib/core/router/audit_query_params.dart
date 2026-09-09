import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/audit/model/audit_log_filters.dart';

/// Codec for encoding/decoding audit log query state (TR-S1-26c / ADM-SMP-63).
class AuditQueryParamsCodec extends QueryParamsCodec<AuditLogFilters> {
  const AuditQueryParamsCodec();

  @override
  AuditLogFilters decodeFilters(Map<String, String> query) {
    return AuditLogFilters(
      actorUserId: query['actorUserId'],
      action: query['action'],
      entityType: query['entityType'],
      entityId: query['entityId'],
      from: _parseDate(query['from']),
      to: _parseDate(query['to']),
      ip: query['ip'],
    );
  }

  @override
  Map<String, String> encodeFilters(AuditLogFilters filters) {
    final params = <String, String>{};
    if (filters.actorUserId != null && filters.actorUserId!.isNotEmpty) {
      params['actorUserId'] = filters.actorUserId!;
    }
    if (filters.action != null && filters.action!.isNotEmpty) {
      params['action'] = filters.action!;
    }
    if (filters.entityType != null && filters.entityType!.isNotEmpty) {
      params['entityType'] = filters.entityType!;
    }
    if (filters.entityId != null && filters.entityId!.isNotEmpty) {
      params['entityId'] = filters.entityId!;
    }
    if (filters.from != null) {
      params['from'] = filters.from!.toIso8601String();
    }
    if (filters.to != null) {
      params['to'] = filters.to!.toIso8601String();
    }
    if (filters.ip != null && filters.ip!.isNotEmpty) {
      params['ip'] = filters.ip!;
    }
    return params;
  }
}

/// Audit log query state encoded in URL query parameters.
class AuditQueryParams {
  static const codec = AuditQueryParamsCodec();

  const AuditQueryParams({
    this.filters = const AuditLogFilters(),
    this.cursor,
    this.selectedId,
  });

  final AuditLogFilters filters;
  final String? cursor;
  final String? selectedId;

  factory AuditQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return AuditQueryParams(
      filters: state.filters,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory AuditQueryParams.fromState(GoRouterState state) =>
      AuditQueryParams.fromUri(state.uri);

  factory AuditQueryParams.fromFilters(
    AuditLogFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return AuditQueryParams(
      filters: filters,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<AuditLogFilters>(
        filters: filters,
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }
}

/// Extension on [BuildContext] for updating audit query parameters.
extension AuditQueryNavigation on BuildContext {
  void updateAuditQuery(
    AuditLogFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      AuditQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
