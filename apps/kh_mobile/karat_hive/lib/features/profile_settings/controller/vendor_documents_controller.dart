import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../onboarding/controller/kyc_upload_controller.dart' show KycFileState;
import '../../onboarding/repository/onboarding_repository.dart';

/// VEN-S15 documents deep link (`/vendor/profile/documents`, CP6-B02) — view
/// already-uploaded KYC documents and re-submit replacements outside the
/// initial onboarding flow. Distinct from [KycUploadController], which is
/// tied to first-time-KYC (legal fields + one-shot submit).
class VendorDocumentsState {
  const VendorDocumentsState({
    this.loading = true,
    this.documents = const {},
    this.pending = const {},
    this.busy = false,
    this.failure,
  });

  final bool loading;

  /// Server-confirmed documents, keyed by type.
  final Map<VendorDocumentType, VendorDocument> documents;

  /// Local upload-in-progress/failed overlay, keyed by type.
  final Map<VendorDocumentType, KycFileState> pending;
  final bool busy;
  final Failure? failure;

  bool get canResubmit =>
      !busy &&
      mandatoryVendorDocuments.every(
        (d) => documents.containsKey(d) || (pending[d]?.done ?? false),
      );

  VendorDocumentsState copyWith({
    bool? loading,
    Map<VendorDocumentType, VendorDocument>? documents,
    Map<VendorDocumentType, KycFileState>? pending,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      VendorDocumentsState(
        loading: loading ?? this.loading,
        documents: documents ?? this.documents,
        pending: pending ?? this.pending,
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

class VendorDocumentsController extends Notifier<VendorDocumentsState> {
  @override
  VendorDocumentsState build() {
    Future.microtask(_load);
    return const VendorDocumentsState();
  }

  OnboardingRepository get _repo => ref.read(onboardingRepositoryProvider);

  Future<void> _load() async {
    state = state.copyWith(loading: true, clearFailure: true);
    final res = await _repo.documents();
    res.when(
      ok: (docs) {
        state = state.copyWith(
          loading: false,
          documents: {for (final d in docs) d.documentType: d},
        );
      },
      err: (f) => state = state.copyWith(loading: false, failure: f),
    );
  }

  Future<void> pickAndUpload(
    VendorDocumentType type,
    File file,
    String contentType,
  ) async {
    final bytes = Uint8List.fromList(await file.readAsBytes());
    await pickAndUploadBytes(type, bytes, contentType);
  }

  Future<void> pickAndUploadBytes(
    VendorDocumentType type,
    Uint8List bytes,
    String contentType,
  ) async {
    state = state.copyWith(
      pending: {...state.pending, type: const KycFileState(uploading: true)},
    );

    final uploaded = await _repo.uploadKycDocumentBytes(
      type,
      bytes,
      contentType,
      onProgress: (p) {
        state = state.copyWith(
          pending: {
            ...state.pending,
            type: KycFileState(uploading: true, progress: p),
          },
        );
      },
    );

    await uploaded.when(
      ok: (key) async {
        final attached = await _repo.attachDocument(type: type, mediaKey: key);
        attached.when(
          ok: (docs) {
            state = state.copyWith(
              documents: {for (final d in docs) d.documentType: d},
              pending: {
                ...state.pending,
                type: KycFileState(mediaKey: key, progress: 1),
              },
            );
          },
          err: (f) {
            state = state.copyWith(
              pending: {...state.pending, type: KycFileState(failure: f)},
            );
          },
        );
      },
      err: (f) {
        state = state.copyWith(
          pending: {...state.pending, type: KycFileState(failure: f)},
        );
      },
    );
  }

  /// Submits updated documents for re-verification (`BR-004`) — returns the
  /// account to `PENDING_VERIFICATION` on success.
  Future<bool> resubmit() async {
    state = state.copyWith(busy: true, clearFailure: true);
    final res = await _repo.resubmit();
    return res.when(
      ok: (_) {
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

final vendorDocumentsControllerProvider =
    NotifierProvider<VendorDocumentsController, VendorDocumentsState>(
  VendorDocumentsController.new,
);
