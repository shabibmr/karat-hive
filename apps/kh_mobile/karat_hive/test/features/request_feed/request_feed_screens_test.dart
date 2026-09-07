import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/request_feed/controller/request_feed_controller.dart';
import 'package:karat_hive/features/onboarding/repository/onboarding_repository.dart';
import 'package:karat_hive/features/request_feed/presentation/request_detail_screen.dart';
import 'package:karat_hive/features/request_feed/presentation/request_feed_screen.dart';
import 'package:karat_hive/features/request_feed/presentation/request_filters_sheet.dart';
import 'package:karat_hive/features/request_feed/presentation/vendor_dashboard_screen.dart';
import 'package:karat_hive/features/request_feed/repository/request_feed_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

VendorRequestItem _testRequest({
  String id = 'req-test-1',
  String? reference = 'REQ-2026-0001',
  int offerCount = 3,
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
    offerCount: offerCount,
    customer: const MaskedParty(
      role: UserRole.customer,
      region: 'Dubai',
      dealCount: 5,
    ),
    publishedAt: DateTime.utc(2026, 9, 7, 0, 0),
    expiresAt: DateTime.utc(2026, 9, 9, 0, 0),
  );
}

class FakeRequestFeedRepository implements RequestFeedRepository {
  FakeRequestFeedRepository({
    this.requests = const [],
    this.dashboardData,
    this.matchesError,
    this.requestError,
    this.dashboardError,
    this.hangMatches = false,
    this.hangRequest = false,
    this.hangDashboard = false,
  });

  final List<VendorRequestItem> requests;
  final VendorDashboard? dashboardData;
  final Failure? matchesError;
  final Failure? requestError;
  final Failure? dashboardError;
  final bool hangMatches;
  final bool hangRequest;
  final bool hangDashboard;

  @override
  Future<Result<PagedResult<VendorRequestItem>>> getMatches({
    String? cursor,
    int limit = 20,
    String? sort,
    String? requestType,
    String? categoryId,
    String? regionId,
    double? minBudget,
    double? maxBudget,
    String? purityKarat,
    bool? includeResponded,
    String? presetId,
  }) async {
    if (hangMatches) await Completer<void>().future;
    if (matchesError != null) return Err(matchesError!);
    return Ok(PagedResult(items: requests));
  }

  @override
  Future<Result<VendorRequestItem>> getRequest(String id) async {
    if (hangRequest) await Completer<void>().future;
    if (requestError != null) return Err(requestError!);
    final item = requests.firstWhere((r) => r.id == id, orElse: () => _testRequest(id: id));
    return Ok(item);
  }

  @override
  Future<Result<void>> markViewed(String requestId) async => const Ok(null);

  @override
  Future<Result<List<FilterPresetItem>>> getFilterPresets() async => const Ok([]);

  @override
  Future<Result<FilterPresetItem>> createFilterPreset({
    required String name,
    required Map<String, dynamic> filters,
  }) async =>
      Ok(FilterPresetItem(id: 'pre-1', name: name, filters: filters, createdAt: DateTime.now()));

  @override
  Future<Result<FilterPresetItem>> updateFilterPreset(
    String id, {
    String? name,
    Map<String, dynamic>? filters,
  }) async =>
      Ok(FilterPresetItem(id: id, name: name ?? '', filters: filters ?? const {}, createdAt: DateTime.now()));

  @override
  Future<Result<void>> deleteFilterPreset(String id) async => const Ok(null);

  @override
  Future<Result<VendorDashboard>> getDashboard() async {
    if (hangDashboard) await Completer<void>().future;
    if (dashboardError != null) return Err(dashboardError!);
    return Ok(dashboardData ??
        const VendorDashboard(
          newRequests: 4,
          pendingOffers: 2,
          activeConnections: 1,
          ratingAverage: 4.8,
          reviewCount: 10,
          subscriptions: [
            VendorSubscriptionItem(
              requestType: 'FIND_ORNAMENT',
              state: 'ACTIVE',
              priceAed: '499.00',
              canOffer: true,
            ),
          ],
        ));
  }
}

class FakeSessionController extends SessionController {
  @override
  SessionState build() => const SignedOut();
}

class _SeededRequestFiltersController extends RequestFiltersController {
  _SeededRequestFiltersController(this._seed);

  final RequestFiltersState _seed;

  @override
  RequestFiltersState build() => _seed;
}

void main() {
  group('RequestFeedScreen (VEN-S06)', () {
    testWidgets('renders empty state when matching feed is empty', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(requests: const []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestFeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('request-feed-screen')), findsOneWidget);
      expect(find.text('No Matching Requests'), findsOneWidget);
      expect(find.text('Available Requests'), findsOneWidget);
      expect(find.byKey(const Key('empty-feed-subscriptions-cta')), findsOneWidget);
    });

    testWidgets('renders request items with masked customer and expiry countdown', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(requests: [_testRequest()]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestFeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(VendorRequestCard), findsOneWidget);
      expect(find.text('REQ-2026-0001'), findsOneWidget);
      expect(find.text('Rings'), findsOneWidget);
      expect(find.text('22K'), findsOneWidget);
      expect(find.text('3 offers'), findsOneWidget);

      // CRITICAL MASKING CHECK (BR-006 / AD-FE-07):
      // Customer real name and mobile MUST NOT exist in the widget tree
      expect(find.textContaining('+971'), findsNothing);
      expect(find.textContaining('Customer Name'), findsNothing);
      expect(find.byType(MaskedPartyLabel), findsOneWidget);
    });

    testWidgets('shows responded marker when hasResponded is true', (tester) async {
      final responded = VendorRequestItem(
        id: 'req-responded',
        reference: 'REQ-RESPONDED',
        requestType: 'FIND_ORNAMENT',
        direction: 'BUY',
        state: 'OFFERS_RECEIVED',
        categoryId: 'cat-ring',
        categoryName: 'Rings',
        regionId: 'reg-dxb',
        regionName: 'Dubai',
        purityKarat: '22',
        offerCount: 1,
        hasResponded: true,
        customer: const MaskedParty(
          role: UserRole.customer,
          region: 'Dubai',
          dealCount: 2,
        ),
        expiresAt: DateTime.utc(2026, 9, 9, 0, 0),
      );
      final fakeRepo = FakeRequestFeedRepository(requests: [responded]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestFeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('responded-marker')), findsOneWidget);
      expect(find.text('Responded'), findsOneWidget);
    });

    testWidgets('empty state with active filters shows Reset Filters CTA and clears on tap',
        (tester) async {
      final fakeRepo = FakeRequestFeedRepository(requests: const []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
            requestFiltersProvider.overrideWith(
              () => _SeededRequestFiltersController(
                const RequestFiltersState(
                  requestType: 'BULLION',
                  includeResponded: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: RequestFeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Matching Requests'), findsOneWidget);
      expect(
        find.text('Try resetting your active filters to see more requests.'),
        findsOneWidget,
      );
      expect(find.text('Reset Filters'), findsOneWidget);
      expect(find.byKey(const Key('empty-feed-subscriptions-cta')), findsNothing);

      await tester.tap(find.text('Reset Filters'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty-feed-subscriptions-cta')), findsOneWidget);
      expect(find.text('Reset Filters'), findsNothing);
      expect(
        find.textContaining('Broaden your Categories and Regions'),
        findsOneWidget,
      );
    });

    testWidgets('filter button opens RequestFiltersSheet', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(requests: [_testRequest()]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
            categoriesProvider.overrideWith(
              (ref) async => const [
                TaxonomyNode(id: 'cat-ring', nameEn: 'Rings', nameAr: 'خواتم'),
              ],
            ),
            regionsProvider.overrideWith(
              (ref) async => const [
                TaxonomyNode(id: 'reg-dxb', nameEn: 'Dubai', nameAr: 'دبي'),
              ],
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            home: const RequestFeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filter-button')));
      await tester.pumpAndSettle();

      expect(find.byType(RequestFiltersSheet), findsOneWidget);
      expect(find.text('Filter Requests'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });

    testWidgets('shows KhLoadingView while matching feed is loading', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(hangMatches: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestFeedScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(KhLoadingView), findsOneWidget);
      expect(find.byKey(const Key('loading-view')), findsOneWidget);
    });

    testWidgets('shows KhErrorView when matching feed fails (SH-FND-13)', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(
        matchesError: const ServerFailure(message: 'feed unavailable'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestFeedScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KhErrorView), findsOneWidget);
      expect(find.byKey(const Key('error-view')), findsOneWidget);
      expect(find.text('Failed to load matching requests.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('RequestDetailScreen (VEN-S08)', () {
    testWidgets('renders detail spec, masked customer label, and competitor blindness warning', (tester) async {
      final item = _testRequest(id: 'req-999', reference: 'REQ-DETAIL-999');
      final fakeRepo = FakeRequestFeedRepository(requests: [item]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestDetailScreen(requestId: 'req-999'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('request-detail-screen')), findsOneWidget);
      expect(find.text('REQ-DETAIL-999'), findsOneWidget);
      expect(find.byType(SpecificationGrid), findsOneWidget);
      expect(find.byType(MaskedPartyLabel), findsOneWidget);
      expect(find.textContaining('Competitor pricing and terms are hidden'), findsOneWidget);

      // Customer identity absent
      expect(find.textContaining('mobileNumber'), findsNothing);
      expect(find.textContaining('customer.name'), findsNothing);
    });

    testWidgets('shows KhLoadingView while request detail is loading', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(hangRequest: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestDetailScreen(requestId: 'req-loading'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(KhLoadingView), findsOneWidget);
      expect(find.byKey(const Key('loading-view')), findsOneWidget);
    });

    testWidgets('shows KhErrorView when request detail fails (SH-FND-13)', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(
        requestError: const ServerFailure(message: 'request unavailable'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestDetailScreen(requestId: 'req-error'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KhErrorView), findsOneWidget);
      expect(find.byKey(const Key('error-view')), findsOneWidget);
      expect(find.text('Could not load request details.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  /// CP2-B09 / AD-FE-07: pre-acceptance feed+detail must only hold MaskedParty
  /// and must not render identity fields even if a leaky fixture includes them.
  group('AD-FE-07 client masking (CP2-B09)', () {
    late VendorRequestItem leakyMaskedItem;

    setUp(() {
      leakyMaskedItem = VendorRequestItem.fromJson({
        'id': 'req-leaky-1',
        'reference': 'REQ-LEAKY-1',
        'requestType': 'FIND_ORNAMENT',
        'direction': 'BUY',
        'state': 'PUBLISHED',
        'categoryId': 'cat-ring',
        'category': {'nameEn': 'Rings'},
        'regionId': 'reg-dxb',
        'region': {'nameEn': 'Dubai'},
        'purityKarat': '22',
        'weightGrams': 15.0,
        'budgetMin': 4000.0,
        'budgetMax': 5500.0,
        'offerCount': 2,
        'publishedAt': '2026-09-07T00:00:00.000Z',
        'expiresAt': '2026-09-09T00:00:00.000Z',
        'customer': {
          'name': 'Fatima Al Zahra',
          'mobile': '+971559876543',
          'address': 'Villa 12, Jumeirah',
          'role': 'CUSTOMER',
          'region': 'Dubai',
          'dealCount': 4,
        },
      });
    });

    test('VendorRequestItem from leaky payload is MaskedParty, not RevealedParty', () {
      expect(leakyMaskedItem.customer, isA<MaskedParty>());
      expect(leakyMaskedItem.customer is RevealedParty, isFalse);
      expect(leakyMaskedItem.customer.isMasked, isTrue);
      expect(leakyMaskedItem.customer.displayPseudonym, 'Customer in Dubai');
    });

    testWidgets('RequestFeedScreen never surfaces customer name or mobile', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(requests: [leakyMaskedItem]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestFeedScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VendorRequestCard), findsOneWidget);
      expect(find.byType(MaskedPartyLabel), findsOneWidget);
      expect(find.text('Customer in Dubai'), findsOneWidget);

      expect(find.text('Fatima Al Zahra'), findsNothing);
      expect(find.textContaining('+971559876543'), findsNothing);
      expect(find.textContaining('Villa 12'), findsNothing);
    });

    testWidgets('RequestDetailScreen never surfaces customer name or mobile', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(requests: [leakyMaskedItem]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RequestDetailScreen(requestId: 'req-leaky-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('request-detail-screen')), findsOneWidget);
      expect(find.byType(MaskedPartyLabel), findsOneWidget);
      expect(find.text('Customer in Dubai'), findsOneWidget);

      expect(find.text('Fatima Al Zahra'), findsNothing);
      expect(find.textContaining('+971559876543'), findsNothing);
      expect(find.textContaining('Villa 12'), findsNothing);
    });
  });

  group('VendorDashboardScreen (VEN-S05)', () {
    testWidgets('renders real aggregate counts and deep link cards', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(
        dashboardData: VendorDashboard(
          newRequests: 5,
          newRequestPreview: [_testRequest(id: 'preview-1')],
          pendingOffers: 3,
          pendingOffersExpiringWithin24h: 1,
          activeConnections: 2,
          activeConnectionsNoTalkCount: 1,
          ratingAverage: 4.8,
          reviewCount: 10,
          subscriptions: const [
            VendorSubscriptionItem(
              requestType: 'FIND_ORNAMENT',
              state: 'ACTIVE',
              priceAed: '499.00',
              canOffer: true,
            ),
            VendorSubscriptionItem(
              requestType: 'CUSTOM_DESIGN',
              state: 'ACTIVE',
              priceAed: '299.00',
              canOffer: true,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
            sessionProvider.overrideWith(FakeSessionController.new),
          ],
          child: const MaterialApp(
            home: VendorDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard-new-requests')), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.byKey(const Key('dashboard-preview-preview-1')), findsOneWidget);
      expect(find.textContaining('expiring within 24h'), findsOneWidget);
      expect(find.textContaining('with no talk yet'), findsOneWidget);
    });

    testWidgets('shows KhLoadingView while dashboard is loading', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(hangDashboard: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
            sessionProvider.overrideWith(FakeSessionController.new),
          ],
          child: const MaterialApp(
            home: VendorDashboardScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(KhLoadingView), findsOneWidget);
      expect(find.byKey(const Key('loading-view')), findsOneWidget);
    });

    testWidgets('shows KhErrorView when dashboard fails (SH-FND-13)', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(
        dashboardError: const ServerFailure(message: 'dashboard unavailable'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
            sessionProvider.overrideWith(FakeSessionController.new),
          ],
          child: const MaterialApp(
            home: VendorDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KhErrorView), findsOneWidget);
      expect(find.byKey(const Key('error-view')), findsOneWidget);
      expect(find.text('Could not load your dashboard.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows KhEmptyView when dashboard aggregates are zero (SH-FND-12)', (tester) async {
      final fakeRepo = FakeRequestFeedRepository(
        dashboardData: const VendorDashboard(
          newRequests: 0,
          pendingOffers: 0,
          activeConnections: 0,
          ratingAverage: null,
          reviewCount: 0,
          subscriptions: [],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestFeedRepositoryProvider.overrideWithValue(fakeRepo),
            sessionProvider.overrideWith(FakeSessionController.new),
          ],
          child: const MaterialApp(
            home: VendorDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KhEmptyView), findsOneWidget);
      expect(find.byKey(const Key('empty-view')), findsOneWidget);
      expect(find.text('Nothing here yet'), findsOneWidget);
    });
  });
}
