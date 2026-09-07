import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// Local copy of `tooling/golden_runner.dart` so this package's tests can import it.
///
/// [settle] defaults to true. Set false for widgets with periodic timers
/// (e.g. [ExpiryCountdown]) so [pumpAndSettle] does not hang.
Future<void> expectKhGoldens(
  WidgetTester tester, {
  required String name,
  required Widget Function() builder,
  Size size = const Size(400, 200),
  bool settle = true,
  Widget Function(Widget child)? wrap,
}) async {
  Future<void> pump(TextDirection direction, String suffix) async {
    await tester.binding.setSurfaceSize(size);
    final child = builder();
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Center(
              child: wrap != null ? wrap(child) : child,
            ),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/${name}_$suffix.png'),
    );
  }

  await pump(TextDirection.ltr, 'ltr');
  await pump(TextDirection.rtl, 'rtl');
}
