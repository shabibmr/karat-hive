import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/design/theme/theme_preference_store.dart';

/// Controls light/dark theme for the admin portal. Default is light.
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._store)
      : super(_store.read() ?? ThemeMode.light);

  final ThemePreferenceStore _store;

  void setMode(ThemeMode mode) {
    if (state == mode) return;
    state = mode;
    _store.write(mode);
  }

  void toggle() {
    setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themePreferenceStoreProvider = Provider<ThemePreferenceStore>(
  (ref) => ThemePreferenceStore(),
);

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref.watch(themePreferenceStoreProvider));
});
