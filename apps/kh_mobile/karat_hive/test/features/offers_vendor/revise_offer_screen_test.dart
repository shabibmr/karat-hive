import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/di.dart';
import 'package:karat_hive/features/offers_vendor/presentation/revise_offer_screen.dart';
import 'package:karat_hive/features/offers_vendor/repository/offers_vendor_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

PlatformConfig _testConfig() => const PlatformConfig(
      offerValidityHours: [12, 24, 48],
      defaultOfferValidityHours: 24,
    );

OfferForVendor _testOffer({
  String id = 'off-1',
  OfferState state = OfferState.pending,
  int revisionCount = 0,
  String offeredPrice = '5200.00',
}) {
  return OfferForVendor(
    id: id,
    requestId: 'req-offer-1',
    state: state,
    terms: OfferTerms(
      offeredPrice: offeredPrice,
      weightGrams: '10.00',
      purityKarat: '22K',
    ),
    submittedAt: DateTime.now().toUtc(),
    expiresAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
    revisionCount: revisionCount,
  );
}

class FakeOffersVendorRepository implements OffersVendorRepository {
  FakeOffersVendorRepository({
    this.offer,
    this.config,
    this.offerError,
    this.configError,
    this.reviseError,
    this.hangOffer = false,
  });

  final OfferForVendor? offer;
  final PlatformConfig? config;
  final Failure? offerError;
  final Failure? configError;
  final Failure? reviseError;
  final bool hangOffer;

  int reviseCalls = 0;

  @override
  Future<Result<PlatformConfig>> getPlatformConfig() async {
    if (configError != null) return Err(configError!);
    return Ok(config ?? _testConfig());
  }

  @override
  Future<Result<VendorRequestItem>> getRequest(String requestId) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> getOffer(String offerId) async {
    if (hangOffer) await Completer<void>().future;
    if (offerError != null) return Err(offerError!);
    return Ok(offer ?? _testOffer(id: offerId));
  }

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
  }) async {
    reviseCalls++;
    if (reviseError != null) return Err(reviseError!);
    return Ok(_testOffer(id: offerId, revisionCount: 1));
  }

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
  }) async =>
      const Ok(PagedResult(items: []));
}

Widget _host({
  required FakeOffersVendorRepository repo,
  String offerId = 'off-1',
  DateTime? now,
}) {
  return ProviderScope(
    overrides: [
      offersVendorRepositoryProvider.overrideWithValue(repo),
      serverClockProvider.overrideWithValue(
        ServerClock(nowProvider: () => now ?? DateTime.now().toUtc()),
      ),
    ],
    child: MaterialApp(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      home: ReviseOfferScreen(offerId: offerId),
    ),
  );
}

void main() {
  group('ReviseOfferScreen (VEN-S10)', () {
    Future<void> setTallSurface(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('shows loading spinner while offer/config load',
        (tester) async {
      await setTallSurface(tester);
      final repo = FakeOffersVendorRepository(hangOffer: true);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pump();

      expect(find.byKey(const Key('revise-offer-screen')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('revise-offer-button')), findsNothing);
      expect(find.byKey(const Key('withdraw-offer-button')), findsNothing);
    });

    testWidgets('shows KhErrorView when offer load fails (error)',
        (tester) async {
      await setTallSurface(tester);
      final repo = FakeOffersVendorRepository(
        offerError: const NetworkFailure(message: 'offline'),
      );

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byType(KhErrorView), findsOneWidget);
      expect(find.byKey(const Key('error-view')), findsOneWidget);
      expect(find.text('offline'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.byKey(const Key('revise-offer-button')), findsNothing);
    });

    testWidgets('renders read-only terms, ineligibility notice, and withdraw button',
        (tester) async {
      await setTallSurface(tester);
      final repo = FakeOffersVendorRepository(offer: _testOffer());

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('revise-offer-screen')), findsOneWidget);
      expect(find.byKey(const Key('offer-terms-readonly')), findsOneWidget);
      expect(find.textContaining('5,200'), findsWidgets);
      expect(
        find.text(
          'Offers cannot be updated once sent. You may withdraw this offer if you wish to submit a new one.',
        ),
        findsOneWidget,
      );
      expect(find.byType(OfferTermsForm), findsNothing);
      expect(find.byKey(const Key('revise-offer-button')), findsNothing);
      expect(find.byKey(const Key('withdraw-offer-button')), findsOneWidget);
    });
  });
}
