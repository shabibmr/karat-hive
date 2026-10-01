import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_media/kh_media.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/di.dart';
import '../../../core/firebase/firestore_debug_logger.dart';
import '../repository/offers_vendor_repository.dart';

const _submitOfferLogScope = 'SubmitOffer';

class OfferImageSlot {
  const OfferImageSlot({
    required this.key,
    this.localLabel,
    this.localBytes,
    this.contentType,
    this.progress = 1,
    this.uploading = false,
    this.failure,
  });

  final String key;
  final String? localLabel;
  final Uint8List? localBytes;
  final String? contentType;
  final double progress;
  final bool uploading;
  final Failure? failure;

  bool get isPending => key.startsWith('pending:');

  OfferImageSlot copyWith({
    String? key,
    String? localLabel,
    Uint8List? localBytes,
    String? contentType,
    double? progress,
    bool? uploading,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      OfferImageSlot(
        key: key ?? this.key,
        localLabel: localLabel ?? this.localLabel,
        localBytes: localBytes ?? this.localBytes,
        contentType: contentType ?? this.contentType,
        progress: progress ?? this.progress,
        uploading: uploading ?? this.uploading,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

/// Uploads Offer image bytes. Web skips conversion and sends the pick as-is;
/// native callers pass already-converted WebP bytes.
class OfferImageUploader {
  const OfferImageUploader(this._upload);

  final Future<Result<String>> Function(
    Uint8List bytes,
    String contentType, {
    void Function(double progress)? onProgress,
  }) _upload;

  Future<Result<String>> upload(
    Uint8List bytes,
    String contentType, {
    void Function(double progress)? onProgress,
  }) =>
      _upload(bytes, contentType, onProgress: onProgress);
}

/// Web has no WebP encoder, so Offer photos upload the original JPEG/PNG.
/// Native re-encodes to WebP, matching Request Create.
final offerUploadSkipsConversionProvider = Provider<bool>((ref) => kIsWeb);

final offerImageConverterProvider = Provider<ImageConverter>(
  (ref) => const WebpImageConverter(),
);

/// Wait between submit retries while offer photos finish server-side processing.
final offerMediaReadyRetryDelayProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

const _offerMediaReadyMaxRetries = 30;

final offerRetrySleepProvider = Provider<Future<void> Function(Duration)>(
  (ref) => Future<void>.delayed,
);

final offerImageUploaderProvider = Provider<OfferImageUploader>((ref) {
  final uploader = MediaUploader(
    ref.watch(khApiProvider),
    onDebug: ref
        .watch(firestoreDebugLoggerProvider)
        .sinkFor('OfferImageUpload'),
  );
  return OfferImageUploader(
    (bytes, contentType, {onProgress}) => uploader.uploadBytes(
      bytes,
      purpose: MediaUploadPurpose.offerImage,
      contentType: contentType,
      awaitReady: false,
      onProgress: onProgress,
    ),
  );
});

sealed class SubmitOfferState {
  const SubmitOfferState();
}

class SubmitOfferLoading extends SubmitOfferState {
  const SubmitOfferLoading();
}

class SubmitOfferReady extends SubmitOfferState {
  const SubmitOfferReady({
    required this.request,
    required this.config,
    required this.draft,
    this.submitting = false,
    this.failure,
    this.images = const [],
    this.touched = false,
  });

  final VendorRequestItem request;
  final PlatformConfig config;
  final OfferTermsDraft draft;
  final bool submitting;
  final Failure? failure;
  final List<OfferImageSlot> images;
  /// True once the vendor has edited a field or added/removed a photo —
  /// drives the discard-changes confirmation on back navigation.
  final bool touched;

  SubmitOfferReady copyWith({
    VendorRequestItem? request,
    PlatformConfig? config,
    OfferTermsDraft? draft,
    bool? submitting,
    Failure? failure,
    bool clearFailure = false,
    List<OfferImageSlot>? images,
    bool? touched,
  }) {
    return SubmitOfferReady(
      request: request ?? this.request,
      config: config ?? this.config,
      draft: draft ?? this.draft,
      submitting: submitting ?? this.submitting,
      failure: clearFailure ? null : (failure ?? this.failure),
      images: images ?? this.images,
      touched: touched ?? this.touched,
    );
  }
}

class SubmitOfferFailed extends SubmitOfferState {
  const SubmitOfferFailed(this.failure);
  final Failure failure;
}

class SubmitOfferSucceeded extends SubmitOfferState {
  const SubmitOfferSucceeded(this.offer);
  final OfferForVendor offer;
}

class SubmitOfferController extends Notifier<SubmitOfferState> {
  SubmitOfferController(this.arg);

  final String arg;

  static const maxImages = 3;

  int _gen = 0;
  int _pickSeq = 0;

  @override
  SubmitOfferState build() {
    final gen = ++_gen;
    ref.onDispose(() {
      if (_gen == gen) _gen++;
    });
    Future.microtask(_load);
    return const SubmitOfferLoading();
  }

  bool _stale(int gen) => gen != _gen;

  OffersVendorRepository get _repo =>
      ref.read(offersVendorRepositoryProvider);

  Future<void> _load() async {
    final gen = _gen;
    final requestId = arg;
    final requestResult = await _repo.getRequest(requestId);
    final configResult = await _repo.getPlatformConfig();
    if (_stale(gen)) return;

    final requestFail = requestResult.failureOrNull;
    if (requestFail != null) {
      state = SubmitOfferFailed(requestFail);
      return;
    }
    final configFail = configResult.failureOrNull;
    if (configFail != null) {
      state = SubmitOfferFailed(configFail);
      return;
    }

    final config = configResult.valueOrNull!;
    final request = requestResult.valueOrNull!;
    final reqPurity = request.purityKarat != null && request.purityKarat!.isNotEmpty
        ? Karat.parse(request.purityKarat)
        : Karat.k22;
    final reqWeight = request.weightGrams != null
        ? request.weightGrams!.toStringAsFixed(2)
        : '';

    state = SubmitOfferReady(
      request: request,
      config: config,
      draft: OfferTermsDraft(
        purityKarat: reqPurity == Karat.unknown ? Karat.k22 : reqPurity,
        weightGrams: reqWeight,
      ),
    );
  }

  void touch() {
    final current = state;
    if (current is SubmitOfferReady) {
      state = current.copyWith(clearFailure: true, touched: true);
    }
  }

  Future<void> addPickedImage({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    final current = state;
    if (current is! SubmitOfferReady || current.submitting) return;
    if (current.images.length >= maxImages) return;
    if (bytes.isEmpty) return;

    final gen = _gen;
    final label = filename.trim().isEmpty ? 'photo.jpg' : filename;
    final placeholderKey = 'pending:${++_pickSeq}';
    state = current.copyWith(
      images: [
        ...current.images,
        OfferImageSlot(
          key: placeholderKey,
          localLabel: label,
          localBytes: bytes,
          contentType: contentType,
          progress: 0,
          uploading: true,
        ),
      ],
      clearFailure: true,
      touched: true,
    );

    final prepared = await _prepareForUpload(bytes, contentType);
    if (_stale(gen) || !_hasImage(placeholderKey)) return;
    if (prepared == null) {
      _replaceSlot(
        placeholderKey,
        (slot) => slot.copyWith(
          uploading: false,
          failure: const ServerFailure(
            message: 'Could not convert that photo. Try another.',
          ),
        ),
      );
      return;
    }

    final result = await ref.read(offerImageUploaderProvider).upload(
          prepared.bytes,
          prepared.contentType,
          onProgress: (progress) {
            _replaceSlot(
              placeholderKey,
              (slot) => slot.copyWith(progress: progress),
            );
          },
        );

    if (_stale(gen) || !_hasImage(placeholderKey)) return;
    final fail = result.failureOrNull;
    if (fail != null) {
      _replaceSlot(
        placeholderKey,
        (slot) => slot.copyWith(uploading: false, failure: fail),
        failure: fail,
      );
      return;
    }

    final key = result.valueOrNull!;
    final latest = state;
    if (_stale(gen) || latest is! SubmitOfferReady) return;
    if (!latest.images.any((image) => image.key == placeholderKey)) return;
    if (!latest.draft.mediaKeys.contains(key)) {
      latest.draft.mediaKeys.add(key);
    }
    state = latest.copyWith(
      images: [
        for (final image in latest.images)
          if (image.key == placeholderKey)
            image.copyWith(
              key: key,
              uploading: false,
              progress: 1,
              clearFailure: true,
            )
          else
            image,
      ],
      clearFailure: true,
      touched: true,
    );
  }

  Future<void> retryImage(String key) async {
    final current = state;
    if (current is! SubmitOfferReady || current.submitting) return;
    OfferImageSlot? slot;
    for (final image in current.images) {
      if (image.key == key) {
        slot = image;
        break;
      }
    }
    if (slot == null || slot.failure == null) return;
    final bytes = slot.localBytes;
    if (bytes == null || bytes.isEmpty) return;
    final label = slot.localLabel ?? 'photo.jpg';
    final contentType = slot.contentType ?? 'image/jpeg';
    removeImage(key);
    await addPickedImage(
      bytes: bytes,
      filename: label,
      contentType: contentType,
    );
  }

  void removeImage(String key) {
    final current = state;
    if (current is! SubmitOfferReady || current.submitting) return;
    current.draft.mediaKeys.remove(key);
    state = current.copyWith(
      images: current.images.where((image) => image.key != key).toList(),
      touched: true,
    );
  }

  Future<({Uint8List bytes, String contentType})?> _prepareForUpload(
    Uint8List bytes,
    String contentType,
  ) async {
    if (ref.read(offerUploadSkipsConversionProvider)) {
      return (bytes: bytes, contentType: contentType);
    }
    try {
      final asset =
          await ref.read(offerImageConverterProvider).convertBytes(bytes);
      return (bytes: await asset.readBytes(), contentType: asset.contentType);
    } catch (_) {
      return null;
    }
  }

  bool _hasImage(String key) {
    final current = state;
    if (current is! SubmitOfferReady) return false;
    return current.images.any((image) => image.key == key);
  }

  void _replaceSlot(
    String key,
    OfferImageSlot Function(OfferImageSlot slot) update, {
    Failure? failure,
    bool clearFailure = false,
  }) {
    final current = state;
    if (current is! SubmitOfferReady) return;
    if (!current.images.any((image) => image.key == key)) return;
    state = current.copyWith(
      images: [
        for (final image in current.images)
          if (image.key == key) update(image) else image,
      ],
      failure: failure,
      clearFailure: clearFailure,
    );
  }

  Future<void> submit() async {
    final current = state;
    if (current is! SubmitOfferReady || current.submitting) return;
    final gen = _gen;
    final log = ref.read(firestoreDebugLoggerProvider);
    final mediaKeys = List<String>.from(current.draft.mediaKeys);

    log.log(_submitOfferLogScope, 'submit.tap', {
      'requestId': arg,
      'mediaKeyCount': mediaKeys.length,
      'mediaKeys': mediaKeys,
      'imageCount': current.images.length,
      'uploadingCount':
          current.images.where((image) => image.uploading).length,
      'failedImageCount':
          current.images.where((image) => image.failure != null).length,
      'priceRaw': current.draft.offeredPrice,
      'weightRaw': current.draft.weightGrams,
    });

    final price = double.tryParse(current.draft.offeredPrice);
    if (price == null || price <= 0) {
      log.log(_submitOfferLogScope, 'submit.validationFailed', {
        'requestId': arg,
        'reason': 'invalid_price',
      });
      state = current.copyWith(
        failure: const ValidationFailure(message: 'Enter a valid offered price.'),
      );
      return;
    }

    final weight = double.tryParse(current.draft.weightGrams);
    if (weight == null || weight <= 0) {
      log.log(_submitOfferLogScope, 'submit.validationFailed', {
        'requestId': arg,
        'reason': 'invalid_weight',
      });
      state = current.copyWith(
        failure: const ValidationFailure(message: 'Enter a valid gold weight.'),
      );
      return;
    }

    if (current.images.any((image) => image.uploading)) {
      log.log(_submitOfferLogScope, 'submit.validationFailed', {
        'requestId': arg,
        'reason': 'image_uploading',
      });
      state = current.copyWith(
        failure: const ValidationFailure(
          message: 'Photo is still uploading.',
        ),
      );
      return;
    }

    if (current.images.any((image) => image.failure != null)) {
      log.log(_submitOfferLogScope, 'submit.validationFailed', {
        'requestId': arg,
        'reason': 'image_upload_failed',
      });
      state = current.copyWith(
        failure: const ValidationFailure(
          message: 'Remove or retry the photo that failed to upload.',
        ),
      );
      return;
    }

    if (mediaKeys.isEmpty) {
      log.log(_submitOfferLogScope, 'submit.validationFailed', {
        'requestId': arg,
        'reason': 'no_media_keys',
      });
      state = current.copyWith(
        failure: const ValidationFailure(
          message: 'Please add at least 1 image to your offer.',
        ),
      );
      return;
    }

    state = current.copyWith(submitting: true, clearFailure: true);
    final delay = ref.read(offerMediaReadyRetryDelayProvider);
    final startedAt = DateTime.now().toUtc();
    log.log(_submitOfferLogScope, 'submit.api.start', {
      'requestId': arg,
      'mediaKeys': mediaKeys,
      'delayMs': delay.inMilliseconds,
      'maxRetries': _offerMediaReadyMaxRetries,
    });

    var result = await _repo.submitOffer(
      requestId: arg,
      terms: current.draft.toInput(),
    );
    log.log(_submitOfferLogScope, 'submit.api.result', {
      'requestId': arg,
      'attempt': 0,
      'ok': result.isOk,
      'code': result.failureOrNull?.code,
      'message': result.failureOrNull?.message,
      'elapsedMs': DateTime.now().toUtc().difference(startedAt).inMilliseconds,
    });

    for (
      var n = 0;
      n < _offerMediaReadyMaxRetries &&
          result.failureOrNull?.code == 'MEDIA_NOT_READY';
      n++
    ) {
      if (_stale(gen)) {
        log.log(_submitOfferLogScope, 'submit.stale', {
          'requestId': arg,
          'at': 'before_retry_sleep',
          'attempt': n,
        });
        return;
      }
      log.log(_submitOfferLogScope, 'submit.mediaNotReady.retry', {
        'requestId': arg,
        'attempt': n + 1,
        'delayMs': delay.inMilliseconds,
      });
      await ref.read(offerRetrySleepProvider)(delay);
      if (_stale(gen)) {
        log.log(_submitOfferLogScope, 'submit.stale', {
          'requestId': arg,
          'at': 'after_retry_sleep',
          'attempt': n + 1,
        });
        return;
      }
      final retryStartedAt = DateTime.now().toUtc();
      result = await _repo.submitOffer(
        requestId: arg,
        terms: current.draft.toInput(),
      );
      log.log(_submitOfferLogScope, 'submit.api.result', {
        'requestId': arg,
        'attempt': n + 1,
        'ok': result.isOk,
        'code': result.failureOrNull?.code,
        'message': result.failureOrNull?.message,
        'elapsedMs':
            DateTime.now().toUtc().difference(retryStartedAt).inMilliseconds,
      });
    }
    if (_stale(gen)) {
      log.log(_submitOfferLogScope, 'submit.stale', {
        'requestId': arg,
        'at': 'after_retries',
      });
      return;
    }
    result.when(
      ok: (offer) {
        log.log(_submitOfferLogScope, 'submit.succeeded', {
          'requestId': arg,
          'offerId': offer.id,
          'totalElapsedMs':
              DateTime.now().toUtc().difference(startedAt).inMilliseconds,
        });
        state = SubmitOfferSucceeded(offer);
      },
      err: (f) {
        log.log(_submitOfferLogScope, 'submit.failed', {
          'requestId': arg,
          'code': f.code,
          'message': f.message,
          'totalElapsedMs':
              DateTime.now().toUtc().difference(startedAt).inMilliseconds,
        });
        state = current.copyWith(submitting: false, failure: f);
      },
    );
  }
}

final submitOfferControllerProvider = NotifierProvider.autoDispose.family<
    SubmitOfferController, SubmitOfferState, String>(
  SubmitOfferController.new,
);
