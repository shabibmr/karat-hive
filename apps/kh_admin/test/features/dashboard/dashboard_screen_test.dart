import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/features/dashboard/presentation/dashboard_screen.dart';
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

Widget createDashboardWidget() {
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

  return MaterialApp.router(
    theme: buildKhAdminTheme(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

void main() {
  /// The metric grid is width-driven, so every test pins a desktop viewport;
  /// at test defaults the six tiles would stack and overflow.
  Future<void> pumpDesktopDashboard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createDashboardWidget());
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

  testWidgets('renders six metric cards', (tester) async {
    await pumpDesktopDashboard(tester);

    expect(find.byType(KhMetricCard), findsNWidgets(6));
    expect(find.text('1,420'), findsOneWidget);
    expect(find.text('AED 4.2M'), findsOneWidget);
  });

  testWidgets('marks every figure on the screen as sample data',
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
}
