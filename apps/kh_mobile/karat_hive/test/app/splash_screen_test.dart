import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/shells/splash_screen.dart';
import 'package:kh_l10n/kh_l10n.dart';

Widget _wrap(Widget child, [Locale locale = const Locale('en')]) => MaterialApp(
      locale: locale,
      supportedLocales: KhStrings.supportedLocales,
      localizationsDelegates: KhStrings.delegates,
      home: child,
    );

void main() {
  testWidgets('SplashScreen renders deep ink background, brand logo, and tagline', (tester) async {
    await tester.pumpWidget(_wrap(const SplashScreen()));
    await tester.pump();

    // Verify initial render
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Initial pump (emblem drawing in)
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('splash-logo')), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Pump past the reveal keyframe timeline (2200ms)
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('THE MODERN GOLD STANDARD'), findsOneWidget);
  });

  testWidgets('SplashScreen renders in Arabic locale without error', (tester) async {
    await tester.pumpWidget(_wrap(const SplashScreen(), const Locale('ar')));

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('splash-logo')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('المعيار الذهبي الحديث'), findsOneWidget);
  });
}
