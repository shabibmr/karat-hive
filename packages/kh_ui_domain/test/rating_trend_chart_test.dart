import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
}) =>
    MaterialApp(
      theme: khTheme(),
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );

void main() {
  group('RatingTrendPoint', () {
    test('initializes properties and computes averageString', () {
      const point = RatingTrendPoint(
        period: '2026-03',
        average: 4.67,
        count: 14,
      );

      expect(point.period, '2026-03');
      expect(point.average, 4.67);
      expect(point.count, 14);
      expect(point.averageString, '4.7');
    });

    test('supports value equality and hashCode', () {
      const p1 = RatingTrendPoint(period: 'Mar', average: 4.5, count: 10);
      const p2 = RatingTrendPoint(period: 'Mar', average: 4.5, count: 10);
      const p3 = RatingTrendPoint(period: 'Apr', average: 4.5, count: 10);

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
      expect(p1.toString(), contains('RatingTrendPoint'));
    });

    test('serializes to and from json', () {
      const point = RatingTrendPoint(period: 'Jan', average: 4.2, count: 8);
      final json = point.toJson();
      final fromJson = RatingTrendPoint.fromJson(json);

      expect(fromJson, equals(point));
    });
  });

  group('RatingTrendChart', () {
    final validPoints = [
      const RatingTrendPoint(period: 'Oct', average: 4.2, count: 10),
      const RatingTrendPoint(period: 'Nov', average: 4.5, count: 15),
      const RatingTrendPoint(period: 'Dec', average: 4.8, count: 20),
      const RatingTrendPoint(period: 'Jan', average: 5.0, count: 18),
      const RatingTrendPoint(period: 'Feb', average: 3.9, count: 12),
      const RatingTrendPoint(period: 'Mar', average: 4.7, count: 22),
    ];

    testWidgets('renders valid trend data with score and month labels',
        (tester) async {
      await tester.pumpWidget(
        _host(
          RatingTrendChart(
            title: '6-Month Rating Trend',
            points: validPoints,
          ),
        ),
      );

      // Chart container should exist, insufficient container should not
      expect(find.byKey(const Key('rating-trend-chart')), findsOneWidget);
      expect(
        find.byKey(const Key('rating-trend-chart-insufficient')),
        findsNothing,
      );

      // Title should be visible
      expect(find.text('6-Month Rating Trend'), findsOneWidget);

      // All score labels formatted to 1 dp should be rendered
      expect(find.text('4.2'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('3.9'), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);

      // All period/month labels should be rendered
      expect(find.text('Oct'), findsOneWidget);
      expect(find.text('Nov'), findsOneWidget);
      expect(find.text('Dec'), findsOneWidget);
      expect(find.text('Jan'), findsOneWidget);
      expect(find.text('Feb'), findsOneWidget);
      expect(find.text('Mar'), findsOneWidget);

      // Bars are rendered proportional to score (FractionallySizedBox heightFactors)
      final octBox = tester.widget<FractionallySizedBox>(
        find.descendant(
          of: find.byKey(const Key('rating-trend-bar-Oct')),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(octBox.heightFactor, closeTo(4.2 / 5.0, 0.001));

      final janBox = tester.widget<FractionallySizedBox>(
        find.descendant(
          of: find.byKey(const Key('rating-trend-bar-Jan')),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(janBox.heightFactor, closeTo(1.0, 0.001));
    });

    testWidgets('renders insufficient history state when points list is empty',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const RatingTrendChart(points: []),
        ),
      );

      expect(
        find.byKey(const Key('rating-trend-chart-insufficient')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('rating-trend-chart')), findsNothing);
      expect(find.text('Insufficient history for trend'), findsOneWidget);
    });

    testWidgets('renders insufficient history state when points length < 2',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const RatingTrendChart(
            points: [
              RatingTrendPoint(period: 'Mar', average: 4.8, count: 5),
            ],
          ),
        ),
      );

      expect(
        find.byKey(const Key('rating-trend-chart-insufficient')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('rating-trend-chart')), findsNothing);
      expect(find.text('Insufficient history for trend'), findsOneWidget);
    });

    testWidgets('renders insufficient history state when all counts are 0',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const RatingTrendChart(
            points: [
              RatingTrendPoint(period: 'Jan', average: 0.0, count: 0),
              RatingTrendPoint(period: 'Feb', average: 0.0, count: 0),
              RatingTrendPoint(period: 'Mar', average: 0.0, count: 0),
            ],
          ),
        ),
      );

      expect(
        find.byKey(const Key('rating-trend-chart-insufficient')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('rating-trend-chart')), findsNothing);
      expect(find.text('Insufficient history for trend'), findsOneWidget);
    });

    testWidgets('supports custom insufficientHistoryLabel', (tester) async {
      await tester.pumpWidget(
        _host(
          const RatingTrendChart(
            points: [],
            insufficientHistoryLabel: 'Not enough reviews yet',
          ),
        ),
      );

      expect(
        find.byKey(const Key('rating-trend-chart-insufficient')),
        findsOneWidget,
      );
      expect(find.text('Not enough reviews yet'), findsOneWidget);
      expect(find.text('Insufficient history for trend'), findsNothing);
    });

    testWidgets('renders chart when at least one point has count > 0 and length >= 2',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const RatingTrendChart(
            points: [
              RatingTrendPoint(period: 'Jan', average: 0.0, count: 0),
              RatingTrendPoint(period: 'Feb', average: 4.5, count: 3),
            ],
          ),
        ),
      );

      expect(find.byKey(const Key('rating-trend-chart')), findsOneWidget);
      expect(
        find.byKey(const Key('rating-trend-chart-insufficient')),
        findsNothing,
      );
      expect(find.text('0.0'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('supports RTL directionality', (tester) async {
      final points = [
        const RatingTrendPoint(period: 'Jan', average: 4.0, count: 5),
        const RatingTrendPoint(period: 'Feb', average: 4.5, count: 8),
        const RatingTrendPoint(period: 'Mar', average: 5.0, count: 12),
      ];

      // 1. Pump in LTR mode: Jan is on the left, Mar is on the right
      await tester.pumpWidget(
        _host(
          RatingTrendChart(points: points),
          textDirection: TextDirection.ltr,
        ),
      );
      await tester.pumpAndSettle();

      final janLtrX = tester.getCenter(find.text('Jan')).dx;
      final marLtrX = tester.getCenter(find.text('Mar')).dx;
      expect(janLtrX < marLtrX, isTrue,
          reason: 'In LTR, Jan should be to the left of Mar');

      // 2. Pump in RTL mode: Jan is on the right, Mar is on the left
      await tester.pumpWidget(
        _host(
          RatingTrendChart(points: points),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      final janRtlX = tester.getCenter(find.text('Jan')).dx;
      final marRtlX = tester.getCenter(find.text('Mar')).dx;
      expect(janRtlX > marRtlX, isTrue,
          reason: 'In RTL, Jan should be to the right of Mar');
    });

    testWidgets('clamps scores beyond 0.0 to 5.0 scale cleanly',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const RatingTrendChart(
            points: [
              RatingTrendPoint(period: 'Low', average: -2.0, count: 3),
              RatingTrendPoint(period: 'High', average: 7.5, count: 4),
            ],
          ),
        ),
      );

      expect(find.byKey(const Key('rating-trend-chart')), findsOneWidget);

      final lowBox = tester.widget<FractionallySizedBox>(
        find.descendant(
          of: find.byKey(const Key('rating-trend-bar-Low')),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(lowBox.heightFactor, equals(0.0));

      final highBox = tester.widget<FractionallySizedBox>(
        find.descendant(
          of: find.byKey(const Key('rating-trend-bar-High')),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(highBox.heightFactor, equals(1.0));
    });
  });
}
