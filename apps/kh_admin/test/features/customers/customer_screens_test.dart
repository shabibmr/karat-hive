import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';
import 'package:kh_admin/features/customers/model/customer_list_item.dart';
import 'package:kh_admin/features/customers/model/customer_list_page.dart';
import 'package:kh_admin/features/customers/presentation/customer_detail_screen.dart';
import 'package:kh_admin/features/customers/presentation/customer_list_screen.dart';
import 'package:kh_admin/features/customers/repository/customer_repository.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository() : super(ApiClient());

  bool empty = false;
  bool failNext = false;
  Completer<CustomerListPage>? listDelay;
  Completer<CustomerDetail>? detailDelay;

  @override
  Future<CustomerListPage> fetchCustomers({
    CustomerListFilters filters = const CustomerListFilters(),
    String? cursor,
    int limit = CustomerRepository.defaultPageSize,
  }) async {
    if (listDelay != null) {
      return listDelay!.future;
    }
    if (failNext) throw Exception('Customer service unavailable');
    if (empty) return const CustomerListPage(items: []);

    return CustomerListPage(
      items: [
        CustomerListItem(
          id: 'cust-1',
          userId: 'user-1',
          displayName: 'Fatima Al Mansoori',
          email: 'fatima@example.ae',
          mobileNumber: '+971501234567',
          accountState: CustomerAccountState.active,
          requestCount: 3,
          createdAt: DateTime.parse('2026-08-10T12:00:00.000Z'),
        ),
      ],
    );
  }

  @override
  Future<CustomerDetail> fetchCustomerDetail(String customerId) async {
    if (detailDelay != null) {
      return detailDelay!.future;
    }
    if (failNext) throw Exception('Customer not found');

    return CustomerDetail(
      id: customerId,
      userId: 'user-$customerId',
      displayName: 'Fatima Al Mansoori',
      email: 'fatima@example.ae',
      mobileNumber: '+971501234567',
      accountState: CustomerAccountState.active,
      defaultRegion: 'Dubai',
      createdAt: DateTime.parse('2026-08-01T10:00:00.000Z'),
    );
  }
}

void main() {
  late _FakeCustomerRepository fakeRepository;

  setUp(() {
    fakeRepository = _FakeCustomerRepository();
  });

  Widget createListWidget() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: CustomerListScreen(),
          ),
        ),
        GoRoute(
          path: '/customers/:id',
          builder: (context, state) => Scaffold(
            body: Text('Customer ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        customerRepositoryProvider.overrideWithValue(fakeRepository),
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

  Widget createDetailWidget({String customerId = 'cust-1'}) {
    final router = GoRouter(
      initialLocation: '/customers/$customerId',
      routes: [
        GoRoute(
          path: '/customers',
          builder: (context, state) =>
              const Scaffold(body: Text('Back to Customers')),
        ),
        GoRoute(
          path: '/customers/:id',
          builder: (context, state) => CustomerDetailScreen(
            customerId: state.pathParameters['id']!,
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        customerRepositoryProvider.overrideWithValue(fakeRepository),
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

  group('CustomerListScreen (ADM-S03)', () {
    testWidgets('shows loading indicator while the first page is in flight',
        (tester) async {
      fakeRepository.listDelay = Completer<CustomerListPage>();

      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createListWidget());
      await tester.pump();

      expect(find.byKey(const Key('customer-list-loading')), findsOneWidget);

      fakeRepository.listDelay!.complete(
        const CustomerListPage(items: []),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('renders customer table with PII audit notice', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createListWidget());
      await tester.pumpAndSettle();

      expect(find.text('Customers'), findsOneWidget);
      expect(find.byKey(const Key('pii-audit-notice-banner')), findsOneWidget);
      expect(find.byKey(const Key('customer-list-table')), findsOneWidget);
      expect(find.text('Fatima Al Mansoori'), findsOneWidget);

      await tester.tap(find.byKey(const Key('customer-action-view-cust-1')));
      await tester.pumpAndSettle();
      expect(find.text('Customer cust-1'), findsOneWidget);
    });

    testWidgets('shows empty state when no customers match', (tester) async {
      fakeRepository.empty = true;

      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createListWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer-list-empty')), findsOneWidget);
      expect(find.text('No customers found'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      fakeRepository.failNext = true;

      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createListWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer-list-error')), findsOneWidget);
      expect(find.text('Customer service unavailable'), findsOneWidget);
      expect(find.byKey(const Key('customer-retry-button')), findsOneWidget);
    });
  });

  group('CustomerDetailScreen (ADM-S04)', () {
    testWidgets('shows loading indicator while detail is in flight',
        (tester) async {
      fakeRepository.detailDelay = Completer<CustomerDetail>();

      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDetailWidget());
      await tester.pump();

      expect(find.byKey(const Key('customer-detail-loading')), findsOneWidget);

      fakeRepository.detailDelay!.complete(
        const CustomerDetail(
          id: 'cust-1',
          userId: 'user-1',
          displayName: 'Fatima Al Mansoori',
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('renders profile and lifecycle actions', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDetailWidget());
      await tester.pumpAndSettle();

      expect(find.text('Fatima Al Mansoori'), findsWidgets);
      expect(find.byKey(const Key('customer-summary-card')), findsOneWidget);
      expect(find.byKey(const Key('customer-suspend-button')), findsOneWidget);
      expect(find.byKey(const Key('customer-erasure-button')), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      fakeRepository.failNext = true;

      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDetailWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer-detail-error')), findsOneWidget);
      expect(find.text('Failed to load customer profile'), findsOneWidget);
      expect(find.byKey(const Key('customer-detail-retry-button')), findsOneWidget);
    });
  });
}
