import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_filters.dart';

/// Codec for encoding/decoding vendor list query state (TR-S1-25 / ADM-SMP-07).
class VendorQueryParamsCodec extends QueryParamsCodec<VendorListFilters> {
  const VendorQueryParamsCodec();

  @override
  VendorListFilters decodeFilters(Map<String, String> query) {
    final q = query['q'];
    return VendorListFilters(
      query: (q == null || q.isEmpty) ? '' : q,
      verificationState:
          VendorVerificationState.fromApi(query['verificationState']),
      accountState: VendorAccountState.fromApi(query['accountState']),
    );
  }

  @override
  Map<String, String> encodeFilters(VendorListFilters filters) {
    final params = <String, String>{};
    if (filters.query.isNotEmpty) {
      params['q'] = filters.query;
    }
    if (filters.verificationState != null) {
      params['verificationState'] = filters.verificationState!.apiValue;
    }
    if (filters.accountState != null) {
      params['accountState'] = filters.accountState!.apiValue;
    }
    return params;
  }
}

/// Vendor list query state encoded in URL query parameters (AD-FE §16.2).
class VendorQueryParams {
  static const codec = VendorQueryParamsCodec();

  const VendorQueryParams({
    this.query,
    this.verificationState,
    this.accountState,
    this.cursor,
    this.selectedId,
  });

  final String? query;
  final VendorVerificationState? verificationState;
  final VendorAccountState? accountState;
  final String? cursor;
  final String? selectedId;

  factory VendorQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return VendorQueryParams(
      query: state.filters.query.isEmpty ? null : state.filters.query,
      verificationState: state.filters.verificationState,
      accountState: state.filters.accountState,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory VendorQueryParams.fromState(GoRouterState state) =>
      VendorQueryParams.fromUri(state.uri);

  factory VendorQueryParams.fromFilters(
    VendorListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return VendorQueryParams(
      query: filters.query.isEmpty ? null : filters.query,
      verificationState: filters.verificationState,
      accountState: filters.accountState,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  VendorListFilters toFilters() {
    return VendorListFilters(
      query: query ?? '',
      verificationState: verificationState,
      accountState: accountState,
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<VendorListFilters>(
        filters: toFilters(),
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }

  VendorQueryParams copyWith({
    String? query,
    VendorVerificationState? verificationState,
    VendorAccountState? accountState,
    String? cursor,
    String? selectedId,
    bool clearQuery = false,
    bool clearVerification = false,
    bool clearAccount = false,
    bool clearCursor = false,
    bool clearSelected = false,
  }) {
    return VendorQueryParams(
      query: clearQuery ? null : (query ?? this.query),
      verificationState: clearVerification
          ? null
          : (verificationState ?? this.verificationState),
      accountState:
          clearAccount ? null : (accountState ?? this.accountState),
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
    );
  }
}

/// Extension on [BuildContext] for updating vendor list query parameters.
extension VendorQueryNavigation on BuildContext {
  void updateVendorQuery(
    VendorListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      VendorQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}
