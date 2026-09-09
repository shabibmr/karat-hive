import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SH-ID-04 renders five stars unset', (tester) async {
    await tester.pumpWidget(
      _host(const StarRatingInput(value: null)),
    );

    expect(find.byKey(const Key('star-rating-input')), findsOneWidget);
    for (var i = 1; i <= 5; i++) {
      expect(find.byKey(Key('star-rating-input-star-$i')), findsOneWidget);
    }
    expect(
      find.byIcon(Icons.star_outline_rounded),
      findsNWidgets(5),
    );
  });

  testWidgets('SH-ID-04 fills stars up to value', (tester) async {
    await tester.pumpWidget(
      _host(const StarRatingInput(value: 3)),
    );

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
  });

  testWidgets('SH-ID-04 onChanged fires with tapped star', (tester) async {
    int? selected;
    await tester.pumpWidget(
      _host(
        StarRatingInput(
          value: selected,
          onChanged: (v) => selected = v,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('star-rating-input-star-4')));
    await tester.pump();
    expect(selected, 4);
  });

  testWidgets('SH-ID-04 disabled ignores taps', (tester) async {
    int? selected = 2;
    await tester.pumpWidget(
      _host(
        StarRatingInput(
          value: selected,
          enabled: false,
          onChanged: (v) => selected = v,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('star-rating-input-star-5')));
    await tester.pump();
    expect(selected, 2);
  });

  testWidgets('SH-ID-04 shows error and hides helper', (tester) async {
    await tester.pumpWidget(
      _host(
        const StarRatingInput(
          value: null,
          label: 'Overall Rating',
          helperText: 'Tap to rate',
          errorText: 'Rating is required',
        ),
      ),
    );

    expect(find.byKey(const Key('star-rating-input-label')), findsOneWidget);
    expect(find.text('Overall Rating'), findsOneWidget);
    expect(find.byKey(const Key('star-rating-input-error')), findsOneWidget);
    expect(find.text('Rating is required'), findsOneWidget);
    expect(find.byKey(const Key('star-rating-input-helper')), findsNothing);
  });
}
