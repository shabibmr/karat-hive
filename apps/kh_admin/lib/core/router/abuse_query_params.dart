import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';

/// Codec for encoding/decoding abuse report query state (TR-S1-26d / ADM-SMP-63).
class AbuseQueryParamsCodec extends QueryParamsCodec<AbuseReportFilters> {
  const AbuseQueryParamsCodec();

  @override
  AbuseReportFilters decodeFilters(Map<String, String> query) {
    final q = query['q'];
    return AbuseReportFilters(
      state: AbuseReportState.fromWire(query['state']),
      entityType: AbuseEntityType.fromWire(query['entityType']),
      query: (q == null || q.isEmpty) ? '' : q,
    );
  }

  @override
  Map<String, String> encodeFilters(AbuseReportFilters filters) {
    final params = <String, String>{};
    if (filters.state != null) {
      params['state'] = filters.state!.wireValue;
    }
    if (filters.entityType != null) {
      params['entityType'] = filters.entityType!.wireValue;
    }
    if (filters.query.isNotEmpty) {
      params['q'] = filters.query;
    }
    return params;
  }
}

/// Abuse report query state encoded in URL query parameters.
class AbuseQueryParams {
  static const codec = AbuseQueryParamsCodec();

  const AbuseQueryParams({
    this.state,
    this.entityType,
    this.query,
    this.cursor,
    this.selectedId,
  });

  final AbuseReportState? state;
  final AbuseEntityType? entityType;
  final String? query;
  final String? cursor;
  final String? selectedId;

  factory AbuseQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return AbuseQueryParams(
      state: state.filters.state,
      entityType: state.filters.entityType,
      query: state.filters.query.isEmpty ? null : state.filters.query,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory AbuseQueryParams.fromState(GoRouterState state) =>
      AbuseQueryParams.fromUri(state.uri);

  factory AbuseQueryParams.fromFilters(
    AbuseReportFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return AbuseQueryParams(
      state: filters.state,
      entityType: filters.entityType,
      query: filters.query.isEmpty ? null : filters.query,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  AbuseReportFilters toFilters() {
    return AbuseReportFilters(
      state: state,
      entityType: entityType,
      query: query ?? '',
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<AbuseReportFilters>(
        filters: toFilters(),
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }
}

/// Extension on [BuildContext] for updating abuse report query parameters.
extension AbuseQueryNavigation on BuildContext {
  void updateAbuseQuery(
    AbuseReportFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      AbuseQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}
