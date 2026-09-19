import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_media/kh_media.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/di.dart';
import '../repository/offers_vendor_repository.dart';

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
    this.uploadedKeys = const [],
    this.touched = false,
  });

  final VendorRequestItem request;
  final PlatformConfig config;
  final OfferTermsDraft draft;
  final bool submitting;
  final Failure? failure;
  final List<String> uploadedKeys;
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
    List<String>? uploadedKeys,
    bool? touched,
  }) {
    return SubmitOfferReady(
      request: request ?? this.request,
      config: config ?? this.config,
      draft: draft ?? this.draft,
      submitting: submitting ?? this.submitting,
      failure: clearFailure ? null : (failure ?? this.failure),
      uploadedKeys: uploadedKeys ?? this.uploadedKeys,
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

class SubmitOfferController extends AutoDisposeFamilyNotifier<SubmitOfferState, String> {
  late final MediaPickController _media;

  @override
  SubmitOfferState build(String requestId) {
    _media = MediaPickController(
      uploader: MediaUploader(ref.read(khApiProvider)),
      purpose: MediaUploadPurpose.offerImage,
    );
    Future.microtask(_load);
    return const SubmitOfferLoading();
  }

  /// Called from the screen's `initState` so the upload-intent request
  /// overlaps with the vendor reading the request, rather than happening
  /// after they've already picked a photo. Idempotent (delegates to
  /// [MediaPickController.prefetchIntent]) — safe to call more than once,
  /// and deliberately not wired into [build] so plain controller tests
  /// (no screen mounted) never trigger a real network call.
  Future<void> prefetchImageIntent() => _media.prefetchIntent();

  OffersVendorRepository get _repo =>
      ref.read(offersVendorRepositoryProvider);

  Future<void> _load() async {
    final requestId = arg;
    final requestResult = await _repo.getRequest(requestId);
    final configResult = await _repo.getPlatformConfig();

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
    final options = config.offerValidityHours;
    final defaultHours =
        options.contains(24) ? 24 : (options.firstOrNull ?? 24);

    state = SubmitOfferReady(
      request: requestResult.valueOrNull!,
      config: config,
      draft: OfferTermsDraft(validityHours: defaultHours),
    );
  }

  void touch() {
    final current = state;
    if (current is SubmitOfferReady) {
      state = current.copyWith(clearFailure: true, touched: true);
    }
  }

  Future<void> addImage() async {
    final current = state;
    if (current is! SubmitOfferReady || current.submitting) return;
    if (current.draft.mediaKeys.length >= 3) return;

    final slot = 'offer-image-${current.draft.mediaKeys.length}';
    final result = await _media.pickImageConvertAndUpload(
      correlationId: slot,
      source: ImageSource.gallery,
    );
    if (result == null) return; // user cancelled the picker

    final fail = result.failureOrNull;
    if (fail != null) {
      state = current.copyWith(failure: fail);
      return;
    }
    final key = result.valueOrNull!;
    current.draft.mediaKeys.add(key);
    state = current.copyWith(
      uploadedKeys: [...current.uploadedKeys, key],
      clearFailure: true,
      touched: true,
    );
  }

  void removeImage(String key) {
    final current = state;
    if (current is! SubmitOfferReady || current.submitting) return;
    current.draft.mediaKeys.remove(key);
    state = current.copyWith(
      uploadedKeys: current.uploadedKeys.where((k) => k != key).toList(),
      touched: true,
    );
  }

  Future<void> submit() async {
    final current = state;
    if (current is! SubmitOfferReady || current.submitting) return;

    final price = double.tryParse(current.draft.offeredPrice);
    if (price == null || price <= 0) {
      state = current.copyWith(
        failure: const ValidationFailure(message: 'Enter a valid offered price.'),
      );
      return;
    }

    if (current.draft.mediaKeys.isEmpty) {
      state = current.copyWith(
        failure: const ValidationFailure(
          message: 'Please add at least 1 image to your offer.',
        ),
      );
      return;
    }

    state = current.copyWith(submitting: true, clearFailure: true);
    final result = await _repo.submitOffer(
      requestId: arg,
      terms: current.draft.toInput(),
    );
    result.when(
      ok: (offer) => state = SubmitOfferSucceeded(offer),
      err: (f) => state = current.copyWith(submitting: false, failure: f),
    );
  }
}

final submitOfferControllerProvider = AutoDisposeNotifierProvider.family<
    SubmitOfferController, SubmitOfferState, String>(
  SubmitOfferController.new,
);
