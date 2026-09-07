import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

void main() {
  testWidgets('MoneyDisplay formats AED amounts', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: const Scaffold(
          body: MoneyDisplay(amount: 1250.5),
        ),
      ),
    );

    expect(find.textContaining('AED'), findsOneWidget);
    expect(find.textContaining('1,250'), findsOneWidget);
  });
}
