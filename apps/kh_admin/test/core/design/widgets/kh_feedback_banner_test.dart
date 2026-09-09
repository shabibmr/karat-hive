import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/design/theme/kh_colors.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_feedback_banner.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    theme: buildKhAdminTheme(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 600, child: child),
      ),
    ),
  );
}

void main() {
  group('KhFeedbackBanner', () {
    testWidgets('renders the message', (tester) async {
      await tester.pumpWidget(
        wrap(const KhFeedbackBanner(message: 'Vendor suspended', isSuccess: true)),
      );

      expect(find.text('Vendor suspended'), findsOneWidget);
    });

    testWidgets('uses the success token and outline check icon', (tester) async {
      await tester.pumpWidget(
        wrap(const KhFeedbackBanner(message: 'Done', isSuccess: true)),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.check_circle_outline);
      expect(icon.color, KhColors.dark.success);

      final text = tester.widget<Text>(find.text('Done'));
      expect(text.style?.color, KhColors.dark.success);
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('uses the error token and outline error icon', (tester) async {
      await tester.pumpWidget(
        wrap(const KhFeedbackBanner(message: 'Failed', isSuccess: false)),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.error_outline);
      expect(icon.color, KhColors.dark.error);
    });

    testWidgets('hides the dismiss button when onDismiss is null', (tester) async {
      await tester.pumpWidget(
        wrap(const KhFeedbackBanner(message: 'No dismiss', isSuccess: true)),
      );

      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('shows and invokes the dismiss button when onDismiss is set',
        (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        wrap(KhFeedbackBanner(
          message: 'Dismiss me',
          isSuccess: false,
          onDismiss: () => dismissed = true,
        )),
      );

      expect(find.byType(IconButton), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      expect(dismissed, isTrue);
    });
  });
}
