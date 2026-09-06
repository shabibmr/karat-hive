import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/shells/vendor_shell.dart';

void main() {
  testWidgets(
    'VendorShell never mounts a NavigationBar with fewer than 2 destinations',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VendorShell(
            child: Text('home-body'),
          ),
        ),
      );

      expect(find.byType(VendorShell), findsOneWidget);
      expect(find.byKey(const Key('vendor-shell')), findsOneWidget);
      expect(find.text('home-body'), findsOneWidget);

      // Material NavigationBar asserts destinations.length >= 2 (navigation_bar.dart).
      // A one-item bar red-screens the ACTIVE dashboard after Categories/Regions.
      final bars = tester.widgetList<NavigationBar>(find.byType(NavigationBar));
      for (final bar in bars) {
        expect(
          bar.destinations.length,
          greaterThanOrEqualTo(2),
          reason: 'NavigationBar requires destinations.length >= 2',
        );
      }
    },
  );
}
