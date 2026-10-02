import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/shells/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders Karat Hive logo and circular progress indicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.byKey(const Key('splash-screen')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
