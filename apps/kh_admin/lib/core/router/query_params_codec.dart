import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/router/query_navigation.dart';

/// Full URL state for a list screen (TR-S1-21 / E19 / ADM-SMP-63).
///
/// Encapsulates:
/// - [filters]: typed domain filter object
/// - [cursor]: optional pagination cursor
/// - [selectedId]: optional selected item identifier (e.g. for split panes or inspection)
class ListUrlState<TFilters> {
  const ListUrlState({
    required this.filters,
    this.cursor,
    this.selectedId,
  });

  final TFilters filters;
  final String? cursor;
  final String? selectedId;

  ListUrlState<TFilters> copyWith({
    TFilters? filters,
    String? cursor,
    String? selectedId,
    bool clearCursor = false,
    bool clearSelected = false,
  }) {
    return ListUrlState<TFilters>(
      filters: filters ?? this.filters,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListUrlState<TFilters> &&
          other.filters == filters &&
          other.cursor == cursor &&
          other.selectedId == selectedId;

  @override
  int get hashCode => Object.hash(filters, cursor, selectedId);

  @override
  String toString() =>
      'ListUrlState(filters: $filters, cursor: $cursor, selectedId: $selectedId)';
}

/// Generic bidirectional codec for encoding/decoding [ListUrlState] to/from query parameters.
abstract class QueryParamsCodec<TFilters> {
  const QueryParamsCodec();

  /// Decodes only the domain filter object from the flat query parameters map.
  TFilters decodeFilters(Map<String, String> query);

  /// Encodes only the domain filter object into a flat query parameters map.
  Map<String, String> encodeFilters(TFilters filters);

  /// Query parameter name for pagination cursor (default: 'cursor').
  String get cursorKey => 'cursor';

  /// Query parameter name for selected item ID (default: 'selected').
  String get selectedIdKey => 'selected';

  /// Decodes a full [ListUrlState] from a flat query parameters map.
  ListUrlState<TFilters> decode(Map<String, String> query) {
    final rawCursor = query[cursorKey];
    final cursor = (rawCursor != null && rawCursor.isNotEmpty) ? rawCursor : null;

    var rawSelected = query[selectedIdKey];
    if ((rawSelected == null || rawSelected.isEmpty) && selectedIdKey != 'selectedId') {
      rawSelected = query['selectedId'];
    }
    final selectedId = (rawSelected != null && rawSelected.isNotEmpty) ? rawSelected : null;

    return ListUrlState<TFilters>(
      filters: decodeFilters(query),
      cursor: cursor,
      selectedId: selectedId,
    );
  }

  /// Encodes a full [ListUrlState] into a flat query parameters map.
  Map<String, String> encode(ListUrlState<TFilters> state) {
    final params = Map<String, String>.from(encodeFilters(state.filters));
    if (state.cursor != null && state.cursor!.isNotEmpty) {
      params[cursorKey] = state.cursor!;
    }
    if (state.selectedId != null && state.selectedId!.isNotEmpty) {
      params[selectedIdKey] = state.selectedId!;
    }
    return params;
  }

  /// Convenience decode from a [Uri].
  ListUrlState<TFilters> fromUri(Uri uri) => decode(uri.queryParameters);

  /// Convenience decode from a [GoRouterState].
  ListUrlState<TFilters> fromState(GoRouterState state) => fromUri(state.uri);
}

/// Context extension for updating full list state through [QueryParamsCodec].
extension ListUrlNavigation on BuildContext {
  void updateListUrlState<TFilters>(
    QueryParamsCodec<TFilters> codec,
    ListUrlState<TFilters> state,
  ) {
    applyQueryParameters(codec.encode(state));
  }
}
