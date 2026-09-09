import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

Review _review({
  String? authorDisplayName = 'Fatima M.',
  int rating = 5,
  String? comment = 'Exceptional craftsmanship.',
}) =>
    Review(
      id: 'rev-1',
      connectionId: 'conn-1',
      authorType: PartyRole.customer,
      rating: rating,
      state: ReviewState.published,
      editableUntil: DateTime.utc(2026, 8, 17),
      createdAt: DateTime.utc(2026, 8, 10),
      publishedAt: DateTime.utc(2026, 8, 10),
      comment: comment,
      authorDisplayName: authorDisplayName,
    );

void main() {
  testWidgets('SH-ID-06 renders author, stars, date, and comment',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const ReviewListItem(
          abbreviatedAuthor: 'Fatima M.',
          rating: 5,
          dateLabel: '10 Aug 2026',
          contextLabel: '22K Gold Necklace',
          comment:
              'Exceptional craftsmanship and smooth transaction. Highly recommended Deira jeweller.',
        ),
      ),
    );

    expect(find.byKey(const Key('review-list-item')), findsOneWidget);
    expect(find.byKey(const Key('review-list-item-author')), findsOneWidget);
    expect(find.text('Fatima M.'), findsOneWidget);
    expect(find.byKey(const Key('review-list-item-stars')), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    expect(
      find.text('10 Aug 2026 · 22K Gold Necklace'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Exceptional craftsmanship and smooth transaction. Highly recommended Deira jeweller.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('SH-ID-06 omits blank comment and optional context',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const ReviewListItem(
          abbreviatedAuthor: 'Rashed K.',
          rating: 4,
          dateLabel: '02 Aug 2026',
          comment: '   ',
        ),
      ),
    );

    expect(find.text('Rashed K.'), findsOneWidget);
    expect(find.text('02 Aug 2026'), findsOneWidget);
    expect(find.byKey(const Key('review-list-item-comment')), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
  });

  testWidgets('SH-ID-06 onTap fires', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        ReviewListItem(
          abbreviatedAuthor: 'Ahmed K.',
          rating: 3,
          dateLabel: '01 Jul 2026',
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('review-list-item')));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('SH-ID-06 fromReview maps domain fields', (tester) async {
    await tester.pumpWidget(
      _host(
        ReviewListItem.fromReview(
          _review(),
          dateLabel: '10 Aug 2026',
          contextLabel: 'Sell Old Gold Scrap',
        ),
      ),
    );

    expect(find.text('Fatima M.'), findsOneWidget);
    expect(find.text('10 Aug 2026 · Sell Old Gold Scrap'), findsOneWidget);
    expect(find.text('Exceptional craftsmanship.'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
  });

  testWidgets('SH-ID-06 fromExcerpt maps abbreviatedName', (tester) async {
    await tester.pumpWidget(
      _host(
        ReviewListItem.fromExcerpt(
          const ReviewExcerpt(
            abbreviatedName: 'Ahmed K.',
            rating: 4,
            comment: 'Fair pricing.',
          ),
          dateLabel: '15 Jul 2026',
        ),
      ),
    );

    expect(find.text('Ahmed K.'), findsOneWidget);
    expect(find.text('15 Jul 2026'), findsOneWidget);
    expect(find.text('Fair pricing.'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
  });

  testWidgets('SH-ID-06 fromReview falls back when author missing',
      (tester) async {
    await tester.pumpWidget(
      _host(
        ReviewListItem.fromReview(
          _review(authorDisplayName: null, comment: null),
          dateLabel: '10 Aug 2026',
        ),
      ),
    );

    expect(find.text('—'), findsOneWidget);
    expect(find.byKey(const Key('review-list-item-comment')), findsNothing);
  });
}
