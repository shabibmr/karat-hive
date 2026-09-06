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

/// Per-document upload state machine (intent → PUT → complete → attach).
/// Keep-alive so leaving VEN-S02 does not drop in-flight slots.
class KycUploadController extends Notifier<Map<VendorDocumentType, KycFileState>> {
  @override
  Map<VendorDocumentType, KycFileState> build() => {
        for (final d in mandatoryVendorDocuments) d: const KycFileState(),
      };

  OnboardingRepository get _repo => ref.read(onboardingRepositoryProvider);

  Future<void> pickAndUpload(VendorDocumentType type, File file, String contentType) async {
    state = {...state, type: const KycFileState(uploading: true)};
    final uploaded = await _repo.uploadKycDocument(
      file,
      contentType,
      onProgress: (p) {
        final current = state[type];
        state = {
          ...state,
          type: KycFileState(uploading: true, progress: p, failure: current?.failure),
        };
      },
    );
    await uploaded.when(
      ok: (key) async {
        final attached = await _repo.attachDocument(type: type, mediaKey: key);
        state = {
          ...state,
          type: attached.when(
            ok: (_) => KycFileState(mediaKey: key, progress: 1),
            err: (f) => KycFileState(failure: f),
          ),
        };
      },
      err: (f) async => state = {...state, type: KycFileState(failure: f)},
    );
  }

  bool get allMandatoryDone =>
      mandatoryVendorDocuments.every((d) => state[d]?.done ?? false);
}

final kycUploadControllerProvider =
    NotifierProvider<KycUploadController, Map<VendorDocumentType, KycFileState>>(
  KycUploadController.new,
);
