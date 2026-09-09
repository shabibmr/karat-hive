import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Shared helpers for reflecting list-filter state into the browser URL.
///
/// Each list feature owns its own `*QueryParams` codec; the navigation
/// mechanics around that codec are identical everywhere and live here.
extension QueryNavigation on BuildContext {
  /// Replaces the current route's query string with [updated].
  ///
  /// No-ops when [updated] already matches the current query, so redundant
  /// filter rebuilds do not push duplicate history entries. Passing an empty
  /// map clears the query string.
  ///
  /// Safe to call outside a GoRouter context (e.g. isolated widget tests):
  /// the lookup failure is swallowed and navigation is skipped.
  void applyQueryParameters(Map<String, String> updated) {
    try {
      final routerState = GoRouterState.of(this);
      if (stringMapsEqual(routerState.uri.queryParameters, updated)) return;

      go(routerState.uri.replace(queryParameters: updated).toString());
    } on Object catch (_) {
      // Outside a GoRouter context — nothing to navigate.
    }
  }
}

/// Order-insensitive equality for flat query-parameter maps.
bool stringMapsEqual(Map<String, String> a, Map<String, String> b) {
  if (a.length != b.length) return false;
  for (final entry in b.entries) {
    if (a[entry.key] != entry.value) return false;
  }
  return true;
}
