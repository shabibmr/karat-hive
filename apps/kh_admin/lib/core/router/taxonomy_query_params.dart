import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';

/// Codec for encoding/decoding taxonomy query state (TR-S1-25 / ADM-SMP-07).
class TaxonomyQueryParamsCodec extends QueryParamsCodec<bool> {
  const TaxonomyQueryParamsCodec();

  @override
  bool decodeFilters(Map<String, String> query) {
    return query['showInactive'] == 'true';
  }

  @override
  Map<String, String> encodeFilters(bool filters) {
    if (filters) return {'showInactive': 'true'};
    return const {};
  }
}

/// Taxonomy list query state encoded in URL query parameters (AD-FE §16.2).
/// Preserves selected node and showInactive filter across page reloads and browser history.
class TaxonomyQueryParams {
  static const codec = TaxonomyQueryParamsCodec();

  const TaxonomyQueryParams({
    this.selectedId,
    this.showInactive = false,
  });

  final String? selectedId;
  final bool showInactive;

  factory TaxonomyQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return TaxonomyQueryParams(
      selectedId: state.selectedId,
      showInactive: state.filters,
    );
  }

  factory TaxonomyQueryParams.fromState(GoRouterState state) {
    return TaxonomyQueryParams.fromUri(state.uri);
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<bool>(
        filters: showInactive,
        selectedId: selectedId,
      ),
    );
  }

  TaxonomyQueryParams copyWith({
    String? selectedId,
    bool? showInactive,
    bool clearSelected = false,
  }) {
    return TaxonomyQueryParams(
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
      showInactive: showInactive ?? this.showInactive,
    );
  }
}

/// Extension on [BuildContext] for updating taxonomy query parameters in the URL.
extension TaxonomyQueryNavigation on BuildContext {
  void updateTaxonomyQuery({
    String? selectedId,
    bool? showInactive,
    bool clearSelected = false,
  }) {
    try {
      final state = GoRouterState.of(this);
      final current = TaxonomyQueryParams.fromState(state);
      final updated = current.copyWith(
        selectedId: selectedId,
        showInactive: showInactive,
        clearSelected: clearSelected,
      );

      applyQueryParameters(updated.toQueryParameters());
    } on Object catch (_) {
      // Safe fallback when executed outside a GoRouter context (e.g. isolated widget tests)
    }
  }
}
