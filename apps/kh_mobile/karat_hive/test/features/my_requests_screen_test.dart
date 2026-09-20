import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/features/request_manage/presentation/my_requests_screen.dart';
import 'package:karat_hive/features/request_manage/repository/request_manage_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements RequestManageRepository {}

GoRouter _testRouter() => GoRouter(
      initialLocation: '/customer/requests',
      routes: [
        GoRoute(
          path: '/customer/requests',
          builder: (_, __) => const MyRequestsScreen(),
        ),
        GoRoute(
          path: '/customer/history',
          builder: (_, __) => const Scaffold(
            key: Key('request-history-screen'),
            body: Text('history'),
          ),
        ),
        GoRoute(
          path: '/customer/requests/create',
          builder: (_, __) => const SizedBox(),
        ),
      ],
    );

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  testWidgets('My Requests shows History and empty open list', (tester) async {
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

    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          requestManageRepositoryProvider.overrideWithValue(repo),
        ],
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

    expect(find.byKey(const Key('my-requests-screen')), findsOneWidget);
    expect(find.byKey(const Key('open-history')), findsOneWidget);
    expect(find.text('My Requests'), findsWidgets);
    expect(find.byKey(const Key('customer-home-hero')), findsNothing);
  });

  testWidgets('History button opens history screen', (tester) async {
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          requestManageRepositoryProvider.overrideWithValue(repo),
        ],
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

    await tester.tap(find.byKey(const Key('open-history')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('request-history-screen')), findsOneWidget);
  });
}
