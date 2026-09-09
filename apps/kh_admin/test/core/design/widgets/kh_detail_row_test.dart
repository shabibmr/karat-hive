import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/design/theme/kh_colors.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_detail_row.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    theme: buildKhAdminTheme(),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('KhDetailRow', () {
    testWidgets('renders label and value properly', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailRow(
            label: 'Customer Name',
            value: 'Fatima Al-Zahra',
          ),
        ),
      );

      expect(find.text('Customer Name'), findsOneWidget);
      expect(find.text('Fatima Al-Zahra'), findsOneWidget);

      final labelText = tester.widget<Text>(find.text('Customer Name'));
      expect(labelText.style?.color, KhColors.dark.textSecondary);

      final valueText = tester.widget<Text>(find.text('Fatima Al-Zahra'));
      expect(valueText.style?.color, KhColors.dark.textPrimary);
    });

    testWidgets('renders valueWidget when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailRow(
            label: 'Account Status',
            valueWidget: KeyedSubtree(
              key: Key('custom-status-badge'),
              child: Text('Active VIP'),
            ),
          ),
        ),
      );

      expect(find.text('Account Status'), findsOneWidget);
      expect(find.byKey(const Key('custom-status-badge')), findsOneWidget);
      expect(find.text('Active VIP'), findsOneWidget);
    });

    testWidgets('valueWidget overrides value string if both are passed',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailRow(
            label: 'Reference',
            value: 'STRING_VALUE',
            valueWidget: Text('WIDGET_VALUE'),
          ),
        ),
      );

      expect(find.text('WIDGET_VALUE'), findsOneWidget);
      expect(find.text('STRING_VALUE'), findsNothing);
    });

    testWidgets('renders labelWidget when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailRow(
            labelWidget: Text(
              'Custom Label Widget',
              key: Key('custom-label-key'),
            ),
            value: 'Value Text',
          ),
        ),
      );

      expect(find.byKey(const Key('custom-label-key')), findsOneWidget);
      expect(find.text('Custom Label Widget'), findsOneWidget);
      expect(find.text('Value Text'), findsOneWidget);
    });

    testWidgets('applies default padding of 6.0 vertical', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailRow(
            label: 'Label',
            value: 'Value',
          ),
        ),
      );

      final paddingWidget = tester.widget<Padding>(
        find.descendant(
          of: find.byType(KhDetailRow),
          matching: find.byType(Padding),
        ),
      );

      expect(paddingWidget.padding, const EdgeInsets.symmetric(vertical: 6.0));
    });

    testWidgets('applies custom padding when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailRow(
            label: 'Label',
            value: 'Value',
            padding: EdgeInsets.all(12.0),
          ),
        ),
      );

      final paddingWidget = tester.widget<Padding>(
        find.descendant(
          of: find.byType(KhDetailRow),
          matching: find.byType(Padding),
        ),
      );

      expect(paddingWidget.padding, const EdgeInsets.all(12.0));
    });

    testWidgets('applies custom labelStyle and valueStyle overrides',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailRow(
            label: 'Total AED',
            value: '15,200.00',
            labelStyle: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            valueStyle: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Total AED'));
      expect(labelText.style?.fontSize, 14.0);
      expect(labelText.style?.fontWeight, FontWeight.bold);

      final valueText = tester.widget<Text>(find.text('15,200.00'));
      expect(valueText.style?.color, Colors.amber);
      expect(valueText.style?.fontWeight, FontWeight.w900);
    });

    testWidgets('allocates specified labelWidth', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailRow(
            label: 'Category',
            value: 'Gold Jewellery',
            labelWidth: 200.0,
          ),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(KhDetailRow),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBoxes.any((box) => box.width == 200.0), isTrue);
    });

    testWidgets('gracefully renders empty value when value and valueWidget are null',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhDetailRow(
            label: 'Optional Note',
          ),
        ),
      );

      expect(find.text('Optional Note'), findsOneWidget);
    });
  });
}
