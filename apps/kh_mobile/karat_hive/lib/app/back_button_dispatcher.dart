import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import 'shells/active_shell_registry.dart';

/// App-wide hardware/gesture back handling.
///
/// go_router's `GoRoute.onExit` fires on *any* removal of a route from
/// `currentConfiguration` — including ordinary `goBranch` tab switches and
/// session redirects, not only a genuine "nothing left to pop" back-press —
/// so it's the wrong tool for shell-root (bottom-nav tab) back behaviour.
/// This dispatcher intercepts the OS back event itself, before go_router's
/// route diffing runs, and only special-cases the case where nothing in any
/// nested Navigator can pop. Everything else (including the wizard's own
/// `RequestCreatePaths.type` onExit safety net) still goes through the
/// router's default handling via `super.didPopRoute()`.
class AppBackButtonDispatcher extends RootBackButtonDispatcher {
  AppBackButtonDispatcher(this._router);

  final GoRouter _router;
  DateTime? _lastHomeExitPressAt;

  @override
  Future<bool> didPopRoute() async {
    if (_router.canPop()) {
      return super.didPopRoute();
    }

    final shell = ActiveShellRegistry.instance.current;
    if (shell == null) {
      return super.didPopRoute();
    }

    if (!shell.isHome) {
      shell.goHome();
      return true;
    }

    return !_shouldExitOnDoubleBack();
  }

  /// Returns true only on the second back-press within 2s of the first.
  bool _shouldExitOnDoubleBack() {
    final now = DateTime.now();
    final last = _lastHomeExitPressAt;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return true;
    }
    _lastHomeExitPressAt = now;

    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context != null) {
      final raw = KhStrings.of(context).s('shell.exitPrompt');
      final message =
          raw == 'shell.exitPrompt' ? 'Press back again to exit' : raw;
      showKhToast(
        context,
        message: message,
        tone: KhToastTone.info,
        duration: const Duration(seconds: 2),
      );
    }
    return false;
  }
}
