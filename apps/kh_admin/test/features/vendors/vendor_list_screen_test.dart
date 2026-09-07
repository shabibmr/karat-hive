import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_filters.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_item.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_page.dart';
import 'package:kh_admin/features/vendors/presentation/vendor_list_screen.dart';
import 'package:kh_admin/features/vendors/repository/vendor_repository.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

class _FakeVendorRepository extends VendorRepository {
  _FakeVendorRepository() : super(ApiClient());

  bool empty = false;
  bool failNext = false;

  @override
  Future<VendorListPage> fetchVendors({
    VendorListFilters filters = const VendorListFilters(),
    String? cursor,
    int limit = VendorRepository.defaultPageSize,
  }) async {
    if (failNext) throw Exception('Vendor service unavailable');
    if (empty) return const VendorListPage(items: []);

    return const VendorListPage(
      items: [
        VendorListItem(
          id: 'vendor-verified',
          legalBusinessName: 'Al Noor Jewellery LLC',
          tradingName: 'Al Noor',
          verificationState: VendorVerificationState.verified,
          accountState: VendorAccountState.active,
        ),
        VendorListItem(
          id: 'vendor-pending',
          legalBusinessName: 'Sharjah Heritage Gold',
          tradingName: 'Heritage',
          verificationState: VendorVerificationState.pendingVerification,
          accountState: VendorAccountState.active,
          waitingHours: 48,
        ),
      ],
    );
  }
}

void main() {
  late _FakeVendorRepository fakeRepository;

  setUp(() {
    fakeRepository = _FakeVendorRepository();
  });

  Widget createVendorListWidget() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: VendorListScreen(),
          ),
        ),
        GoRoute(
          path: '/verification',
          builder: (context, state) =>
              const Scaffold(body: Text('Verification Queue')),
        ),
        GoRoute(
          path: '/vendors/:id',
          builder: (context, state) => Scaffold(
            body: Text('Vendor ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        vendorRepositoryProvider.overrideWithValue(fakeRepository),
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
    );
  }

  testWidgets('VendorListScreen renders vendor table with waiting age', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createVendorListWidget());
    await tester.pumpAndSettle();

    expect(find.text('VENDOR MANAGEMENT'), findsOneWidget);
    expect(find.text('Vendors'), findsOneWidget);
    expect(find.byKey(const Key('vendor-list-table')), findsOneWidget);
    expect(find.text('Al Noor Jewellery LLC'), findsOneWidget);
    expect(find.text('Sharjah Heritage Gold'), findsOneWidget);
    expect(find.text('48h waiting'), findsOneWidget);
    expect(find.text('Review KYC'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
  });

  testWidgets('VendorListScreen shows empty state when no vendors match',
      (tester) async {
    fakeRepository.empty = true;

    await tester.pumpWidget(createVendorListWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vendor-empty-view')), findsOneWidget);
    expect(find.text('No vendors found'), findsOneWidget);
  });

  testWidgets('VendorListScreen shows error view on fetch failure', (tester) async {
    fakeRepository.failNext = true;

    await tester.pumpWidget(createVendorListWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vendor-error-view')), findsOneWidget);
    expect(find.text('Vendor service unavailable'), findsOneWidget);
    expect(find.byKey(const Key('vendor-retry-button')), findsOneWidget);
  });

  testWidgets('pending vendor action navigates to verification queue', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createVendorListWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('vendor-action-vendor-pending')));
    await tester.pumpAndSettle();

    expect(find.text('Verification Queue'), findsOneWidget);
  });
}
