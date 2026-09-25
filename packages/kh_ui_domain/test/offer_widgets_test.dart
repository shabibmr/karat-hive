import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

OfferForVendor _vendorOffer({
  OfferState state = OfferState.accepted,
  bool awardedElsewhere = false,
}) {
  return OfferForVendor(
    id: 'off-1',
    requestId: 'req-1',
    state: state,
    terms: const OfferTerms(
      offeredPrice: '5500.00',
      weightGrams: '10.00',
      purityKarat: '22K',
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

OfferForCustomer _customerOffer({
  OfferState state = OfferState.pending,
  bool viewedKeyPresent = false,
  DateTime? viewedAt,
}) {
  return OfferForCustomer(
    id: 'off-c1',
    requestId: 'req-1',
    state: state,
    terms: const OfferTerms(
      offeredPrice: '12500.00',
      weightGrams: '20.00',
      purityKarat: '22K',
      makingCharges: '200.00',
    ),
    vendor: const MaskedParty(
      role: UserRole.vendor,
      region: 'Deira',
      pseudonym: 'Vendor · Deira',
      rating: RatingSummary.score(4.5, 8),
      dealCount: 8,
    ),
    submittedAt: DateTime.utc(2026, 9, 1, 11),
    expiresAt: DateTime.utc(2026, 9, 2, 11),
    revisionCount: 0,
    viewedByCustomerAt: viewedAt,
    viewedByCustomerAtPresent: viewedKeyPresent,
  );
}

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SH-OFF-01 vendor shows price, masked customer, no identity fields',
      (tester) async {
    await tester.pumpWidget(_host(OfferSummaryCard(offer: _vendorOffer())));

    expect(find.byKey(const Key('offer-summary-off-1')), findsOneWidget);
    expect(find.text('Bangles'), findsOneWidget);
    expect(find.text('Customer · Deira'), findsOneWidget);
    expect(find.textContaining('AED'), findsWidgets);
    expect(find.textContaining('+971'), findsNothing);
    expect(find.textContaining('Al Noor'), findsNothing);
  });

  testWidgets('SH-OFF-01 customer shows MaskedParty vendor, price, no identity',
      (tester) async {
    await tester.pumpWidget(
      _host(OfferSummaryCard.customer(offer: _customerOffer())),
    );

    expect(find.byKey(const Key('offer-summary-off-c1')), findsOneWidget);
    expect(find.textContaining('AED'), findsWidgets);
    expect(find.text('Vendor · Deira'), findsOneWidget);
    // MaskedParty has no name/mobile — these must never appear.
    expect(find.textContaining('+971'), findsNothing);
    expect(find.textContaining('Al Romaizan'), findsNothing);
    expect(find.textContaining('TL-'), findsNothing);
  });

  testWidgets('SH-OFF-01 customer unread badge only when viewed key present+null',
      (tester) async {
    await tester.pumpWidget(
      _host(
        OfferSummaryCard.customer(
          offer: _customerOffer(viewedKeyPresent: true),
        ),
      ),
    );
    expect(find.byKey(const Key('kh-badge')), findsOneWidget);

    await tester.pumpWidget(
      _host(
        OfferSummaryCard.customer(
          offer: _customerOffer(
            viewedKeyPresent: true,
            viewedAt: DateTime.utc(2026, 9, 1, 12),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('kh-badge')), findsNothing);

    await tester.pumpWidget(
      _host(OfferSummaryCard.customer(offer: _customerOffer())),
    );
    expect(find.byKey(const Key('kh-badge')), findsNothing);
  });

  testWidgets('awardedElsewhere copy never includes a winning price',
      (tester) async {
    await tester.pumpWidget(
      _host(
        OfferSummaryCard(
          offer: _vendorOffer(
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
            weightGrams: '10.00',
            purityKarat: '22K',
            makingCharges: '150.00',
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('offer-terms-readonly')), findsOneWidget);
    expect(find.textContaining('AED'), findsWidgets);
    expect(find.textContaining('22K'), findsWidgets);
    expect(find.textContaining('10.00g'), findsWidgets);
  });

  testWidgets('SH-OFF-04 shows media strip when terms include media',
      (tester) async {
    await tester.pumpWidget(
      _host(
        OfferTermsReadOnly(
          terms: OfferTerms(
            offeredPrice: '9800.00',
            weightGrams: '10.00',
            purityKarat: '22K',
            media: [
              MediaRef(
                id: 'm1',
                key: 'https://cdn.example/m1.jpg',
                state: MediaState.ready,
                purpose: MediaPurpose.requestImage,
                contentType: 'image/jpeg',
                byteSize: 1024,
                displayOrder: 0,
                displayUrl: 'https://cdn.example/m1.jpg',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('offer-terms-media')), findsOneWidget);
  });
}
