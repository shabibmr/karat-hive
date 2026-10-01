import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

void main() {
  testWidgets('KhBrandMark shows tracked uppercase Latin wordmark', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: KhTheme.light(locale: const Locale('en')),
        home: const Scaffold(
          body: KhBrandMark(label: 'Karat Hive'),
        ),
      ),
    );

    expect(find.text('KARAT HIVE'), findsOneWidget);
    final text = tester.widget<Text>(find.text('KARAT HIVE'));
    expect(text.style?.letterSpacing, 3.2);
    expect(text.style?.color, KhTokens.light.gold);
    expect(text.style?.fontFamily, contains('CormorantGaramond'));
  });
}

