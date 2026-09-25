import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('en'),
      theme: khTheme(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

RequestForCustomer _sampleOwnerRequest({
  String id = 'req-1',
  String? reference = 'KH-RQ-2026-000001',
  RequestState state = RequestState.published,
  Direction direction = Direction.buy,
  int offerCount = 3,
  int? unreadOfferCount = 1,
  String? weightGrams = '25.50',
  bool weightIsApproximate = true,
  String? budgetMin = '5000',
  String? budgetMax = '8000',
  bool budgetIsFlexible = true,
  DateTime? expiresAt,
}) =>
    RequestForCustomer(
      id: id,
      reference: reference,
      requestType: RequestType.findOrnament,
      direction: direction,
      state: state,
      category: const CategorySummary(
        id: 'cat-1',
        nameEn: 'Bangles',
        nameAr: 'أساور',
      ),
      region: const RegionSummary(
        id: 'reg-1',
        nameEn: 'Dubai',
        nameAr: 'دبي',
      ),
      weightGrams: weightGrams,
      weightIsApproximate: weightIsApproximate,
      purityKarat: Karat.k22,
      ornamentType: OrnamentType.bangle,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      budgetIsFlexible: budgetIsFlexible,
      offerCount: offerCount,
      unreadOfferCount: unreadOfferCount,
      media: const [],
      createdAt: DateTime.utc(2026, 9, 1),
      updatedAt: DateTime.utc(2026, 9, 1),
      publishedAt: DateTime.utc(2026, 9, 1, 10, 0),
      expiresAt: expiresAt ?? DateTime.utc(2026, 9, 3, 10, 0),
    );

void main() {
  group('OwnerRequestCard / RequestSummaryCard (SH-REQ-01)', () {
    testWidgets('renders owner request details without vendor identity', (tester) async {
      var tapped = false;
      final req = _sampleOwnerRequest();

      await tester.pumpWidget(
        _wrap(
          RequestSummaryCard.owner(
            request: req,
            onTap: () => tapped = true,
          ),
        ),
      );

      // Specs title, state, category, direction, purity
      expect(find.text('Bangle 25.5gm 22K'), findsOneWidget);
      expect(find.text('PUBLISHED'), findsOneWidget);
      expect(find.text('BUY'), findsOneWidget);
      expect(find.text('Bangles'), findsOneWidget);
      expect(find.text('22K'), findsOneWidget);

      // Verify weight with approximate marker
      expect(find.text('25.50g (~)'), findsOneWidget);

      // Verify offer count and unread badge
      expect(find.text('3 Offers'), findsOneWidget);
      expect(find.byKey(const Key('unread-offers-badge')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Verify tap handler
      await tester.tap(find.byKey(const Key('owner-request-card')));
      expect(tapped, isTrue);
    });

    testWidgets('omits unread badge when unreadOfferCount is null or 0', (tester) async {
      final req = _sampleOwnerRequest(unreadOfferCount: 0);

      await tester.pumpWidget(
        _wrap(OwnerRequestCard(request: req)),
      );

      expect(find.byKey(const Key('unread-offers-badge')), findsNothing);
    });
  });

  group('RequestDirectionControl (SH-REQ-03)', () {
    testWidgets('renders fixed read-only direction', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const RequestDirectionControl(
            value: Direction.buy,
            fixed: true,
          ),
        ),
      );
      expect(find.text('BUY'), findsOneWidget);
      expect(find.byType(RadioListTile<Direction>), findsNothing);
    });

    testWidgets('allows selecting BUY / SELL when not fixed', (tester) async {
      Direction? selected = Direction.buy;
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => RequestDirectionControl(
              value: selected,
              fixed: false,
              onChanged: (d) => setState(() => selected = d),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('direction-buy')), findsOneWidget);
      expect(find.byKey(const Key('direction-sell')), findsOneWidget);

      await tester.tap(find.byKey(const Key('direction-sell')));
      await tester.pump();
      expect(selected, Direction.sell);
    });
  });

  group('BudgetEditor (SH-REQ-04)', () {
    testWidgets('switches between maxOnly and range modes and edits budget', (tester) async {
      var mode = BudgetMode.maxOnly;
      String? minVal;
      String? maxVal;
      var flex = false;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => BudgetEditor(
              mode: mode,
              budgetMin: minVal,
              budgetMax: maxVal,
              budgetIsFlexible: flex,
              onModeChanged: (m) => setState(() => mode = m),
              onMinChanged: (v) => minVal = v,
              onMaxChanged: (v) => maxVal = v,
              onFlexibleChanged: (f) => setState(() => flex = f),
            ),
          ),
        ),
      );

      // maxOnly mode: min field not visible
      expect(find.byKey(const Key('budget-min-field')), findsNothing);
      expect(find.byKey(const Key('budget-max-field')), findsOneWidget);

      // Switch to range mode
      await tester.tap(find.byKey(const Key('budget-mode-range')));
      await tester.pump();

      expect(mode, BudgetMode.range);
      expect(find.byKey(const Key('budget-min-field')), findsOneWidget);

      // Toggle flexible switch
      await tester.tap(find.byKey(const Key('budget-flexible-switch')));
      await tester.pump();
      expect(flex, isTrue);
    });
  });

  group('OrnamentTypePicker (SH-REQ-05)', () {
    testWidgets('lists ornament types and selects one', (tester) async {
      OrnamentType? selected;
      await tester.pumpWidget(
        _wrap(
          OrnamentTypePicker(
            label: 'Ornament type',
            value: OrnamentType.ring,
            onChanged: (t) => selected = t,
          ),
        ),
      );

      expect(find.text('Ring'), findsOneWidget);
      await tester.tap(find.byKey(const Key('kh-select-field')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Necklace').last);
      await tester.pumpAndSettle();
      expect(selected, OrnamentType.necklace);
    });
  });

  group('CoinSpecInput (SH-REQ-06)', () {
    testWidgets('computes total weight from denomination and quantity', (tester) async {
      double? denom = 5.0;
      int? qty = 4;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => CoinSpecInput(
              denominationGrams: denom,
              quantity: qty,
              onDenominationChanged: (d) => setState(() => denom = d),
              onQuantityChanged: (q) => setState(() => qty = q),
            ),
          ),
        ),
      );

      // 5.0g * 4 = 20.00 g
      expect(find.textContaining('20.00 g'), findsOneWidget);
    });
  });

  group('BullionSpecInput (SH-REQ-07)', () {
    testWidgets('computes total weight and indicative value, flags below-minimum error', (tester) async {
      // 1g bar * 1 = 1g @ 300 AED/g = 300 AED < 500 AED minimum threshold
      await tester.pumpWidget(
        _wrap(
          const BullionSpecInput(
            barWeightGrams: 1.0,
            quantity: 1,
            ratePerGramAed: 300.0,
            minThresholdAed: 500.0,
          ),
        ),
      );

      // Total weight: 1.00 g
      expect(find.textContaining('1.00 g'), findsOneWidget);
      // Below-minimum error
      expect(find.byKey(const Key('bullion-minimum-error')), findsOneWidget);
      expect(find.textContaining('BR-010'), findsOneWidget);
    });

    testWidgets('passes without error when indicative value >= AED 500', (tester) async {
      // 10g bar * 1 = 10g @ 300 AED/g = 3000 AED >= 500 AED
      await tester.pumpWidget(
        _wrap(
          const BullionSpecInput(
            barWeightGrams: 10.0,
            quantity: 1,
            ratePerGramAed: 300.0,
            minThresholdAed: 500.0,
          ),
        ),
      );

      expect(find.textContaining('10.00 g'), findsOneWidget);
      expect(find.byKey(const Key('bullion-minimum-error')), findsNothing);
    });
  });
}
