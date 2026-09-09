import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/features/moderation/model/moderation_enums.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';

/// Codec for encoding/decoding moderation query state (TR-S1-26e / ADM-SMP-63).
class ModerationQueryParamsCodec extends QueryParamsCodec<ModerationFilters> {
  const ModerationQueryParamsCodec();

  @override
  ModerationFilters decodeFilters(Map<String, String> query) {
    final q = query['q'];
    final stateParam = query['state'];
    return ModerationFilters(
      state: stateParam != null ? ReviewState.fromWire(stateParam) : ReviewState.pendingModeration,
      authorType: AuthorType.fromWire(query['authorType']),
      query: (q == null || q.isEmpty) ? '' : q,
    );
  }

  @override
  Map<String, String> encodeFilters(ModerationFilters filters) {
    final params = <String, String>{};
    if (filters.state != null) {
      params['state'] = filters.state!.wireValue;
    }
    if (filters.authorType != null) {
      params['authorType'] = filters.authorType!.wireValue;
    }
    if (filters.query.isNotEmpty) {
      params['q'] = filters.query;
    }
    return params;
  }
}

/// Moderation query state encoded in URL query parameters.
class ModerationQueryParams {
  static const codec = ModerationQueryParamsCodec();

  const ModerationQueryParams({
    this.state = ReviewState.pendingModeration,
    this.authorType,
    this.query,
    this.cursor,
    this.selectedId,
  });

  final ReviewState? state;
  final AuthorType? authorType;
  final String? query;
  final String? cursor;
  final String? selectedId;

  factory ModerationQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return ModerationQueryParams(
      state: state.filters.state,
      authorType: state.filters.authorType,
      query: state.filters.query.isEmpty ? null : state.filters.query,
      cursor: state.cursor,
      selectedId: state.selectedId,
    );
  }

  factory ModerationQueryParams.fromState(GoRouterState state) =>
      ModerationQueryParams.fromUri(state.uri);

  factory ModerationQueryParams.fromFilters(
    ModerationFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    return ModerationQueryParams(
      state: filters.state,
      authorType: filters.authorType,
      query: filters.query.isEmpty ? null : filters.query,
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  ModerationFilters toFilters() {
    return ModerationFilters(
      state: state,
      authorType: authorType,
      query: query ?? '',
    );
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<ModerationFilters>(
        filters: toFilters(),
        cursor: cursor,
        selectedId: selectedId,
      ),
    );
  }
}

/// Extension on [BuildContext] for updating moderation query parameters.
extension ModerationQueryNavigation on BuildContext {
  void updateModerationQuery(
    ModerationFilters filters, {
    String? cursor,
    String? selectedId,
  }) {
    applyQueryParameters(
      ModerationQueryParams.fromFilters(
        filters,
        cursor: cursor,
        selectedId: selectedId,
      ).toQueryParameters(),
    );
  }
}
