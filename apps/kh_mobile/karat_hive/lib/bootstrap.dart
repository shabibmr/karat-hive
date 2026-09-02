import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// Nothing heavy before the first frame (Architecture-Frontend §17): restore
/// tokens and render; the session provider resolves the rest.
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KaratHiveApp()));
}
