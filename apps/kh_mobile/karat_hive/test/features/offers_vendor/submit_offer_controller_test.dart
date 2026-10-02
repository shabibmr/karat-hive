import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/offers_vendor/controller/submit_offer_controller.dart';
import 'package:karat_hive/features/offers_vendor/repository/offers_vendor_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

VendorRequestItem _testRequest({
  String id = 'req-offer-1',
  String? reference = 'REQ-2026-0099',
  String requestType = 'FIND_ORNAMENT',
}) {
  return VendorRequestItem(
    id: id,
    reference: reference,
    requestType: requestType,
    direction: 'BUY',
    state: 'PUBLISHED',
    regionId: 'reg-dxb',
    regionName: 'Dubai',
    purityKarat: '22',
    weightGrams: 15.0,
    budgetMin: 4000.0,
    budgetMax: 5500.0,
    offerCount: 2,
    customer: const MaskedParty(
      role: UserRole.customer,
      region: 'Dubai',
      dealCount: 5,
    ),
    publishedAt: DateTime.utc(2026, 9, 7, 0, 0),
    expiresAt: DateTime.utc(2026, 9, 9, 0, 0),
  );
}

PlatformConfig _testConfig({
  List<int> offerValidityHours = const [12, 24, 48],
}) =>
    PlatformConfig(offerValidityHours: offerValidityHours);

OfferForVendor _testOffer({
  String id = 'off-1',
  String requestId = 'req-offer-1',
}) {
  return OfferForVendor(
    id: id,
    requestId: requestId,
    state: OfferState.pending,
    terms: const OfferTerms(
      offeredPrice: '5200.00',
      weightGrams: '15.00',
      purityKarat: '22K',
    ),
    submittedAt: DateTime.utc(2026, 9, 7, 12, 0),
    expiresAt: DateTime.utc(2026, 9, 8, 12, 0),
    revisionCount: 0,
  );
}

class FakeOffersVendorRepository implements OffersVendorRepository {
  FakeOffersVendorRepository({
    this.request,
    this.config,
    this.requestError,
    this.configError,
    this.submitError,
    this.submitResult,
    this.submitScript,
    this.hangRequest = false,
    this.hangConfig = false,
  });

  final VendorRequestItem? request;
  final PlatformConfig? config;
  final Failure? requestError;
  final Failure? configError;
  final Failure? submitError;
  final OfferForVendor? submitResult;
  /// When set, each submit consumes the next entry. A null entry succeeds.
  final List<Failure?>? submitScript;
  final bool hangRequest;
  final bool hangConfig;

  int getRequestCalls = 0;
  int getConfigCalls = 0;
  int submitCalls = 0;
  void Function()? onSubmit;
  OfferTermsInput? lastTerms;
  String? lastSubmitRequestId;

  @override
  Future<Result<PlatformConfig>> getPlatformConfig() async {
    getConfigCalls++;
    if (hangConfig) await Completer<void>().future;
    if (configError != null) return Err(configError!);
    return Ok(config ?? _testConfig());
  }

  @override
  Future<Result<VendorRequestItem>> getRequest(String requestId) async {
    getRequestCalls++;
    if (hangRequest) await Completer<void>().future;
    if (requestError != null) return Err(requestError!);
    return Ok(request ?? _testRequest(id: requestId));
  }

  @override
  Future<Result<OfferForVendor>> getOffer(String offerId) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> submitOffer({
    required String requestId,
    required OfferTermsInput terms,
  }) async {
    submitCalls++;
    lastSubmitRequestId = requestId;
    lastTerms = terms;
    onSubmit?.call();
    final script = submitScript;
    if (script != null && script.isNotEmpty) {
      final next = script.removeAt(0);
      if (next != null) return Err(next);
    } else if (submitError != null) {
      return Err(submitError!);
    }
    return Ok(
      submitResult ??
          _testOffer(
            requestId: requestId,
          ),
    );
  }

  @override
  Future<Result<OfferForVendor>> reviseOffer({
    required String offerId,
    required OfferTermsInput terms,
  }) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> withdrawOffer(String offerId) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<PagedResult<OfferForVendor>>> listMyOffers({
    required String tab,
    String? requestType,
    DateTime? from,
    DateTime? to,
    String? q,
    String? cursor,
  }) async =>
      const Ok(PagedResult(items: []));
}

Future<SubmitOfferState> _waitUntilSettled(
  ProviderContainer container,
  String requestId,
) async {
  for (var i = 0; i < 50; i++) {
    final state = container.read(submitOfferControllerProvider(requestId));
    if (state is! SubmitOfferLoading) return state;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return container.read(submitOfferControllerProvider(requestId));
}

void main() {
  const requestId = 'req-offer-1';

  ProviderContainer containerWith(FakeOffersVendorRepository repo) {
    final container = ProviderContainer(
      overrides: [
        offersVendorRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(
      submitOfferControllerProvider(requestId),
      (_, _) {},
    );
    addTearDown(sub.close);
    return container;
  }

  group('SubmitOfferController (VEN-S09)', () {
    test('starts loading then reaches ready with empty draft (data/empty)',
        () async {
      final repo = FakeOffersVendorRepository(
        request: _testRequest(),
        config: _testConfig(),
      );
      final container = containerWith(repo);

      expect(
        container.read(submitOfferControllerProvider(requestId)),
        isA<SubmitOfferLoading>(),
      );

      final state = await _waitUntilSettled(container, requestId);
      expect(state, isA<SubmitOfferReady>());
      final ready = state as SubmitOfferReady;
      expect(ready.request.reference, 'REQ-2026-0099');
      expect(ready.config.offerValidityHours, [12, 24, 48]);
      expect(ready.draft.offeredPrice, isEmpty);
      expect(ready.draft.weightGrams, '15.00');
      expect(ready.draft.purityKarat, Karat.k22);
      expect(ready.submitting, isFalse);
      expect(ready.failure, isNull);
      expect(repo.getRequestCalls, 1);
      expect(repo.getConfigCalls, 1);
    });

    test('surfaces request load failure as SubmitOfferFailed (error)', () async {
      final repo = FakeOffersVendorRepository(
        requestError: const NetworkFailure(message: 'offline'),
      );
      final container = containerWith(repo);

      final state = await _waitUntilSettled(container, requestId);
      expect(state, isA<SubmitOfferFailed>());
      expect((state as SubmitOfferFailed).failure.message, 'offline');
    });

    test('surfaces config load failure as SubmitOfferFailed (error)', () async {
      final repo = FakeOffersVendorRepository(
        configError: const ServerFailure(message: 'config unavailable'),
      );
      final container = containerWith(repo);

      final state = await _waitUntilSettled(container, requestId);
      expect(state, isA<SubmitOfferFailed>());
      expect(
        (state as SubmitOfferFailed).failure.message,
        'config unavailable',
      );
    });

    test('submit with empty price keeps ready and sets validation failure',
        () async {
      final repo = FakeOffersVendorRepository();
      final container = containerWith(repo);
      await _waitUntilSettled(container, requestId);

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      final state = container.read(submitOfferControllerProvider(requestId));
      expect(state, isA<SubmitOfferReady>());
      final ready = state as SubmitOfferReady;
      expect(ready.failure, isA<ValidationFailure>());
      expect(ready.failure!.message, 'Enter a valid offered price.');
      expect(repo.submitCalls, 0);
    });

    test('submit with valid price succeeds', () async {
      final repo = FakeOffersVendorRepository(
        submitResult: _testOffer(id: 'off-new'),
      );
      final container = containerWith(repo);
      final loaded = await _waitUntilSettled(container, requestId);
      final ready = loaded as SubmitOfferReady;
      ready.draft.offeredPrice = '5200.50';
      ready.draft.weightGrams = '15.00';
      ready.draft.mediaKeys.add('media/1');
      ready.draft.vendorNote = 'Ready in 2 days';

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      final state = container.read(submitOfferControllerProvider(requestId));
      expect(state, isA<SubmitOfferSucceeded>());
      expect((state as SubmitOfferSucceeded).offer.id, 'off-new');

      expect(repo.submitCalls, 1);
      expect(repo.lastSubmitRequestId, requestId);
      expect(repo.lastTerms!.offeredPrice, '5200.50');
      expect(repo.lastTerms!.weightGrams, '15.00');
      expect(repo.lastTerms!.purityKarat, '22K');
      expect(repo.lastTerms!.vendorNote, 'Ready in 2 days');
    });

    test('bullion submit succeeds without media keys', () async {
      final repo = FakeOffersVendorRepository(
        request: _testRequest(requestType: 'GOLD_BULLION'),
        submitResult: _testOffer(id: 'off-bullion'),
      );
      final container = containerWith(repo);
      final loaded = await _waitUntilSettled(container, requestId);
      final ready = loaded as SubmitOfferReady;
      ready.draft.offeredPrice = '9000';
      ready.draft.weightGrams = '100.00';

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      final state = container.read(submitOfferControllerProvider(requestId));
      expect(state, isA<SubmitOfferSucceeded>());
      expect(repo.submitCalls, 1);
      expect(repo.lastTerms!.mediaKeys, isEmpty);
    });

    test('submit API failure returns to ready with inline failure', () async {
      final repo = FakeOffersVendorRepository(
        submitError: const ConflictFailure(
          code: 'OFFER_ALREADY_PENDING',
          message: 'You already have a pending Offer.',
        ),
      );
      final container = containerWith(repo);
      final loaded = await _waitUntilSettled(container, requestId);
      (loaded as SubmitOfferReady).draft.offeredPrice = '5000';
      loaded.draft.mediaKeys.add('media/1');

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      final state = container.read(submitOfferControllerProvider(requestId));
      expect(state, isA<SubmitOfferReady>());
      final ready = state as SubmitOfferReady;
      expect(ready.submitting, isFalse);
      expect(ready.failure?.code, 'OFFER_ALREADY_PENDING');
      expect(ready.failure?.message, 'You already have a pending Offer.');
    });

    test('touch clears inline failure on ready state', () async {
      final repo = FakeOffersVendorRepository();
      final container = containerWith(repo);
      await _waitUntilSettled(container, requestId);

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();
      expect(
        (container.read(submitOfferControllerProvider(requestId))
                as SubmitOfferReady)
            .failure,
        isNotNull,
      );

      container
          .read(submitOfferControllerProvider(requestId).notifier)
          .touch();

      expect(
        (container.read(submitOfferControllerProvider(requestId))
                as SubmitOfferReady)
            .failure,
        isNull,
      );
    });

    test('web attach shows the photo and stores the server key without conversion',
        () async {
      String? uploadedType;
      int? uploadedLength;
      final container = ProviderContainer(
        overrides: [
          offersVendorRepositoryProvider.overrideWithValue(
            FakeOffersVendorRepository(),
          ),
          offerUploadSkipsConversionProvider.overrideWithValue(true),
          offerImageUploaderProvider.overrideWithValue(
            OfferImageUploader((bytes, contentType, {onProgress}) async {
              uploadedType = contentType;
              uploadedLength = bytes.length;
              onProgress?.call(1);
              return const Ok('media-key-1');
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(submitOfferControllerProvider(requestId), (_, _) {});

      await _waitUntilSettled(container, requestId);
      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .addPickedImage(
            bytes: Uint8List.fromList(const [1, 2, 3, 4]),
            filename: 'ring.jpg',
            contentType: 'image/jpeg',
          );

      final ready = container.read(submitOfferControllerProvider(requestId))
          as SubmitOfferReady;
      expect(uploadedType, 'image/jpeg');
      expect(uploadedLength, 4);
      expect(ready.images.single.key, 'media-key-1');
      expect(ready.images.single.localBytes, [1, 2, 3, 4]);
      expect(ready.images.single.uploading, isFalse);
      expect(ready.draft.mediaKeys, ['media-key-1']);
    });

    test('failed attach keeps the preview and blocks submit', () async {
      final repo = FakeOffersVendorRepository();
      final container = ProviderContainer(
        overrides: [
          offersVendorRepositoryProvider.overrideWithValue(repo),
          offerUploadSkipsConversionProvider.overrideWithValue(true),
          offerImageUploaderProvider.overrideWithValue(
            OfferImageUploader((bytes, contentType, {onProgress}) async {
              return const Err(ServerFailure(message: 'Upload failed. Try again.'));
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(submitOfferControllerProvider(requestId), (_, _) {});

      final loaded = await _waitUntilSettled(container, requestId);
      (loaded as SubmitOfferReady).draft.offeredPrice = '5200';
      loaded.draft.weightGrams = '15.00';

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .addPickedImage(
            bytes: Uint8List.fromList(const [9, 9]),
            filename: 'ring.jpg',
            contentType: 'image/jpeg',
          );

      final afterUpload =
          container.read(submitOfferControllerProvider(requestId))
              as SubmitOfferReady;
      expect(afterUpload.images.single.isPending, isTrue);
      expect(afterUpload.images.single.localBytes, isNotEmpty);
      expect(afterUpload.images.single.failure?.message, 'Upload failed. Try again.');
      expect(afterUpload.draft.mediaKeys, isEmpty);

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();
      final afterSubmit =
          container.read(submitOfferControllerProvider(requestId))
              as SubmitOfferReady;
      expect(
        afterSubmit.failure?.message,
        'Remove or retry the photo that failed to upload.',
      );
      expect(repo.submitCalls, 0);
    });

    test('submit retries while offer photos are still processing', () async {
      final repo = FakeOffersVendorRepository(
        submitScript: [
          const ValidationFailure(code: 'MEDIA_NOT_READY', message: 'not ready'),
          null,
        ],
      );
      final container = ProviderContainer(
        overrides: [
          offersVendorRepositoryProvider.overrideWithValue(repo),
          offerMediaReadyRetryDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);
      container.listen(submitOfferControllerProvider(requestId), (_, _) {});

      final loaded = await _waitUntilSettled(container, requestId);
      final ready = loaded as SubmitOfferReady;
      ready.draft.offeredPrice = '5200';
      ready.draft.weightGrams = '15.00';
      ready.draft.mediaKeys.add('media-key-1');

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      expect(
        container.read(submitOfferControllerProvider(requestId)),
        isA<SubmitOfferSucceeded>(),
      );
      expect(repo.submitCalls, 2);
    });

    test('a failed photo can be removed and does not ride along on submit',
        () async {
      final repo = FakeOffersVendorRepository();
      final container = ProviderContainer(
        overrides: [
          offersVendorRepositoryProvider.overrideWithValue(repo),
          offerUploadSkipsConversionProvider.overrideWithValue(true),
          offerImageUploaderProvider.overrideWithValue(
            OfferImageUploader((bytes, contentType, {onProgress}) async {
              return bytes.length == 1
                  ? const Ok('media-key-ok')
                  : const Err(ServerFailure(message: 'Upload failed. Try again.'));
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(submitOfferControllerProvider(requestId), (_, _) {});
      final notifier =
          container.read(submitOfferControllerProvider(requestId).notifier);
      final loaded = await _waitUntilSettled(container, requestId);
      final ready = loaded as SubmitOfferReady;
      ready.draft.offeredPrice = '5200';
      ready.draft.weightGrams = '15.00';

      await notifier.addPickedImage(
        bytes: Uint8List.fromList(const [1]),
        filename: 'ok.jpg',
        contentType: 'image/jpeg',
      );
      await notifier.addPickedImage(
        bytes: Uint8List.fromList(const [2, 2]),
        filename: 'bad.jpg',
        contentType: 'image/jpeg',
      );

      final mixed = container.read(submitOfferControllerProvider(requestId))
          as SubmitOfferReady;
      final failed = mixed.images.singleWhere((image) => image.failure != null);
      notifier.removeImage(failed.key);

      final afterRemove =
          container.read(submitOfferControllerProvider(requestId))
              as SubmitOfferReady;
      expect(afterRemove.images, hasLength(1));
      expect(afterRemove.images.single.failure, isNull);
      expect(afterRemove.draft.mediaKeys, ['media-key-ok']);

      await notifier.addPickedImage(
        bytes: Uint8List.fromList(const [3, 3]),
        filename: 'bad-again.jpg',
        contentType: 'image/jpeg',
      );
      await notifier.submit();
      final blocked = container.read(submitOfferControllerProvider(requestId))
          as SubmitOfferReady;
      expect(blocked.failure, isA<ValidationFailure>());
      expect(repo.submitCalls, 0);
    });

    test('leaving the screen stops a not-ready submit retry', () async {
      late ProviderContainer container;
      final repo = FakeOffersVendorRepository(
        submitScript: [
          const ValidationFailure(code: 'MEDIA_NOT_READY', message: 'not ready'),
          null,
        ],
      );
      container = ProviderContainer(
        overrides: [
          offersVendorRepositoryProvider.overrideWithValue(repo),
          offerRetrySleepProvider.overrideWithValue((_) async {
            container.dispose();
          }),
        ],
      );
      container.listen(submitOfferControllerProvider(requestId), (_, _) {});
      final loaded = await _waitUntilSettled(container, requestId);
      final ready = loaded as SubmitOfferReady;
      ready.draft.offeredPrice = '5200';
      ready.draft.weightGrams = '15.00';
      ready.draft.mediaKeys.add('media-key-1');

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      expect(repo.submitCalls, 1);
    });

    test('a removed photo does not attach to a later pick of the same file',
        () async {
      final first = Completer<Result<String>>();
      final second = Completer<Result<String>>();
      var calls = 0;
      final container = ProviderContainer(
        overrides: [
          offersVendorRepositoryProvider.overrideWithValue(
            FakeOffersVendorRepository(),
          ),
          offerUploadSkipsConversionProvider.overrideWithValue(true),
          offerImageUploaderProvider.overrideWithValue(
            OfferImageUploader((bytes, contentType, {onProgress}) {
              calls++;
              return calls == 1 ? first.future : second.future;
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(submitOfferControllerProvider(requestId), (_, _) {});
      await _waitUntilSettled(container, requestId);
      final notifier =
          container.read(submitOfferControllerProvider(requestId).notifier);
      const bytes = [1, 2, 3];

      final firstPick = notifier.addPickedImage(
        bytes: Uint8List.fromList(bytes),
        filename: 'ring.jpg',
        contentType: 'image/jpeg',
      );
      await Future<void>.delayed(Duration.zero);
      final pending = (container.read(submitOfferControllerProvider(requestId))
              as SubmitOfferReady)
          .images
          .single
          .key;
      notifier.removeImage(pending);

      final secondPick = notifier.addPickedImage(
        bytes: Uint8List.fromList(bytes),
        filename: 'ring.jpg',
        contentType: 'image/jpeg',
      );
      await Future<void>.delayed(Duration.zero);
      first.complete(const Ok('old-key'));
      await firstPick;
      second.complete(const Ok('new-key'));
      await secondPick;

      final ready = container.read(submitOfferControllerProvider(requestId))
          as SubmitOfferReady;
      expect(ready.images.single.key, 'new-key');
      expect(ready.images.single.failure, isNull);
      expect(ready.draft.mediaKeys, ['new-key']);
    });

    test('reloading the form still accepts a later photo', () async {
      final first = Completer<Result<String>>();
      var calls = 0;
      final container = ProviderContainer(
        overrides: [
          offersVendorRepositoryProvider.overrideWithValue(
            FakeOffersVendorRepository(),
          ),
          offerUploadSkipsConversionProvider.overrideWithValue(true),
          offerImageUploaderProvider.overrideWithValue(
            OfferImageUploader((bytes, contentType, {onProgress}) {
              calls++;
              if (calls == 1) return first.future;
              return Future.value(const Ok('media-key-2'));
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(submitOfferControllerProvider(requestId), (_, _) {});
      await _waitUntilSettled(container, requestId);
      final notifier =
          container.read(submitOfferControllerProvider(requestId).notifier);

      final hanging = notifier.addPickedImage(
        bytes: Uint8List.fromList(const [1]),
        filename: 'ring.jpg',
        contentType: 'image/jpeg',
      );
      await Future<void>.delayed(Duration.zero);
      container.invalidate(submitOfferControllerProvider(requestId));
      await _waitUntilSettled(container, requestId);
      first.complete(const Ok('old-key'));
      await hanging;

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .addPickedImage(
            bytes: Uint8List.fromList(const [2]),
            filename: 'band.jpg',
            contentType: 'image/jpeg',
          );

      final ready = container.read(submitOfferControllerProvider(requestId))
          as SubmitOfferReady;
      expect(ready.images.single.key, 'media-key-2');
      expect(ready.images.single.uploading, isFalse);
      expect(ready.draft.mediaKeys, ['media-key-2']);
    });

    test('dispose during a not-ready submit does not start another attempt',
        () async {
      late ProviderContainer container;
      final repo = FakeOffersVendorRepository(
        submitScript: [
          const ValidationFailure(code: 'MEDIA_NOT_READY', message: 'not ready'),
        ],
      );
      container = ProviderContainer(
        overrides: [
          offersVendorRepositoryProvider.overrideWithValue(repo),
        ],
      );
      container.listen(submitOfferControllerProvider(requestId), (_, _) {});
      final loaded = await _waitUntilSettled(container, requestId);
      final ready = loaded as SubmitOfferReady;
      ready.draft.offeredPrice = '5200';
      ready.draft.weightGrams = '15.00';
      ready.draft.mediaKeys.add('media-key-1');
      repo.onSubmit = () {
        container.dispose();
      };

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      expect(repo.submitCalls, 1);
    });
  });
}
