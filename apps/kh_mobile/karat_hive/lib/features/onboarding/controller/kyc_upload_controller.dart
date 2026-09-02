import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/onboarding_repository.dart';

class KycFileState {
  const KycFileState({this.uploading = false, this.mediaKey, this.failure});
  final bool uploading;
  final String? mediaKey;
  final Failure? failure;

  bool get done => mediaKey != null;
}

/// Per-document upload state machine (intent → PUT → complete → attach). Each
/// slot's failure is isolated (Architecture-Frontend §12).
class KycUploadController
    extends AutoDisposeNotifier<Map<VendorDocumentType, KycFileState>> {
  @override
  Map<VendorDocumentType, KycFileState> build() => {
        for (final d in mandatoryVendorDocuments) d: const KycFileState(),
      };

  OnboardingRepository get _repo => ref.read(onboardingRepositoryProvider);

  Future<void> pickAndUpload(VendorDocumentType type, File file, String contentType) async {
    state = {...state, type: const KycFileState(uploading: true)};
    final uploaded = await _repo.uploadKycDocument(file, contentType);
    await uploaded.when(
      ok: (key) async {
        final attached = await _repo.attachDocument(type: type, mediaKey: key);
        state = {
          ...state,
          type: attached.when(
            ok: (_) => KycFileState(mediaKey: key),
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

final kycUploadControllerProvider = AutoDisposeNotifierProvider<KycUploadController,
    Map<VendorDocumentType, KycFileState>>(KycUploadController.new);
