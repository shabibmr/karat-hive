import 'dart:async';

import 'package:flutter/widgets.dart';

/// Debounces the search field on a list screen.
///
/// Every admin list screen types into a search box that should not fire a
/// request per keystroke. The timer plumbing is identical on all of them; only
/// the action differs, so it lives here once.
///
/// The [State] that mixes this in keeps its own `dispose()` — the timer is
/// cancelled by this mixin's `dispose()`, reached through `super.dispose()`.
mixin DebouncedSearchMixin<T extends StatefulWidget> on State<T> {
  Timer? _searchDebounce;

  /// How long to wait after the last keystroke. Override to change it.
  Duration get searchDebounceDuration => const Duration(milliseconds: 350);

  /// Runs [action] once the user stops typing for [searchDebounceDuration],
  /// replacing any pending call. Skipped if the screen is gone by then.
  void debounceSearch(VoidCallback action) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(searchDebounceDuration, () {
      if (mounted) action();
    });
  }

  /// Drops a pending [debounceSearch] call — used when the user submits the
  /// field explicitly and the search should run immediately instead.
  void cancelSearchDebounce() => _searchDebounce?.cancel();

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
