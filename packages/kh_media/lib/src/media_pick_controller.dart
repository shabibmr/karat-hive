import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';

import 'image_converter.dart';
import 'media_asset.dart';
import 'media_uploader.dart';
import 'pending_upload_cache.dart';

/// Per-purpose upload ceilings mirrored from the backend's `media-rules.ts`
/// `MEDIA_CONSTRAINTS`, used only to size a prefetched intent before the
/// real (post-conversion) file size is known. The backend independently
/// enforces the same ceiling regardless of what the client declares here.
const Map<MediaUploadPurpose, int> mediaPurposeMaxBytes = {
  MediaUploadPurpose.kycDocument: 10 * 1024 * 1024,
  MediaUploadPurpose.requestImage: 5 * 1024 * 1024,
  MediaUploadPurpose.offerImage: 5 * 1024 * 1024,
};

/// The content type a prefetched intent is speculatively requested for.
/// KYC's dominant case is a PDF; the two pure-image purposes always convert
/// to AVIF on pick.
String _speculativeContentType(MediaUploadPurpose purpose) =>
    purpose == MediaUploadPurpose.kycDocument ? 'application/pdf' : 'image/avif';

/// Orchestrates prefetch → pick → (image) convert-to-AVIF → cache → upload
/// → retry for one upload purpose (e.g. KYC documents, or offer/request
/// images). One instance per screen; each operation is addressed by a
/// caller-chosen `correlationId` (e.g. a document type, or a per-image slot
/// key) so a screen with several independent upload slots — like Request
/// Create's multi-image step — can retry one slot without touching another.
class MediaPickController {
  MediaPickController({
    required MediaUploader uploader,
    required MediaUploadPurpose purpose,
    ImageConverter? imageConverter,
    PendingUploadCache? cache,
    ImagePicker? imagePicker,
  })  : _uploader = uploader,
        _purpose = purpose,
        _imageConverter = imageConverter ?? const AvifImageConverter(),
        _cache = cache ?? PendingUploadCache(),
        _imagePicker = imagePicker ?? ImagePicker();

  final MediaUploader _uploader;
  final MediaUploadPurpose _purpose;
  final ImageConverter _imageConverter;
  final PendingUploadCache _cache;
  final ImagePicker _imagePicker;

  UploadIntent? _prefetchedIntent;
  bool _prefetching = false;

  bool get hasPrefetchedIntent => _prefetchedIntent != null;

  /// Idempotent — safe to call repeatedly (e.g. from `initState` /
  /// `build()`); only the first call issues a network request. One
  /// prefetched intent is shared across whichever slot uploads first.
  Future<void> prefetchIntent() async {
    if (_prefetchedIntent != null || _prefetching) return;
    _prefetching = true;
    try {
      final result = await _uploader.prefetchIntent(
        purpose: _purpose,
        contentType: _speculativeContentType(_purpose),
        byteSize: mediaPurposeMaxBytes[_purpose]!,
      );
      _prefetchedIntent = result.valueOrNull;
    } finally {
      _prefetching = false;
    }
  }

  /// Picks an image (camera/gallery), converts it to AVIF, caches the
  /// converted file under [correlationId], and uploads it. Returns `null`
  /// if the user cancelled the picker.
  Future<Result<String>?> pickImageConvertAndUpload({
    required String correlationId,
    required ImageSource source,
    void Function(double progress)? onProgress,
  }) async {
    final picked = await _imagePicker.pickImage(source: source);
    if (picked == null) return null;
    return convertAndUpload(File(picked.path), correlationId: correlationId, onProgress: onProgress);
  }

  /// Converts an already-picked image file to AVIF, caches it under
  /// [correlationId], and uploads.
  Future<Result<String>> convertAndUpload(
    File file, {
    required String correlationId,
    void Function(double progress)? onProgress,
  }) async {
    final asset = await _imageConverter.convertToAvif(file);
    await _cache.put(correlationId, asset);
    return _upload(asset, correlationId: correlationId, onProgress: onProgress);
  }

  /// Uploads an already-picked file as-is, with no on-device conversion —
  /// used for non-image documents (e.g. KYC PDFs).
  Future<Result<String>> uploadRaw(
    File file,
    String contentType, {
    required String correlationId,
    void Function(double progress)? onProgress,
  }) =>
      _upload(
        MediaAsset(file: file, contentType: contentType, byteSize: 0),
        correlationId: correlationId,
        onProgress: onProgress,
      );

  /// Re-runs the upload against the cached, already-converted file for
  /// [correlationId], without re-picking or re-converting. Returns `null`
  /// if nothing is cached for that slot (e.g. the app was reinstalled, or
  /// nothing was ever picked).
  Future<Result<String>?> retry(
    String correlationId, {
    void Function(double progress)? onProgress,
  }) async {
    final cached = await _cache.get(correlationId);
    if (cached == null) return null;
    return _upload(cached, correlationId: correlationId, onProgress: onProgress);
  }

  Future<Result<String>> _upload(
    MediaAsset asset, {
    required String correlationId,
    void Function(double progress)? onProgress,
  }) async {
    final prefetched = _prefetchedIntent;
    final reusable = prefetched != null &&
            asset.contentType == _speculativeContentType(_purpose)
        ? prefetched
        : null;
    // Consumed either way: a stale/mismatched intent shouldn't be retried later.
    _prefetchedIntent = null;
    final result = await _uploader.upload(
      asset.file,
      purpose: _purpose,
      contentType: asset.contentType,
      onProgress: onProgress,
      prefetchedIntent: reusable,
    );
    if (result.isOk) await _cache.evict(correlationId);
    return result;
  }
}
