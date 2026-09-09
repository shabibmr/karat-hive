import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart' show khApiBase;
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/features/verification/model/verification_decision_dto.dart';
import 'package:kh_admin/features/verification/model/verification_queue_item.dart';
import 'package:kh_admin/features/verification/model/vendor_verification_detail.dart';
import 'package:kh_admin/features/verification/repository/verification_repository.dart';

/// Riverpod [AsyncNotifier] managing the verification queue list (ADM-S07).
class VerificationQueueController extends AsyncNotifier<List<VerificationQueueItem>> {
  @override
  Future<List<VerificationQueueItem>> build() async {
    final repository = ref.watch(verificationRepositoryProvider);
    return repository.fetchQueue();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(verificationRepositoryProvider);
      return repository.fetchQueue();
    });
  }

  Future<void> verifyVendor(String vendorId, String rationale) async {
    final repository = ref.read(verificationRepositoryProvider);
    await repository.verifyVendor(
      vendorId,
      VerifyDecisionDto(rationale: rationale),
    );
    await reload();
  }

  Future<void> rejectVendor(String vendorId, String rationale) async {
    final repository = ref.read(verificationRepositoryProvider);
    await repository.rejectVendor(
      vendorId,
      RejectDecisionDto(rationale: rationale),
    );
    await reload();
  }

  Future<void> requestInfo(String vendorId, String message) async {
    final repository = ref.read(verificationRepositoryProvider);
    await repository.requestInfo(
      vendorId,
      RequestInfoDto(message: message),
    );
    await reload();
  }
}

final verificationQueueControllerProvider =
    AsyncNotifierProvider<VerificationQueueController, List<VerificationQueueItem>>(
  VerificationQueueController.new,
);

/// Riverpod family notifier for the selected vendor's review detail.
class VerificationDetailController
    extends FamilyAsyncNotifier<VendorVerificationDetail, String> {
  @override
  Future<VendorVerificationDetail> build(String arg) async {
    final repository = ref.watch(verificationRepositoryProvider);
    return repository.fetchVendorDetail(arg);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(verificationRepositoryProvider);
      return repository.fetchVendorDetail(arg);
    });
  }
}

final verificationDetailControllerProvider = AsyncNotifierProvider.family<
    VerificationDetailController,
    VendorVerificationDetail,
    String>(
  VerificationDetailController.new,
);

/// Immutable view-state for the KYC document viewer in [VerificationDetailPane].
///
/// Keeps the "which doc is opening / which failed / which was last opened"
/// bookkeeping in the controller layer so the presentation widget never calls a
/// repository directly (TR-S2-15).
class VerificationDocView {
  const VerificationDocView({
    this.loadingDocId,
    this.error,
    this.openedDocId,
    this.openedDocUrl,
  });

  /// Id of the document whose URL is currently being fetched, if any.
  final String? loadingDocId;

  /// The last fetch failure (raw), resolved to a message in presentation via
  /// `resolveApiErrorMessage`. Null when there is no outstanding error.
  final Object? error;

  /// Id of the most recently opened document.
  final String? openedDocId;

  /// Resolved absolute URL of the most recently opened document.
  final String? openedDocUrl;

  static const Object _keep = Object();

  VerificationDocView _copy({
    Object? loadingDocId = _keep,
    Object? error = _keep,
    Object? openedDocId = _keep,
    Object? openedDocUrl = _keep,
  }) {
    return VerificationDocView(
      loadingDocId: identical(loadingDocId, _keep)
          ? this.loadingDocId
          : loadingDocId as String?,
      error: identical(error, _keep) ? this.error : error,
      openedDocId: identical(openedDocId, _keep)
          ? this.openedDocId
          : openedDocId as String?,
      openedDocUrl: identical(openedDocUrl, _keep)
          ? this.openedDocUrl
          : openedDocUrl as String?,
    );
  }
}

/// Owns the document-viewer side effects for the verification detail pane:
/// fetching the audited signed URL and tracking loading / error / opened state.
class VerificationDocViewController
    extends FamilyNotifier<VerificationDocView, String> {
  @override
  VerificationDocView build(String arg) => const VerificationDocView();

  /// origin/main's document-url endpoint returns a RELATIVE path
  /// (`/v1/media/<key>`), not a signed absolute URL. Prefix the API base so the
  /// browser can resolve it. NOTE: `/v1/media/<key>` is an authenticated route
  /// and opening it in a new tab cannot attach the bearer token — a signed /
  /// public media URL from the backend is still needed for this to actually
  /// render (owned by S4 / TR-S4-19). Until then this at least points at the
  /// right origin.
  static String _resolveDocumentUrl(String url) {
    if (url.startsWith('/')) {
      return '${khApiBase.replaceAll(RegExp(r'/+$'), '')}$url';
    }
    return url;
  }

  /// Fetches the audited URL for [documentId], records it in state, and returns
  /// the resolved absolute URL for the caller to open (null on failure).
  Future<String?> openDocument(String documentId) async {
    state = state._copy(loadingDocId: documentId, error: null);
    try {
      final repository = ref.read(verificationRepositoryProvider);
      final res = await repository.fetchDocumentUrl(
        vendorId: arg,
        documentId: documentId,
      );
      final resolved = _resolveDocumentUrl(res.url);
      state = state._copy(
        loadingDocId: null,
        openedDocId: documentId,
        openedDocUrl: resolved,
      );
      return resolved;
    } on ApiException catch (e) {
      state = state._copy(loadingDocId: null, error: e);
      return null;
    }
  }
}

final verificationDocViewControllerProvider = NotifierProvider.family<
    VerificationDocViewController, VerificationDocView, String>(
  VerificationDocViewController.new,
);
