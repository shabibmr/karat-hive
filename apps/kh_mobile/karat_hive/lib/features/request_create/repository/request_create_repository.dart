import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_media/kh_media.dart';

import '../../../app/di.dart';

class DraftSaveResult {
  const DraftSaveResult({required this.request, this.warnings = const []});

  final RequestForCustomer request;
  final List<String> warnings;

  factory DraftSaveResult.fromApi(RequestDraftSave save) => DraftSaveResult(
        request: save.request,
        warnings: save.warnings,
      );
}

/// Customer Request create/publish. Maps envelope → domain via CM-S07
/// typed `RequestsClient` methods so widgets never see JSON.
class RequestCreateRepository {
  RequestCreateRepository(this._api, {MediaPickController? media})
      : _media = media ??
            MediaPickController(
              uploader: MediaUploader(_api),
              purpose: MediaUploadPurpose.requestImage,
            );

  final KhApi _api;
  final MediaPickController _media;

  Future<Result<PlatformConfig>> platformConfig() =>
      _api.platformConfig.getConfig();

  Future<Result<GoldRateSnapshot>> goldRates() => _api.goldRates();

  Future<Result<List<TaxonomyNode>>> categories() => _api.categories();

  Future<Result<List<TaxonomyNode>>> regions() => _api.regions();

  Future<Result<MeUser>> me() => _api.me();

  Future<Result<DraftSaveResult>> createDraft(Map<String, dynamic> body) async {
    final r = await _api.requests.create(RequestDraftInput.fromJson(body));
    return r.when(
      ok: (save) => Ok(DraftSaveResult.fromApi(save)),
      err: Err.new,
    );
  }

  Future<Result<DraftSaveResult>> patchDraft(
    String id,
    Map<String, dynamic> body,
  ) async {
    final r = await _api.requests.patch(id, RequestDraftInput.fromJson(body));
    return r.when(
      ok: (save) => Ok(DraftSaveResult.fromApi(save)),
      err: Err.new,
    );
  }

  Future<Result<RequestForCustomer>> getRequest(String id) =>
      _api.requests.getMine(id);

  /// Publish uses a caller-held idempotency key so OAuth bind + retry
  /// does not mint a second key (Architecture-Frontend §9.4).
  Future<Result<RequestForCustomer>> publish(
    String id, {
    required String idempotencyKey,
  }) =>
      _api.requests.publish(id, idempotencyKey: idempotencyKey);

  Future<Result<void>> bindOAuth({
    required String identityToken,
    String provider = 'GOOGLE',
  }) async {
    final r = await _api.client.send(
      'POST',
      '/v1/auth/oauth/bind',
      body: {'provider': provider, 'identityToken': identityToken},
    );
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  Future<Result<void>> deleteMedia(String key) => _api.deleteMedia(key);

  Future<Result<String>> uploadRequestImage(
    File file,
    String contentType, {
    void Function(double progress)? onProgress,
  }) =>
      _media.uploadRaw(
        file,
        contentType,
        correlationId: 'guest-${file.path.hashCode}',
        onProgress: onProgress,
      );

  /// Warms the upload-intent ahead of the customer reaching the images
  /// step (called from that step's `initState`). Idempotent.
  Future<void> prefetchRequestImageIntent() => _media.prefetchIntent();

  /// Picks a photo, converts it to AVIF on-device, caches it under
  /// [correlationId], and uploads. Returns `null` if the customer cancelled
  /// the picker. A failed upload leaves the converted file cached so
  /// [retryRequestImage] can resume without re-picking or re-converting.
  Future<Result<String>?> pickAndUploadRequestImage(
    String correlationId, {
    void Function(double progress)? onProgress,
  }) =>
      _media.pickImageConvertAndUpload(
        correlationId: correlationId,
        source: ImageSource.gallery,
        onProgress: onProgress,
      );

  /// Re-runs the upload against the cached converted file for
  /// [correlationId]. Returns `null` if nothing is cached (e.g. the app was
  /// killed and reopened) — the caller should ask the customer to re-pick.
  Future<Result<String>?> retryRequestImage(
    String correlationId, {
    void Function(double progress)? onProgress,
  }) =>
      _media.retry(correlationId, onProgress: onProgress);
}

final requestCreateRepositoryProvider = Provider<RequestCreateRepository>(
  (ref) => RequestCreateRepository(ref.watch(khApiProvider)),
);
