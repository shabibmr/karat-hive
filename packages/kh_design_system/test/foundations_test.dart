import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: khTheme(),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('KhNumericField shows unit suffix and number keyboard (SH-FND-03)',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const KhNumericField(
          label: 'Weight',
          unit: 'g',
          decimalPlaces: 2,
        ),
      ),
    );

    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('g'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(
      field.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
  });

  testWidgets('KhNumericField reports parsed value and range error (SH-FND-03)',
      (tester) async {
    double? parsed;
    await tester.pumpWidget(
      _wrap(
        KhNumericField(
          label: 'Budget',
          unit: 'AED',
          min: 10,
          max: 100,
          rangeErrorText: 'Out of range',
          onChanged: (value) => parsed = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '5');
    await tester.pump();
    expect(parsed, 5);
    expect(find.text('Out of range'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '40');
    await tester.pump();
    expect(parsed, 40);
    expect(find.text('Out of range'), findsNothing);
  });

  testWidgets('KhSelectField selects a filtered option (SH-FND-04)',
      (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return KhSelectField<String>(
                label: 'Purity',
                value: selected,
                emptyLabel: 'Choose',
                searchHint: 'Search',
                options: const [
                  KhSelectOption(value: '24K', label: '24 karat'),
                  KhSelectOption(value: '22K', label: '22 karat'),
                  KhSelectOption(value: '18K', label: '18 karat'),
                ],
                onChanged: (value) => setState(() => selected = value),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Choose'), findsOneWidget);
    await tester.tap(find.byKey(const Key('kh-select-field')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('kh-select-search')), '18');
    await tester.pumpAndSettle();
    expect(find.text('24 karat'), findsNothing);
    expect(find.text('18 karat'), findsOneWidget);

    await tester.tap(find.text('18 karat'));
    await tester.pumpAndSettle();
    expect(selected, '18K');
    expect(find.text('18 karat'), findsOneWidget);
  });

  testWidgets('KhConfirmDialog pops true on confirm and uses KhButton (SH-FND-15)',
      (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: KhButton(
                label: 'Open',
                onPressed: () async {
                  result = await showKhConfirmDialog(
                    context,
                    title: 'Mark as Interested',
                    body: 'This cannot be undone.',
                    confirmLabel: 'Confirm',
                    cancelLabel: 'Cancel',
                    destructive: true,
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Mark as Interested'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
    expect(find.byType(KhButton), findsWidgets);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('KhBadge hides zero and caps high counts (SH-FND-18)',
      (tester) async {
    await tester.pumpWidget(_wrap(const KhBadge(count: 0)));
    expect(find.byKey(const Key('kh-badge')), findsNothing);

    await tester.pumpWidget(_wrap(const KhBadge(count: 3)));
    expect(find.text('3'), findsOneWidget);

    await tester.pumpWidget(_wrap(const KhBadge(count: 120)));
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('KhStatusChip is domain-free and maps tones to tokens (SH-FND-19)',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const KhStatusChip(label: 'LIVE', tone: KhStatusTone.success),
      ),
    );

    expect(find.text('LIVE'), findsOneWidget);
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('kh-status-chip')),
        matching: find.byType(Material),
      ).first,
    );
    expect(material.color, KhTokens.light.success);
  });
}
