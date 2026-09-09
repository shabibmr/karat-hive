import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/features/request_feed/presentation/request_detail_screen.dart';
import 'package:karat_hive/features/request_feed/repository/request_feed_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

VendorRequestItem _testRequest({
  String id = 'req-test-101',
  String reference = 'REQ-2026-0101',
  String state = 'PUBLISHED',
  DateTime? expiresAt,
}) {
  return VendorRequestItem(
    id: id,
    reference: reference,
    requestType: 'FIND_ORNAMENT',
    direction: 'BUY',
    state: state,
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
      dealCount: 3,
    ),
    publishedAt: DateTime.utc(2026, 9, 7, 0, 0),
    expiresAt: expiresAt ?? DateTime.utc(2026, 9, 12, 0, 0),
  );
}

class _FakeRequestFeedRepository implements RequestFeedRepository {
  _FakeRequestFeedRepository({required this.request});

  VendorRequestItem request;

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
  }) async =>
      Ok(PagedResult(items: [request]));

  @override
  Future<Result<VendorRequestItem>> getRequest(String id) async => Ok(request);

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
  Future<Result<VendorDashboard>> getDashboard() async =>
      const Ok(VendorDashboard(newRequests: 1, pendingOffers: 0, activeConnections: 0, reviewCount: 0));
}

GoRouter _buildRouter({
  required String initialLocation,
  void Function(Uri uri)? onAbuseRouteVisited,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/vendor/requests/:requestId',
        builder: (context, state) => RequestDetailScreen(
          requestId: state.pathParameters['requestId']!,
        ),
      ),
      GoRoute(
        path: '/abuse/new',
        builder: (context, state) {
          onAbuseRouteVisited?.call(state.uri);
          return Scaffold(
            body: Text(
              'Abuse Destination targetType=${state.uri.queryParameters['targetType']}&targetId=${state.uri.queryParameters['targetId']}',
            ),
          );
        },
      ),
    ],
  );
}

void main() {
  group('RequestDetailScreen Report Abuse Entry (VEN-S08)', () {
    testWidgets(
      'tapping Report this request in overflow menu navigates to /abuse/new?targetType=REQUEST&targetId=...',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repo = _FakeRequestFeedRepository(
          request: _testRequest(id: 'req-abc-123'),
        );

        Uri? visitedUri;
        final router = _buildRouter(
          initialLocation: '/vendor/requests/req-abc-123',
          onAbuseRouteVisited: (uri) => visitedUri = uri,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              requestFeedRepositoryProvider.overrideWithValue(repo),
            ],
            child: MaterialApp.router(
              theme: khTheme(),
              localizationsDelegates: KhStrings.delegates,
              supportedLocales: KhStrings.supportedLocales,
              routerConfig: router,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Overflow menu button in AppBar exists
        final overflowFinder = find.byKey(const Key('request-detail-overflow-menu'));
        expect(overflowFinder, findsOneWidget);

        // Tap the overflow menu button
        await tester.tap(overflowFinder);
        await tester.pumpAndSettle();

        // Menu item "Report this request" appears
        final reportMenuItemFinder = find.text('Report this request');
        expect(reportMenuItemFinder, findsOneWidget);

        // Tap the report option
        await tester.tap(reportMenuItemFinder);
        await tester.pumpAndSettle();

        // Verifies navigation to /abuse/new with query parameters
        expect(visitedUri, isNotNull);
        expect(visitedUri!.path, '/abuse/new');
        expect(visitedUri!.queryParameters['targetType'], 'REQUEST');
        expect(visitedUri!.queryParameters['targetId'], 'req-abc-123');
        expect(
          find.text('Abuse Destination targetType=REQUEST&targetId=req-abc-123'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'report action is available when request is expired',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repo = _FakeRequestFeedRepository(
          request: _testRequest(
            id: 'req-expired-999',
            expiresAt: DateTime.utc(2026, 9, 1, 0, 0),
          ),
        );

        Uri? visitedUri;
        final router = _buildRouter(
          initialLocation: '/vendor/requests/req-expired-999',
          onAbuseRouteVisited: (uri) => visitedUri = uri,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              requestFeedRepositoryProvider.overrideWithValue(repo),
            ],
            child: MaterialApp.router(
              theme: khTheme(),
              localizationsDelegates: KhStrings.delegates,
              supportedLocales: KhStrings.supportedLocales,
              routerConfig: router,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final overflowFinder = find.byKey(const Key('request-detail-overflow-menu'));
        expect(overflowFinder, findsOneWidget);

        await tester.tap(overflowFinder);
        await tester.pumpAndSettle();

        final reportMenuItemFinder = find.text('Report this request');
        expect(reportMenuItemFinder, findsOneWidget);

        await tester.tap(reportMenuItemFinder);
        await tester.pumpAndSettle();

        expect(visitedUri, isNotNull);
        expect(visitedUri!.path, '/abuse/new');
        expect(visitedUri!.queryParameters['targetType'], 'REQUEST');
        expect(visitedUri!.queryParameters['targetId'], 'req-expired-999');
      },
    );
  });
}
