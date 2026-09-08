import 'dart:io';

import 'package:dio/dio.dart';
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
/// never see JSON. Uses [KhApi.client.send] until CM-S07 lands typed methods.
class RequestCreateRepository {
  RequestCreateRepository(this._api, {MediaUploader? media})
      : _media = media ?? MediaUploader(_api);

  final KhApi _api;
  final MediaUploader _media;

  KhApiClient get _client => _api.client;

  Future<Result<PlatformConfig>> platformConfig() =>
      _api.platformConfig.getConfig();

  Future<Result<GoldRateSnapshot>> goldRates() => _api.goldRates();

  Future<Result<List<TaxonomyNode>>> categories() => _api.categories();

  Future<Result<List<TaxonomyNode>>> regions() => _api.regions();

  Future<Result<MeUser>> me() => _api.me();

  Future<Result<DraftSaveResult>> createDraft(Map<String, dynamic> body) async {
    final r = await _client.send(
      'POST',
      '/v1/requests',
      body: body,
      unwrapData: false,
    );
    return r.when(ok: _mapDraftSave, err: Err.new);
  }

  Future<Result<DraftSaveResult>> patchDraft(
    String id,
    Map<String, dynamic> body,
  ) async {
    final r = await _client.send(
      'PATCH',
      '/v1/requests/$id',
      body: body,
      unwrapData: false,
    );
    return r.when(ok: _mapDraftSave, err: Err.new);
  }

  Future<Result<RequestForCustomer>> getRequest(String id) async {
    final r = await _client.send('GET', '/v1/requests/$id');
    return r.when(
      ok: (d) => Ok(RequestForCustomer.fromJson(_asMap(d))),
      err: Err.new,
    );
  }

  /// Publish uses a caller-held idempotency key so OAuth bind + retry
  /// does not mint a second key (Architecture-Frontend §9.4).
  Future<Result<RequestForCustomer>> publish(
    String id, {
    required String idempotencyKey,
  }) async {
    try {
      final response = await _client.dio.request<dynamic>(
        '/v1/requests/$id/publish',
        options: Options(
          method: 'POST',
          headers: {'idempotency-key': idempotencyKey},
        ),
      );
      return _mapHttp(response);
    } on DioException catch (e) {
      return Err(_dioFailure(e));
    }
  }

  Future<Result<void>> bindOAuth({
    required String identityToken,
    String provider = 'GOOGLE',
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/auth/oauth/bind',
      body: {'provider': provider, 'identityToken': identityToken},
    );
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  Future<Result<void>> deleteMedia(String key) async {
    final r = await _client.send('DELETE', '/v1/media/$key');
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

  Result<RequestForCustomer> _mapHttp(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status >= 200 && status < 300) {
      Object? payload = data;
      if (data is Map && data.containsKey('data')) payload = data['data'];
      return Ok(RequestForCustomer.fromJson(_asMap(payload)));
    }
    return Err(_envelopeFailure(status, data));
  }

  Failure _dioFailure(DioException e) {
    if (e.response != null) {
      return _envelopeFailure(e.response!.statusCode ?? 500, e.response!.data);
    }
    return const NetworkFailure();
  }

  Failure _envelopeFailure(int status, dynamic data) {
    String? code;
    String? message;
    final fieldErrors = <String, String>{};
    if (data is Map && data['error'] is Map) {
      final err = data['error'] as Map;
      code = err['code'] as String?;
      message = err['message'] as String?;
      for (final d in (err['details'] as List? ?? const [])) {
        if (d is Map && d['path'] != null) {
          fieldErrors[d['path'].toString()] = (d['message'] ?? '').toString();
        }
      }
    }
    // GET/POST 503 for bullion is GOLD_RATE_UNAVAILABLE, not generic maintenance.
    if (status == 503) {
      return ServerFailure(
        code: code ?? 'GOLD_RATE_UNAVAILABLE',
        message: message ?? 'Gold rate unavailable. Try again shortly.',
      );
    }
    return switch (status) {
      401 => UnauthorisedFailure(code: code, message: message),
      403 => ForbiddenFailure(code: code, message: message),
      404 => NotFoundFailure(code: code, message: message),
      409 => ConflictFailure(code: code, message: message),
      422 || 400 => ValidationFailure(
          code: code,
          message: message,
          fieldErrors: fieldErrors,
        ),
      423 || 429 => RateLimitedFailure(code: code, message: message),
      _ => ServerFailure(code: code, message: message),
    };
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
