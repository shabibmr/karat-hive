import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';

/// Codec for encoding/decoding reports query state (TR-S1-26h / ADM-SMP-63).
class ReportQueryParamsCodec extends QueryParamsCodec<ReportFilters> {
  const ReportQueryParamsCodec();

  @override
  ReportFilters decodeFilters(Map<String, String> query) {
    return ReportFilters(
      from: _parseDate(query['from']),
      to: _parseDate(query['to']),
      regionId: query['regionId'],
      categoryId: query['categoryId'],
    );
  }

  @override
  Map<String, String> encodeFilters(ReportFilters filters) {
    final params = <String, String>{};
    if (filters.from != null) {
      params['from'] = ReportFilters.toIsoDate(filters.from!);
    }
    if (filters.to != null) {
      params['to'] = ReportFilters.toIsoDate(filters.to!);
    }
    if (filters.regionId != null && filters.regionId!.trim().isNotEmpty) {
      params['regionId'] = filters.regionId!.trim();
    }
    if (filters.categoryId != null && filters.categoryId!.trim().isNotEmpty) {
      params['categoryId'] = filters.categoryId!.trim();
    }
    return params;
  }
}

/// Reports query state encoded in URL query parameters.
class ReportQueryParams {
  static const codec = ReportQueryParamsCodec();

  const ReportQueryParams({
    this.filters = const ReportFilters(),
    this.cursor,
    this.selectedId,
  });

  final ReportFilters filters;
  final String? cursor;
  final String? selectedId;

  factory ReportQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return ReportQueryParams(
      filters: state.filters,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory ReportQueryParams.fromState(GoRouterState state) =>
      ReportQueryParams.fromUri(state.uri);

  factory ReportQueryParams.fromFilters(
    ReportFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return ReportQueryParams(
      filters: filters,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<ReportFilters>(
        filters: filters,
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }
}

/// Extension on [BuildContext] for updating report query parameters.
extension ReportQueryNavigation on BuildContext {
  void updateReportQuery(
    ReportFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      ReportQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}
