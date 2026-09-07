import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/design/theme/kh_colors.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    theme: buildKhAdminTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('KhStatusChip', () {
    testWidgets('renders its label verbatim so state is never colour-only',
        (tester) async {
      await tester.pumpWidget(
        wrap(const KhStatusChip(label: 'Inactive', tone: KhStatusTone.error)),
      );

      expect(find.text('Inactive'), findsOneWidget);
    });

    testWidgets('tints the label with the tone colour', (tester) async {
      await tester.pumpWidget(
        wrap(const KhStatusChip(label: 'PENDING', tone: KhStatusTone.pending)),
      );

      final text = tester.widget<Text>(find.text('PENDING'));
      expect(text.style?.color, KhColors.dark.warning);
    });
  });

  group('KhMetricCard', () {
    testWidgets('shows value, label and link, and fires onTap', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrap(
          KhMetricCard(
            value: '1,420',
            label: 'Customers',
            linkText: 'Customer List →',
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.text('1,420'), findsOneWidget);
      expect(find.text('CUSTOMERS'), findsOneWidget);
      expect(find.text('Customer List →'), findsOneWidget);

      await tester.tap(find.byType(KhMetricCard));
      expect(taps, 1);
    });
  });

  group('KhScreenHeader', () {
    testWidgets('upper-cases the eyebrow and keeps heading casing',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const KhScreenHeader(
            eyebrow: 'Taxonomy Config',
            heading: 'Product Categories',
            supportingText: 'Two-level taxonomy.',
          ),
        ),
      );

      expect(find.text('TAXONOMY CONFIG'), findsOneWidget);
      expect(find.text('Product Categories'), findsOneWidget);
      expect(find.text('Two-level taxonomy.'), findsOneWidget);
    });
  });

  group('KhDataTable', () {
    testWidgets('renders upper-cased headers and every row cell',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 800,
            child: KhDataTable(
              columns: [KhTableColumn('Queue Item'), KhTableColumn('Status')],
              rows: [
                KhTableRow(
                  key: Key('row-a'),
                  cells: [Text('Al Noor Jewellery LLC'), Text('PENDING')],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('QUEUE ITEM'), findsOneWidget);
      expect(find.text('STATUS'), findsOneWidget);
      expect(find.byKey(const Key('row-a')), findsOneWidget);
      expect(find.text('Al Noor Jewellery LLC'), findsOneWidget);
    });
  });
}
