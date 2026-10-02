import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/request_create/presentation/widgets/create_flow_chrome.dart';
import 'package:karat_hive/features/request_create/routes.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../helpers/fake_session.dart';

void main() {
  testWidgets('create-flow AppBar back pops to previous route', (tester) async {
    final router = GoRouter(
      initialLocation: AppGuards.customerGuest,
      routes: [
        GoRoute(
          path: AppGuards.customerGuest,
          builder: (_, __) => const Scaffold(body: Text('guest-home')),
        ),
        GoRoute(
          path: RequestCreatePaths.ornament,
          builder: (_, __) => const CreateFlowChrome(
            title: 'Find An Ornament',
            child: Text('compose-body'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionController(const SignedOut()),
          ),
        ],
        child: MaterialApp.router(
          theme: khTheme(),
          localizationsDelegates: KhStrings.delegates,
          supportedLocales: KhStrings.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    router.push(RequestCreatePaths.ornament);
    await tester.pumpAndSettle();
    expect(find.text('compose-body'), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-flow-back')));
    await tester.pumpAndSettle();

    expect(find.text('guest-home'), findsOneWidget);
    expect(find.text('compose-body'), findsNothing);
  });

  testWidgets('create-flow AppBar back goes Guest when stack is empty',
      (tester) async {
    final router = GoRouter(
      initialLocation: RequestCreatePaths.ornament,
      routes: [
        GoRoute(
          path: AppGuards.customerGuest,
          builder: (_, __) => const Scaffold(body: Text('guest-home')),
        ),
        GoRoute(
          path: RequestCreatePaths.ornament,
          builder: (_, __) => const CreateFlowChrome(
            title: 'Find An Ornament',
            child: Text('compose-body'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionController(const SignedOut()),
          ),
        ],
        child: MaterialApp.router(
          theme: khTheme(),
          localizationsDelegates: KhStrings.delegates,
          supportedLocales: KhStrings.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('compose-body'), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-flow-back')));
    await tester.pumpAndSettle();

    expect(find.text('guest-home'), findsOneWidget);
  });
}
