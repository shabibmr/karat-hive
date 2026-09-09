import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_domain/kh_domain.dart' show RevealedParty, UserRole;
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/model/offer_enums.dart';
import 'package:kh_admin/features/offers/presentation/offer_detail_screen.dart';
import 'package:kh_admin/features/offers/repository/offer_repository.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

class _FakeOfferDetailRepository extends OfferRepository {
  _FakeOfferDetailRepository() : super(ApiClient());

  OfferDetail? detailToReturn;
  bool shouldFail = false;
  bool addNoteCalled = false;
  String? lastAddedNote;

  @override
  Future<OfferDetail> fetchOfferDetail(String offerId) async {
    if (shouldFail) throw Exception('Failed to load offer detail');
    return detailToReturn ??
        OfferDetail(
          id: offerId,
          reference: 'OFF-2026-9921',
          state: OfferState.rejected,
          offeredPrice: 14850.0,
          makingCharges: 450.0,
          ratePerGram: 275.0,
          goldPrice: 13750.0,
          vat: 650.0,
          totalAmount: 14850.0,
          deliveryTimeframe: '2-3 business days',
          warrantyTerms: '1-year polish and repair included',
          vendorNote: 'Includes custom velvet gift presentation box.',
          validityHours: 48,
          submittedAt: DateTime(2026, 8, 10, 5, 12),
          expiresAt: DateTime(2026, 8, 12, 5, 12),
          decidedAt: DateTime(2026, 8, 11, 10, 0),
          declineReason: 'PRICE_TOO_HIGH',
          revisionCount: 1,
          winningOfferId: 'off-winner-1',
          winningOfferReference: 'OFF-2026-9905',
          winningOfferPrice: 13900.0,
          winningVendorName: 'Sharjah Heritage Gold',
          parentRequest: OfferParentRequestSummary(
            id: 'req-1',
            reference: 'KH-RQ-2026-01482',
            requestType: RequestType.findOrnament,
            customer: RevealedParty(
              displayName: 'Sara Al Maktoum',
              mobile: '+971501234567',
              role: UserRole.customer,
            ),
            categoryName: 'Bridal Set',
            regionName: 'Dubai',
            indicativeValue: 15000.0,
            notes: 'Looking for an 18K necklace and earrings set',
          ),
          vendor: const OfferVendorSummary(
            id: 'ven-1',
            legalBusinessName: 'Al Noor Jewellery LLC',
            tradingName: 'Al Noor Jewellers',
            tradeLicenceNumber: 'CN-1092834',
            contactPersonName: 'Ahmed Hassan',
            mobileNumber: '+971 4 555 0101',
            email: 'contact@alnoor.ae',
            rating: 4.8,
            completedDeals: 42,
          ),
          attachments: [
            const OfferAttachment(
              id: 'att-1',
              fileName: 'bridal_necklace_render.jpg',
              sizeBytes: 245000,
            ),
          ],
          revisions: [
            OfferRevisionItem(
              revisionNumber: 1,
              revisedAt: DateTime(2026, 8, 10, 8, 30),
              offeredPrice: 14850.0,
              makingCharges: 450.0,
              changeSummary: 'Reduced making charges from AED 600 to AED 450',
              vendorNote: 'Special revised price for valued customer',
            ),
          ],
          stateTransitions: [
            OfferStateTransitionItem(
              fromState: 'PENDING',
              toState: 'REJECTED',
              transitionedAt: DateTime(2026, 8, 11, 10, 0),
              actor: 'Customer',
              reason: 'Selected competing offer OFF-2026-9905',
            ),
          ],
          internalNotes: [
            OfferInternalNoteItem(
              id: 'note-1',
              author: 'Platform Admin',
              text: 'Vendor verified pricing against standard 24K bullion index.',
              createdAt: DateTime(2026, 8, 10, 6, 0),
            ),
          ],
        );
  }

  @override
  Future<OfferInternalNoteItem> addNote(
    String offerId, {
    required String note,
  }) async {
    addNoteCalled = true;
    lastAddedNote = note;
    final newNote = OfferInternalNoteItem(
      id: 'note-new',
      author: 'Admin Reviewer',
      text: note,
      createdAt: DateTime.now(),
    );
    return newNote;
  }
}

void main() {
  late _FakeOfferDetailRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeOfferDetailRepository();
  });

  Widget createOfferDetailWidget({String offerId = 'off-1'}) {
    final router = GoRouter(
      initialLocation: '/offers/$offerId',
      routes: [
        GoRoute(
          path: '/offers',
          builder: (context, state) => const Scaffold(body: Text('Offers List')),
        ),
        GoRoute(
          path: '/offers/:id',
          builder: (context, state) => OfferDetailScreen(
            offerId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/requests/:id',
          builder: (context, state) => Scaffold(
            body: Text('Request Detail ${state.pathParameters['id']}'),
          ),
        ),
        GoRoute(
          path: '/vendors/:id',
          builder: (context, state) => Scaffold(
            body: Text('Vendor Detail ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        offerRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp.router(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  testWidgets(
      'renders pricing breakdown, commercial terms, unmasked vendor, and parent request',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createOfferDetailWidget());
    await tester.pumpAndSettle();

    // Header
    expect(find.text('OFFER OFF-2026-9921'), findsOneWidget);
    expect(find.text('AED 14,850.00'), findsWidgets);
    expect(find.text('REJECTED'), findsOneWidget);

    // Pricing breakdown
    expect(find.byKey(const Key('pricing-breakdown-card')), findsOneWidget);
    expect(find.text('Gold Metal Value'), findsOneWidget);
    expect(find.text('AED 13,750.00'), findsOneWidget);
    expect(find.text('Making / Crafting Charges'), findsOneWidget);
    expect(find.text('AED 450.00'), findsWidgets);
    expect(find.text('Value Added Tax (VAT 5%)'), findsOneWidget);
    expect(find.text('AED 650.00'), findsOneWidget);

    // Unmasked vendor card
    expect(find.text('Unmasked Vendor Profile'), findsOneWidget);
    expect(find.text('Al Noor Jewellery LLC'), findsOneWidget);
    expect(find.text('CN-1092834'), findsOneWidget);
    expect(
      find.text('Ahmed Hassan · +971 4 555 0101'),
      findsOneWidget,
    );

    // Parent request card
    expect(find.text('Parent Request Reference'), findsOneWidget);
    expect(find.text('KH-RQ-2026-01482'), findsOneWidget);
    expect(
      find.text('Sara Al Maktoum · +971501234567'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('parent-request-link')), findsOneWidget);

    // Revisions timeline
    expect(find.byKey(const Key('revisions-timeline-card')), findsOneWidget);
    expect(find.text('Rev #1'), findsOneWidget);
    expect(
      find.text('Reduced making charges from AED 600 to AED 450'),
      findsOneWidget,
    );

    // State transitions timeline
    expect(find.byKey(const Key('state-transitions-card')), findsOneWidget);
    expect(find.text('PENDING → REJECTED'), findsOneWidget);

    // Winning offer card
    expect(find.byKey(const Key('winning-offer-card')), findsOneWidget);
    expect(find.text('COMPETING OFFER WON THIS REQUEST'), findsOneWidget);
    expect(find.byKey(const Key('inspect-winning-offer-button')), findsOneWidget);

    // Internal notes
    expect(
      find.text('Vendor verified pricing against standard 24K bullion index.'),
      findsOneWidget,
    );
  });

  testWidgets('adding an internal note posts note and updates UI',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createOfferDetailWidget());
    await tester.pumpAndSettle();

    final inputFinder = find.byKey(const Key('offer-internal-note-input'));
    expect(inputFinder, findsOneWidget);
    await tester.ensureVisible(inputFinder);
    await tester.pumpAndSettle();

    await tester.enterText(inputFinder, 'Inspection confirmed valid VAT breakdown.');
    final buttonFinder = find.byKey(const Key('offer-add-note-button'));
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(fakeRepo.addNoteCalled, isTrue);
    expect(fakeRepo.lastAddedNote, 'Inspection confirmed valid VAT breakdown.');
    expect(
      find.text('Inspection confirmed valid VAT breakdown.'),
      findsOneWidget,
    );
  });

  testWidgets('navigation actions work properly', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createOfferDetailWidget());
    await tester.pumpAndSettle();
    // Back to offers button
    await tester.tap(find.byKey(const Key('back-to-offers-button')));
    await tester.pumpAndSettle();
    expect(find.text('Offers List'), findsOneWidget);

    // Re-pump widget to test parent request link
    await tester.pumpWidget(createOfferDetailWidget());
    await tester.pumpAndSettle();

    // Open Parent Request
    final requestLink = find.byKey(const Key('parent-request-link'));
    await tester.ensureVisible(requestLink);
    await tester.tap(requestLink);
    await tester.pumpAndSettle();
    expect(find.text('Request Detail req-1'), findsOneWidget);

    // Re-pump widget to test inspect winning offer link
    await tester.pumpWidget(createOfferDetailWidget());
    await tester.pumpAndSettle();

    final winnerLink = find.byKey(const Key('inspect-winning-offer-button'));
    await tester.ensureVisible(winnerLink);
    await tester.tap(winnerLink);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('winning-offer-card')), findsWidgets);
  });

  testWidgets('shows error state on failure with retry option',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeRepo.shouldFail = true;

    await tester.pumpWidget(createOfferDetailWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offer-detail-error')), findsOneWidget);
    expect(find.text('Failed to load offer detail'), findsOneWidget);
    expect(find.byKey(const Key('offer-detail-retry-button')), findsOneWidget);

    fakeRepo.shouldFail = false;
    await tester.tap(find.byKey(const Key('offer-detail-retry-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pricing-breakdown-card')), findsOneWidget);
  });
}
