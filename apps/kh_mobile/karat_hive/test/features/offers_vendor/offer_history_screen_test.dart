import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/offers_vendor/controller/offer_history_controller.dart';
import 'package:karat_hive/features/offers_vendor/presentation/offer_history_screen.dart';
import 'package:karat_hive/features/offers_vendor/repository/offer_history_repository.dart';
import 'package:karat_hive/features/onboarding/repository/onboarding_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

class FakeOfferHistoryRepository implements OfferHistoryRepository {
  FakeOfferHistoryRepository({
    this.hang = false,
    this.performance = const VendorPerformanceDto(
      offersSubmitted: 0,
      acceptanceRate: '0.00',
      averageResponseMinutes: 0,
    ),
    this.terminalOffers = const [],
    this.failure,
    this.terminalFailure,
    this.hangTerminal = false,
    this.exportFailure,
    this.hangExport = false,
    this.exportDto,
  });

  final bool hang;
  final VendorPerformanceDto performance;
  final List<OfferForVendor> terminalOffers;
  final Failure? failure;
  final Failure? terminalFailure;
  final bool hangTerminal;
  final Failure? exportFailure;
  final bool hangExport;
  final PerformanceExportDto? exportDto;
  int calls = 0;
  DateTime? lastFrom;
  DateTime? lastTo;
  String? lastRequestType;
  String? lastCategoryId;
  String? lastRegionId;

  int exportCalls = 0;
  DateTime? lastExportFrom;
  DateTime? lastExportTo;
  String? lastExportRequestType;
  String? lastExportCategoryId;
  String? lastExportRegionId;

  int terminalCalls = 0;
  String? lastTerminalTab;
  String? lastTerminalRequestType;
  DateTime? lastTerminalFrom;
  DateTime? lastTerminalTo;
  String? lastTerminalCursor;
  int? lastTerminalLimit;

  @override
  Future<Result<VendorPerformanceDto>> getPerformance({
    DateTime? from,
    DateTime? to,
    String? requestType,
    String? categoryId,
    String? regionId,
  }) async {
    calls++;
    lastFrom = from;
    lastTo = to;
    lastRequestType = requestType;
    lastCategoryId = categoryId;
    lastRegionId = regionId;
    if (hang) await Completer<void>().future;
    if (failure != null) return Err(failure!);
    return Ok(performance);
  }

  @override
  Future<Result<PagedResult<OfferForVendor>>> getTerminalOffers({
    String? tab = 'CLOSED',
    String? requestType,
    DateTime? from,
    DateTime? to,
    String? cursor,
    int limit = 50,
  }) async {
    terminalCalls++;
    lastTerminalTab = tab;
    lastTerminalRequestType = requestType;
    lastTerminalFrom = from;
    lastTerminalTo = to;
    lastTerminalCursor = cursor;
    lastTerminalLimit = limit;
    if (hangTerminal) await Completer<void>().future;
    if (terminalFailure != null) return Err(terminalFailure!);
    return Ok(PagedResult(items: terminalOffers));
  }

  @override
  Future<Result<PerformanceExportDto>> exportPerformance({
    DateTime? from,
    DateTime? to,
    String? requestType,
    String? categoryId,
    String? regionId,
  }) async {
    exportCalls++;
    lastExportFrom = from;
    lastExportTo = to;
    lastExportRequestType = requestType;
    lastExportCategoryId = categoryId;
    lastExportRegionId = regionId;
    if (hangExport) await Completer<void>().future;
    if (exportFailure != null) return Err(exportFailure!);
    return Ok(
      exportDto ??
          PerformanceExportDto(
            downloadUrl: 'https://storage.karathive.ae/exports/vendor-perf.csv',
            expiresAt: DateTime.utc(2026, 8, 11),
          ),
    );
  }
}

OfferForVendor _testOffer({
  String id = 'off-1',
  OfferState state = OfferState.accepted,
  String reference = 'KH-RQ-24A1',
  String categoryName = 'Bangles',
  String? categoryId,
  String? regionId,
  String offeredPrice = '5200.00',
  String? makingCharges,
  String? ratePerGram,
  String? deliveryTimeframe,
  String? warrantyTerms,
  int validityHours = 24,
  DateTime? submittedAt,
  DateTime? expiresAt,
  DateTime? decidedAt,
  bool awardedElsewhere = false,
}) {
  return OfferForVendor(
    id: id,
    requestId: 'req-$id',
    state: state,
    terms: OfferTerms(
      offeredPrice: offeredPrice,
      makingCharges: makingCharges,
      ratePerGram: ratePerGram,
      deliveryTimeframe: deliveryTimeframe,
      warrantyTerms: warrantyTerms,
      validityHours: validityHours,
    ),
    submittedAt: submittedAt ?? DateTime(2026, 9, 1, 10, 0),
    expiresAt: expiresAt ?? DateTime(2026, 9, 5, 10, 0),
    decidedAt: decidedAt ?? DateTime(2026, 9, 3, 15, 0),
    revisionCount: 0,
    awardedElsewhere: awardedElsewhere,
    requestSummary: OfferRequestSummary(
      id: 'req-$id',
      reference: reference,
      requestType: RequestType.findOrnament,
      direction: Direction.buy,
      customerLabel: 'Customer · Deira',
      categoryId: categoryId,
      categoryName: categoryName,
      regionId: regionId,
    ),
  );
}

Widget _host({
  required FakeOfferHistoryRepository repo,
  DateTime? clock,
  Future<bool> Function(String url)? openUrl,
}) {
  return ProviderScope(
    overrides: [
      offerHistoryRepositoryProvider.overrideWithValue(repo),
      offerHistoryClockProvider.overrideWithValue(
        clock ?? DateTime(2026, 9, 8),
      ),
      categoriesProvider.overrideWith((ref) async => const <TaxonomyNode>[]),
      regionsProvider.overrideWith((ref) async => const <TaxonomyNode>[]),
    ],
    child: MaterialApp(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      home: OfferHistoryScreen(openUrl: openUrl),
    ),
  );
}

void main() {
  group('OfferHistoryScreen (VEN-S14 filters)', () {
    testWidgets('renders date range, type, category, region, outcome filters',
        (tester) async {
      final repo = FakeOfferHistoryRepository();
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pump();

      expect(find.byKey(const Key('offer-history-screen')), findsOneWidget);
      expect(find.byKey(const Key('kh-date-range-picker')), findsOneWidget);
      expect(find.byKey(const Key('offer-history-from')), findsOneWidget);
      expect(find.byKey(const Key('offer-history-to')), findsOneWidget);
      expect(
        find.byKey(const Key('offer-history-type-FIND_ORNAMENT')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('offer-history-outcome-ACCEPTED')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('offer-history-reset')), findsOneWidget);
    });

    testWidgets('date preset updates filters and calls PerformanceClient',
        (tester) async {
      final repo = FakeOfferHistoryRepository();
      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(repo.calls, greaterThanOrEqualTo(1));
      final baseline = repo.calls;

      await tester.tap(find.byKey(const Key('kh-date-range-preset-last7')));
      await tester.pumpAndSettle();

      expect(repo.calls, greaterThan(baseline));
      expect(repo.lastFrom, DateTime(2026, 9, 2));
      expect(repo.lastTo?.year, 2026);
      expect(repo.lastTo?.month, 9);
      expect(repo.lastTo?.day, 8);
    });

    testWidgets('request type chip is forwarded to performance query',
        (tester) async {
      final repo = FakeOfferHistoryRepository();
      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('offer-history-type-SELL_OLD_GOLD')),
      );
      await tester.pumpAndSettle();

      expect(repo.lastRequestType, 'SELL_OLD_GOLD');
    });

    testWidgets('outcome chip does not change performance query params',
        (tester) async {
      final repo = FakeOfferHistoryRepository();
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();
      final baseline = repo.calls;
      final lastType = repo.lastRequestType;

      await tester.tap(
        find.byKey(const Key('offer-history-outcome-REJECTED')),
      );
      await tester.pumpAndSettle();

      expect(repo.calls, baseline);
      expect(repo.lastRequestType, lastType);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(OfferHistoryScreen)),
      );
      expect(
        container.read(offerHistoryFiltersProvider).outcome,
        'REJECTED',
      );
    });
  });

  group('OfferHistoryScreen (VEN-S14 performance metrics)', () {
    testWidgets(
        'renders the 3 performance metrics and never a competitor-price stat (BR-008)',
        (tester) async {
      final repo = FakeOfferHistoryRepository(
        performance: const VendorPerformanceDto(
          offersSubmitted: 48,
          acceptanceRate: '0.25',
          averageResponseMinutes: 45,
        ),
      );
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('metric-offers-submitted')), findsOneWidget);
      expect(find.byKey(const Key('metric-acceptance-rate')), findsOneWidget);
      expect(find.byKey(const Key('metric-response-time')), findsOneWidget);
      expect(
        find.byKey(const Key('metric-offered-vs-accepted')),
        findsNothing,
      );

      expect(find.text('48'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);
    });

    testWidgets('shows loading indicator while performance data loads',
        (tester) async {
      final repo = FakeOfferHistoryRepository(hang: true);
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pump();

      expect(
        find.byKey(const Key('offer-history-performance-loading')),
        findsOneWidget,
      );
    });

    testWidgets('displays inline error when performance fetch fails',
        (tester) async {
      final repo = FakeOfferHistoryRepository(
        failure: const NetworkFailure(
          message: 'Could not load performance metrics',
        ),
      );
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('inline-error')), findsOneWidget);
      expect(find.text('Could not load performance metrics'), findsOneWidget);
    });
  });

  group('OfferHistoryScreen formatting helpers', () {
    test('formatAcceptanceRate handles decimals and percentages', () {
      expect(formatAcceptanceRate('0.25'), '25%');
      expect(formatAcceptanceRate('0.50'), '50%');
      expect(formatAcceptanceRate('0.375'), '37.5%');
      expect(formatAcceptanceRate('1.00'), '100%');
      expect(formatAcceptanceRate('0.00'), '0%');
      expect(formatAcceptanceRate('25%'), '25%');
    });

    test('formatResponseTime formats minutes and hours correctly', () {
      expect(formatResponseTime(0), '0 min');
      expect(formatResponseTime(45), '45 min');
      expect(formatResponseTime(60), '1h');
      expect(formatResponseTime(135), '2h 15m');
    });
  });

  group('OfferHistoryScreen (VEN-S14 terminal offer history list)', () {
    testWidgets(
        'renders terminal offer cards with submission date, closed date, price, and status badge',
        (tester) async {
      final repo = FakeOfferHistoryRepository(
        terminalOffers: [
          _testOffer(
            id: 'off-1',
            state: OfferState.accepted,
            reference: 'KH-RQ-001',
            categoryName: 'Necklaces',
            offeredPrice: '14850.00',
            submittedAt: DateTime(2026, 9, 1, 10, 0),
            decidedAt: DateTime(2026, 9, 3, 15, 30),
            deliveryTimeframe: '3 days',
          ),
          _testOffer(
            id: 'off-2',
            state: OfferState.rejected,
            reference: 'KH-RQ-002',
            categoryName: 'Bangles',
            offeredPrice: '8200.00',
            submittedAt: DateTime(2026, 9, 2, 9, 0),
            expiresAt: DateTime(2026, 9, 4, 9, 0),
            decidedAt: DateTime(2026, 9, 3, 11, 0),
            warrantyTerms: '1 year warranty',
          ),
        ],
      );
      tester.view.physicalSize = const Size(800, 2500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('offer-card-off-1')), findsOneWidget);
      expect(find.byKey(const Key('offer-card-off-2')), findsOneWidget);

      // Titles & Categories
      expect(find.text('KH-RQ-001'), findsOneWidget);
      expect(find.text('Necklaces'), findsOneWidget);
      expect(find.text('KH-RQ-002'), findsOneWidget);
      expect(find.text('Bangles'), findsOneWidget);

      // Submission date and closed date
      expect(find.text('Submitted: 1 Sep 2026'), findsOneWidget);
      expect(find.text('Closed: 3 Sep 2026'), findsNWidgets(2));
      expect(find.text('Submitted: 2 Sep 2026'), findsOneWidget);

      // Price and terms
      expect(find.byKey(const Key('offer-price-off-1')), findsOneWidget);
      expect(find.byKey(const Key('offer-price-off-2')), findsOneWidget);
      expect(find.textContaining('3 days'), findsOneWidget);
      expect(find.textContaining('1 year warranty'), findsOneWidget);

      // Status badges
      expect(
        find.descendant(
          of: find.byKey(const Key('offer-status-off-1')),
          matching: find.text('Accepted'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('offer-status-off-2')),
          matching: find.text('Rejected'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays awarded-elsewhere badge when awardedElsewhere is true',
        (tester) async {
      final repo = FakeOfferHistoryRepository(
        terminalOffers: [
          _testOffer(
            id: 'off-lost',
            state: OfferState.rejected,
            awardedElsewhere: true,
          ),
        ],
      );
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('awarded-elsewhere-badge-off-lost')),
        findsOneWidget,
      );
      expect(find.text('Awarded to another vendor'), findsOneWidget);
    });

    testWidgets('strictly renders NO competitor price or identity per BR-008',
        (tester) async {
      final repo = FakeOfferHistoryRepository(
        terminalOffers: [
          _testOffer(
            id: 'off-lost',
            state: OfferState.rejected,
            offeredPrice: '12500.00',
            awardedElsewhere: true,
          ),
        ],
      );
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      // Vendor's own offer and awardedElsewhere badge are present
      expect(find.byKey(const Key('offer-card-off-lost')), findsOneWidget);
      expect(
        find.byKey(const Key('awarded-elsewhere-badge-off-lost')),
        findsOneWidget,
      );

      // Strictly NO competitor prices or identities rendered
      expect(find.textContaining('Competitor'), findsNothing);
      expect(find.textContaining('Winning price'), findsNothing);
      expect(find.textContaining('Winning vendor'), findsNothing);
      expect(find.textContaining('Competitor price'), findsNothing);
      expect(find.textContaining('Winning Deal'), findsNothing);
      expect(find.textContaining('Vendor B'), findsNothing);
    });

    testWidgets('outcome filter correctly filters terminal offers',
        (tester) async {
      final repo = FakeOfferHistoryRepository(
        terminalOffers: [
          _testOffer(id: 'off-acc', state: OfferState.accepted),
          _testOffer(id: 'off-rej', state: OfferState.rejected),
          _testOffer(id: 'off-exp', state: OfferState.expired),
          _testOffer(id: 'off-wth', state: OfferState.withdrawn),
        ],
      );
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      // All 4 terminal offers initially visible
      expect(find.byKey(const Key('offer-card-off-acc')), findsOneWidget);
      expect(find.byKey(const Key('offer-card-off-rej')), findsOneWidget);
      expect(find.byKey(const Key('offer-card-off-exp')), findsOneWidget);
      expect(find.byKey(const Key('offer-card-off-wth')), findsOneWidget);

      // Filter by ACCEPTED
      await tester.tap(find.byKey(const Key('offer-history-outcome-ACCEPTED')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('offer-card-off-acc')), findsOneWidget);
      expect(find.byKey(const Key('offer-card-off-rej')), findsNothing);
      expect(find.byKey(const Key('offer-card-off-exp')), findsNothing);
      expect(find.byKey(const Key('offer-card-off-wth')), findsNothing);

      // Filter by REJECTED
      await tester.tap(find.byKey(const Key('offer-history-outcome-REJECTED')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('offer-card-off-acc')), findsNothing);
      expect(find.byKey(const Key('offer-card-off-rej')), findsOneWidget);
      expect(find.byKey(const Key('offer-card-off-exp')), findsNothing);
      expect(find.byKey(const Key('offer-card-off-wth')), findsNothing);

      // Reset filters restores all
      await tester.tap(find.byKey(const Key('offer-history-reset')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('offer-card-off-acc')), findsOneWidget);
      expect(find.byKey(const Key('offer-card-off-rej')), findsOneWidget);
      expect(find.byKey(const Key('offer-card-off-exp')), findsOneWidget);
      expect(find.byKey(const Key('offer-card-off-wth')), findsOneWidget);
    });

    testWidgets('displays empty state when no offers found', (tester) async {
      final repo = FakeOfferHistoryRepository(terminalOffers: const []);
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('No offers found'), findsOneWidget);
      expect(find.byKey(const Key('offer-history-empty')), findsOneWidget);
    });

    testWidgets('displays loading indicator while terminal offers load',
        (tester) async {
      final repo = FakeOfferHistoryRepository(hangTerminal: true);
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pump();

      expect(
        find.byKey(const Key('offer-history-loading')),
        findsOneWidget,
      );
    });

    testWidgets('displays error state when terminal offers fetch fails',
        (tester) async {
      final repo = FakeOfferHistoryRepository(
        terminalFailure: const NetworkFailure(
          message: 'Could not load offer history',
        ),
      );
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Could not load offer history'), findsOneWidget);
    });
  });

  group('OfferHistoryScreen (VEN-S14 CSV Export)', () {
    testWidgets('tapping Export CSV triggers repo export and opens download URL',
        (tester) async {
      final repo = FakeOfferHistoryRepository(
        exportDto: PerformanceExportDto(
          downloadUrl:
              'https://storage.karathive.ae/exports/vendor-perf-123.csv',
          expiresAt: DateTime.utc(2026, 9, 10),
        ),
      );
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? openedUrl;
      await tester.pumpWidget(
        _host(
          repo: repo,
          openUrl: (url) async {
            openedUrl = url;
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final exportBtn = find.byKey(const Key('offer-history-export-button'));
      expect(exportBtn, findsOneWidget);
      await tester.tap(exportBtn);
      await tester.pumpAndSettle();

      expect(repo.exportCalls, 1);
      expect(openedUrl,
          'https://storage.karathive.ae/exports/vendor-perf-123.csv');
    });

    testWidgets('shows loading indicator on button while exporting',
        (tester) async {
      final repo = FakeOfferHistoryRepository(hangExport: true);
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      final exportBtn = find.byKey(const Key('offer-history-export-button'));
      expect(exportBtn, findsOneWidget);
      await tester.tap(exportBtn);
      await tester.pump();

      expect(
        find.byKey(const Key('offer-history-export-loading')),
        findsOneWidget,
      );
    });

    testWidgets('shows error snackbar when CSV export fails',
        (tester) async {
      final repo = FakeOfferHistoryRepository(
        exportFailure: const ServerFailure(
            message: 'CSV export failed. Try again later.'),
      );
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(repo: repo));
      await tester.pumpAndSettle();

      final exportBtn = find.byKey(const Key('offer-history-export-button'));
      expect(exportBtn, findsOneWidget);
      await tester.tap(exportBtn);
      await tester.pumpAndSettle();

      expect(repo.exportCalls, 1);
      expect(find.text('CSV export failed. Try again later.'), findsOneWidget);
    });
  });
}
