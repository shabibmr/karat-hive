import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

OfferForVendor _offer({
  OfferState state = OfferState.accepted,
  bool awardedElsewhere = false,
}) {
  return OfferForVendor(
    id: 'off-1',
    requestId: 'req-1',
    state: state,
    terms: const OfferTerms(
      offeredPrice: '5500.00',
      validityHours: 24,
    ),
    submittedAt: DateTime.utc(2026, 9, 1, 11),
    expiresAt: DateTime.utc(2026, 9, 2, 11),
    revisionCount: 0,
    awardedElsewhere: awardedElsewhere,
    requestSummary: const OfferRequestSummary(
      id: 'req-1',
      reference: 'KH-RQ-24A1',
      requestType: RequestType.findOrnament,
      direction: Direction.buy,
      customerLabel: 'Customer · Deira',
      categoryName: 'Bangles',
    ),
  );
}

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SH-OFF-01 shows price, masked customer, no identity fields',
      (tester) async {
    await tester.pumpWidget(_host(OfferSummaryCard(offer: _offer())));

    expect(find.byKey(const Key('offer-summary-off-1')), findsOneWidget);
    expect(find.text('KH-RQ-24A1'), findsOneWidget);
    expect(find.text('Customer · Deira'), findsOneWidget);
    expect(find.textContaining('AED'), findsWidgets);
    expect(find.textContaining('+971'), findsNothing);
    expect(find.textContaining('Al Noor'), findsNothing);
  });

  testWidgets('awardedElsewhere copy never includes a winning price',
      (tester) async {
    await tester.pumpWidget(
      _host(
        OfferSummaryCard(
          offer: _offer(
            state: OfferState.rejected,
            awardedElsewhere: true,
          ),
        ),
      ),
    );

    expect(find.text('This Request was awarded elsewhere.'), findsOneWidget);
    expect(find.textContaining('winning'), findsNothing);
  });

  testWidgets('SH-OFF-04 renders current terms snapshot', (tester) async {
    await tester.pumpWidget(
      _host(
        OfferTermsReadOnly(
          terms: const OfferTerms(
            offeredPrice: '9800.00',
            validityHours: 12,
            makingCharges: '150.00',
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('offer-terms-readonly')), findsOneWidget);
    expect(find.textContaining('AED'), findsWidgets);
    expect(find.textContaining('12'), findsWidgets);
  });
}
