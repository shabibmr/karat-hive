import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';

/// Wire values for `POST /v1/media/upload-intent` `purpose`.
enum MediaPurpose {
  kycDocument('KYC_DOCUMENT'),
  requestImage('REQUEST_IMAGE');

  const MediaPurpose(this.wire);
  final String wire;
}

/// Shared upload pipeline: intent → PUT bytes → complete → poll `READY`.
class MediaUploader {
  MediaUploader(
    this._api, {
    Dio? putClient,
    this.pollInterval = const Duration(seconds: 1),
    this.maxPolls = 15,
    Future<void> Function(Duration duration)? sleep,
  })  : _putClient = putClient,
        _sleep = sleep ?? Future<void>.delayed;

  final KhApi _api;
  final Dio? _putClient;
  final Duration pollInterval;
  final int maxPolls;
  final Future<void> Function(Duration duration) _sleep;

  Dio get _dio => _putClient ?? _api.client.dio;

  /// Returns the media key on success.
  Future<Result<String>> upload(
    File file, {
    required MediaPurpose purpose,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    final length = await file.length();
    final intent = await _api.uploadIntent(
      purpose: purpose.wire,
      contentType: contentType,
      byteSize: length,
    );
    return intent.when(
      ok: (i) async {
        final bytes = await file.readAsBytes();
        final res = await _dio.put<dynamic>(
          i.uploadUrl,
          data: Stream.fromIterable([bytes]),
          options: Options(
            headers: {...i.requiredHeaders, 'content-length': length},
            contentType: contentType,
          ),
          onSendProgress: length == 0
              ? null
              : (sent, total) {
                  final t = total > 0 ? total : length;
                  onProgress?.call((sent / t).clamp(0, 1));
                },
        );
        if ((res.statusCode ?? 0) >= 300) {
          return const Err<String>(ServerFailure(message: 'Upload failed. Try again.'));
        }
        onProgress?.call(1);
        final done = await _api.completeUpload(i.key);
        final fail = done.failureOrNull;
        if (fail != null) return Err<String>(fail);
        if (done.valueOrNull != 'READY') {
          for (var n = 0; n < maxPolls; n++) {
            await _sleep(pollInterval);
            final again = await _api.completeUpload(i.key);
            if (again.valueOrNull == 'READY') break;
          }
        }
        return Ok<String>(i.key);
      },
      err: Err<String>.new,
    );
  }
}
