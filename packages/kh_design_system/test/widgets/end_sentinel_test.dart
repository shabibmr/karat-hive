import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: const [KhTokens.light],
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('KhEndSentinel / EndSentinel (SH-FND-25)', () {
    testWidgets('renders end message and divider when hasMore is false with items',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const KhEndSentinel(
            hasMore: false,
            itemCount: 15,
            endMessage: "You've reached the end of matches",
          ),
        ),
      );

      expect(find.byKey(const Key('end-sentinel-end')), findsOneWidget);
      expect(find.text("You've reached the end of matches"), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.byKey(const Key('end-sentinel-loading')), findsNothing);
      expect(find.byKey(const Key('end-sentinel-error')), findsNothing);
    });

    testWidgets('gracefully hides end message on empty page (itemCount == 0)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const KhEndSentinel(
            hasMore: false,
            itemCount: 0,
            endMessage: "You've reached the end",
          ),
        ),
      );

      expect(find.byKey(const Key('end-sentinel-empty')), findsOneWidget);
      expect(find.byKey(const Key('end-sentinel-end')), findsNothing);
      expect(find.text("You've reached the end"), findsNothing);
    });

    testWidgets('renders loading spinner when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const KhEndSentinel(
            hasMore: true,
            isLoading: true,
          ),
        ),
      );

      expect(find.byKey(const Key('end-sentinel-loading')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('end-sentinel-end')), findsNothing);
    });

    testWidgets('renders error view with retry button on error',
        (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        createTestApp(
          KhEndSentinel(
            hasMore: true,
            error: 'Connection dropped. Please retry.',
            retryLabel: 'Try again',
            onRetry: () => retryCalled = true,
          ),
        ),
      );

      expect(find.byKey(const Key('end-sentinel-error')), findsOneWidget);
      expect(find.text('Connection dropped. Please retry.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      expect(retryCalled, isTrue);
    });

    testWidgets('fires onVisible callback when scrolled to trigger with hasMore=true',
        (tester) async {
      var triggerCalled = false;

      await tester.pumpWidget(
        createTestApp(
          KhEndSentinel(
            hasMore: true,
            isLoading: false,
            onVisible: () => triggerCalled = true,
          ),
        ),
      );

      // Trigger post-frame callback
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('end-sentinel-trigger')), findsOneWidget);
      expect(triggerCalled, isTrue);
    });

    testWidgets('respects showDivider: false', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const KhEndSentinel(
            hasMore: false,
            itemCount: 5,
            showDivider: false,
          ),
        ),
      );

      expect(find.byKey(const Key('end-sentinel-end')), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
    });
  });
}
