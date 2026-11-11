import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/src/internals.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/app/shells/vendor_shell.dart';
import 'package:karat_hive/features/guest/presentation/guest_landing_screen.dart';
import 'package:karat_hive/features/notifications/controller/notifications_controller.dart';
import 'package:karat_hive/features/request_create/presentation/widgets/create_flow_chrome.dart';
import 'package:karat_hive/features/request_create/routes.dart';
import 'package:karat_hive/features/request_manage/presentation/customer_home_screen.dart';
import 'package:karat_hive/features/request_manage/repository/request_manage_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_session.dart';

class _MockRepo extends Mock implements RequestManageRepository {}

class _Surface {
  const _Surface(this.size, this.textScale);
  final Size size;
  final double textScale;

  String get label =>
      '${size.width.toInt()}x${size.height.toInt()} scale $textScale';
}

const _surfaces = <_Surface>[
  _Surface(Size(320, 568), 1),
  _Surface(Size(390, 844), 1),
  _Surface(Size(1024, 768), 1),
  _Surface(Size(390, 844), 2),
];

void _useSurface(WidgetTester tester, _Surface surface) {
  tester.view.physicalSize = surface.size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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

GoRouter _homeRouter() => GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (_, __) => const CustomerHomeScreen()),
    GoRoute(path: '/customer/requests', builder: (_, __) => const SizedBox()),
    GoRoute(
      path: '/customer/connections',
      builder: (_, __) => const SizedBox(),
    ),
    GoRoute(
      path: '/customer/alerts',
      builder: (_, __) => const SizedBox(),
    ),
    GoRoute(
      path: '/customer/profile',
      builder: (_, __) => const SizedBox(),
    ),
  ],
);

Widget _homeHost(_Surface surface, List<Override> overrides) {
  return ProviderScope(
    overrides: [
      unreadNotificationsProvider.overrideWith((ref) async => false),
      ...overrides,
    ],
    child: MaterialApp.router(
      theme: KhTheme.light(locale: const Locale('en')),
      locale: const Locale('en'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(surface.textScale),
        ),
        child: child!,
      ),
      routerConfig: _homeRouter(),
      localizationsDelegates: const [
        ...KhStrings.delegates,
        AppLocalizations.delegate,
      ],
      supportedLocales: KhStrings.supportedLocales,
    ),
  );
}

GoRouter _guestRouter() => GoRouter(
  initialLocation: AppGuards.customerGuest,
  routes: [
    GoRoute(
      path: AppGuards.customerGuest,
      builder: (_, __) => const GuestLandingScreen(),
    ),
    GoRoute(
      path: AppGuards.customerOnboarding,
      builder: (_, __) => const Scaffold(body: Text('login-stub')),
    ),
    GoRoute(
      path: RequestCreatePaths.ornament,
      builder: (_, __) => const Scaffold(body: Text('ornament-compose')),
    ),
  ],
);

Widget _guestHost(_Surface surface) {
  return ProviderScope(
    overrides: [
      sessionProvider.overrideWith(
        () => FakeSessionController(const SignedOut()),
      ),
    ],
    child: MaterialApp.router(
      theme: khTheme(),
      locale: const Locale('en'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(surface.textScale),
        ),
        child: child!,
      ),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      routerConfig: _guestRouter(),
    ),
  );
}

Widget _createHost(_Surface surface) {
  return MaterialApp(
    theme: khTheme(),
    locale: const Locale('en'),
    localizationsDelegates: KhStrings.delegates,
    supportedLocales: KhStrings.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(surface.textScale),
      ),
      child: child!,
    ),
    home: CreateFlowChrome(
      title: 'Find',
      bottom: DraftActions(
        busy: false,
        onSaveDraft: () {},
        onContinue: () {},
      ),
      child: const SizedBox(
        key: Key('create-probe'),
        width: double.infinity,
        height: 8,
      ),
    ),
  );
}

Widget _navHost(_Surface surface, Widget bar) {
  return MaterialApp(
    theme: khTheme(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(surface.textScale),
      ),
      child: child!,
    ),
    home: Scaffold(bottomNavigationBar: bar),
  );
}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(
      () => repo.listMine(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
        state: any(named: 'state'),
        requestType: any(named: 'requestType'),
        direction: any(named: 'direction'),
        q: any(named: 'q'),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer(
      (_) async => const Ok(
        PagedResult<RequestForCustomer>(items: [], nextCursor: null),
      ),
    );
  });

  for (final surface in _surfaces) {
    testWidgets('Customer home lays out at ${surface.label}', (tester) async {
      _useSurface(tester, surface);
      await tester.pumpWidget(
        _homeHost(surface, [
          requestManageRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(
            () => FakeSessionController(_signedInCustomer()),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      if (surface.size.width == 1024) {
        expect(tester.getSize(find.byType(ListView).first).width, 560);
      }
    });

    testWidgets('Guest landing lays out at ${surface.label}', (tester) async {
      _useSurface(tester, surface);
      await tester.pumpWidget(_guestHost(surface));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      if (surface.size.width == 1024) {
        expect(tester.getSize(find.byType(ListView).first).width, 560);
      }
    });

    testWidgets('Create flow lays out at ${surface.label}', (tester) async {
      _useSurface(tester, surface);
      await tester.pumpWidget(_createHost(surface));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      if (surface.size.width == 1024) {
        expect(tester.getSize(find.byKey(const Key('create-probe'))).width, 560);
      }
      if (surface.size.width == 320) {
        expect(
          tester.widget<Flex>(find.byKey(const Key('create-draft-actions'))),
          isA<Column>(),
        );
      }
    });

    testWidgets('tab bars lay out at ${surface.label}', (tester) async {
      _useSurface(tester, surface);
      await tester.pumpWidget(
        _navHost(
          surface,
          KhBottomNav(
            editorial: true,
            currentIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              KhNavDestination(label: 'Home', icon: Icons.home_outlined),
              KhNavDestination(
                label: 'My Requests',
                icon: Icons.list_alt_outlined,
              ),
              KhNavDestination(label: 'Connections', icon: Icons.link_outlined),
              KhNavDestination(label: 'Profile', icon: Icons.person_outline),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _navHost(
          surface,
          VendorBottomNav(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
