import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/features/requests/model/request_list_filters.dart';

/// Codec for encoding/decoding request list query state (TR-S1-25 / ADM-SMP-07).
class RequestQueryParamsCodec extends QueryParamsCodec<RequestListFilters> {
  const RequestQueryParamsCodec();

  @override
  RequestListFilters decodeFilters(Map<String, String> query) {
    final q = query['q'];
    final categoryId = query['categoryId'];
    final regionId = query['regionId'];
    return RequestListFilters(
      query: (q == null || q.isEmpty) ? '' : q,
      requestType: RequestType.fromApi(query['requestType']),
      direction: Direction.fromApi(query['direction']),
      state: RequestState.fromApi(query['state']),
      categoryId: (categoryId == null || categoryId.isEmpty) ? null : categoryId,
      regionId: (regionId == null || regionId.isEmpty) ? null : regionId,
      zeroOffersOnly: query['zeroOffers'] == 'true',
      minValue: _parseDecimal(query['minValue']),
      maxValue: _parseDecimal(query['maxValue']),
    );
  }

  @override
  Map<String, String> encodeFilters(RequestListFilters filters) {
    final params = <String, String>{};
    if (filters.query.isNotEmpty) {
      params['q'] = filters.query;
    }
    if (filters.requestType != null) {
      params['requestType'] = filters.requestType!.apiValue;
    }
    if (filters.direction != null) {
      params['direction'] = filters.direction!.apiValue;
    }
    if (filters.state != null) {
      params['state'] = filters.state!.apiValue;
    }
    if (filters.categoryId != null && filters.categoryId!.isNotEmpty) {
      params['categoryId'] = filters.categoryId!;
    }
    if (filters.regionId != null && filters.regionId!.isNotEmpty) {
      params['regionId'] = filters.regionId!;
    }
    if (filters.zeroOffersOnly) {
      params['zeroOffers'] = 'true';
    }
    if (filters.minValue != null) {
      params['minValue'] = filters.minValue.toString();
    }
    if (filters.maxValue != null) {
      params['maxValue'] = filters.maxValue.toString();
    }
    return params;
  }
}

/// Request list query state encoded in URL query parameters (AD-FE §16.2).
class RequestQueryParams {
  static const codec = RequestQueryParamsCodec();

  const RequestQueryParams({
    this.query,
    this.requestType,
    this.direction,
    this.state,
    this.categoryId,
    this.regionId,
    this.zeroOffersOnly = false,
    this.minValue,
    this.maxValue,
    this.cursor,
    this.selectedId,
  });

  final String? query;
  final RequestType? requestType;
  final Direction? direction;
  final RequestState? state;
  final String? categoryId;
  final String? regionId;
  final bool zeroOffersOnly;
  final double? minValue;
  final double? maxValue;
  final String? cursor;
  final String? selectedId;

  factory RequestQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return RequestQueryParams(
      query: state.filters.query.isEmpty ? null : state.filters.query,
      requestType: state.filters.requestType,
      direction: state.filters.direction,
      state: state.filters.state,
      categoryId: state.filters.categoryId,
      regionId: state.filters.regionId,
      zeroOffersOnly: state.filters.zeroOffersOnly,
      minValue: state.filters.minValue,
      maxValue: state.filters.maxValue,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory RequestQueryParams.fromState(GoRouterState state) =>
      RequestQueryParams.fromUri(state.uri);

  factory RequestQueryParams.fromFilters(
    RequestListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return RequestQueryParams(
      query: filters.query.isEmpty ? null : filters.query,
      requestType: filters.requestType,
      direction: filters.direction,
      state: filters.state,
      categoryId: filters.categoryId,
      regionId: filters.regionId,
      zeroOffersOnly: filters.zeroOffersOnly,
      minValue: filters.minValue,
      maxValue: filters.maxValue,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  RequestListFilters toFilters() {
    return RequestListFilters(
      query: query ?? '',
      requestType: requestType,
      direction: direction,
      state: state,
      categoryId: categoryId,
      regionId: regionId,
      zeroOffersOnly: zeroOffersOnly,
      minValue: minValue,
      maxValue: maxValue,
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<RequestListFilters>(
        filters: toFilters(),
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }

  RequestQueryParams copyWith({
    String? query,
    RequestType? requestType,
    Direction? direction,
    RequestState? state,
    String? categoryId,
    String? regionId,
    bool? zeroOffersOnly,
    double? minValue,
    double? maxValue,
    String? cursor,
    String? selectedId,
    bool clearQuery = false,
    bool clearCursor = false,
    bool clearSelected = false,
  }) {
    return RequestQueryParams(
      query: clearQuery ? null : (query ?? this.query),
      requestType: requestType ?? this.requestType,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      categoryId: categoryId ?? this.categoryId,
      regionId: regionId ?? this.regionId,
      zeroOffersOnly: zeroOffersOnly ?? this.zeroOffersOnly,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
    );
  }
}

/// Extension on [BuildContext] for updating request list query parameters.
extension RequestQueryNavigation on BuildContext {
  void updateRequestQuery(
    RequestListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      RequestQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}

double? _parseDecimal(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return double.tryParse(raw);
}
