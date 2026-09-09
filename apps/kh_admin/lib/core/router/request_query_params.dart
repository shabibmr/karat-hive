import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/features/requests/model/request_list_filters.dart';
import 'package:kh_admin/core/router/query_navigation.dart';

/// Request list query state encoded in URL query parameters (AD-FE §16.2).
class RequestQueryParams {
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

  factory RequestQueryParams.fromUri(Uri uri) {
    final q = uri.queryParameters['q'];
    final categoryId = uri.queryParameters['categoryId'];
    final regionId = uri.queryParameters['regionId'];
    return RequestQueryParams(
      query: (q == null || q.isEmpty) ? null : q,
      requestType: RequestType.fromApi(uri.queryParameters['requestType']),
      direction: Direction.fromApi(uri.queryParameters['direction']),
      state: RequestState.fromApi(uri.queryParameters['state']),
      categoryId: (categoryId == null || categoryId.isEmpty) ? null : categoryId,
      regionId: (regionId == null || regionId.isEmpty) ? null : regionId,
      zeroOffersOnly: uri.queryParameters['zeroOffers'] == 'true',
      minValue: _parseDecimal(uri.queryParameters['minValue']),
      maxValue: _parseDecimal(uri.queryParameters['maxValue']),
    );
  }

  factory RequestQueryParams.fromState(GoRouterState state) {
    return RequestQueryParams.fromUri(state.uri);
  }

  factory RequestQueryParams.fromFilters(RequestListFilters filters) {
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
    final params = <String, String>{};
    if (query != null && query!.isNotEmpty) {
      params['q'] = query!;
    }
    if (requestType != null) {
      params['requestType'] = requestType!.apiValue;
    }
    if (direction != null) {
      params['direction'] = direction!.apiValue;
    }
    if (state != null) {
      params['state'] = state!.apiValue;
    }
    if (categoryId != null && categoryId!.isNotEmpty) {
      params['categoryId'] = categoryId!;
    }
    if (regionId != null && regionId!.isNotEmpty) {
      params['regionId'] = regionId!;
    }
    if (zeroOffersOnly) {
      params['zeroOffers'] = 'true';
    }
    if (minValue != null) {
      params['minValue'] = minValue.toString();
    }
    if (maxValue != null) {
      params['maxValue'] = maxValue.toString();
    }
    return params;
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
    bool clearQuery = false,
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
    );
  }
}

/// Extension on [BuildContext] for updating request list query parameters.
extension RequestQueryNavigation on BuildContext {
  void updateRequestQuery(RequestListFilters filters) {
    applyQueryParameters(RequestQueryParams.fromFilters(filters).toQueryParameters());
  }
}

double? _parseDecimal(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return double.tryParse(raw);
}
