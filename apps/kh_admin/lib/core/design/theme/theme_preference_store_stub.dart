import 'package:flutter/material.dart';

/// In-memory theme preference (non-web). Defaults to light.
class ThemePreferenceStore {
  ThemeMode? _mode;

  ThemeMode? read() => _mode;

  void write(ThemeMode mode) {
    _mode = mode;
  }
}
