import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';
import '../../../core/media/media_uploader.dart';

class DraftSaveResult {
  const DraftSaveResult({required this.request, this.warnings = const []});

  final RequestForCustomer request;
  final List<String> warnings;
}

/// Customer Request create/publish. Maps envelope → domain here so widgets
/// never see JSON.
class RequestCreateRepository {
  RequestCreateRepository(this._api, {MediaUploader? media})
      : _media = media ?? MediaUploader(_api);

  final KhApi _api;
  final MediaUploader _media;

  Future<Result<PlatformConfig>> platformConfig() =>
      _api.platformConfig.getConfig();

  Future<Result<GoldRateSnapshot>> goldRates() => _api.goldRates();

  Future<Result<List<TaxonomyNode>>> categories() => _api.categories();

  Future<Result<List<TaxonomyNode>>> regions() => _api.regions();

  Future<Result<MeUser>> me() => _api.me();

  Future<Result<DraftSaveResult>> createDraft(Map<String, dynamic> body) async {
    final r = await _api.requests.create(body, unwrapData: false);
    return r.when(ok: _mapDraftSave, err: Err.new);
  }

  Future<Result<DraftSaveResult>> patchDraft(
    String id,
    Map<String, dynamic> body,
  ) async {
    final r = await _api.requests.patch(id, body, unwrapData: false);
    return r.when(ok: _mapDraftSave, err: Err.new);
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

  Future<Result<void>> deleteMedia(String key) async {
    final r = await _api.client.send('DELETE', '/v1/media/$key');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  Future<Result<String>> uploadRequestImage(
    File file,
    String contentType, {
    void Function(double progress)? onProgress,
  }) =>
      _media.upload(
        file,
        purpose: MediaUploadPurpose.requestImage,
        contentType: contentType,
        onProgress: onProgress,
      );

  Result<DraftSaveResult> _mapDraftSave(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};
    final data = map.containsKey('data') ? map['data'] : map;
    final meta = map['meta'] is Map
        ? Map<String, dynamic>.from(map['meta'] as Map)
        : const <String, dynamic>{};
    return Ok(
      DraftSaveResult(
        request: RequestForCustomer.fromJson(_asMap(data)),
        warnings: _warnings(meta),
      ),
    );
  }

  static Map<String, dynamic> _asMap(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  static List<String> _warnings(Map<String, dynamic> meta) {
    final raw = meta['warnings'];
    if (raw is! List) return const [];
    return raw
        .map((e) {
          if (e is String) return e;
          if (e is Map) return (e['message'] ?? e['code'] ?? '').toString();
          return e.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
}

final requestCreateRepositoryProvider = Provider<RequestCreateRepository>(
  (ref) => RequestCreateRepository(ref.watch(khApiProvider)),
);
