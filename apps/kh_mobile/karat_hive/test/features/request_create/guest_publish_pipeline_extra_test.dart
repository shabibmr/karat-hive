import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_state.dart';
import 'package:karat_hive/features/request_create/pending_publish_intent.dart';
import 'package:karat_hive/features/request_create/presentation/request_review_publish_screen.dart';
import 'package:karat_hive/features/request_create/repository/request_create_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements RequestCreateRepository {}

class _MutableSessionController extends SessionController {
  _MutableSessionController(this._initial);
  final SessionState _initial;

  @override
  SessionState build() => _initial;

  void setSession(SessionState next) => state = next;

  @override
  Future<void> refreshUser() async {}
}

MeUser _customer() => MeUser(
  userId: 'c1',
  userType: 'CUSTOMER',
  mobileNumber: '+971500000009',
  preferredLanguage: 'en',
  canCreateRequest: true,
  customer: CustomerMe(
    displayName: 'Layla',
    reviewCount: 0,
    connectionCount: 0,
    canCreateRequest: true,
  ),
);

RequestForCustomer _request({required String state}) =>
    RequestForCustomer.fromJson({
      'id': 'req-cold-1',
      'requestType': 'FIND_ORNAMENT',
      'direction': 'BUY',
      'state': state,
      'category': {'id': 'cat-1', 'nameEn': 'Rings', 'nameAr': 'خواتم'},
      'region': {'id': 'reg-1', 'nameEn': 'Dubai', 'nameAr': 'دبي'},
      'weightIsApproximate': false,
      'budgetIsFlexible': false,
      'offerCount': 0,
      'media': [],
      'createdAt': '2026-09-01T10:00:00.000Z',
      'updatedAt': '2026-09-01T10:00:00.000Z',
      if (state == 'PUBLISHED') 'publishedAt': '2026-09-01T10:05:00.000Z',
    });

void main() {
  late _MockRepo repo;
  late Directory tempDir;

  setUp(() {
    repo = _MockRepo();
    tempDir = Directory.systemTemp.createTempSync('kh_pending_draft_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  void stubHappyPublish() {
    when(
      () => repo.uploadRequestImage(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => const Ok('media-key-1'));
    when(() => repo.createDraft(any())).thenAnswer(
      (_) async => Ok(DraftSaveResult(request: _request(state: 'DRAFT'))),
    );
    when(() => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')))
        .thenAnswer((_) async => Ok(_request(state: 'PUBLISHED')));
    when(() => repo.me()).thenAnswer((_) async => Ok(_customer()));
  }

  group('GL-59 cold-boot restore', () {
    test('persisted draft survives a fresh provider container and auto-publishes',
        () async {
      stubHappyPublish();
      final store = PendingPublishDraftStore(baseDir: tempDir);

      // "Session 1": guest fills the wizard and reaches review while offline/guest.
      final containerA = ProviderContainer(
        overrides: [
          requestCreateRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(
            () => _MutableSessionController(const SignedOut()),
          ),
          pendingPublishDraftStoreProvider.overrideWithValue(store),
        ],
      );
      final ctrlA = containerA.read(requestCreateControllerProvider.notifier);
      ctrlA.selectType(RequestType.findOrnament);
      ctrlA.setNotes('kept across restart');
      await ctrlA.persistPendingDraft();
      containerA.dispose();

      // "Session 2": fresh process, fresh container — simulates a cold boot.
      final containerB = ProviderContainer(
        overrides: [
          requestCreateRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(
            () => _MutableSessionController(SignedIn(_customer())),
          ),
          pendingPublishDraftStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(containerB.dispose);

      final ctrlB = containerB.read(requestCreateControllerProvider.notifier);
      // Let the fire-and-forget restore kicked off from build() complete.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
        containerB.read(requestCreateControllerProvider).notes,
        'kept across restart',
      );
      expect(containerB.read(pendingPublishIntentProvider), isTrue);

      final ok = await ctrlB.reconcilePendingPublish();
      expect(ok, isTrue);
      expect(
        containerB.read(requestCreateControllerProvider).step,
        RequestCreateStep.success,
      );
      expect(containerB.read(pendingPublishIntentProvider), isFalse);
    });
  });

  group('GL-60 router redirect after reconcile', () {
    testWidgets('successful reconcile navigates to the request detail screen',
        (tester) async {
      stubHappyPublish();
      final sessionCtrl = _MutableSessionController(const SignedOut());
      final container = ProviderContainer(
        overrides: [
          requestCreateRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(() => sessionCtrl),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(requestCreateControllerProvider.notifier)
          .selectType(RequestType.findOrnament);
      container.read(pendingPublishIntentProvider.notifier).setPending();

      final router = GoRouter(
        initialLocation: '/customer/requests/create/review',
        routes: [
          GoRoute(
            path: '/customer/requests/create/review',
            builder: (_, __) => const RequestReviewPublishScreen(),
          ),
          GoRoute(
            path: '/customer/requests/:requestId',
            builder: (context, state) => Text(
              'detail:${state.pathParameters['requestId']}',
              key: const Key('detail-screen'),
            ),
          ),
          GoRoute(
            path: '/customer/home',
            builder: (_, __) => const Text('home', key: Key('home-screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: khTheme(),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      sessionCtrl.setSession(SignedIn(_customer()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('detail-screen')), findsOneWidget);
      expect(find.text('detail:req-cold-1'), findsOneWidget);
    });
  });
}
