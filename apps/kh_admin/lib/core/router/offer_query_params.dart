import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/offers/model/offer_enums.dart';
import 'package:kh_admin/features/offers/model/offer_list_filters.dart';

/// Codec for encoding/decoding offer list query state (TR-S1-25 / ADM-SMP-07).
class OfferQueryParamsCodec extends QueryParamsCodec<OfferListFilters> {
  const OfferQueryParamsCodec();

  @override
  OfferListFilters decodeFilters(Map<String, String> query) {
    final q = query['q'];
    final vendorId = query['vendorId'];
    return OfferListFilters(
      query: (q == null || q.isEmpty) ? '' : q,
      state: OfferState.fromApi(query['state']),
      requestType: RequestType.fromApi(query['requestType']),
      vendorId: (vendorId == null || vendorId.isEmpty) ? null : vendorId,
      dateFrom: _parseDate(query['dateFrom']),
      dateTo: _parseDate(query['dateTo']),
      minPrice: _parseDecimal(query['minPrice']),
      maxPrice: _parseDecimal(query['maxPrice']),
    );
  }

  @override
  Map<String, String> encodeFilters(OfferListFilters filters) {
    final params = <String, String>{};
    if (filters.query.isNotEmpty) {
      params['q'] = filters.query;
    }
    if (filters.state != null) {
      params['state'] = filters.state!.apiValue;
    }
    if (filters.requestType != null) {
      params['requestType'] = filters.requestType!.apiValue;
    }
    if (filters.vendorId != null && filters.vendorId!.isNotEmpty) {
      params['vendorId'] = filters.vendorId!;
    }
    final from = _formatDate(filters.dateFrom);
    if (from != null) {
      params['dateFrom'] = from;
    }
    final to = _formatDate(filters.dateTo);
    if (to != null) {
      params['dateTo'] = to;
    }
    if (filters.minPrice != null) {
      params['minPrice'] = filters.minPrice.toString();
    }
    if (filters.maxPrice != null) {
      params['maxPrice'] = filters.maxPrice.toString();
    }
    return params;
  }
}

/// Offer list query state encoded in URL query parameters (AD-FE §16.2).
class OfferQueryParams {
  static const codec = OfferQueryParamsCodec();

  const OfferQueryParams({
    this.query,
    this.state,
    this.requestType,
    this.vendorId,
    this.dateFrom,
    this.dateTo,
    this.minPrice,
    this.maxPrice,
    this.cursor,
    this.selectedId,
  });

  final String? query;
  final OfferState? state;
  final RequestType? requestType;
  final String? vendorId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? minPrice;
  final double? maxPrice;
  final String? cursor;
  final String? selectedId;

  factory OfferQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return OfferQueryParams(
      query: state.filters.query.isEmpty ? null : state.filters.query,
      state: state.filters.state,
      requestType: state.filters.requestType,
      vendorId: state.filters.vendorId,
      dateFrom: state.filters.dateFrom,
      dateTo: state.filters.dateTo,
      minPrice: state.filters.minPrice,
      maxPrice: state.filters.maxPrice,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory OfferQueryParams.fromState(GoRouterState state) =>
      OfferQueryParams.fromUri(state.uri);

  factory OfferQueryParams.fromFilters(
    OfferListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return OfferQueryParams(
      query: filters.query.isEmpty ? null : filters.query,
      state: filters.state,
      requestType: filters.requestType,
      vendorId: filters.vendorId,
      dateFrom: _dateOnly(filters.dateFrom),
      dateTo: _dateOnly(filters.dateTo),
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      cursor: cursor,
      selectedId: selectedId,
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
    return codec.encode(
      ListUrlState<OfferListFilters>(
        filters: toFilters(),
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
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
    String? cursor,
    String? selectedId,
    bool clearQuery = false,
    bool clearCursor = false,
    bool clearSelected = false,
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
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
    );
  }
}

/// Extension on [BuildContext] for updating offer list query parameters.
extension OfferQueryNavigation on BuildContext {
  void updateOfferQuery(
    OfferListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      OfferQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}

DateTime? _dateOnly(DateTime? value) {
  if (value == null) return null;
  return DateTime(value.year, value.month, value.day);
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

String? _formatDate(DateTime? value) {
  if (value == null) return null;
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

double? _parseDecimal(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return double.tryParse(raw);
}
