import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Persists admin theme mode in `localStorage` (web).
class ThemePreferenceStore {
  static const _key = 'kh_admin_theme_mode';

  ThemeMode? read() {
    try {
      final raw = web.window.localStorage.getItem(_key);
      return switch (raw) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => null,
      };
    } on Object catch (_) {
      return null;
    }
  }

  void write(ThemeMode mode) {
    try {
      final value = switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
      web.window.localStorage.setItem(_key, value);
    } on Object catch (_) {
      // Preference persistence is best-effort.
    }
  }
}
