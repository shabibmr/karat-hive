import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import 'golden_runner.dart';

/// Fixed instants so RelativeTimeLabel / ExpiryCountdown goldens are deterministic.
final DateTime _fixedNow = DateTime.utc(2026, 9, 7, 12, 0, 0);

MaskedParty get _maskedCustomer => const MaskedParty(
      role: UserRole.customer,
      region: 'DXB',
      pseudonym: 'Cust. DXB',
      rating: RatingSummary.score(4.5, 12),
      dealCount: 8,
    );

VendorRequestItem get _requestItem => VendorRequestItem(
      id: 'req-1',
      reference: 'REQ-1001',
      requestType: 'FIND_ORNAMENT',
      direction: 'BUY',
      state: 'PUBLISHED',
      categoryId: 'cat-1',
      categoryName: 'Bangles',
      regionId: 'reg-1',
      regionName: 'Deira',
      weightGrams: 25.5,
      purityKarat: '21',
      budgetMin: 5000,
      notes: 'Prefer classic design',
      // Omit publishedAt: VendorRequestCard does not forward a frozen `now`
      // into RelativeTimeLabel, so relative text would be non-deterministic.
      // Omit expiresAt when using pumpAndSettle (periodic timer would hang).
      offerCount: 3,
      viewedAt: DateTime.utc(2026, 9, 1),
      hasResponded: true,
      customer: _maskedCustomer,
    );

/// Card golden omits weight so the budget Row fits under Ahem (wider than prod fonts).
VendorRequestItem get _cardItem => VendorRequestItem(
      id: _requestItem.id,
      reference: _requestItem.reference,
      requestType: _requestItem.requestType,
      direction: _requestItem.direction,
      state: _requestItem.state,
      categoryId: _requestItem.categoryId,
      categoryName: _requestItem.categoryName,
      regionId: _requestItem.regionId,
      regionName: _requestItem.regionName,
      purityKarat: _requestItem.purityKarat,
      budgetMin: _requestItem.budgetMin,
      notes: _requestItem.notes,
      offerCount: _requestItem.offerCount,
      viewedAt: _requestItem.viewedAt,
      hasResponded: _requestItem.hasResponded,
      customer: _requestItem.customer,
    );

void main() {
  testWidgets('MoneyDisplay LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'money_display',
      size: const Size(320, 80),
      builder: () => const MoneyDisplay(amount: 1250.5, delta: 40),
    );
  });

  testWidgets('RelativeTimeLabel LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'relative_time_label',
      size: const Size(200, 60),
      builder: () => RelativeTimeLabel(
        at: _fixedNow.subtract(const Duration(hours: 2)),
        now: _fixedNow,
      ),
    );
  });

  testWidgets('SubscriptionBadge LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'subscription_badge',
      size: const Size(240, 80),
      builder: () => const Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          SubscriptionBadge(state: 'ACTIVE'),
          SubscriptionBadge(state: 'GRACE'),
          SubscriptionBadge(state: 'EXPIRED'),
        ],
      ),
    );
  });

  testWidgets('MaskedPartyLabel LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'masked_party_label',
      size: const Size(360, 100),
      builder: () => SizedBox(
        width: 320,
        child: MaskedPartyLabel(party: _maskedCustomer),
      ),
    );
  });

  testWidgets('TrustSignalBadge LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'trust_signal_badge',
      size: const Size(280, 60),
      builder: () => TrustSignalBadge(
        rating: const RatingSummary.score(4.5, 12),
        dealCount: 8,
      ),
    );
  });

  testWidgets('SpecificationGrid LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'specification_grid',
      size: const Size(400, 360),
      builder: () => SizedBox(
        width: 360,
        child: SpecificationGrid(item: _requestItem),
      ),
    );
  });

  testWidgets('VendorRequestCard LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'vendor_request_card',
      size: const Size(440, 300),
      builder: () => SizedBox(
        width: 400,
        child: VendorRequestCard(item: _cardItem, onTap: () {}),
      ),
    );
  });

  testWidgets('OfferSummaryCard LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'offer_summary_card',
      size: const Size(440, 220),
      builder: () => SizedBox(
        width: 400,
        child: OfferSummaryCard(
          offer: OfferForVendor(
            id: 'off-1',
            requestId: 'req-1',
            state: OfferState.accepted,
            terms: const OfferTerms(
              offeredPrice: '5500.00',
              validityHours: 24,
            ),
            submittedAt: DateTime.utc(2026, 9, 1, 11),
            expiresAt: DateTime.utc(2026, 9, 2, 11),
            revisionCount: 0,
            requestSummary: const OfferRequestSummary(
              id: 'req-1',
              reference: 'KH-RQ-24A1',
              requestType: RequestType.findOrnament,
              direction: Direction.buy,
              customerLabel: 'Customer · Deira',
              categoryName: 'Bangles',
            ),
          ),
        ),
      ),
    );
  });

  testWidgets('ConnectionSummaryRow LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'connection_summary_row',
      size: const Size(440, 220),
      builder: () => SizedBox(
        width: 400,
        child: ConnectionSummaryRow(
          connectionId: 'conn-1',
          counterpartyName: 'Fatima Al Zahra',
          state: ConnectionState.active,
          requestReference: 'KH-RQ-24A1',
          offeredPrice: '12500.00',
          onTalk: () {},
          onTap: () {},
        ),
      ),
    );
  });

  testWidgets('TalkButton LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'talk_button',
      size: const Size(400, 80),
      builder: () => TalkButton(
        talk: const TalkPayload(
          waUrl: 'https://wa.me/971501234567?text=Hello',
          mobileNumber: '+971501234567',
          available: true,
          callUrl: 'tel:+971501234567',
        ),
        onTalk: () {},
      ),
    );
  });

  testWidgets('RevealedPartyCard LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'revealed_party_card',
      size: const Size(440, 220),
      builder: () => SizedBox(
        width: 400,
        child: RevealedPartyCard(
          party: RevealedParty(
            displayName: 'Fatima Al Zahra',
            mobile: PhoneNumber.parse('+971501234567'),
            role: UserRole.customer,
            dealCount: 3,
            rating: const RatingSummary.score(4.8, 3),
          ),
        ),
      ),
    );
  });

  testWidgets('ConnectionClosedBanner LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'connection_closed_banner',
      size: const Size(400, 100),
      builder: () => const SizedBox(
        width: 360,
        child: ConnectionClosedBanner(),
      ),
    );
  });

  testWidgets('ExpiryCountdown LTR+RTL golden', (tester) async {
    final clock = ServerClock(nowProvider: () => _fixedNow);
    await expectKhGoldens(
      tester,
      name: 'expiry_countdown',
      size: const Size(240, 60),
      // Periodic timer — do not pumpAndSettle.
      settle: false,
      builder: () => ExpiryCountdown(
        expiresAt: _fixedNow.add(const Duration(hours: 12)),
        clock: clock,
      ),
    );
  });
}
