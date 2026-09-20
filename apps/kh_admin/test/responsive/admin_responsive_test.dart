import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/shell/kh_admin_scaffold.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_queue_item.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kh_admin/features/dashboard/repository/dashboard_repository.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';
import 'package:kh_admin/features/reports/model/report_name.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_kind.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_node.dart';
import 'package:kh_admin/features/taxonomy/presentation/taxonomy_screen.dart';
import 'package:kh_admin/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// The Admin Portal is desktop-first but must stay usable everywhere: a
/// RenderFlex overflow anywhere in this sweep fails the test, because
/// `flutter_test` reports layout overflow as an unhandled exception.
const List<({String name, Size size})> _viewports = [
  (name: 'phone portrait', size: Size(360, 800)),
  (name: 'large phone', size: Size(414, 896)),
  (name: 'phone landscape', size: Size(800, 360)),
  (name: 'tablet portrait', size: Size(768, 1024)),
  (name: 'tablet landscape', size: Size(1024, 768)),
  (name: 'small laptop', size: Size(1280, 800)),
  (name: 'desktop', size: Size(1920, 1080)),
];

class _FakeTaxonomyRepository extends TaxonomyRepository {
  _FakeTaxonomyRepository() : super(ApiClient());

  static const _tree = [
    TaxonomyNode(
      id: 'cat-jewellery',
      nameEn: 'Bridal & Fine Necklaces',
      nameAr: 'قلائد مجوهرات',
      displayOrder: 1,
    ),
    TaxonomyNode(
      id: 'cat-rings',
      nameEn: 'Rings & Diamond Bands',
      nameAr: 'خواتم وألماس',
      displayOrder: 2,
      isActive: false,
    ),
  ];

  @override
  Future<List<TaxonomyNode>> fetchCategories({bool includeInactive = true}) async =>
      _tree;

  @override
  Future<List<TaxonomyNode>> fetchRegions({bool includeInactive = true}) async =>
      _tree;
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStats> fetchStats({DateTime? from, DateTime? to}) async =>
      const DashboardStats(
        totalCustomers: 120,
        totalVendors: 45,
        pendingVerificationVendors: 3,
        activeRequests: 80,
        activeOffers: 210,
        activeConnections: 55,
      );

  @override
  Future<List<DashboardQueueItem>> fetchVerificationSnapshot() async => const [];

  @override
  Future<List<DashboardQueueItem>> fetchAbuseSnapshot() async => const [];

  @override
  Future<List<DashboardQueueItem>> fetchPendingReviewsSnapshot() async => const [];

  @override
  Future<ReportResult> fetchTrend(ReportFilters filters) async => ReportResult(
        name: ReportName.requestVolume,
        generatedAt: DateTime.utc(2026, 9, 9),
        rows: const [
          {'state': 'OPEN', 'count': 12},
          {'state': 'CONNECTED', 'count': 4},
        ],
      );
}

Widget _app(Widget home, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
      ...overrides,
    ],
    child: MaterialApp(
      theme: buildKhAdminTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: home),
    ),
  );
}

void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    Size size,
    Widget widget,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  for (final viewport in _viewports) {
    testWidgets('dashboard lays out cleanly on ${viewport.name}',
        (tester) async {
      await pumpAt(tester, viewport.size, _app(const DashboardScreen()));

      expect(find.text('Admin Control Center'), findsOneWidget);
      expect(find.byKey(const Key('dashboard-queue-table')), findsOneWidget);
    });

    testWidgets('category management lays out cleanly on ${viewport.name}',
        (tester) async {
      await pumpAt(
        tester,
        viewport.size,
        _app(
          const TaxonomyScreen(kind: TaxonomyKind.category),
          overrides: [
            taxonomyRepositoryProvider
                .overrideWithValue(_FakeTaxonomyRepository()),
          ],
        ),
      );

      expect(find.text('Product Categories'), findsOneWidget);
      expect(find.byKey(const Key('taxonomy-add-root-button')), findsOneWidget);
    });

    testWidgets('admin shell lays out cleanly on ${viewport.name}',
        (tester) async {
      final router = GoRouter(
        routes: [
          ShellRoute(
            builder: (context, state, child) => KhAdminScaffold(child: child),
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
        ],
      );

      tester.view.physicalSize = viewport.size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardRepositoryProvider
                .overrideWithValue(_FakeDashboardRepository()),
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
        ),
      );
      await tester.pumpAndSettle();

      // Sidebar is permanent from the desktop breakpoint up, a drawer below it.
      final isDesktop = viewport.size.width >= kDesktopBreakpoint;
      expect(
        find.text('Karat Hive Portal'),
        isDesktop ? findsOneWidget : findsNothing,
      );
    });
  }
}
