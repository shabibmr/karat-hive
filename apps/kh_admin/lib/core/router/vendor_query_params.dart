import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_filters.dart';
import 'package:kh_admin/core/router/query_navigation.dart';

/// Vendor list query state encoded in URL query parameters (AD-FE §16.2).
class VendorQueryParams {
  const VendorQueryParams({
    this.query,
    this.verificationState,
    this.accountState,
  });

  final String? query;
  final VendorVerificationState? verificationState;
  final VendorAccountState? accountState;

  factory VendorQueryParams.fromUri(Uri uri) {
    final q = uri.queryParameters['q'];
    return VendorQueryParams(
      query: (q == null || q.isEmpty) ? null : q,
      verificationState:
          VendorVerificationState.fromApi(uri.queryParameters['verificationState']),
      accountState: VendorAccountState.fromApi(uri.queryParameters['accountState']),
    );
  }

  factory VendorQueryParams.fromState(GoRouterState state) {
    return VendorQueryParams.fromUri(state.uri);
  }

  factory VendorQueryParams.fromFilters(VendorListFilters filters) {
    return VendorQueryParams(
      query: filters.query.isEmpty ? null : filters.query,
      verificationState: filters.verificationState,
      accountState: filters.accountState,
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
    final params = <String, String>{};
    if (query != null && query!.isNotEmpty) {
      params['q'] = query!;
    }
    if (verificationState != null) {
      params['verificationState'] = verificationState!.apiValue;
    }
    if (accountState != null) {
      params['accountState'] = accountState!.apiValue;
    }
    return params;
  }

  VendorQueryParams copyWith({
    String? query,
    VendorVerificationState? verificationState,
    VendorAccountState? accountState,
    bool clearQuery = false,
    bool clearVerification = false,
    bool clearAccount = false,
  }) {
    return VendorQueryParams(
      query: clearQuery ? null : (query ?? this.query),
      verificationState: clearVerification
          ? null
          : (verificationState ?? this.verificationState),
      accountState:
          clearAccount ? null : (accountState ?? this.accountState),
    );
  }
}

/// Extension on [BuildContext] for updating vendor list query parameters.
extension VendorQueryNavigation on BuildContext {
  void updateVendorQuery(VendorListFilters filters) {
    applyQueryParameters(VendorQueryParams.fromFilters(filters).toQueryParameters());
  }
}
