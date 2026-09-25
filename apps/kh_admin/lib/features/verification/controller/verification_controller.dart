import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart' show khApiBase;
import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/features/vendors/controller/vendor_list_controller.dart';
import 'package:kh_admin/features/verification/model/grant_subscription_dto.dart';
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

  /// Soft reload after a successful mutation — never throws.
  Future<void> _softReload() async {
    final previous = state;
    final next = await AsyncValue.guard(() async {
      final repository = ref.read(verificationRepositoryProvider);
      return repository.fetchQueue();
    });
    if (next.hasError && previous.hasValue) {
      state = previous;
      return;
    }
    state = next;
  }

  void _invalidateRelated(String vendorId) {
    ref.invalidate(verificationDetailControllerProvider(vendorId));
    ref.invalidate(vendorListControllerProvider);
  }

  Future<void> verifyVendor(String vendorId, String rationale) async {
    final repository = ref.read(verificationRepositoryProvider);
    await repository.verifyVendor(
      vendorId,
      VerifyDecisionDto(rationale: rationale),
    );
    await _softReload();
    _invalidateRelated(vendorId);
  }

  Future<void> rejectVendor(String vendorId, String rationale) async {
    final repository = ref.read(verificationRepositoryProvider);
    await repository.rejectVendor(
      vendorId,
      RejectDecisionDto(rationale: rationale),
    );
    await _softReload();
    _invalidateRelated(vendorId);
  }

  /// Records one type subscription per entry in [types] (`FR-VEN-031`).
  ///
  /// Grants run after `/verify` as separate calls, so a failed grant leaves the
  /// verification standing rather than rolling it back. Returns the types that
  /// could not be granted, paired with the failure, for the caller to report
  /// and retry — already-granted types must not be resent, the backend has no
  /// duplicate guard on `(vendor, requestType, ACTIVE)`.
  Future<List<({RequestType type, Object error})>> grantTypeSubscriptions(
    String vendorId,
    List<RequestType> types,
  ) async {
    if (types.isEmpty) return const [];

    final repository = ref.read(verificationRepositoryProvider);
    final failures = <({RequestType type, Object error})>[];
    for (final type in types) {
      try {
        await repository.grantSubscription(
          vendorId,
          GrantSubscriptionDto.forType(type),
        );
      } on Object catch (e) {
        failures.add((type: type, error: e));
      }
    }
    _invalidateRelated(vendorId);
    return failures;
  }

  Future<void> requestInfo(String vendorId, String message) async {
    final repository = ref.read(verificationRepositoryProvider);
    await repository.requestInfo(
      vendorId,
      RequestInfoDto(message: message),
    );
    await _softReload();
    _invalidateRelated(vendorId);
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

  /// Prefix relative paths with the API base for display/diagnostics.
  /// Opening still requires a signed absolute URL ([_looksLikeSignedUrl]).
  static String _resolveDocumentUrl(String url) {
    if (url.startsWith('/')) {
      return '${khApiBase.replaceAll(RegExp(r'/+$'), '')}$url';
    }
    return url;
  }

  /// True when [url] is absolute http(s) with query params that look like a
  /// signed/tokenized media URL. Auth-gated `/v1/media/` paths without a
  /// signature cannot be opened in a bare browser tab.
  static bool _looksLikeSignedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    if (!uri.hasAuthority) return false;
    if (uri.queryParameters.isEmpty) return false;

    final keys = uri.queryParameters.keys.map((k) => k.toLowerCase());
    final hasSig = keys.any(
      (k) =>
          k.contains('sign') ||
          k.contains('token') ||
          k.contains('x-amz') ||
          k == 'expires' ||
          k == 'expiry',
    );

    return hasSig;
  }

  static const _unsignedPreviewMessage =
      'Document preview requires a signed URL; relative or unsigned media paths cannot be opened in a new tab.';

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
      if (!_looksLikeSignedUrl(resolved)) {
        state = state._copy(
          loadingDocId: null,
          error: _unsignedPreviewMessage,
        );
        return null;
      }
      state = state._copy(
        loadingDocId: null,
        openedDocId: documentId,
        openedDocUrl: resolved,
        error: null,
      );
      return resolved;
    } on Object catch (e) {
      state = state._copy(loadingDocId: null, error: e);
      return null;
    }
  }
}

final verificationDocViewControllerProvider = NotifierProvider.family<
    VerificationDocViewController, VerificationDocView, String>(
  VerificationDocViewController.new,
);
