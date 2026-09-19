import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// Centralised `GoRoute.onExit` handlers for every bottom-nav tab root.
///
/// go_router's system back handling (`GoRouterDelegate.popRoute`) never
/// touches `Navigator`/`PopScope` when every nested branch Navigator's
/// history is empty (`NavigatorState.canPop()` is a pure history-length
/// check) — it short-circuits straight to `GoRoute.onExit` on the current
/// route. `PopScope` cannot intercept a tab-root back-press for this reason;
/// these route-level hooks are the only place go_router actually asks.
/// Wire one of these into `onExit` on every `StatefulShellBranch`'s root
/// `GoRoute` instead of adding ad-hoc `PopScope`s per shell.

/// Non-Home branch root: switch to Home instead of letting the app exit.
Future<bool> handleNonHomeTabExit(BuildContext context, String homePath) async {
  context.go(homePath);
  return false;
}

/// Home tab root: require a second back-press within 2s to actually exit.
Future<bool> handleHomeTabExit(BuildContext context) async =>
    _ExitOnDoubleBack.instance.confirm(context);

class _ExitOnDoubleBack {
  _ExitOnDoubleBack._();
  static final instance = _ExitOnDoubleBack._();

  DateTime? _lastPressAt;

  bool confirm(BuildContext context) {
    final now = DateTime.now();
    final last = _lastPressAt;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return true;
    }
    _lastPressAt = now;
    final raw = KhStrings.of(context).s('shell.exitPrompt');
    final message = raw == 'shell.exitPrompt' ? 'Press back again to exit' : raw;
    showKhToast(
      context,
      message: message,
      tone: KhToastTone.info,
      duration: const Duration(seconds: 2),
    );
    return false;
  }
}
