import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/di.dart';
import 'package:karat_hive/features/offers_vendor/presentation/submit_offer_screen.dart';
import 'package:karat_hive/features/offers_vendor/repository/offers_vendor_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

VendorRequestItem _testRequest({
  String id = 'req-offer-1',
  String? reference = 'REQ-2026-0099',
}) {
  return VendorRequestItem(
    id: id,
    reference: reference,
    requestType: 'FIND_ORNAMENT',
    direction: 'BUY',
    state: 'PUBLISHED',
    categoryId: 'cat-ring',
    categoryName: 'Rings',
    regionId: 'reg-dxb',
    regionName: 'Dubai',
    purityKarat: '22',
    weightGrams: 15.0,
    budgetMin: 4000.0,
    budgetMax: 5500.0,
    offerCount: 2,
    customer: const MaskedParty(
      role: UserRole.customer,
      region: 'Dubai',
      dealCount: 5,
    ),
    publishedAt: DateTime.utc(2026, 9, 7, 0, 0),
    expiresAt: DateTime.utc(2026, 9, 9, 12, 0),
  );
}

PlatformConfig _testConfig() => const PlatformConfig(
      offerValidityHours: [12, 24, 48],
      defaultOfferValidityHours: 24,
    );

OfferForVendor _testOffer({String requestId = 'req-offer-1'}) {
  return OfferForVendor(
    id: 'off-1',
    requestId: requestId,
    state: OfferState.pending,
    terms: const OfferTerms(offeredPrice: '5200.00', validityHours: 24),
    submittedAt: DateTime.utc(2026, 9, 7, 12, 0),
    expiresAt: DateTime.utc(2026, 9, 8, 12, 0),
    revisionCount: 0,
  );
}

class FakeOffersVendorRepository implements OffersVendorRepository {
  FakeOffersVendorRepository({
    this.request,
    this.config,
    this.requestError,
    this.configError,
    this.submitError,
    this.hangRequest = false,
    this.hangConfig = false,
  });

  final VendorRequestItem? request;
  final PlatformConfig? config;
  final Failure? requestError;
  final Failure? configError;
  final Failure? submitError;
  final bool hangRequest;
  final bool hangConfig;

  int submitCalls = 0;

  @override
  Future<Result<PlatformConfig>> getPlatformConfig() async {
    if (hangConfig) await Completer<void>().future;
    if (configError != null) return Err(configError!);
    return Ok(config ?? _testConfig());
  }

  @override
  Future<Result<VendorRequestItem>> getRequest(String requestId) async {
    if (hangRequest) await Completer<void>().future;
    if (requestError != null) return Err(requestError!);
    return Ok(request ?? _testRequest(id: requestId));
  }

  @override
  Future<Result<OfferForVendor>> getOffer(String offerId) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> submitOffer({
    required String requestId,
    required OfferTermsInput terms,
  }) async {
    submitCalls++;
    if (submitError != null) return Err(submitError!);
    return Ok(_testOffer(requestId: requestId));
  }

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
  }) async =>
      const Ok(PagedResult(items: []));
}

Widget _host({
  required FakeOffersVendorRepository repo,
  String requestId = 'req-offer-1',
  DateTime? now,
}) {
  return ProviderScope(
    overrides: [
      offersVendorRepositoryProvider.overrideWithValue(repo),
      serverClockProvider.overrideWithValue(
        ServerClock(nowProvider: () => now ?? DateTime.utc(2026, 9, 7, 12)),
      ),
    ],
    child: MaterialApp(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      home: SubmitOfferScreen(requestId: requestId),
    ),
  );
}

void main() {
  group('SubmitOfferScreen (VEN-S09)', () {
    Future<void> setTallSurface(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('shows loading spinner while request/config load',
        (tester) async {
      await setTallSurface(tester);
      final repo = FakeOffersVendorRepository(hangRequest: true);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pump();

      expect(find.byKey(const Key('submit-offer-screen')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('submit-offer-button')), findsNothing);
    });

    testWidgets('shows KhErrorView when request load fails (SH-FND-13)',
        (tester) async {
      await setTallSurface(tester);
      final repo = FakeOffersVendorRepository(
        requestError: const NetworkFailure(message: 'offline'),
      );

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byType(KhErrorView), findsOneWidget);
      expect(find.byKey(const Key('error-view')), findsOneWidget);
      expect(find.text('offline'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('renders empty compose form with request context (empty/data)',
        (tester) async {
      await setTallSurface(tester);
      final repo = FakeOffersVendorRepository(request: _testRequest());

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('submit-offer-screen')), findsOneWidget);
      expect(find.text('REQ-2026-0099'), findsOneWidget);
      expect(find.text('Customer in Dubai'), findsOneWidget);
      expect(find.byType(OfferTermsForm), findsOneWidget);
      expect(find.byKey(const Key('offer-price-field')), findsOneWidget);
      expect(find.byKey(const Key('offer-image-add')), findsOneWidget);
      expect(find.byKey(const Key('submit-offer-button')), findsOneWidget);

      // Identity masking (BR-006): no phone / real name in tree.
      expect(find.textContaining('+971'), findsNothing);
      expect(find.textContaining('Customer Name'), findsNothing);
    });

    testWidgets('submit with empty price shows inline validation error',
        (tester) async {
      await setTallSurface(tester);
      final repo = FakeOffersVendorRepository();

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('submit-offer-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('inline-error')), findsOneWidget);
      expect(find.text('Enter a valid offered price.'), findsOneWidget);
      expect(repo.submitCalls, 0);
    });

    testWidgets('submit API failure shows inline error on ready form',
        (tester) async {
      await setTallSurface(tester);
      final repo = FakeOffersVendorRepository(
        submitError: const ConflictFailure(
          code: 'SUBSCRIPTION_REQUIRED',
          message: 'Active subscription required.',
        ),
      );

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('offer-price-field')), '5200');
      await tester.pump();

      await tester.tap(find.byKey(const Key('submit-offer-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('inline-error')), findsOneWidget);
      expect(find.text('Active subscription required.'), findsOneWidget);
      expect(find.byKey(const Key('submit-offer-button')), findsOneWidget);
      expect(repo.submitCalls, 1);
    });
  });
}
