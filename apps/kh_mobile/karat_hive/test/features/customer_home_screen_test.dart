import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_controller.dart';
import 'package:karat_hive/features/request_create/pending_publish_intent.dart';
import 'package:karat_hive/features/request_manage/presentation/customer_home_screen.dart';
import 'package:karat_hive/features/request_manage/repository/request_manage_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_session.dart';

class _MockRepo extends Mock implements RequestManageRepository {}

GoRouter _testRouter() => GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const CustomerHomeScreen(),
        ),
        GoRoute(
          path: '/customer/requests',
          builder: (_, __) => const SizedBox(),
        ),
        GoRoute(
          path: '/customer/connections',
          builder: (_, __) => const SizedBox(),
        ),
        GoRoute(
          path: '/customer/requests/create/ornament',
          builder: (_, __) => const SizedBox(),
        ),
        GoRoute(
          path: '/customer/requests/create/sell-gold',
          builder: (_, __) => const SizedBox(),
        ),
        GoRoute(
          path: '/customer/requests/create/coins',
          builder: (_, __) => const SizedBox(),
        ),
        GoRoute(
          path: '/customer/requests/create/bullion',
          builder: (_, __) => const SizedBox(),
        ),
        GoRoute(
          path: '/customer/requests/create',
          builder: (_, __) => const SizedBox(),
        ),
      ],
    );

Widget _host(List<Override> overrides, {GoRouter? router}) => ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        theme: khTheme(),
        routerConfig: router ?? _testRouter(),
        localizationsDelegates: const [
          ...KhStrings.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: KhStrings.supportedLocales,
      ),
    );

class _PendingPublishIntentTrue extends PendingPublishIntent {
  @override
  bool build() => true;
}

SignedIn _signedInCustomer() => SignedIn(
      MeUser(
        userId: 'u2',
        userType: 'CUSTOMER',
        mobileNumber: '+971500000002',
        preferredLanguage: 'en',
        liveRequestCount: 2,
        customer: testCustomerMe(connectionCount: 3),
      ),
    );

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.listMine(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          state: any(named: 'state'),
          requestType: any(named: 'requestType'),
          direction: any(named: 'direction'),
          q: any(named: 'q'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer(
      (_) async => const Ok(
        PagedResult<RequestForCustomer>(items: [], nextCursor: null),
      ),
    );
  });

  testWidgets('Customer Home dashboard shows hero, services, summary; no History',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host([
      requestManageRepositoryProvider.overrideWithValue(repo),
      sessionProvider.overrideWith(
        () => FakeSessionController(_signedInCustomer()),
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-home-hero')), findsOneWidget);
    expect(find.byKey(const Key('customer-type-ornament')), findsOneWidget);
    expect(find.byKey(const Key('customer-type-sell-gold')), findsOneWidget);
    expect(find.byKey(const Key('customer-type-coins')), findsOneWidget);
    expect(find.byKey(const Key('customer-type-bullion')), findsOneWidget);
    expect(find.byKey(const Key('summary-open')), findsOneWidget);
    expect(find.byKey(const Key('summary-offers')), findsOneWidget);
    expect(find.byKey(const Key('summary-connections')), findsOneWidget);
    expect(find.byKey(const Key('open-history')), findsNothing);
    expect(find.byKey(const Key('quick-create')), findsOneWidget);
  });

  testWidgets('Tapping a request type updates requestCreateController',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        requestManageRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(
          () => FakeSessionController(_signedInCustomer()),
        ),
      ],
    );

    final router = _testRouter();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: khTheme(),
          routerConfig: router,
          localizationsDelegates: const [
            ...KhStrings.delegates,
            AppLocalizations.delegate,
          ],
          supportedLocales: KhStrings.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('customer-type-sell-gold')));
    await tester.pumpAndSettle();

    expect(
      container.read(requestCreateControllerProvider).requestType,
      RequestType.sellOldGold,
    );
  });

  testWidgets(
      'renders _RetryPublicationBanner without layout overflow when publish is pending',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        requestManageRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(
          () => FakeSessionController(_signedInCustomer()),
        ),
        pendingPublishIntentProvider.overrideWith(_PendingPublishIntentTrue.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: khTheme(),
          routerConfig: _testRouter(),
          localizationsDelegates: const [
            ...KhStrings.delegates,
            AppLocalizations.delegate,
          ],
          supportedLocales: KhStrings.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your request could not be published yet.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
