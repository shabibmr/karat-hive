import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/offers/model/offer_enums.dart';
import '../../features/offers/model/offer_list_filters.dart';

/// Offer list query state encoded in URL query parameters (AD-FE §16.2).
class OfferQueryParams {
  const OfferQueryParams({
    this.query,
    this.state,
    this.requestType,
    this.vendorId,
    this.dateFrom,
    this.dateTo,
    this.minPrice,
    this.maxPrice,
  });

  final String? query;
  final OfferState? state;
  final RequestType? requestType;
  final String? vendorId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? minPrice;
  final double? maxPrice;

  factory OfferQueryParams.fromUri(Uri uri) {
    final q = uri.queryParameters['q'];
    final vendorId = uri.queryParameters['vendorId'];
    return OfferQueryParams(
      query: (q == null || q.isEmpty) ? null : q,
      state: OfferState.fromApi(uri.queryParameters['state']),
      requestType: RequestType.fromApi(uri.queryParameters['requestType']),
      vendorId: (vendorId == null || vendorId.isEmpty) ? null : vendorId,
      dateFrom: _parseDate(uri.queryParameters['dateFrom']),
      dateTo: _parseDate(uri.queryParameters['dateTo']),
      minPrice: _parseDecimal(uri.queryParameters['minPrice']),
      maxPrice: _parseDecimal(uri.queryParameters['maxPrice']),
    );
  }

  factory OfferQueryParams.fromState(GoRouterState state) {
    return OfferQueryParams.fromUri(state.uri);
  }

  factory OfferQueryParams.fromFilters(OfferListFilters filters) {
    return OfferQueryParams(
      query: filters.query.isEmpty ? null : filters.query,
      state: filters.state,
      requestType: filters.requestType,
      vendorId: filters.vendorId,
      dateFrom: _dateOnly(filters.dateFrom),
      dateTo: _dateOnly(filters.dateTo),
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
    );
  }

  OfferListFilters toFilters() {
    return OfferListFilters(
      query: query ?? '',
      state: state,
      requestType: requestType,
      vendorId: vendorId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};
    if (query != null && query!.isNotEmpty) {
      params['q'] = query!;
    }
    if (state != null) {
      params['state'] = state!.apiValue;
    }
    if (requestType != null) {
      params['requestType'] = requestType!.apiValue;
    }
    if (vendorId != null && vendorId!.isNotEmpty) {
      params['vendorId'] = vendorId!;
    }
    final from = _formatDate(dateFrom);
    if (from != null) {
      params['dateFrom'] = from;
    }
    final to = _formatDate(dateTo);
    if (to != null) {
      params['dateTo'] = to;
    }
    if (minPrice != null) {
      params['minPrice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      params['maxPrice'] = maxPrice.toString();
    }
    return params;
  }

  OfferQueryParams copyWith({
    String? query,
    OfferState? state,
    RequestType? requestType,
    String? vendorId,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? minPrice,
    double? maxPrice,
    bool clearQuery = false,
  }) {
    return OfferQueryParams(
      query: clearQuery ? null : (query ?? this.query),
      state: state ?? this.state,
      requestType: requestType ?? this.requestType,
      vendorId: vendorId ?? this.vendorId,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

/// Extension on [BuildContext] for updating offer list query parameters.
extension OfferQueryNavigation on BuildContext {
  void updateOfferQuery(OfferListFilters filters) {
    try {
      final routerState = GoRouterState.of(this);
      final updated = OfferQueryParams.fromFilters(filters).toQueryParameters();
      if (_stringMapsEqual(routerState.uri.queryParameters, updated)) return;

      final newUri = updated.isEmpty
          ? routerState.uri.replace(queryParameters: const <String, String>{})
          : routerState.uri.replace(queryParameters: updated);
      go(newUri.toString());
    } catch (_) {
      // Safe fallback when executed outside a GoRouter context (e.g. widget tests)
    }
  }
}

DateTime? _dateOnly(DateTime? value) {
  if (value == null) return null;
  return DateTime(value.year, value.month, value.day);
}

String? _formatDate(DateTime? value) {
  if (value == null) return null;
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
  if (match == null) return null;
  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  if (year == null || month == null || day == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return DateTime(year, month, day);
}

double? _parseDecimal(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return double.tryParse(raw);
}

bool _stringMapsEqual(Map<String, String> a, Map<String, String> b) {
  if (a.length != b.length) return false;
  for (final entry in b.entries) {
    if (a[entry.key] != entry.value) return false;
  }
  return true;
}
