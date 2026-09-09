import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/offers_vendor/presentation/my_offers_screen.dart';
import 'package:karat_hive/features/offers_vendor/repository/offers_vendor_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

OfferForVendor _testOffer({
  String id = 'off-1',
  OfferState state = OfferState.pending,
  String reference = 'KH-RQ-24A1',
  String offeredPrice = '5200.00',
}) {
  return OfferForVendor(
    id: id,
    requestId: 'req-1',
    state: state,
    terms: OfferTerms(offeredPrice: offeredPrice, validityHours: 24),
    submittedAt: DateTime.utc(2026, 9, 7, 12, 0),
    expiresAt: DateTime.utc(2026, 9, 8, 12, 0),
    revisionCount: 0,
    requestSummary: OfferRequestSummary(
      id: 'req-1',
      reference: reference,
      requestType: RequestType.findOrnament,
      direction: Direction.buy,
      customerLabel: 'Customer · Deira',
      categoryName: 'Bangles',
    ),
  );
}

class FakeOffersVendorRepository implements OffersVendorRepository {
  FakeOffersVendorRepository({
    this.items = const [],
    this.error,
    this.hangList = false,
  });

  final List<OfferForVendor> items;
  final Failure? error;
  final bool hangList;

  int listCalls = 0;
  String? lastTab;
  String? lastQuery;

  @override
  Future<Result<PlatformConfig>> getPlatformConfig() async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<VendorRequestItem>> getRequest(String requestId) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> getOffer(String offerId) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> submitOffer({
    required String requestId,
    required OfferTermsInput terms,
  }) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> reviseOffer({
    required String offerId,
    required OfferTermsInput terms,
  }) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> withdrawOffer(String offerId) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<PagedResult<OfferForVendor>>> listMyOffers({
    required String tab,
    String? requestType,
    DateTime? from,
    DateTime? to,
    String? q,
    String? cursor,
  }) async {
    listCalls++;
    lastTab = tab;
    lastQuery = q;
    if (hangList) await Completer<void>().future;
    if (error != null) return Err(error!);
    return Ok(PagedResult(items: items));
  }
}

Widget _host({required FakeOffersVendorRepository repo}) {
  return ProviderScope(
    overrides: [
      offersVendorRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      home: const MyOffersScreen(),
    ),
  );
}

void main() {
  group('MyOffersScreen (VEN-S11)', () {
    testWidgets('shows loading spinner while my offers load', (tester) async {
      final repo = FakeOffersVendorRepository(hangList: true);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pump();

      expect(find.byKey(const Key('my-offers-screen')), findsOneWidget);
      expect(find.text('My Offers'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('empty-view')), findsNothing);
      expect(find.byKey(const Key('error-view')), findsNothing);
    });

    testWidgets('shows KhEmptyView when my offers list is empty (SH-FND-12)',
        (tester) async {
      final repo = FakeOffersVendorRepository(items: const []);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('my-offers-screen')), findsOneWidget);
      expect(find.byType(KhEmptyView), findsOneWidget);
      expect(find.byKey(const Key('empty-view')), findsOneWidget);
      expect(
        find.text('No offers yet. Submit an Offer from a matched Request.'),
        findsOneWidget,
      );
      expect(find.byType(OfferSummaryCard), findsNothing);
    });

    testWidgets('shows KhErrorView when my offers fail (SH-FND-13)',
        (tester) async {
      final repo = FakeOffersVendorRepository(
        error: const NetworkFailure(message: 'offline'),
      );

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byType(KhErrorView), findsOneWidget);
      expect(find.byKey(const Key('error-view')), findsOneWidget);
      expect(find.text('offline'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.byType(OfferSummaryCard), findsNothing);
    });

    testWidgets('renders offer summary cards for pending tab data',
        (tester) async {
      final repo = FakeOffersVendorRepository(
        items: [
          _testOffer(id: 'off-1', reference: 'KH-RQ-24A1'),
          _testOffer(
            id: 'off-2',
            reference: 'KH-RQ-24B2',
            offeredPrice: '6100.00',
          ),
        ],
      );

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('my-offers-screen')), findsOneWidget);
      expect(find.text('My Offers'), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Search by reference'), findsOneWidget);

      expect(find.byType(OfferSummaryCard), findsNWidgets(2));
      expect(find.byKey(const Key('offer-summary-off-1')), findsOneWidget);
      expect(find.byKey(const Key('offer-summary-off-2')), findsOneWidget);
      expect(find.text('KH-RQ-24A1'), findsOneWidget);
      expect(find.text('KH-RQ-24B2'), findsOneWidget);
      expect(find.text('Customer · Deira'), findsNWidgets(2));
      expect(find.textContaining('AED'), findsWidgets);

      expect(repo.listCalls, greaterThanOrEqualTo(1));
      expect(repo.lastTab, 'PENDING');
    });
  });
}
