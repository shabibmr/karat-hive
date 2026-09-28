import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';

/// Wire values for `POST /v1/media/upload-intent` `purpose`.
/// Named to avoid colliding with `kh_domain`'s `MediaPurpose`.
enum MediaUploadPurpose {
  kycDocument('KYC_DOCUMENT'),
  requestImage('REQUEST_IMAGE'),
  offerImage('OFFER_IMAGE'),
  vendorLogo('VENDOR_LOGO');

  const MediaUploadPurpose(this.wire);
  final String wire;
}

/// Shared upload pipeline: intent → PUT bytes → complete → poll `READY`.
///
/// Pass `awaitReady: false` to return as soon as the server has accepted the
/// bytes (`PENDING_PROCESSING`) — the caller then owns waiting for `READY`,
/// e.g. Request publish retrying on `MEDIA_NOT_READY`.
class MediaUploader {
  MediaUploader(
    this._api, {
    Dio? putClient,
    this.pollInterval = const Duration(seconds: 2),
    this.maxPolls = 30,
    Future<void> Function(Duration duration)? sleep,
  })  : _putClient = putClient,
        _sleep = sleep ?? Future<void>.delayed;

  final KhApi _api;
  final Dio? _putClient;
  final Duration pollInterval;
  final int maxPolls;
  final Future<void> Function(Duration duration) _sleep;

  Dio? _defaultPutClient;
  Dio get _dio =>
      _putClient ??
      (_defaultPutClient ??= Dio(
        BaseOptions(
          validateStatus: (_) => true,
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(minutes: 2),
        ),
      ));

  /// Requests an upload intent ahead of picking a file, so the network
  /// round-trip overlaps with on-device work instead of happening after it.
  /// `byteSize` may be a declared ceiling (e.g. the purpose's `maxBytes`)
  /// rather than the true final size — the backend accepts any upload at or
  /// under what was declared.
  Future<Result<UploadIntent>> prefetchIntent({
    required MediaUploadPurpose purpose,
    required String contentType,
    required int byteSize,
  }) =>
      _api.uploadIntent(
        purpose: purpose.wire,
        contentType: contentType,
        byteSize: byteSize,
      );

  /// Returns the media key on success. If [prefetchedIntent] is supplied and
  /// still fits the real file (matching content type, declared size at least
  /// the real byte size), it's reused instead of requesting a fresh intent.
  Future<Result<String>> upload(
    File file, {
    required MediaUploadPurpose purpose,
    required String contentType,
    void Function(double progress)? onProgress,
    UploadIntent? prefetchedIntent,
    bool awaitReady = true,
  }) async {
    final bytes = await file.readAsBytes();
    return uploadBytes(
      Uint8List.fromList(bytes),
      purpose: purpose,
      contentType: contentType,
      onProgress: onProgress,
      prefetchedIntent: prefetchedIntent,
      awaitReady: awaitReady,
    );
  }

  /// Web-safe upload path — [FilePicker] on web has no filesystem path.
  Future<Result<String>> uploadBytes(
    Uint8List bytes, {
    required MediaUploadPurpose purpose,
    required String contentType,
    void Function(double progress)? onProgress,
    UploadIntent? prefetchedIntent,
    bool awaitReady = true,
  }) async {
    final length = bytes.length;
    final perf = PerfLog(
      'media.upload',
      context: {'purpose': purpose.wire, 'bytes': length},
    );
    final canReusePrefetched =
        prefetchedIntent != null && prefetchedIntent.maxBytes >= length;
    final Result<UploadIntent> intent = canReusePrefetched
        ? Ok(prefetchedIntent)
        : await _api.uploadIntent(
            purpose: purpose.wire,
            contentType: contentType,
            byteSize: length,
          );
    perf.lap(canReusePrefetched ? 'intent(prefetched)' : 'intent');
    return intent.when(
      ok: (i) async {
        final Response<dynamic> res;
        try {
          res = await _dio.put<dynamic>(
            i.uploadUrl,
            data: bytes,
            options: Options(
              headers: {
                ...i.requiredHeaders,
                if (!kIsWeb) 'content-length': length,
              },
              contentType: contentType,
            ),
            onSendProgress: length == 0
                ? null
                : (sent, total) {
                    final t = total > 0 ? total : length;
                    onProgress?.call((sent / t).clamp(0, 1));
                  },
          );
        } on DioException catch (e) {
          perf.done(extra: {'outcome': 'put-error'});
          return Err<String>(ServerFailure(message: e.message ?? 'Upload failed. Try again.'));
        } catch (e) {
          perf.done(extra: {'outcome': 'put-error'});
          return Err<String>(ServerFailure(message: e.toString()));
        }
        perf.lap('put');
        if ((res.statusCode ?? 0) >= 300) {
          perf.done(extra: {'outcome': 'put-failed', 'status': res.statusCode});
          return const Err<String>(ServerFailure(message: 'Upload failed. Try again.'));
        }
        onProgress?.call(1);
        final done = await _api.completeUpload(i.key);
        perf.lap('complete');
        final fail = done.failureOrNull;
        if (fail != null) {
          perf.done(extra: {'outcome': 'complete-error'});
          return Err<String>(fail);
        }
        var currentState = done.valueOrNull;
        var polls = 0;
        if (awaitReady && currentState != 'READY') {
          for (var n = 0; n < maxPolls; n++) {
            polls++;
            await _sleep(pollInterval);
            final again = await _api.completeUpload(i.key);
            final againFail = again.failureOrNull;
            if (againFail != null) {
              perf.done(extra: {'outcome': 'poll-error', 'polls': polls});
              return Err<String>(againFail);
            }
            currentState = again.valueOrNull;
            if (currentState == 'READY') break;
            if (currentState == 'QUARANTINED') {
              perf.done(extra: {'outcome': 'quarantined', 'polls': polls});
              return const Err<String>(
                ValidationFailure(
                  code: 'MEDIA_QUARANTINED',
                  message: 'That file failed a safety check and cannot be used.',
                ),
              );
            }
          }
          perf.lap('poll');
        }
        perf.done(extra: {'outcome': 'ready', 'polls': polls});
        return Ok<String>(i.key);
      },
      err: (f) {
        perf.done(extra: {'outcome': 'intent-error'});
        return Err<String>(f);
      },
    );
  }
}
