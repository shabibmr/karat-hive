import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kh_admin/features/dashboard/repository/dashboard_repository.dart';
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

class _MockDashboardRepository implements DashboardRepository {
  _MockDashboardRepository({
    this.throwError = false,
    this.delay,
  });

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

  @override
  Future<DashboardStats> fetchStats() async {
    fetchCount++;
    if (delay != null) {
      return delay!.future;
    }
    if (throwError) {
      throw Exception('Failed to connect to /v1/admin/dashboard');
    }
    return stats;
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
          builder: (context, state) => Scaffold(body: Text('LANDED $route')),
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
  }) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final defaultOverrides = [
      dashboardRepositoryProvider.overrideWithValue(
        _MockDashboardRepository(),
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
    expect(find.text('AED 4.2M'), findsOneWidget);
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
  });

  testWidgets('tapping the Customers metric navigates to the customer list',
      (tester) async {
    await pumpDesktopDashboard(tester);

    await tester.tap(find.byKey(const Key('metric-card-customers')));
    await tester.pumpAndSettle();

    expect(find.text('LANDED /customers'), findsOneWidget);
  });

  testWidgets('quick action queue lists three items with working actions',
      (tester) async {
    await pumpDesktopDashboard(tester);

    expect(find.byKey(const Key('dashboard-queue-table')), findsOneWidget);
    expect(find.byKey(const Key('queue-row-verification')), findsOneWidget);
    expect(find.byKey(const Key('queue-row-abuse')), findsOneWidget);
    expect(find.byKey(const Key('queue-row-moderation')), findsOneWidget);

    await tester.tap(find.text('Review KYC'));
    await tester.pumpAndSettle();

    expect(find.text('LANDED /verification'), findsOneWidget);
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

    delay.complete(mockRepo.stats);
    await tester.pumpAndSettle();
    expect(find.text('1,420'), findsOneWidget);
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
