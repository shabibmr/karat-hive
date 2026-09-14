import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/onboarding_repository.dart';

class KycFileState {
  const KycFileState({
    this.uploading = false,
    this.mediaKey,
    this.failure,
    this.progress = 0,
  });
  final bool uploading;
  final String? mediaKey;
  final Failure? failure;
  final double progress;

  bool get done => mediaKey != null;
}

class KycScreenState {
  const KycScreenState({
    this.legalBusinessName = '',
    this.tradeLicenceNumber = '',
    this.licenceExpiryDate = '',
    this.documents = const {},
    this.busy = false,
    this.failure,
  });

  final String legalBusinessName;
  final String tradeLicenceNumber;
  final String licenceExpiryDate;
  final Map<VendorDocumentType, KycFileState> documents;
  final bool busy;
  final Failure? failure;

  bool get fieldsComplete =>
      legalBusinessName.trim().isNotEmpty &&
      tradeLicenceNumber.trim().isNotEmpty &&
      licenceExpiryDate.trim().isNotEmpty;

  bool get mandatoryDocsDone =>
      mandatoryVendorDocuments.every((d) => documents[d]?.done ?? false);

  bool get isReadyToSubmit => fieldsComplete && mandatoryDocsDone && !busy;

  KycScreenState copyWith({
    String? legalBusinessName,
    String? tradeLicenceNumber,
    String? licenceExpiryDate,
    Map<VendorDocumentType, KycFileState>? documents,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      KycScreenState(
        legalBusinessName: legalBusinessName ?? this.legalBusinessName,
        tradeLicenceNumber: tradeLicenceNumber ?? this.tradeLicenceNumber,
        licenceExpiryDate: licenceExpiryDate ?? this.licenceExpiryDate,
        documents: documents ?? this.documents,
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

class KycUploadController extends Notifier<KycScreenState> {
  @override
  KycScreenState build() => KycScreenState(
        documents: {
          for (final d in mandatoryVendorDocuments) d: const KycFileState(),
        },
      );

  OnboardingRepository get _repo => ref.read(onboardingRepositoryProvider);

  /// Called from the screen's `initState` so the upload-intent request
  /// overlaps with the vendor reading the KYC form, rather than happening
  /// after they've already picked a document. Idempotent.
  Future<void> prefetchDocumentIntent() => _repo.prefetchKycDocumentIntent();

  void patchFields({
    String? legalBusinessName,
    String? tradeLicenceNumber,
    String? licenceExpiryDate,
  }) {
    state = state.copyWith(
      legalBusinessName: legalBusinessName,
      tradeLicenceNumber: tradeLicenceNumber,
      licenceExpiryDate: licenceExpiryDate,
      clearFailure: true,
    );
  }

  Future<void> pickAndUpload(VendorDocumentType type, File file, String contentType) async {
    final updatedDocs = {
      ...state.documents,
      type: const KycFileState(uploading: true),
    };
    state = state.copyWith(documents: updatedDocs);

    final uploaded = await _repo.uploadKycDocument(
      type,
      file,
      contentType,
      onProgress: (p) {
        final current = state.documents[type];
        state = state.copyWith(
          documents: {
            ...state.documents,
            type: KycFileState(uploading: true, progress: p, failure: current?.failure),
          },
        );
      },
    );

    await uploaded.when(
      ok: (key) async {
        final attached = await _repo.attachDocument(
          type: type,
          mediaKey: key,
        );
        state = state.copyWith(
          documents: {
            ...state.documents,
            type: attached.when(
              ok: (_) => KycFileState(mediaKey: key, progress: 1),
              err: (f) => KycFileState(failure: f),
            ),
          },
        );
      },
      err: (f) async {
        state = state.copyWith(
          documents: {
            ...state.documents,
            type: KycFileState(failure: f),
          },
        );
      },
    );
  }

  Future<bool> submitKyc() async {
    state = state.copyWith(busy: true, clearFailure: true);
    final patchRes = await _repo.patchKycProfile(
      legalBusinessName: state.legalBusinessName,
      tradeLicenceNumber: state.tradeLicenceNumber,
    );
    return patchRes.when(
      ok: (_) async {
        state = state.copyWith(busy: false);
        return true;
      },
      err: (f) {
        state = state.copyWith(busy: false, failure: f);
        return false;
      },
    );
  }
}

final kycUploadControllerProvider =
    NotifierProvider<KycUploadController, KycScreenState>(
  KycUploadController.new,
);
