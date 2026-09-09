import 'package:flutter/widgets.dart' hide ConnectionState;
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/connections/model/connection_enums.dart';
import 'package:kh_admin/features/connections/model/connection_list_filters.dart';

/// Codec for encoding/decoding connection list query state (TR-S1-26b / ADM-SMP-63).
class ConnectionQueryParamsCodec extends QueryParamsCodec<ConnectionListFilters> {
  const ConnectionQueryParamsCodec();

  @override
  ConnectionListFilters decodeFilters(Map<String, String> query) {
    final q = query['q'];
    return ConnectionListFilters(
      query: (q == null || q.isEmpty) ? '' : q,
      state: ConnectionState.fromApi(query['state']),
      hasNoContactOnly: query['hasNoContactOnly'] == 'true',
    );
  }

  @override
  Map<String, String> encodeFilters(ConnectionListFilters filters) {
    final params = <String, String>{};
    if (filters.query.isNotEmpty) {
      params['q'] = filters.query;
    }
    if (filters.state != null) {
      params['state'] = filters.state!.apiValue;
    }
    if (filters.hasNoContactOnly) {
      params['hasNoContactOnly'] = 'true';
    }
    return params;
  }
}

/// Connection list query state encoded in URL query parameters.
class ConnectionQueryParams {
  static const codec = ConnectionQueryParamsCodec();

  const ConnectionQueryParams({
    this.query,
    this.state,
    this.hasNoContactOnly = false,
    this.cursor,
    this.selectedId,
  });

  final String? query;
  final ConnectionState? state;
  final bool hasNoContactOnly;
  final String? cursor;
  final String? selectedId;

  factory ConnectionQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return ConnectionQueryParams(
      query: state.filters.query.isEmpty ? null : state.filters.query,
      state: state.filters.state,
      hasNoContactOnly: state.filters.hasNoContactOnly,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory ConnectionQueryParams.fromState(GoRouterState state) =>
      ConnectionQueryParams.fromUri(state.uri);

  factory ConnectionQueryParams.fromFilters(
    ConnectionListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return ConnectionQueryParams(
      query: filters.query.isEmpty ? null : filters.query,
      state: filters.state,
      hasNoContactOnly: filters.hasNoContactOnly,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  ConnectionListFilters toFilters() {
    return ConnectionListFilters(
      query: query ?? '',
      state: state,
      hasNoContactOnly: hasNoContactOnly,
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<ConnectionListFilters>(
        filters: toFilters(),
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }

  ConnectionQueryParams copyWith({
    String? query,
    ConnectionState? state,
    bool? hasNoContactOnly,
    String? cursor,
    String? selectedId,
    bool clearQuery = false,
    bool clearState = false,
    bool clearCursor = false,
    bool clearSelected = false,
  }) {
    return ConnectionQueryParams(
      query: clearQuery ? null : (query ?? this.query),
      state: clearState ? null : (state ?? this.state),
      hasNoContactOnly: hasNoContactOnly ?? this.hasNoContactOnly,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
    );
  }
}

/// Extension on [BuildContext] for updating connection list query parameters.
extension ConnectionQueryNavigation on BuildContext {
  void updateConnectionQuery(
    ConnectionListFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      ConnectionQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}
