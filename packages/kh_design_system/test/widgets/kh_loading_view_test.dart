import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

void main() {
  testWidgets('KhLoadingView renders CircularProgressIndicator and logo structure', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KhLoadingView(),
        ),
      ),
    );

    expect(find.byKey(const Key('loading-view')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('KhLoadingView respects showLogo = false', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KhLoadingView(showLogo: false),
        ),
      ),
    );

    expect(find.byKey(const Key('loading-view')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
