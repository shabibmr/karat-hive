import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('renders with currentLocale en, shows English (LTR), and EN selected',
      (tester) async {
    await tester.pumpWidget(
      _host(
        LanguagePickerTile(
          currentLocale: 'en',
          onLocaleChanged: (_) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.language), findsOneWidget);
    expect(find.text('App Language'), findsOneWidget);
    expect(find.text('English (LTR)'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('عربي'), findsOneWidget);

    final segmentedButton =
        tester.widget<SegmentedButton<String>>(find.byType(SegmentedButton<String>));
    expect(segmentedButton.selected, {'en'});
  });

  testWidgets('tapping عربي triggers callback with ar', (tester) async {
    String? updatedLocale;

    await tester.pumpWidget(
      _host(
        LanguagePickerTile(
          currentLocale: 'en',
          onLocaleChanged: (locale) {
            updatedLocale = locale;
          },
        ),
      ),
    );

    await tester.tap(find.text('عربي'));
    await tester.pumpAndSettle();

    expect(updatedLocale, 'ar');
  });

  testWidgets(
      'renders with currentLocale ar, shows العربية (Arabic - RTL), and عربي selected',
      (tester) async {
    await tester.pumpWidget(
      _host(
        LanguagePickerTile(
          currentLocale: 'ar',
          onLocaleChanged: (_) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.language), findsOneWidget);
    expect(find.text('App Language'), findsOneWidget);
    expect(find.text('العربية (Arabic - RTL)'), findsOneWidget);

    final segmentedButton =
        tester.widget<SegmentedButton<String>>(find.byType(SegmentedButton<String>));
    expect(segmentedButton.selected, {'ar'});
  });

  testWidgets('tapping EN triggers callback with en', (tester) async {
    String? updatedLocale;

    await tester.pumpWidget(
      _host(
        LanguagePickerTile(
          currentLocale: 'ar',
          onLocaleChanged: (locale) {
            updatedLocale = locale;
          },
        ),
      ),
    );

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(updatedLocale, 'en');
  });
}
