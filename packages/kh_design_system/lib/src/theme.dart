import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData khTheme() {
  const t = KhTokens.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: t.gold,
    primary: t.gold,
    surface: t.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.surface,
    extensions: const [t],
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
  );
}
