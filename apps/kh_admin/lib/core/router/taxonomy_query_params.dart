import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Taxonomy list query state encoded in URL query parameters (AD-FE §16.2).
/// Preserves selected node and showInactive filter across page reloads and browser history.
class TaxonomyQueryParams {
  const TaxonomyQueryParams({
    this.selectedId,
    this.showInactive = false,
  });

  final String? selectedId;
  final bool showInactive;

  factory TaxonomyQueryParams.fromUri(Uri uri) {
    return TaxonomyQueryParams(
      selectedId: uri.queryParameters['selected'],
      showInactive: uri.queryParameters['showInactive'] == 'true',
    );
  }

  factory TaxonomyQueryParams.fromState(GoRouterState state) {
    return TaxonomyQueryParams.fromUri(state.uri);
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};
    if (selectedId != null && selectedId!.isNotEmpty) {
      params['selected'] = selectedId!;
    }
    if (showInactive) {
      params['showInactive'] = 'true';
    }
    return params;
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

      final newUri = state.uri.replace(
        queryParameters: updated.toQueryParameters().isEmpty
            ? null
            : updated.toQueryParameters(),
      );

      go(newUri.toString());
    } on Object catch (_) {
      // Safe fallback when executed outside a GoRouter context (e.g. isolated widget tests)
    }
  }
}
