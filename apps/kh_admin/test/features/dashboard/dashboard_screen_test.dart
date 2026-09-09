import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_queue_item.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kh_admin/features/dashboard/repository/dashboard_repository.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';
import 'package:kh_admin/features/reports/model/report_name.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Routes the dashboard drills into. Each renders a marker so a tap can be
/// asserted without pulling in the real shell.
const List<String> _targetRoutes = [
  '/customers',
  '/vendors',
  '/requests',
  '/offers',
  '/connections',
  '/reports',
  '/verification',
  '/abuse',
  '/moderation',
];

final _kLiveVerification = DashboardQueueItem(
  id: 'ven-live-1',
  subject: 'Live Gold Trading LLC',
  reference: 'CN-555001',
  type: 'KYC Verification',
  status: 'PENDING',
  actionLabel: 'Review KYC',
  route: '/verification',
  kind: DashboardQueueKind.verification,
  submittedAt: DateTime.utc(2026, 8, 10, 1, 30),
);

final _kLiveAbuse = DashboardQueueItem(
  id: 'ab-live-1',
  subject: 'Report #ab-live-1',
  reference: 'Off-platform payment demand',
  type: 'Abuse Report',
  status: 'OPEN',
  actionLabel: 'Inspect',
  route: '/abuse',
  kind: DashboardQueueKind.abuse,
  submittedAt: DateTime.utc(2026, 8, 10, 0, 12),
);

final _kLiveReview = DashboardQueueItem(
  id: 'rev-live-1',
  subject: 'Review #rev-live-1',
  reference: 'By Sara Customer',
  type: 'Review Moderation',
  status: 'MODERATION',
  actionLabel: 'Approve',
  route: '/moderation',
  kind: DashboardQueueKind.review,
  submittedAt: DateTime.utc(2026, 8, 9, 18, 40),
);

class _MockDashboardRepository implements DashboardRepository {
  _MockDashboardRepository({
    this.throwError = false,
    this.delay,
    this.throwAbuse = false,
    this.throwTrend = false,
    this.emptyTrend = false,
    List<DashboardQueueItem>? verificationItems,
    List<DashboardQueueItem>? abuseItems,
    List<DashboardQueueItem>? reviewItems,
  })  : verificationItems = verificationItems ?? <DashboardQueueItem>[_kLiveVerification],
        abuseItems = abuseItems ?? <DashboardQueueItem>[_kLiveAbuse],
        reviewItems = reviewItems ?? <DashboardQueueItem>[_kLiveReview];

  bool throwTrend;
  bool emptyTrend;
  int trendFetchCount = 0;
  ReportFilters? lastTrendFilters;
  DateTime? lastStatsFrom;
  DateTime? lastStatsTo;

  @override
  Future<ReportResult> fetchTrend(ReportFilters filters) async {
    trendFetchCount++;
    lastTrendFilters = filters;
    if (throwTrend) {
      throw Exception('reports/request-volume unavailable');
    }
    return ReportResult(
      name: ReportName.requestVolume,
      generatedAt: DateTime.utc(2026, 9, 9),
      rows: emptyTrend
          ? const []
          : const [
              {'state': 'OPEN', 'count': 12},
              {'state': 'CONNECTED', 'count': 4},
            ],
    );
  }

  final DashboardStats stats = const DashboardStats(
    totalCustomers: 1420,
    totalVendors: 185,
    pendingVerificationVendors: 7,
    activeRequests: 890,
    activeOffers: 2340,
    activeConnections: 512,
  );
  bool throwError;
  Completer<DashboardStats>? delay;
  int fetchCount = 0;

  final List<DashboardQueueItem> verificationItems;
  final List<DashboardQueueItem> abuseItems;
  final List<DashboardQueueItem> reviewItems;
  bool throwVerification = false;
  bool throwAbuse = false;
  bool throwReviews = false;

  @override
  Future<DashboardStats> fetchStats({DateTime? from, DateTime? to}) async {
    fetchCount++;
    lastStatsFrom = from;
    lastStatsTo = to;
    if (delay != null) {
      return delay!.future;
    }
    if (throwError) {
      throw Exception('Failed to connect to /v1/admin/dashboard');
    }
    return stats;
  }

  @override
  Future<List<DashboardQueueItem>> fetchVerificationSnapshot() async {
    if (throwVerification) {
      throw Exception('verification-queue unavailable');
    }
    return verificationItems;
  }

  @override
  Future<List<DashboardQueueItem>> fetchAbuseSnapshot() async {
    if (throwAbuse) {
      throw Exception('abuse-reports unavailable');
    }
    return abuseItems;
  }

  @override
  Future<List<DashboardQueueItem>> fetchPendingReviewsSnapshot() async {
    if (throwReviews) {
      throw Exception('reviews unavailable');
    }
    return reviewItems;
  }
}

Widget createDashboardWidget({List<Override> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: DashboardScreen()),
      ),
      for (final route in _targetRoutes)
        GoRoute(
          path: route,
          builder: (context, state) => Scaffold(
            body: Text(
              'LANDED $route${state.uri.hasQuery ? '?${state.uri.query}' : ''}',
            ),
          ),
        ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
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

void main() {
  /// The metric grid is width-driven, so every test pins a desktop viewport;
  /// at test defaults the six tiles would stack and overflow.
  Future<void> pumpDesktopDashboard(
    WidgetTester tester, {
    List<Override> overrides = const [],
    _MockDashboardRepository? repository,
  }) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final defaultOverrides = [
      dashboardRepositoryProvider.overrideWithValue(
        repository ?? _MockDashboardRepository(),
      ),
      ...overrides,
    ];

    await tester.pumpWidget(createDashboardWidget(overrides: defaultOverrides));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the ADM-S02 header with the operational status chip',
      (tester) async {
    await pumpDesktopDashboard(tester);

    expect(find.text('PLATFORM OVERVIEW'), findsOneWidget);
    expect(find.text('Admin Control Center'), findsOneWidget);
    expect(
      find.byKey(const Key('dashboard-system-status-chip')),
      findsOneWidget,
    );
  });

  testWidgets('renders six metric cards with real dynamic data', (tester) async {
    await pumpDesktopDashboard(tester);

    expect(find.byType(KhMetricCard), findsNWidgets(6));
    expect(find.text('1,420'), findsOneWidget);
    expect(find.text('185'), findsOneWidget);
    expect(find.text('Vendor List (7 KYC pending) →'), findsOneWidget);
    expect(find.text('890'), findsOneWidget);
    expect(find.text('2,340'), findsOneWidget);
    expect(find.text('512'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('KYC QUEUE'), findsOneWidget);
    expect(find.text('AED 4.2M'), findsNothing);
    expect(find.text('PLATFORM STATISTICS'), findsNothing);
  });

  testWidgets('marks every figure on the screen as synchronized with dashboard endpoint',
      (tester) async {
    await pumpDesktopDashboard(tester);

    final notice = find.byKey(const Key('dashboard-sample-data-notice'));
    expect(notice, findsOneWidget);
    expect(
      find.descendant(
        of: notice,
        matching: find.textContaining('/v1/admin/dashboard'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: notice,
        matching: find.textContaining('not implemented'),
      ),
      findsNothing,
    );
  });

  testWidgets('tapping the Customers metric navigates to the customer list',
      (tester) async {
    await pumpDesktopDashboard(tester);

    await tester.tap(find.byKey(const Key('metric-card-customers')));
    await tester.pumpAndSettle();

    expect(find.text('LANDED /customers'), findsOneWidget);
  });

  testWidgets('dashboard figures drill into the pre-filtered list (TR-S6-05)',
      (tester) async {
    Future<void> tapMetric(String key, String expected) async {
      await pumpDesktopDashboard(tester);
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      expect(find.text(expected), findsOneWidget);
    }

    await tapMetric('metric-card-kyc queue',
        'LANDED /vendors?verificationState=PENDING_VERIFICATION');
    await tapMetric('metric-card-requests', 'LANDED /requests?state=PUBLISHED');
    await tapMetric('metric-card-offers', 'LANDED /offers?state=PENDING');
    await tapMetric(
        'metric-card-connections', 'LANDED /connections?state=ACTIVE');
  });

  testWidgets('the verification queue row deep-links to the selected item',
      (tester) async {
    await pumpDesktopDashboard(tester);

    await tester.tap(find.text('Review KYC'));
    await tester.pumpAndSettle();

    expect(find.text('LANDED /verification?selectedId=ven-live-1'),
        findsOneWidget);
  });

  testWidgets('quick action queue lists live snapshot rows with working actions',
      (tester) async {
    await pumpDesktopDashboard(tester);

    expect(find.byKey(const Key('dashboard-queue-table')), findsOneWidget);
    expect(
      find.byKey(const Key('queue-row-verification-ven-live-1')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('queue-row-abuse-ab-live-1')), findsOneWidget);
    expect(
      find.byKey(const Key('queue-row-review-rev-live-1')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Al Noor Jewellery LLC', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('Live Gold Trading LLC', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Report #ab-live-1', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Review #rev-live-1', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('Review KYC'));
    await tester.pumpAndSettle();

    expect(find.text('LANDED /verification?selectedId=ven-live-1'),
        findsOneWidget);
  });

  testWidgets('empty queues show an empty table message, not sample rows',
      (tester) async {
    await pumpDesktopDashboard(
      tester,
      repository: _MockDashboardRepository(
        verificationItems: const [],
        abuseItems: const [],
        reviewItems: const [],
      ),
    );

    expect(find.byKey(const Key('dashboard-queue-table')), findsOneWidget);
    expect(find.byKey(const Key('dashboard-queue-empty')), findsOneWidget);
    expect(find.text('No items in the action queues.'), findsOneWidget);
    expect(find.text('Al Noor Jewellery LLC'), findsNothing);
    expect(find.text('Review KYC'), findsNothing);
  });

  testWidgets('a failing queue source shows a retry chip, not a silent omission',
      (tester) async {
    final repo = _MockDashboardRepository(throwAbuse: true);
    await pumpDesktopDashboard(tester, repository: repo);

    // Stats and the healthy sources are unaffected.
    expect(find.byKey(const Key('dashboard-error-banner')), findsNothing);
    expect(find.text('1,420'), findsOneWidget);
    expect(
      find.byKey(const Key('queue-row-verification-ven-live-1')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('queue-row-review-rev-live-1')), findsOneWidget);

    // The abuse source failed: a per-source error chip with a retry (TR-S6-02),
    // not a vanished row that reads as "0 pending" (ADM-INS-61).
    expect(
      find.byKey(const Key('dashboard-queue-source-error-abuse')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('dashboard-queue-source-retry-abuse')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('queue-row-abuse-ab-live-1')), findsNothing);

    // Retry once the endpoint recovers.
    repo.throwAbuse = false;
    await tester.tap(
      find.byKey(const Key('dashboard-queue-source-retry-abuse')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('dashboard-queue-source-error-abuse')),
      findsNothing,
    );
    expect(find.byKey(const Key('queue-row-abuse-ab-live-1')), findsOneWidget);
  });

  testWidgets('changing the date range refetches the dashboard (TR-S6-03)',
      (tester) async {
    final repo = _MockDashboardRepository();
    await pumpDesktopDashboard(tester, repository: repo);

    final before = repo.fetchCount;
    expect(find.byKey(const Key('dashboard-range-selector')), findsOneWidget);

    await tester.tap(find.byKey(const Key('dashboard-range-chip-7')));
    await tester.pumpAndSettle();

    expect(repo.fetchCount, greaterThan(before));
    expect(repo.lastStatsFrom, isNotNull);
    expect(
      repo.lastStatsTo!.difference(repo.lastStatsFrom!).inDays,
      7,
    );
  });

  testWidgets('renders a range-scoped trend chart (TR-S6-04)', (tester) async {
    await pumpDesktopDashboard(tester);

    expect(find.byKey(const Key('dashboard-trend-section')), findsOneWidget);
    expect(find.byKey(const Key('dashboard-trend-chart')), findsOneWidget);
  });

  testWidgets('trend shows an empty placeholder when the series is empty',
      (tester) async {
    await pumpDesktopDashboard(
      tester,
      repository: _MockDashboardRepository(emptyTrend: true),
    );

    expect(find.byKey(const Key('dashboard-trend-empty')), findsOneWidget);
    expect(find.byKey(const Key('dashboard-trend-chart')), findsNothing);
  });

  testWidgets('a failing trend source shows a retry, not a blank section',
      (tester) async {
    final repo = _MockDashboardRepository(throwTrend: true);
    await pumpDesktopDashboard(tester, repository: repo);

    expect(find.byKey(const Key('dashboard-trend-error')), findsOneWidget);

    repo.throwTrend = false;
    await tester.tap(find.byKey(const Key('dashboard-trend-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard-trend-error')), findsNothing);
    expect(find.byKey(const Key('dashboard-trend-chart')), findsOneWidget);
  });

  testWidgets('shows loading metrics while dashboard stats are in flight',
      (tester) async {
    final delay = Completer<DashboardStats>();
    final mockRepo = _MockDashboardRepository(delay: delay);

    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      createDashboardWidget(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockRepo),
        ],
      ),
    );
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('—'), findsWidgets);
    expect(find.text('AED 4.2M'), findsNothing);

    delay.complete(mockRepo.stats);
    await tester.pumpAndSettle();
    expect(find.text('1,420'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('shows error banner when fetching stats fails and retries',
      (tester) async {
    final mockRepo = _MockDashboardRepository(throwError: true);

    await pumpDesktopDashboard(
      tester,
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );

    expect(find.byKey(const Key('dashboard-error-banner')), findsOneWidget);
    expect(
      find.textContaining('Failed to load dashboard metrics'),
      findsOneWidget,
    );

    // Now make repo succeed and tap Retry
    mockRepo.throwError = false;
    await tester.tap(find.byKey(const Key('dashboard-error-retry-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard-error-banner')), findsNothing);
    expect(find.text('1,420'), findsOneWidget);
  });
}
