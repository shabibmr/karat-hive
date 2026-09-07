import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/di.dart';
import '../../../core/media/media_uploader.dart';
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
  });

  final VendorRequestItem request;
  final PlatformConfig config;
  final OfferTermsDraft draft;
  final bool submitting;
  final Failure? failure;
  final List<String> uploadedKeys;

  SubmitOfferReady copyWith({
    VendorRequestItem? request,
    PlatformConfig? config,
    OfferTermsDraft? draft,
    bool? submitting,
    Failure? failure,
    bool clearFailure = false,
    List<String>? uploadedKeys,
  }) {
    return SubmitOfferReady(
      request: request ?? this.request,
      config: config ?? this.config,
      draft: draft ?? this.draft,
      submitting: submitting ?? this.submitting,
      failure: clearFailure ? null : (failure ?? this.failure),
      uploadedKeys: uploadedKeys ?? this.uploadedKeys,
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
  @override
  SubmitOfferState build(String requestId) {
    Future.microtask(_load);
    return const SubmitOfferLoading();
  }

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
    final defaultHours = options.contains(24)
        ? 24
        : (options.isNotEmpty ? options.first : 24);

    state = SubmitOfferReady(
      request: requestResult.valueOrNull!,
      config: config,
      draft: OfferTermsDraft(validityHours: defaultHours),
    );
  }

  void touch() {
    final current = state;
    if (current is SubmitOfferReady) {
      state = current.copyWith(clearFailure: true);
    }
  }

  Future<void> addImage(File file, String contentType) async {
    final current = state;
    if (current is! SubmitOfferReady || current.submitting) return;
    if (current.draft.mediaKeys.length >= 3) return;

    final uploader = MediaUploader(ref.read(khApiProvider));
    final result = await uploader.upload(
      file,
      purpose: MediaUploadPurpose.offerImage,
      contentType: contentType,
    );
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
    );
  }

  void removeImage(String key) {
    final current = state;
    if (current is! SubmitOfferReady || current.submitting) return;
    current.draft.mediaKeys.remove(key);
    state = current.copyWith(
      uploadedKeys: current.uploadedKeys.where((k) => k != key).toList(),
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
