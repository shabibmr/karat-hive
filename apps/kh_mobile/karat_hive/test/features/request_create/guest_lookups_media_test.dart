import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_controller.dart';
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

void main() {
  late _MockRepo repo;
  late File imageFile;

  setUpAll(() {
    registerFallbackValue(File('fallback.bin'));
  });

  setUp(() async {
    repo = _MockRepo();
    imageFile = File(
      '${Directory.systemTemp.path}/kh_guest_img_${DateTime.now().microsecondsSinceEpoch}.jpg',
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
        sessionProvider.overrideWith(() => FakeSessionController(session)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  void stubGuestLookups({Result<GoldRateSnapshot>? rates}) {
    when(
      () => repo.platformConfig(),
    ).thenAnswer((_) async => const Ok(PlatformConfig()));
    when(() => repo.goldRates()).thenAnswer(
      (_) async =>
          rates ??
          const Err(
            ServerFailure(code: 'GOLD_RATE_UNAVAILABLE', message: 'n/a'),
          ),
    );
    when(() => repo.categories()).thenAnswer(
      (_) async => const Ok([
        TaxonomyNode(id: 'cat-1', nameEn: 'Rings', nameAr: 'خواتم'),
      ]),
    );
    when(() => repo.regions()).thenAnswer(
      (_) async =>
          const Ok([TaxonomyNode(id: 'reg-1', nameEn: 'Dubai', nameAr: 'دبي')]),
    );
  }

  group('GL-50…GL-52 guest lookups', () {
    test('loadLookups does not call me() when SignedOut', () async {
      stubGuestLookups();
      final container = containerWith(const SignedOut());
      final ctrl = container.read(requestCreateControllerProvider.notifier);

      await ctrl.loadLookups();

      verifyNever(() => repo.me());
      expect(
        container.read(requestCreateControllerProvider).lookupsReady,
        isTrue,
      );
    });

    test('lookupsReady without me when config/categories/regions ok', () async {
      stubGuestLookups(
        rates: const Err(
          ServerFailure(code: 'GOLD_RATE_UNAVAILABLE', message: 'missing'),
        ),
      );
      final container = containerWith(const SignedOut());
      final ctrl = container.read(requestCreateControllerProvider.notifier);

      await ctrl.loadLookups();

      final state = container.read(requestCreateControllerProvider);
      expect(state.lookupsReady, isTrue);
      expect(state.config, isNotNull);
      expect(state.categories, isNotEmpty);
      expect(state.regions, isNotEmpty);
      expect(state.rates?.available, isFalse);
      verifyNever(() => repo.me());
    });

    test('guest capBlocked stays false', () async {
      stubGuestLookups();
      final container = containerWith(const SignedOut());
      final ctrl = container.read(requestCreateControllerProvider.notifier);

      expect(
        container.read(requestCreateControllerProvider).capBlocked,
        isFalse,
      );
      await ctrl.loadLookups();
      expect(
        container.read(requestCreateControllerProvider).capBlocked,
        isFalse,
      );
      expect(
        container.read(requestCreateControllerProvider).canCreateRequest,
        isTrue,
      );
    });
  });

  group('GL-53…GL-55 guest media', () {
    test('guest addImage stores local File and does not upload', () async {
      final container = containerWith(const SignedOut());
      final ctrl = container.read(requestCreateControllerProvider.notifier);

      await ctrl.addImage(imageFile, 'image/jpeg');

      final state = container.read(requestCreateControllerProvider);
      expect(state.media, hasLength(1));
      expect(state.media.single.isLocalPending, isTrue);
      expect(state.media.single.localFile?.path, imageFile.path);
      expect(state.media.single.contentType, 'image/jpeg');
      expect(state.uploading, isFalse);
      verifyNever(
        () => repo.uploadRequestImage(
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      );
    });

    test('guest removeMediaAt is local only', () async {
      final container = containerWith(const SignedOut());
      final ctrl = container.read(requestCreateControllerProvider.notifier);

      await ctrl.addImage(imageFile, 'image/jpeg');
      await ctrl.removeMediaAt(0);

      expect(container.read(requestCreateControllerProvider).media, isEmpty);
      verifyNever(() => repo.deleteMedia(any()));
    });

    test(
      'uploadPendingLocalMedia then saveDraft uploads before draft',
      () async {
        final sessionCtrl = _MutableSessionController(const SignedOut());
        final container = ProviderContainer(
          overrides: [
            requestCreateRepositoryProvider.overrideWithValue(repo),
            sessionProvider.overrideWith(() => sessionCtrl),
          ],
        );
        addTearDown(container.dispose);

        final ctrl = container.read(requestCreateControllerProvider.notifier);
        await ctrl.addImage(imageFile, 'image/jpeg');
        ctrl.selectType(RequestType.findOrnament);

        sessionCtrl.setSession(SignedIn(_customer()));

        final order = <String>[];
        when(
          () => repo.uploadRequestImage(
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

        final uploaded = await ctrl.uploadPendingLocalMedia();
        expect(uploaded, isTrue);
        expect(container.read(requestCreateControllerProvider).mediaKeys, [
          'media-key-1',
        ]);

        final saved = await ctrl.saveDraft();
        expect(saved, isTrue);
        expect(order, ['upload', 'draft']);
        verify(
          () => repo.uploadRequestImage(
            any(),
            any(),
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
        verify(() => repo.createDraft(any())).called(1);
      },
    );
  });
}
