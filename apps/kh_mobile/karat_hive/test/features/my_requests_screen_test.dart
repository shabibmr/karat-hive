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

GoRouter _testRouter({String initialLocation = '/customer/requests'}) =>
    GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/customer/requests',
          builder: (_, state) => MyRequestsScreen(
            initialTab: state.uri.queryParameters['tab'],
          ),
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

  void stubListMine({
    List<RequestForCustomer> items = const [],
  }) {
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
      (_) async => Ok(
        PagedResult<RequestForCustomer>(items: items, nextCursor: null),
      ),
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    String location = '/customer/requests',
  }) async {
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
          routerConfig: _testRouter(initialLocation: location),
          localizationsDelegates: const [
            ...KhStrings.delegates,
            AppLocalizations.delegate,
          ],
          supportedLocales: KhStrings.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('My Requests shows Open/Drafts tabs, History, and empty open list',
      (tester) async {
    stubListMine();
    await pumpScreen(tester);

    expect(find.byKey(const Key('my-requests-screen')), findsOneWidget);
    expect(find.byKey(const Key('my-requests-tabs')), findsOneWidget);
    expect(find.byKey(const Key('kh-segmented-tab-OPEN')), findsOneWidget);
    expect(find.byKey(const Key('kh-segmented-tab-DRAFTS')), findsOneWidget);
    expect(find.byKey(const Key('open-history')), findsOneWidget);
    expect(find.text('My Requests'), findsWidgets);
    expect(find.byKey(const Key('customer-home-hero')), findsNothing);
  });

  testWidgets('History button opens history screen', (tester) async {
    stubListMine();
    await pumpScreen(tester);

    await tester.tap(find.byKey(const Key('open-history')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('request-history-screen')), findsOneWidget);
  });

  testWidgets('Drafts tab requests DRAFT state and shows drafts empty copy',
      (tester) async {
    stubListMine();
    await pumpScreen(tester);

    await tester.tap(find.byKey(const Key('kh-segmented-tab-DRAFTS')));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.listMine(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          state: captureAny(named: 'state'),
          requestType: any(named: 'requestType'),
          direction: any(named: 'direction'),
          q: any(named: 'q'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).captured;

    expect(
      captured.any((states) =>
          states is List<String> &&
          states.length == 1 &&
          states.single == 'DRAFT'),
      isTrue,
    );
    expect(
      find.text('No drafts yet. Save a request as draft to finish it later.'),
      findsOneWidget,
    );
  });

  testWidgets('?tab=DRAFTS opens on Drafts segment', (tester) async {
    stubListMine();
    await pumpScreen(tester, location: '/customer/requests?tab=DRAFTS');

    final captured = verify(() => repo.listMine(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          state: captureAny(named: 'state'),
          requestType: any(named: 'requestType'),
          direction: any(named: 'direction'),
          q: any(named: 'q'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).captured;

    expect(
      captured.any((states) =>
          states is List<String> &&
          states.length == 1 &&
          states.single == 'DRAFT'),
      isTrue,
    );
    expect(find.text('Drafts'), findsWidgets);
  });
}
