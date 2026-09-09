import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SH-ID-03 shows average 1 dp, count, and distribution',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const RatingSummaryView(
          summary: RatingSummary(
            average: 4.67,
            count: 15,
            distribution: {'5': 12, '4': 3, '3': 0, '2': 0, '1': 0},
            limitedHistory: false,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('rating-summary')), findsOneWidget);
    expect(find.byKey(const Key('rating-summary-average')), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('15 reviews'), findsOneWidget);
    expect(find.byKey(const Key('rating-summary-distribution')), findsOneWidget);
    expect(find.byKey(const Key('rating-summary-limited')), findsNothing);
  });

  testWidgets('SH-ID-03 limited history hides average and shows notice',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const RatingSummaryView(
          summary: RatingSummary(
            average: 5.0,
            count: 2,
            distribution: {'5': 2},
            limitedHistory: true,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('rating-summary-limited')), findsOneWidget);
    expect(find.byKey(const Key('rating-summary-average')), findsNothing);
    expect(
      find.text('New vendor — limited rating history'),
      findsOneWidget,
    );
    expect(find.text('2 reviews'), findsOneWidget);
  });

  testWidgets('SH-ID-03 empty count shows no-reviews copy', (tester) async {
    await tester.pumpWidget(
      _host(
        const RatingSummaryView(
          summary: RatingSummary(
            average: 0,
            count: 0,
            limitedHistory: true,
          ),
        ),
      ),
    );

    expect(find.text('No reviews yet'), findsOneWidget);
    expect(find.byKey(const Key('rating-summary-distribution')), findsNothing);
  });
}
