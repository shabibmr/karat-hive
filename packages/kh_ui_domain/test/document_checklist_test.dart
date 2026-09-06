import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

void main() {
  testWidgets('marks present documents and leaves the rest unchecked', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: const Scaffold(
          body: DocumentChecklist(
            present: {VendorDocumentType.tradeLicence},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsWidgets);
  });
}
