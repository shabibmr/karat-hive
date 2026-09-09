import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/error/error_retry_widget.dart';

void main() {
  group('ErrorRetryWidget', () {
    testWidgets('renders friendly message and Retry button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorRetryWidget(),
        ),
      );

      expect(find.text('An unexpected error occurred.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('triggers onRetry callback when Retry button is pressed', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorRetryWidget(
            onRetry: () {
              retryCalled = true;
            },
          ),
        ),
      );

      expect(retryCalled, isFalse);
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('renders custom message and details when provided', (tester) async {
      final details = FlutterErrorDetails(
        exception: Exception('Widget failed to mount'),
        stack: StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorRetryWidget(
            message: 'Custom failure message',
            details: details,
          ),
        ),
      );

      expect(find.text('Custom failure message'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
