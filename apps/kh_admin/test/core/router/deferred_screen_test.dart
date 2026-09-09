import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/router/app_router.dart';

void main() {
  group('DeferredScreen (TR-S4-11)', () {
    testWidgets('displays CircularProgressIndicator while loading, then loaded widget',
        (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeferredScreen(
              loader: () => completer.future,
              builder: () => const Text('Deferred Content Loaded'),
            ),
          ),
        ),
      );

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Deferred Content Loaded'), findsNothing);

      // Complete loader
      completer.complete();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Deferred Content Loaded'), findsOneWidget);
    });

    testWidgets('displays error message when loader throws', (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeferredScreen(
              loader: () => completer.future,
              builder: () => const Text('Deferred Content Loaded'),
            ),
          ),
        ),
      );

      completer.completeError('Chunk download failed');
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load module: Chunk download failed'),
          findsOneWidget);
    });
  });
}
