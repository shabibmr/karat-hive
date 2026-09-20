import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_media/kh_media.dart';

import '../../../app/di.dart';

class OnboardingRepository {
  OnboardingRepository(this._api, {MediaPickController? media})
      : _media = media ??
            MediaPickController(
              uploader: MediaUploader(_api),
              purpose: MediaUploadPurpose.kycDocument,
            );
  final KhApi _api;
  final MediaPickController _media;

  Future<Result<List<TaxonomyNode>>> categories() => _api.categories();
  Future<Result<List<TaxonomyNode>>> regions() => _api.regions();
  Future<Result<VendorMe>> vendorMe() => _api.vendorMe();
  Future<Result<List<VendorDocument>>> documents() => _api.documents();
  Future<Result<VendorDashboard>> dashboard() => _api.dashboard();
  Future<Result<VendorMe>> resubmit() => _api.resubmit();

  /// Warms the upload-intent ahead of the vendor picking a document (called
  /// from the screen's `initState`). Idempotent.
  Future<void> prefetchKycDocumentIntent() => _media.prefetchIntent();

  /// intent → PUT bytes → complete. Returns the media key on success.
  /// Images (jpeg/png) are converted to AVIF on-device first; other types
  /// (PDFs) upload unmodified — PDF compression is a later pass. Cached
  /// under [type] so each document slot can retry independently.
  Future<Result<String>> uploadKycDocument(
    VendorDocumentType type,
    File file,
    String contentType, {
    void Function(double progress)? onProgress,
  }) =>
      contentType.startsWith('image/')
          ? _media.convertAndUpload(file, correlationId: type.wire, onProgress: onProgress)
          : _media.uploadRaw(file, contentType, correlationId: type.wire, onProgress: onProgress);

  Future<Result<String>> uploadKycDocumentBytes(
    VendorDocumentType type,
    Uint8List bytes,
    String contentType, {
    void Function(double progress)? onProgress,
  }) =>
      contentType.startsWith('image/')
          ? _media.convertBytesAndUpload(
              bytes,
              correlationId: type.wire,
              onProgress: onProgress,
            )
          : _media.uploadRawBytes(
              bytes,
              contentType,
              correlationId: type.wire,
              onProgress: onProgress,
            );

  Future<Result<List<VendorDocument>>> attachDocument({
    required VendorDocumentType type,
    required String mediaKey,
    String? expiryDate,
  }) =>
      _api.attachDocument(
        documentType: type.wire,
        mediaKey: mediaKey,
        expiryDate: expiryDate,
      );

  Future<Result<VendorMe>> patchKycProfile({
    required String legalBusinessName,
    required String tradeLicenceNumber,
    required String licenceExpiryDate,
  }) =>
      _api.patchVendorProfile(
        legalBusinessName: legalBusinessName,
        tradeLicenceNumber: tradeLicenceNumber,
        licenceExpiryDate: licenceExpiryDate,
      );
}

final onboardingRepositoryProvider =
    Provider<OnboardingRepository>((ref) => OnboardingRepository(ref.watch(khApiProvider)));

final categoriesProvider = FutureProvider<List<TaxonomyNode>>((ref) async {
  final r = await ref.watch(onboardingRepositoryProvider).categories();
  return r.when(ok: (v) => v, err: (f) => throw f);
});

final regionsProvider = FutureProvider<List<TaxonomyNode>>((ref) async {
  final r = await ref.watch(onboardingRepositoryProvider).regions();
  return r.when(ok: (v) => v, err: (f) => throw f);
});
