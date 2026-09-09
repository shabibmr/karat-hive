import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';

/// Codec for encoding/decoding customer list query state (TR-S1-26a / ADM-SMP-63).
class CustomerQueryParamsCodec extends QueryParamsCodec<CustomerListFilters> {
  const CustomerQueryParamsCodec();

  @override
  CustomerListFilters decodeFilters(Map<String, String> query) {
    final q = query['q'];
    return CustomerListFilters(
      query: (q == null || q.isEmpty) ? '' : q,
      accountState: CustomerAccountState.fromApi(query['accountState']),
    );
  }

  @override
  Map<String, String> encodeFilters(CustomerListFilters filters) {
    final params = <String, String>{};
    if (filters.query.isNotEmpty) {
      params['q'] = filters.query;
    }
    if (filters.accountState != null) {
      params['accountState'] = filters.accountState!.apiValue;
    }
    return params;
  }
}

/// Customer list query state encoded in URL query parameters.
class CustomerQueryParams {
  static const codec = CustomerQueryParamsCodec();

  const CustomerQueryParams({
    this.query,
    this.accountState,
    this.cursor,
    this.selectedId,
  });

  final String? query;
  final CustomerAccountState? accountState;
  final String? cursor;
  final String? selectedId;

  factory CustomerQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return CustomerQueryParams(
      query: state.filters.query.isEmpty ? null : state.filters.query,
      accountState: state.filters.accountState,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory CustomerQueryParams.fromState(GoRouterState state) =>
      CustomerQueryParams.fromUri(state.uri);

  factory CustomerQueryParams.fromFilters(
    CustomerListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return CustomerQueryParams(
      query: filters.query.isEmpty ? null : filters.query,
      accountState: filters.accountState,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  CustomerListFilters toFilters() {
    return CustomerListFilters(
      query: query ?? '',
      accountState: accountState,
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<CustomerListFilters>(
        filters: toFilters(),
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }

  CustomerQueryParams copyWith({
    String? query,
    CustomerAccountState? accountState,
    String? cursor,
    String? selectedId,
    bool clearQuery = false,
    bool clearAccountState = false,
    bool clearCursor = false,
    bool clearSelected = false,
  }) {
    return CustomerQueryParams(
      query: clearQuery ? null : (query ?? this.query),
      accountState: clearAccountState
          ? null
          : (accountState ?? this.accountState),
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
    );
  }
}

/// Extension on [BuildContext] for updating customer list query parameters.
extension CustomerQueryNavigation on BuildContext {
  void updateCustomerQuery(
    CustomerListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      CustomerQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}
