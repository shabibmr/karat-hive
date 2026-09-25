import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_controller.dart';
import 'package:karat_hive/features/request_create/repository/request_create_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_image_converter.dart';

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

RequestForCustomer _draftRequest() => RequestForCustomer.fromJson({
  'id': 'req-draft-1',
  'requestType': 'FIND_ORNAMENT',
  'direction': 'BUY',
  'state': 'DRAFT',
  'category': {'id': 'cat-1', 'nameEn': 'Rings', 'nameAr': 'خواتم'},
  'region': {'id': 'reg-1', 'nameEn': 'Dubai', 'nameAr': 'دبي'},
  'weightIsApproximate': false,
  'budgetIsFlexible': false,
  'offerCount': 0,
  'media': [],
  'createdAt': '2026-09-01T10:00:00.000Z',
  'updatedAt': '2026-09-01T10:00:00.000Z',
});

RequestForCustomer _publishedRequest() => RequestForCustomer.fromJson({
  'id': 'req-draft-1',
  'requestType': 'FIND_ORNAMENT',
  'direction': 'BUY',
  'state': 'PUBLISHED',
  'category': {'id': 'cat-1', 'nameEn': 'Rings', 'nameAr': 'خواتم'},
  'region': {'id': 'reg-1', 'nameEn': 'Dubai', 'nameAr': 'دبي'},
  'weightIsApproximate': false,
  'budgetIsFlexible': false,
  'offerCount': 0,
  'media': [],
  'createdAt': '2026-09-01T10:00:00.000Z',
  'updatedAt': '2026-09-01T10:05:00.000Z',
  'publishedAt': '2026-09-01T10:05:00.000Z',
});

void main() {
  late _MockRepo repo;
  late File imageFile;
  late FakeImageConverter converter;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    repo = _MockRepo();
    converter = FakeImageConverter();
    imageFile = File(
      '${Directory.systemTemp.path}/kh_signed_img_${DateTime.now().microsecondsSinceEpoch}.jpg',
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
        requestImageConverterProvider.overrideWithValue(converter),
        mediaReadyRetryDelayProvider.overrideWithValue(Duration.zero),
        sessionProvider.overrideWith(() => _MutableSessionController(session)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  void stubUpload({String key = 'media-key-1', Failure? fail}) {
    when(
      () => repo.uploadRequestImageBytes(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((inv) async {
      final contentType = inv.positionalArguments[1] as String;
      expect(contentType, 'image/avif');
      if (fail != null) return Err(fail);
      return Ok(key);
    });
  }

  group('signed-in attach uploads AVIF immediately', () {
    test('addImage converts then uploads; slot is READY', () async {
      stubUpload();
      final container = containerWith(SignedIn(_customer()));
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);

      await ctrl.addImage(imageFile, 'image/jpeg');

      final state = container.read(requestCreateControllerProvider);
      expect(converter.convertCalls, 1);
      expect(state.media, hasLength(1));
      expect(state.media.single.isLocalOnly, isFalse);
      expect(state.media.single.key, 'media-key-1');
      expect(state.mediaKeys, ['media-key-1']);
      expect(state.media.single.contentType, 'image/avif');
      verifyNever(() => repo.createDraft(any()));
      verifyNever(() => repo.patchDraft(any(), any()));
    });

    test('addImage with existing draftId patches mediaKeys', () async {
      stubUpload();
      when(() => repo.createDraft(any())).thenAnswer(
        (_) async => Ok(DraftSaveResult(request: _draftRequest())),
      );
      when(() => repo.patchDraft(any(), any())).thenAnswer(
        (_) async => Ok(DraftSaveResult(request: _draftRequest())),
      );
      final container = containerWith(SignedIn(_customer()));
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      await ctrl.saveDraft();
      await ctrl.addImage(imageFile, 'image/jpeg');

      final captured = verify(() => repo.patchDraft('req-draft-1', captureAny()))
          .captured
          .last as Map<String, dynamic>;
      expect(captured['mediaKeys'], ['media-key-1']);
    });

    test('convert failure does not upload', () async {
      converter.throwOnConvert = true;
      final container = containerWith(SignedIn(_customer()));
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);

      await ctrl.addImage(imageFile, 'image/jpeg');

      final state = container.read(requestCreateControllerProvider);
      expect(state.media.single.failure, isNotNull);
      expect(state.mediaKeysReady, isFalse);
      verifyNever(
        () => repo.uploadRequestImageBytes(
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      );
    });

    test('failed upload then retry uploads AVIF again', () async {
      stubUpload(fail: const ServerFailure(message: 'network'));
      final container = containerWith(SignedIn(_customer()));
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);

      await ctrl.addImage(imageFile, 'image/jpeg');
      expect(
        container.read(requestCreateControllerProvider).media.single.failure,
        isNotNull,
      );

      stubUpload(key: 'media-key-retry');
      await ctrl.retryFailedMediaAt(0);

      final state = container.read(requestCreateControllerProvider);
      expect(state.media.single.key, 'media-key-retry');
      expect(state.media.single.failure, isNull);
      expect(state.mediaKeys, ['media-key-retry']);
    });
  });

  group('guest attach then sign-in flush', () {
    test('flush uploads AVIF without publish', () async {
      stubUpload();
      final sessionCtrl = _MutableSessionController(const SignedOut());
      final container = ProviderContainer(
        overrides: [
          requestCreateRepositoryProvider.overrideWithValue(repo),
          requestImageConverterProvider.overrideWithValue(converter),
          sessionProvider.overrideWith(() => sessionCtrl),
        ],
      );
      addTearDown(container.dispose);

      final ctrl = container.read(requestCreateControllerProvider.notifier);
      await ctrl.addImage(imageFile, 'image/jpeg');
      verifyNever(
        () => repo.uploadRequestImageBytes(
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      );

      sessionCtrl.setSession(SignedIn(_customer()));
      await ctrl.flushPendingLocalMedia();

      expect(
        container.read(requestCreateControllerProvider).mediaKeys,
        ['media-key-1'],
      );
      verifyNever(() => repo.createDraft(any()));
      verifyNever(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      );
    });
  });

  group('publish after READY keys', () {
    test('does not upload again; createDraft then publish', () async {
      final order = <String>[];
      when(
        () => repo.uploadRequestImageBytes(
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async {
        order.add('upload');
        return const Ok('media-key-1');
      });
      when(() => repo.createDraft(any())).thenAnswer((_) async {
        order.add('draft');
        return Ok(DraftSaveResult(request: _draftRequest()));
      });
      when(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      ).thenAnswer((_) async {
        order.add('publish');
        return Ok(_publishedRequest());
      });

      final container = containerWith(SignedIn(_customer()));
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      await ctrl.addImage(imageFile, 'image/jpeg');
      expect(order, ['upload']);

      final ok = await ctrl.publish();
      expect(ok, isTrue);
      expect(order, ['upload', 'draft', 'publish']);
    });
  });

  group('web upload skips client-side AVIF', () {
    test('addImage uploads original bytes/contentType, no conversion', () async {
      when(
        () => repo.uploadRequestImageBytes(
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((inv) async {
        final contentType = inv.positionalArguments[1] as String;
        expect(contentType, 'image/jpeg');
        return const Ok('media-key-web-1');
      });

      final container = ProviderContainer(
        overrides: [
          requestCreateRepositoryProvider.overrideWithValue(repo),
          requestImageConverterProvider.overrideWithValue(converter),
          isWebPlatformProvider.overrideWithValue(true),
          sessionProvider.overrideWith(() => _MutableSessionController(SignedIn(_customer()))),
        ],
      );
      addTearDown(container.dispose);

      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      await ctrl.addImage(imageFile, 'image/jpeg');

      final state = container.read(requestCreateControllerProvider);
      expect(converter.convertCalls, 0);
      expect(state.media.single.key, 'media-key-web-1');
      expect(state.media.single.contentType, 'image/jpeg');
    });
  });

  group('publish while photos are still processing', () {
    void stubDraftAndUpload() {
      stubUpload();
      when(() => repo.createDraft(any())).thenAnswer(
        (_) async => Ok(DraftSaveResult(request: _draftRequest())),
      );
      when(() => repo.patchDraft(any(), any())).thenAnswer(
        (_) async => Ok(DraftSaveResult(request: _draftRequest())),
      );
    }

    const notReady = ValidationFailure(
      code: 'MEDIA_NOT_READY',
      message: 'Photos are still processing.',
    );

    test('retries MEDIA_NOT_READY with the same idempotency key', () async {
      stubDraftAndUpload();
      final keys = <String>[];
      when(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      ).thenAnswer((inv) async {
        keys.add(inv.namedArguments[#idempotencyKey] as String);
        return keys.length < 3 ? const Err(notReady) : Ok(_publishedRequest());
      });

      final container = containerWith(SignedIn(_customer()));
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      await ctrl.addImage(imageFile, 'image/jpeg');

      expect(await ctrl.publish(), isTrue);
      expect(keys, hasLength(3));
      expect(keys.toSet(), hasLength(1));
    });

    test('gives up and surfaces the failure if photos never become ready',
        () async {
      stubDraftAndUpload();
      var calls = 0;
      when(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      ).thenAnswer((_) async {
        calls++;
        return const Err(notReady);
      });

      final container = containerWith(SignedIn(_customer()));
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      await ctrl.addImage(imageFile, 'image/jpeg');

      expect(await ctrl.publish(), isFalse);
      expect(calls, 31);
      expect(
        container.read(requestCreateControllerProvider).failure?.code,
        'MEDIA_NOT_READY',
      );
    });

    test('other publish failures are not retried', () async {
      stubDraftAndUpload();
      var calls = 0;
      when(
        () => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')),
      ).thenAnswer((_) async {
        calls++;
        return const Err(ServerFailure(message: 'boom'));
      });

      final container = containerWith(SignedIn(_customer()));
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      await ctrl.addImage(imageFile, 'image/jpeg');

      expect(await ctrl.publish(), isFalse);
      expect(calls, 1);
    });
  });
}
