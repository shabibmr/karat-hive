import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

GoldRateSnapshot _snap({
  bool available = true,
  bool stale = false,
  String rate = '300.00',
}) =>
    GoldRateSnapshot(
      available: available,
      stale: stale,
      rates: [
        GoldRateRow(karat: Karat.k22, ratePerGramAed: rate),
      ],
    );

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('en'),
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  group('GoldRateStrip (SH-DOM-01)', () {
    testWidgets('shows unavailable message when available:false', (tester) async {
      await tester.pumpWidget(
        _wrap(GoldRateStrip(rates: _snap(available: false))),
      );
      expect(find.textContaining('unavailable'), findsOneWidget);
      expect(find.textContaining('AED'), findsNothing);
    });

    testWidgets('shows stale chip when stale:true', (tester) async {
      await tester.pumpWidget(
        _wrap(GoldRateStrip(rates: _snap(stale: true))),
      );
      expect(find.text('Stale'), findsOneWidget);
      expect(find.textContaining('AED'), findsOneWidget);
    });

    testWidgets('shrinks when rates is null', (tester) async {
      await tester.pumpWidget(_wrap(const GoldRateStrip(rates: null)));
      expect(find.byType(GoldRateStrip), findsOneWidget);
      expect(find.textContaining('AED'), findsNothing);
    });
  });

  group('IndicativeValuation (SH-DOM-02)', () {
    testWidgets('renders estimate when rate available', (tester) async {
      await tester.pumpWidget(
        _wrap(
          IndicativeValuation(
            weightGrams: 10,
            karat: Karat.k22,
            rates: _snap(rate: '250.00'),
          ),
        ),
      );
      expect(find.textContaining('AED'), findsOneWidget);
      expect(find.textContaining('Estimate'), findsOneWidget);
    });

    testWidgets('suppresses when rate unavailable', (tester) async {
      await tester.pumpWidget(
        _wrap(
          IndicativeValuation(
            weightGrams: 10,
            karat: Karat.k22,
            rates: _snap(available: false),
          ),
        ),
      );
      expect(find.textContaining('AED'), findsNothing);
    });
  });

  group('WeightInput / MoneyInput / PurityPicker', () {
    testWidgets('WeightInput shows approximate checkbox', (tester) async {
      var approx = false;
      await tester.pumpWidget(
        _wrap(
          WeightInput(
            label: 'Weight',
            approximate: approx,
            onApproximateChanged: (v) => approx = v,
          ),
        ),
      );
      expect(find.text('Weight is approximate'), findsOneWidget);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(approx, isTrue);
    });

    testWidgets('PurityPicker lists default karats', (tester) async {
      Karat? selected;
      await tester.pumpWidget(
        _wrap(
          PurityPicker(
            label: 'Purity',
            value: Karat.k22,
            onChanged: (v) => selected = v,
          ),
        ),
      );
      expect(find.text('22K'), findsOneWidget);
      await tester.tap(find.byKey(const Key('kh-select-field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('24K').last);
      await tester.pumpAndSettle();
      expect(selected, Karat.k24);
    });

    testWidgets('MoneyInput renders AED unit', (tester) async {
      await tester.pumpWidget(
        _wrap(const MoneyInput(label: 'Budget')),
      );
      expect(find.text('AED'), findsOneWidget);
    });
  });

  group('EntityReferenceChip (SH-DOM-09)', () {
    testWidgets('copies reference to clipboard', (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );

      await tester.pumpWidget(
        _wrap(const EntityReferenceChip(reference: 'KH-RQ-2026-000001')),
      );
      await tester.tap(find.byKey(const Key('entity-reference-chip')));
      await tester.pump();

      expect(
        calls.any(
          (c) =>
              c.method == 'Clipboard.setData' &&
              (c.arguments as Map)['text'] == 'KH-RQ-2026-000001',
        ),
        isTrue,
      );
    });
  });
}

