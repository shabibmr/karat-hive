import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/app/shells/customer_shell.dart';
import 'package:karat_hive/features/notifications/controller/notifications_controller.dart';
import 'package:karat_hive/features/request_manage/presentation/customer_home_screen.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../helpers/fake_session.dart';

void main() {
  testWidgets('Customer Home photographic reference at phone size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 870);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      for (final family in ['CormorantGaramond', 'DMSans']) {
        final loader = FontLoader('packages/kh_design_system/$family');
        loader.addFont(
          rootBundle.load('packages/kh_design_system/fonts/$family-500.ttf'),
        );
        await loader.load();
      }
    });

    final router = GoRouter(
      initialLocation: AppGuards.customerHome,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => CustomerShell(navigationShell: shell),
          branches: [
            for (final path in [
              AppGuards.customerHome,
              AppGuards.customerRequests,
              AppGuards.customerConnections,
              AppGuards.customerAlerts,
              AppGuards.customerProfile,
            ])
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: path,
                    builder: (_, __) => path == AppGuards.customerHome
                        ? const CustomerHomeScreen()
                        : const SizedBox(),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationsProvider.overrideWith((ref) async => true),
          sessionProvider.overrideWith(
            () => FakeSessionController(
              SignedIn(
                testCustomerUser(customer: testCustomerMe(displayName: 'Sara')),
              ),
            ),
          ),
        ],
        child: RepaintBoundary(
          key: const Key('home-reference-render'),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: KhTheme.light().copyWith(platform: TargetPlatform.iOS),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(top: 32, bottom: 34),
                viewPadding: const EdgeInsets.only(top: 32, bottom: 34),
                disableAnimations: true,
              ),
              child: child!,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(CustomerHomeScreen));
      for (final name in [
        'hero-bangle',
        'ornament',
        'sell-gold',
        'coins',
        'bullion',
      ]) {
        await precacheImage(AssetImage('assets/home/$name.png'), context);
      }
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('home-reference-render')),
      matchesGoldenFile('goldens/customer_home_reference.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
