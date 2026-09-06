import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// LTR + RTL golden helper (AD-FE-13). Pump [builder] twice with suffixes `_ltr` / `_rtl`.
Future<void> expectKhGoldens(
  WidgetTester tester, {
  required String name,
  required Widget Function() builder,
  Size size = const Size(400, 200),
}) async {
  Future<void> pump(TextDirection direction, String suffix) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Directionality(
          textDirection: direction,
          child: Scaffold(body: Center(child: builder())),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/${name}_$suffix.png'),
    );
  }

  await pump(TextDirection.ltr, 'ltr');
  await pump(TextDirection.rtl, 'rtl');
}
