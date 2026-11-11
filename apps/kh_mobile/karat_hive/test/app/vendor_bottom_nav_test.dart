import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/shells/vendor_shell.dart';
import 'package:kh_design_system/kh_design_system.dart';

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required int selectedIndex,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: khTheme(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );
      },
      home: Scaffold(
        bottomNavigationBar: VendorBottomNav(
          selectedIndex: selectedIndex,
          onDestinationSelected: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('hides unselected Vendor labels below 360', (tester) async {
    await _pump(
      tester,
      size: const Size(320, 568),
      selectedIndex: 0,
    );

    expect(find.text('Home'), findsOneWidget);
    // onlyShowSelected fades the label; the Text stays in the tree.
    expect(find.text('Connections').hitTestable(), findsNothing);
  });

  testWidgets('shows Vendor labels at 390', (tester) async {
    await _pump(
      tester,
      size: const Size(390, 844),
      selectedIndex: 0,
    );

    expect(find.text('Connections'), findsOneWidget);
  });

  testWidgets('Vendor bar grows to 82 at text scale 2', (tester) async {
    await _pump(
      tester,
      size: const Size(390, 844),
      selectedIndex: 0,
      textScale: 2,
    );

    expect(tester.getSize(find.byType(NavigationBar)).height, 82);
    expect(tester.takeException(), isNull);
  });
}
