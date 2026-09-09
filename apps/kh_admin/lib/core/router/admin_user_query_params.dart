import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_enums.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_filters.dart';

/// Codec for encoding/decoding admin users query state (TR-S1-26g / ADM-SMP-63).
class AdminUserQueryParamsCodec extends QueryParamsCodec<AdminUserFilters> {
  const AdminUserQueryParamsCodec();

  @override
  AdminUserFilters decodeFilters(Map<String, String> query) {
    final q = query['q'];
    return AdminUserFilters(
      state: AdminAccountState.fromWire(query['state']),
      query: (q == null || q.isEmpty) ? '' : q,
    );
  }

  @override
  Map<String, String> encodeFilters(AdminUserFilters filters) {
    final params = <String, String>{};
    if (filters.state != null) {
      params['state'] = filters.state!.wireValue;
    }
    if (filters.query.isNotEmpty) {
      params['q'] = filters.query;
    }
    return params;
  }
}

/// Admin users directory query state encoded in URL query parameters.
class AdminUserQueryParams {
  static const codec = AdminUserQueryParamsCodec();

  const AdminUserQueryParams({
    this.state,
    this.query,
    this.cursor,
    this.selectedId,
  });

  final AdminAccountState? state;
  final String? query;
  final String? cursor;
  final String? selectedId;

  factory AdminUserQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return AdminUserQueryParams(
      state: state.filters.state,
      query: state.filters.query.isEmpty ? null : state.filters.query,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory AdminUserQueryParams.fromState(GoRouterState state) =>
      AdminUserQueryParams.fromUri(state.uri);

  factory AdminUserQueryParams.fromFilters(
    AdminUserFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return AdminUserQueryParams(
      state: filters.state,
      query: filters.query.isEmpty ? null : filters.query,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  AdminUserFilters toFilters() {
    return AdminUserFilters(
      state: state,
      query: query ?? '',
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<AdminUserFilters>(
        filters: toFilters(),
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }
}

/// Extension on [BuildContext] for updating admin user query parameters.
extension AdminUserQueryNavigation on BuildContext {
  void updateAdminUserQuery(
    AdminUserFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      AdminUserQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}
