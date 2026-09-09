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

  testWidgets('KhSegmentedTabs reports selection (SH-FND-26)', (tester) async {
    var selected = 'PENDING';
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return KhSegmentedTabs(
              selectedId: selected,
              onSelected: (id) => setState(() => selected = id),
              tabs: const [
                KhSegmentedTab(id: 'PENDING', label: 'Pending', count: 2),
                KhSegmentedTab(id: 'ACCEPTED', label: 'Accepted'),
                KhSegmentedTab(id: 'CLOSED', label: 'Closed'),
              ],
            );
          },
        ),
      ),
    );

    expect(find.byKey(const Key('kh-segmented-tab-PENDING')), findsOneWidget);
    await tester.tap(find.text('Accepted'));
    await tester.pump();
    expect(selected, 'ACCEPTED');
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

  testWidgets('KhToast maps tones to tokens (SH-FND-17)', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const KhToast(message: 'Saved', tone: KhToastTone.success),
      ),
    );
    expect(find.byKey(const Key('kh-toast')), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    final material = tester.widget<Material>(find.byKey(const Key('kh-toast')));
    expect(material.color, KhTokens.light.success);

    await tester.pumpWidget(
      _wrap(
        const KhToast(message: 'Failed', tone: KhToastTone.error),
      ),
    );
    expect(
      tester.widget<Material>(find.byKey(const Key('kh-toast'))).color,
      KhTokens.light.danger,
    );

    await tester.pumpWidget(
      _wrap(
        const KhToast(message: 'Note', tone: KhToastTone.info),
      ),
    );
    expect(
      tester.widget<Material>(find.byKey(const Key('kh-toast'))).color,
      KhTokens.light.info,
    );
  });

  testWidgets('showKhToast presents a floating snackbar (SH-FND-17)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: KhButton(
                label: 'Notify',
                onPressed: () => showKhToast(
                  context,
                  message: 'Offer submitted',
                  tone: KhToastTone.success,
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Notify'));
    await tester.pump();
    expect(find.text('Offer submitted'), findsOneWidget);
    expect(find.byKey(const Key('kh-toast')), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.behavior, SnackBarBehavior.floating);
  });

  testWidgets('KhToggle reports value changes (SH-FND-06)', (tester) async {
    var value = false;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return KhToggle(
              label: 'Away mode',
              value: value,
              onChanged: (next) => setState(() => value = next),
            );
          },
        ),
      ),
    );

    expect(find.text('Away mode'), findsOneWidget);
    expect(find.byKey(const Key('kh-toggle')), findsOneWidget);
    expect(tester.widget<Switch>(find.byKey(const Key('kh-toggle'))).value, isFalse);

    await tester.tap(find.byKey(const Key('kh-toggle')));
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(tester.widget<Switch>(find.byKey(const Key('kh-toggle'))).value, isTrue);
  });

  testWidgets('KhToggle ignores taps when disabled (SH-FND-06)', (tester) async {
    var value = true;
    await tester.pumpWidget(
      _wrap(
        KhToggle(
          label: 'Flexible budget',
          value: value,
          enabled: false,
          onChanged: (next) => value = next,
        ),
      ),
    );

    final switchWidget =
        tester.widget<Switch>(find.byKey(const Key('kh-toggle')));
    expect(switchWidget.onChanged, isNull);

    await tester.tap(find.byKey(const Key('kh-toggle')));
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets('KhDateTimeField picks date only (SH-FND-09)', (tester) async {
    DateTime? selected;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return KhDateTimeField(
              label: 'Licence expiry',
              value: selected,
              emptyLabel: 'Choose date',
              mode: KhDateTimeMode.dateOnly,
              pickDate: (
                context, {
                required initialDate,
                required firstDate,
                required lastDate,
              }) async =>
                  DateTime(2026, 9, 15),
              onChanged: (value) => setState(() => selected = value),
            );
          },
        ),
      ),
    );

    expect(find.text('Choose date'), findsOneWidget);
    await tester.tap(find.byKey(const Key('kh-date-time-field')));
    await tester.pumpAndSettle();

    expect(selected, DateTime(2026, 9, 15));
    expect(find.textContaining('Sep 15, 2026'), findsOneWidget);
  });

  testWidgets('KhDateTimeField picks schedule date+time (SH-FND-09)',
      (tester) async {
    DateTime? selected;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return KhDateTimeField(
              label: 'Schedule',
              value: selected,
              emptyLabel: 'Choose schedule',
              mode: KhDateTimeMode.dateTime,
              pickDate: (
                context, {
                required initialDate,
                required firstDate,
                required lastDate,
              }) async =>
                  DateTime(2026, 9, 20),
              pickTime: (context, {required initialTime}) async =>
                  const TimeOfDay(hour: 14, minute: 30),
              onChanged: (value) => setState(() => selected = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('kh-date-time-field')));
    await tester.pumpAndSettle();

    expect(selected, DateTime(2026, 9, 20, 14, 30));
    expect(find.textContaining('14:30'), findsOneWidget);
  });

  testWidgets('KhDateRangePicker applies presets (SH-FND-10)', (tester) async {
    KhDateRangeSelection? selection;
    final clock = DateTime(2026, 9, 8);

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return KhDateRangePicker(
              label: 'Period',
              now: clock,
              range: selection?.range,
              preset: selection?.preset,
              onChanged: (next) => setState(() => selection = next),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('kh-date-range-preset-last7')));
    await tester.pump();

    expect(selection?.preset, KhDateRangePreset.last7);
    expect(selection?.range.start, DateTime(2026, 9, 2));
    expect(selection?.range.end, DateTime(2026, 9, 8));
    expect(find.byKey(const Key('kh-date-range-summary')), findsOneWidget);
  });

  testWidgets('KhDateRangePicker custom opens range picker (SH-FND-10)',
      (tester) async {
    KhDateRangeSelection? selection;
    final clock = DateTime(2026, 9, 8);

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return KhDateRangePicker(
              now: clock,
              range: selection?.range,
              preset: selection?.preset,
              pickRange: (
                context, {
                required initialDateRange,
                required firstDate,
                required lastDate,
              }) async =>
                  DateTimeRange(
                    start: DateTime(2026, 8, 1),
                    end: DateTime(2026, 8, 31),
                  ),
              onChanged: (next) => setState(() => selection = next),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('kh-date-range-preset-custom')));
    await tester.pumpAndSettle();

    expect(selection?.preset, KhDateRangePreset.custom);
    expect(selection?.range.start, DateTime(2026, 8, 1));
    expect(selection?.range.end, DateTime(2026, 8, 31));
  });

  testWidgets('KhExternalLinkRow invokes onTap (SH-FND-23)', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        KhExternalLinkRow(
          label: 'Terms of Service',
          onTap: () => taps++,
        ),
      ),
    );

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.byKey(const Key('kh-external-link-row')), findsOneWidget);

    await tester.tap(find.byKey(const Key('kh-external-link-row')));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('KhAppVersionFooter shows label and version (SH-FND-24)',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const KhAppVersionFooter(version: '1.0.0 (Build 2026.08)'),
      ),
    );

    expect(find.text('App version'), findsOneWidget);
    expect(find.byKey(const Key('kh-app-version-footer')), findsOneWidget);
    expect(find.byKey(const Key('kh-app-version-value')), findsOneWidget);
    expect(find.text('1.0.0 (Build 2026.08)'), findsOneWidget);
  });
}
