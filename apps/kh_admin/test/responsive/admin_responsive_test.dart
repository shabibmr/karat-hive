import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/shell/kh_admin_scaffold.dart';
import 'package:kh_admin/features/dashboard/presentation/dashboard_screen.dart';
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
      children: [
        TaxonomyNode(
          id: 'cat-rings',
          parentId: 'cat-jewellery',
          nameEn: 'Rings & Diamond Bands',
          nameAr: 'خواتم وألماس',
          displayOrder: 1,
          isActive: false,
        ),
      ],
    ),
  ];

  @override
  Future<List<TaxonomyNode>> fetchCategories({bool includeInactive = true}) async =>
      _tree;

  @override
  Future<List<TaxonomyNode>> fetchRegions({bool includeInactive = true}) async =>
      _tree;
}

Widget _app(Widget home, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
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
