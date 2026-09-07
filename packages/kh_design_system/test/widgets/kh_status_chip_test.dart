import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

void main() {
  testWidgets('KhStatusChip renders label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: const Scaffold(
          body: KhStatusChip(label: 'Responded', tone: KhStatusTone.accent),
        ),
      ),
    );

    expect(find.text('Responded'), findsOneWidget);
  });

  testWidgets('KhSectionHeader shows optional action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Scaffold(
          body: KhSectionHeader(
            title: 'Latest matches',
            actionLabel: 'See all',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Latest matches'), findsOneWidget);
    await tester.tap(find.text('See all'));
    expect(tapped, isTrue);
  });
}
