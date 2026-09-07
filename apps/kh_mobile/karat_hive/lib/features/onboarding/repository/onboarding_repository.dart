import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';
import '../../../core/media/media_uploader.dart';

class OnboardingRepository {
  OnboardingRepository(this._api, {MediaUploader? media})
      : _media = media ?? MediaUploader(_api);
  final KhApi _api;
  final MediaUploader _media;

  Future<Result<List<TaxonomyNode>>> categories() => _api.categories();
  Future<Result<List<TaxonomyNode>>> regions() => _api.regions();
  Future<Result<VendorMe>> vendorMe() => _api.vendorMe();
  Future<Result<List<VendorDocument>>> documents() => _api.documents();
  Future<Result<VendorDashboard>> dashboard() => _api.dashboard();
  Future<Result<VendorMe>> setCategories(List<String> ids) => _api.setCategories(ids);
  Future<Result<VendorMe>> setRegions(List<String> ids) => _api.setRegions(ids);
  Future<Result<VendorMe>> setAvailability({required bool awayMode}) =>
      _api.setAvailability(awayMode: awayMode);
  Future<Result<VendorMe>> resubmit() => _api.resubmit();

  /// intent → PUT bytes → complete. Returns the media key on success.
  Future<Result<String>> uploadKycDocument(
    File file,
    String contentType, {
    void Function(double progress)? onProgress,
  }) =>
      _media.upload(
        file,
        purpose: MediaUploadPurpose.kycDocument,
        contentType: contentType,
        onProgress: onProgress,
      );

  Future<Result<List<VendorDocument>>> attachDocument({
    required VendorDocumentType type,
    required String mediaKey,
  }) =>
      _api.attachDocument(documentType: type.wire, mediaKey: mediaKey);
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
