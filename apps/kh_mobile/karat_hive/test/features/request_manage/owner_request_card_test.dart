import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/request_manage/presentation/widgets/owner_request_card.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

RequestForCustomer _coinRequest({
  String id = 'req-coin-1',
  List<MediaRef> media = const [
    MediaRef(
      id: 'media-1',
      key: 'm1',
      state: MediaState.ready,
      purpose: MediaPurpose.requestImage,
      contentType: 'image/jpeg',
      byteSize: 1024,
      displayOrder: 0,
      displayUrl: 'https://example.com/a.jpg',
      thumbnailUrl: 'https://example.com/a-thumb.jpg',
    ),
  ],
}) {
  return RequestForCustomer(
    id: id,
    reference: 'KH-RQ-2026-000099',
    requestType: RequestType.goldCoin,
    direction: Direction.sell,
    state: RequestState.published,
    region: const RegionSummary(id: 'reg-dxb', nameEn: 'Dubai', nameAr: 'دبي'),
    weightIsApproximate: false,
    budgetIsFlexible: false,
    offerCount: 2,
    unreadOfferCount: 1,
    media: media,
    createdAt: DateTime.utc(2026, 9, 1),
    updatedAt: DateTime.utc(2026, 9, 1),
    publishedAt: DateTime.utc(2026, 9, 1, 10),
    expiresAt: DateTime.utc(2026, 9, 3, 10),
    purityKarat: Karat.k24,
    denominationGrams: '10.00',
    quantity: 1,
    condition: ItemCondition.brandNew,
    indicativeValue: '4250',
    budgetMin: '4250',
    budgetMax: '4500',
  );
}

void main() {
  testWidgets(
    'OwnerRequestCard matches Card-mock: media count, value panel, ctaFill View Details, no Message',
    (tester) async {
      var opened = false;
      final req = _coinRequest();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: khTheme(),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: OwnerRequestCard(
                  request: req,
                  onOpen: () => opened = true,
                ),
              ),
            ),
          ),
        ),
      );
      // ExpiryCountdown ticks; avoid pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(Key('owner-request-card-${req.id}')), findsOneWidget);
      expect(find.byKey(const Key('owner-request-media-count')), findsOneWidget);
      expect(find.textContaining('Gold Coin'), findsOneWidget);
      expect(find.textContaining('New'), findsOneWidget);
      expect(find.textContaining('24K'), findsOneWidget);

      expect(
        find.byKey(Key('owner-request-value-${req.id}')),
        findsOneWidget,
      );
      expect(find.text('Estimated Value'), findsOneWidget);
      expect(find.textContaining('AED'), findsWidgets);

      expect(find.text('Message'), findsNothing);
      expect(find.text('View offers'), findsNothing);
      expect(find.text('View Details'), findsOneWidget);

      final viewDetails =
          find.byKey(Key('owner-request-view-details-${req.id}'));
      expect(viewDetails, findsOneWidget);

      final theme = Theme.of(tester.element(find.byType(FilledButton)));
      expect(
        theme.filledButtonTheme.style?.backgroundColor?.resolve({}),
        KhTokens.light.ctaFill,
      );
      expect(
        KhTokens.light.ctaFill,
        const Color(0xFFD8C0A8),
      );

      await tester.ensureVisible(viewDetails);
      await tester.tap(viewDetails);
      await tester.pump();
      expect(opened, isTrue);
    },
  );

  testWidgets('OwnerRequestCard hides value panel when no money fields',
      (tester) async {
    final req = RequestForCustomer(
      id: 'req-bare',
      requestType: RequestType.findOrnament,
      direction: Direction.buy,
      state: RequestState.draft,
      region: const RegionSummary(id: 'r', nameEn: 'Dubai', nameAr: 'دبي'),
      weightIsApproximate: false,
      budgetIsFlexible: false,
      offerCount: 0,
      media: const [],
      createdAt: DateTime.utc(2026, 9, 1),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: khTheme(),
          localizationsDelegates: KhStrings.delegates,
          supportedLocales: KhStrings.supportedLocales,
          home: Scaffold(
            body: OwnerRequestCard(request: req, onOpen: () {}),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Estimated Value'), findsNothing);
    expect(find.text('View Details'), findsOneWidget);
    expect(find.byKey(const Key('owner-request-media-count')), findsNothing);
  });
}
