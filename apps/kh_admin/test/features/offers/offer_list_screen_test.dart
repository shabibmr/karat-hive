import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/offers/model/offer_enums.dart';
import 'package:kh_admin/features/offers/model/offer_list_filters.dart';
import 'package:kh_admin/features/offers/model/offer_list_item.dart';
import 'package:kh_admin/features/offers/model/offer_list_page.dart';
import 'package:kh_admin/features/offers/presentation/offer_list_screen.dart';
import 'package:kh_admin/features/offers/repository/offer_repository.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

class _FakeOfferRepository extends OfferRepository {
  _FakeOfferRepository() : super(ApiClient());

  bool empty = false;
  bool failNext = false;
  OfferListFilters? lastFilters;

  @override
  Future<OfferListPage> fetchOffers({
    OfferListFilters filters = const OfferListFilters(),
    String? cursor,
    int limit = OfferRepository.defaultPageSize,
  }) async {
    lastFilters = filters;
    if (failNext) throw Exception('Offers service unavailable');
    if (empty) return const OfferListPage(items: [], totalCount: 0);

    return OfferListPage(
      items: [
        OfferListItem(
          id: 'off-1',
          reference: 'OFF-2026-9921',
          requestId: 'req-1',
          requestReference: 'KH-RQ-2026-01482',
          requestType: RequestType.findOrnament,
          vendorId: 'ven-1',
          vendorName: 'Al Noor Jewellery LLC',
          offeredPrice: 14850.0,
          makingCharges: 450.0,
          state: OfferState.pending,
          submittedAt: DateTime(2026, 8, 10, 5, 12),
          expiresAt: DateTime(2026, 8, 12, 5, 12),
          outcome: 'Pending Customer Review',
        ),
        OfferListItem(
          id: 'off-2',
          reference: 'OFF-2026-9810',
          requestId: 'req-2',
          requestReference: 'KH-RQ-2026-01491',
          requestType: RequestType.sellOldGold,
          vendorId: 'ven-2',
          vendorName: 'Dubai Gold Crafts',
          offeredPrice: 18900.0,
          state: OfferState.accepted,
          submittedAt: DateTime(2026, 8, 9, 14, 30),
          expiresAt: DateTime(2026, 8, 11, 14, 30),
          outcome: 'Accepted by Customer',
        ),
      ],
      totalCount: 2,
    );
  }
}

void main() {
  late _FakeOfferRepository fakeRepository;

  setUp(() {
    fakeRepository = _FakeOfferRepository();
  });

  Widget createOfferListWidget() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: OfferListScreen(),
          ),
        ),
        GoRoute(
          path: '/offers/:id',
          builder: (context, state) => Scaffold(
            body: Text('Offer Detail ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        offerRepositoryProvider.overrideWithValue(fakeRepository),
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

  testWidgets('OfferListScreen renders header, table, and offers correctly',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createOfferListWidget());
    await tester.pumpAndSettle();

    expect(find.text('MARKETPLACE AUDIT'), findsOneWidget);
    expect(find.text('Offers'), findsOneWidget);
    expect(
      find.text('Platform-wide vendor offer monitoring and inspection'),
      findsOneWidget,
    );

    // Table and rows
    expect(find.byKey(const Key('offer-list-table')), findsOneWidget);
    expect(find.text('OFF-2026-9921'), findsOneWidget);
    expect(find.text('KH-RQ-2026-01482'), findsOneWidget);
    expect(find.text('Al Noor Jewellery LLC'), findsOneWidget);
    expect(find.text('AED 14,850.00'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);

    expect(find.text('OFF-2026-9810'), findsOneWidget);
    expect(find.text('Dubai Gold Crafts'), findsOneWidget);
    expect(find.text('AED 18,900.00'), findsOneWidget);
    expect(find.text('ACCEPTED'), findsOneWidget);

    // Inspect buttons
    expect(find.byKey(const Key('inspect-offer-off-1')), findsOneWidget);
    expect(find.byKey(const Key('inspect-offer-off-2')), findsOneWidget);
  });

  testWidgets('OfferListScreen shows empty view when no offers found',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeRepository.empty = true;

    await tester.pumpWidget(createOfferListWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offer-empty-view')), findsOneWidget);
    expect(find.text('No offers found'), findsOneWidget);
  });

  testWidgets('OfferListScreen shows error view on failure with retry',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeRepository.failNext = true;

    await tester.pumpWidget(createOfferListWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offer-error-view')), findsOneWidget);
    expect(find.text('Offers service unavailable'), findsOneWidget);
    expect(find.byKey(const Key('offer-retry-button')), findsOneWidget);

    // Clicking retry after fixing error
    fakeRepository.failNext = false;
    await tester.tap(find.byKey(const Key('offer-retry-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offer-list-table')), findsOneWidget);
  });

  testWidgets('OfferListScreen filters by state and search text',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createOfferListWidget());
    await tester.pumpAndSettle();

    // Select state filter
    await tester.tap(find.byKey(const Key('offer-filter-state')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending').last);
    await tester.pumpAndSettle();

    expect(fakeRepository.lastFilters?.state, OfferState.pending);

    // Enter search text and submit
    await tester.enterText(
      find.byKey(const Key('offer-filter-search')),
      'Al Noor',
    );
    await tester.tap(find.byKey(const Key('offer-search-button')));
    await tester.pumpAndSettle();

    expect(fakeRepository.lastFilters?.query, 'Al Noor');
  });

  testWidgets('Row or Inspect button click navigates to /offers/:id',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createOfferListWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('inspect-offer-off-1')));
    await tester.pumpAndSettle();

    expect(find.text('Offer Detail off-1'), findsOneWidget);
  });
}
