import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/auth/presentation/guest_landing_screen.dart';
import 'package:karat_hive/features/auth/presentation/widgets/how_this_works.dart';
import 'package:karat_hive/features/request_create/controller/request_create_controller.dart';
import 'package:karat_hive/features/request_create/routes.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../helpers/fake_session.dart';

Widget _app({required GoRouter router, List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      sessionProvider.overrideWith(
        () => FakeSessionController(const SignedOut()),
      ),
      ...overrides,
    ],
    child: MaterialApp.router(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      routerConfig: router,
    ),
  );
}

GoRouter _landingRouter({String initialLocation = AppGuards.guestLanding}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppGuards.guestLanding,
        builder: (_, __) => const GuestLandingScreen(),
      ),
      GoRoute(
        path: AppGuards.customerOnboarding,
        builder: (_, __) => const Scaffold(body: Text('login-stub')),
      ),
      GoRoute(
        path: AppGuards.register,
        builder: (_, __) => const Scaffold(body: Text('register-stub')),
      ),
      GoRoute(
        path: RequestCreatePaths.ornament,
        builder: (_, __) => const Scaffold(body: Text('ornament-compose')),
      ),
      GoRoute(
        path: RequestCreatePaths.sellGold,
        builder: (_, __) => const Scaffold(body: Text('sell-gold-compose')),
      ),
      GoRoute(
        path: RequestCreatePaths.coins,
        builder: (_, __) => const Scaffold(body: Text('coins-compose')),
      ),
      GoRoute(
        path: RequestCreatePaths.bullion,
        builder: (_, __) => const Scaffold(body: Text('bullion-compose')),
      ),
    ],
  );
}

void main() {
  testWidgets('HowThisWorks shows shared steps plus one extra line', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        localizationsDelegates: KhStrings.delegates,
        supportedLocales: KhStrings.supportedLocales,
        home: const Scaffold(
          body: HowThisWorks(
            initiallyExpanded: true,
            extras: ['Bullion minimum applies.'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('how-this-works')), findsOneWidget);
    expect(find.text('How this works'), findsOneWidget);
    expect(
      find.text('Post a Request describing what you need'),
      findsOneWidget,
    );
    expect(
      find.text('Verified jewellers send competing Offers'),
      findsOneWidget,
    );
    expect(
      find.text('Accept one Offer — identities are revealed'),
      findsOneWidget,
    );
    expect(find.text('Continue the conversation on WhatsApp'), findsOneWidget);
    expect(find.text('Bullion minimum applies.'), findsOneWidget);
  });

  testWidgets('landing shows four type cards, login, and jeweller footer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = _landingRouter();
    await tester.pumpWidget(_app(router: router));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('guest-landing')), findsOneWidget);
    expect(find.byKey(const Key('guest-type-ornament')), findsOneWidget);
    expect(find.byKey(const Key('guest-type-sell-gold')), findsOneWidget);
    expect(find.byKey(const Key('guest-type-coins')), findsOneWidget);
    expect(find.byKey(const Key('guest-type-bullion')), findsOneWidget);
    expect(find.byKey(const Key('guest-login')), findsOneWidget);
    expect(find.byKey(const Key('guest-jeweller')), findsOneWidget);
    expect(find.byKey(const Key('how-this-works')), findsNWidgets(4));

    expect(find.byType(FilledButton), findsNothing);
    expect(find.text('Find jewellery'), findsOneWidget);
    expect(find.text('Sell my gold'), findsOneWidget);
    expect(find.text('Coins'), findsOneWidget);
    expect(find.text('Bullion'), findsOneWidget);
    expect(find.text('Are you a jeweller? Register here.'), findsOneWidget);
  });

  testWidgets('how-it-works expands under a card', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = _landingRouter();
    await tester.pumpWidget(_app(router: router));
    await tester.pumpAndSettle();

    expect(
      find.text('A minimum indicative value applies to bullion Requests.'),
      findsNothing,
    );

    final bullionCard = find.byKey(const Key('guest-type-bullion'));
    await tester.tap(
      find.descendant(of: bullionCard, matching: find.text('How this works')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('A minimum indicative value applies to bullion Requests.'),
      findsOneWidget,
    );
  });

  testWidgets('Log in navigates to customer onboarding stub', (tester) async {
    final router = _landingRouter();
    await tester.pumpWidget(_app(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('guest-login')));
    await tester.pumpAndSettle();

    expect(find.text('login-stub'), findsOneWidget);
    expect(router.state.uri.path, AppGuards.customerOnboarding);
  });

  testWidgets('jeweller footer navigates to vendor register stub', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = _landingRouter();
    await tester.pumpWidget(_app(router: router));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('guest-jeweller')));
    await tester.tap(find.byKey(const Key('guest-jeweller')));
    await tester.pumpAndSettle();

    expect(find.text('register-stub'), findsOneWidget);
    expect(router.state.uri.path, AppGuards.register);
  });

  testWidgets('jeweller mid-create drops draft then opens vendor register', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = _landingRouter();
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionController(const SignedOut()),
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp.router(
              theme: khTheme(),
              localizationsDelegates: KhStrings.delegates,
              supportedLocales: KhStrings.supportedLocales,
              routerConfig: router,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final create = container.read(requestCreateControllerProvider.notifier);
    create.selectType(RequestType.findOrnament);
    create.setNotes('guest mid-create draft');
    create.setWeightGrams('12.5');
    expect(
      container.read(requestCreateControllerProvider).requestType,
      RequestType.findOrnament,
    );
    expect(
      container.read(requestCreateControllerProvider).notes,
      'guest mid-create draft',
    );

    await tester.ensureVisible(find.byKey(const Key('guest-jeweller')));
    await tester.tap(find.byKey(const Key('guest-jeweller')));
    await tester.pumpAndSettle();

    final after = container.read(requestCreateControllerProvider);
    expect(after.requestType, isNull);
    expect(after.notes, isEmpty);
    expect(after.weightGrams, isNull);
    expect(find.text('register-stub'), findsOneWidget);
    expect(router.state.uri.path, AppGuards.register);
  });

  testWidgets('ornament card sets RequestType and opens compose path', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = _landingRouter();
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionController(const SignedOut()),
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp.router(
              theme: khTheme(),
              localizationsDelegates: KhStrings.delegates,
              supportedLocales: KhStrings.supportedLocales,
              routerConfig: router,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('guest-type-ornament')),
        matching: find.text('Find jewellery'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(requestCreateControllerProvider).requestType,
      RequestType.findOrnament,
    );
    expect(find.text('ornament-compose'), findsOneWidget);
    expect(router.state.uri.path, RequestCreatePaths.ornament);
  });
}
