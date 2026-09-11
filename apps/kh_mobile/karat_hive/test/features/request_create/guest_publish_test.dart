import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_state.dart';
import 'package:karat_hive/features/request_create/pending_publish_intent.dart';
import 'package:karat_hive/features/request_create/repository/request_create_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_session.dart';

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

MeUser _customer({bool canCreateRequest = true}) => MeUser(
  userId: 'c1',
  userType: 'CUSTOMER',
  mobileNumber: '+971500000009',
  preferredLanguage: 'en',
  canCreateRequest: canCreateRequest,
  customer: CustomerMe(
    displayName: 'Layla',
    reviewCount: 0,
    connectionCount: 0,
    canCreateRequest: canCreateRequest,
  ),
);

MeUser _vendor() => testVendorUser(
  vendor: testVendorMe(lifecycle: VendorLifecycle.active),
);

RequestForCustomer _request({required String state}) =>
    RequestForCustomer.fromJson({
      'id': 'req-1',
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
  late File imageFile;

  setUpAll(() {
    registerFallbackValue(File('fallback.bin'));
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    repo = _MockRepo();
    imageFile = File(
      '${Directory.systemTemp.path}/kh_guest_pub_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await imageFile.writeAsBytes(const [1, 2, 3]);
  });

  tearDown(() async {
    if (await imageFile.exists()) await imageFile.delete();
  });

  ProviderContainer containerWith(SessionState session) {
    final container = ProviderContainer(
      overrides: [
        requestCreateRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(() => _MutableSessionController(session)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  void stubHappyPublish({List<String>? order}) {
    when(
      () => repo.uploadRequestImage(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async {
      order?.add('upload');
      return const Ok('media-key-1');
    });
    when(() => repo.createDraft(any())).thenAnswer((_) async {
      order?.add('draft');
      return Ok(DraftSaveResult(request: _request(state: 'DRAFT')));
    });
    when(() => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')))
        .thenAnswer((_) async {
          order?.add('publish');
          return Ok(_request(state: 'PUBLISHED'));
        });
  }

  group('GL-57…GL-60 auto-publish pipeline', () {
    test('SignedIn Customer + pending runs upload→draft→publish once', () async {
      final order = <String>[];
      stubHappyPublish(order: order);

      final sessionCtrl = _MutableSessionController(const SignedOut());
      final container = ProviderContainer(
        overrides: [
          requestCreateRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(() => sessionCtrl),
        ],
      );
      addTearDown(container.dispose);

      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      await ctrl.addImage(imageFile, 'image/jpeg');
      container.read(pendingPublishIntentProvider.notifier).setPending();

      sessionCtrl.setSession(SignedIn(_customer()));
      await ctrl.reconcilePendingPublish();

      expect(order, ['upload', 'draft', 'publish']);
      expect(container.read(pendingPublishIntentProvider), isFalse);
      expect(
        container.read(requestCreateControllerProvider).step,
        RequestCreateStep.success,
      );

      // One-shot: second reconcile must not hit the API again.
      await ctrl.reconcilePendingPublish();
      verify(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      ).called(1);
    });

    test('pipeline API fail stays SignedIn and keeps form error', () async {
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
      // Manual retry re-saves an existing draft via patch (draftId set).
      when(() => repo.patchDraft(any(), any())).thenAnswer(
        (_) async => Ok(DraftSaveResult(request: _request(state: 'DRAFT'))),
      );
      when(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      ).thenAnswer(
        (_) async => const Err(
          ServerFailure(code: 'PUBLISH_FAILED', message: 'backend down'),
        ),
      );

      final sessionCtrl = _MutableSessionController(const SignedOut());
      final container = ProviderContainer(
        overrides: [
          requestCreateRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(() => sessionCtrl),
        ],
      );
      addTearDown(container.dispose);

      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      container.read(pendingPublishIntentProvider.notifier).setPending();

      sessionCtrl.setSession(SignedIn(_customer()));
      await ctrl.reconcilePendingPublish();

      expect(container.read(sessionProvider), isA<SignedIn>());
      expect(
        container.read(requestCreateControllerProvider).failure?.code,
        'PUBLISH_FAILED',
      );
      expect(
        container.read(requestCreateControllerProvider).step,
        isNot(RequestCreateStep.success),
      );

      // No auto-retry loop.
      await ctrl.reconcilePendingPublish();
      verify(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      ).called(1);

      // Manual retry still works (already authed).
      when(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      ).thenAnswer((_) async => Ok(_request(state: 'PUBLISHED')));
      final ok = await ctrl.publish();
      expect(ok, isTrue);
      expect(
        container.read(requestCreateControllerProvider).step,
        RequestCreateStep.success,
      );
    });

    test('success clears pending intent', () async {
      stubHappyPublish();
      final container = containerWith(SignedIn(_customer()));
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      container.read(pendingPublishIntentProvider.notifier).setPending();

      await ctrl.reconcilePendingPublish();

      expect(container.read(pendingPublishIntentProvider), isFalse);
    });
  });

  group('GL-61…GL-62 Vendor drops draft', () {
    test('Vendor + pending resets create and skips publish APIs', () async {
      final container = containerWith(const SignedOut());
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      await ctrl.addImage(imageFile, 'image/jpeg');
      container.read(pendingPublishIntentProvider.notifier).setPending();

      final sessionCtrl =
          container.read(sessionProvider.notifier) as _MutableSessionController;
      sessionCtrl.setSession(SignedIn(_vendor()));
      await ctrl.reconcilePendingPublish();

      expect(container.read(pendingPublishIntentProvider), isFalse);
      final state = container.read(requestCreateControllerProvider);
      expect(state.requestType, isNull);
      expect(state.media, isEmpty);

      verifyNever(() => repo.createDraft(any()));
      verifyNever(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      );
      verifyNever(
        () => repo.uploadRequestImage(
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      );
    });

    test('clearPendingPublishIfVendor invokes resetCreate', () {
      var cleared = false;
      var reset = false;
      clearPendingPublishIfVendor(
        SignedIn(_vendor()),
        true,
        () => cleared = true,
        resetCreate: () => reset = true,
      );
      expect(cleared, isTrue);
      expect(reset, isTrue);

      cleared = false;
      reset = false;
      clearPendingPublishIfVendor(
        SignedIn(_customer()),
        true,
        () => cleared = true,
        resetCreate: () => reset = true,
      );
      expect(cleared, isFalse);
      expect(reset, isFalse);
    });
  });

  group('GL-63 signup then pipeline', () {
    test('pending survives UnboundGoogle → SignedIn Customer', () async {
      stubHappyPublish();

      final sessionCtrl = _MutableSessionController(const SignedOut());
      final container = ProviderContainer(
        overrides: [
          requestCreateRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(() => sessionCtrl),
        ],
      );
      addTearDown(container.dispose);

      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      container.read(pendingPublishIntentProvider.notifier).setPending();

      // New Google: unbound, then signup completes as Customer.
      sessionCtrl.setSession(
        const UnboundGoogle(
          firebaseIdToken: 'tok',
          suggestedEmail: 'a@b.c',
        ),
      );
      expect(container.read(pendingPublishIntentProvider), isTrue);
      await ctrl.reconcilePendingPublish();
      verifyNever(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      );

      sessionCtrl.setSession(SignedIn(_customer()));
      await ctrl.reconcilePendingPublish();

      expect(container.read(pendingPublishIntentProvider), isFalse);
      expect(
        container.read(requestCreateControllerProvider).step,
        RequestCreateStep.success,
      );
      verify(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      ).called(1);
    });
  });

  group('GL-56 guest publish guard', () {
    test('guest publish does not call API', () async {
      final container = containerWith(const SignedOut());
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);

      final ok = await ctrl.publish();
      expect(ok, isFalse);
      verifyNever(() => repo.createDraft(any()));
      verifyNever(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      );
    });
  });
}
