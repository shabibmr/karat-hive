import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/design/theme/kh_colors.dart';
import 'package:kh_admin/core/design/theme/kh_shapes.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_detail_card.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    theme: buildKhAdminTheme(),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('KhDetailCard', () {
    testWidgets('renders child without title or titleTrailing', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailCard(
            child: Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      // No header Row should exist when neither title nor titleTrailing is provided
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('renders title and child', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailCard(
            title: 'Specifications',
            child: Text('Card Body'),
          ),
        ),
      );

      expect(find.text('Specifications'), findsOneWidget);
      expect(find.text('Card Body'), findsOneWidget);
    });

    testWidgets('renders title, titleTrailing, and child', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailCard(
            title: 'Vendor Overview',
            titleTrailing: Icon(Icons.verified, key: Key('verified-icon')),
            child: Text('Vendor details here'),
          ),
        ),
      );

      expect(find.text('Vendor Overview'), findsOneWidget);
      expect(find.byKey(const Key('verified-icon')), findsOneWidget);
      expect(find.text('Vendor details here'), findsOneWidget);
    });

    testWidgets('renders titleTrailing when title is null', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailCard(
            titleTrailing: Text('Action Button'),
            child: Text('Child content'),
          ),
        ),
      );

      expect(find.text('Action Button'), findsOneWidget);
      expect(find.text('Child content'), findsOneWidget);
    });

    testWidgets('applies Karat Hive design tokens for decoration and default padding',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailCard(
            child: Text('Token Test'),
          ),
        ),
      );

      final containerFinder = find.ancestor(
        of: find.text('Token Test'),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      expect(container.padding, const EdgeInsets.all(16.0));

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.color, KhColors.dark.surface);
      expect(decoration.borderRadius, KhShapes.standard.roundedLg);

      final border = decoration.border as Border?;
      expect(border, isNotNull);
      expect(border!.top.color, KhColors.dark.border);
      expect(border.top.width, KhShapes.standard.cardBorderWidth);
    });

    testWidgets('respects custom padding and margin', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailCard(
            padding: EdgeInsets.all(24.0),
            margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text('Custom Padding & Margin'),
          ),
        ),
      );

      final containerFinder = find.ancestor(
        of: find.text('Custom Padding & Margin'),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containerFinder);

      expect(container.padding, const EdgeInsets.all(24.0));
      expect(
        container.margin,
        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      );
    });

    testWidgets('respects custom color, borderColor, and borderRadius overrides',
        (tester) async {
      const customColor = Color(0xFF123456);
      const customBorderColor = Color(0xFF654321);
      final customRadius = BorderRadius.circular(4.0);

      await tester.pumpWidget(
        wrap(
          KhDetailCard(
            color: customColor,
            borderColor: customBorderColor,
            borderRadius: customRadius,
            child: const Text('Override Test'),
          ),
        ),
      );

      final containerFinder = find.ancestor(
        of: find.text('Override Test'),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration!.color, customColor);
      expect(decoration.borderRadius, customRadius);
      final border = decoration.border as Border?;
      expect(border!.top.color, customBorderColor);
    });
  });
}
