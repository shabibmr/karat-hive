import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

void main() {
  Future<void> pumpSurface(WidgetTester tester, Size size, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: child,
      ),
    );
  }

  testWidgets('caps content at 560 on a 1024-wide surface', (tester) async {
    await pumpSurface(
      tester,
      const Size(1024, 768),
      const KhCenteredContent(
        child: SizedBox(key: Key('probe'), width: double.infinity, height: 8),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('probe'))).width, 560);
  });

  testWidgets('uses the full width on a 320-wide surface', (tester) async {
    await pumpSurface(
      tester,
      const Size(320, 568),
      const KhCenteredContent(
        child: SizedBox(key: Key('probe'), width: double.infinity, height: 8),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('probe'))).width, 320);
  });

  testWidgets('gives a ListView a bounded height', (tester) async {
    await pumpSurface(
      tester,
      const Size(390, 600),
      KhCenteredContent(
        child: ListView(children: const [Text('row')]),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
