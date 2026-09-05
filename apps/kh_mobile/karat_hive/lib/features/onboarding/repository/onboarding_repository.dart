import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

class OnboardingRepository {
  OnboardingRepository(this._api);
  final KhApi _api;

  Future<Result<List<TaxonomyNode>>> categories() => _api.categories();
  Future<Result<List<TaxonomyNode>>> regions() => _api.regions();
  Future<Result<VendorMe>> vendorMe() => _api.vendorMe();
  Future<Result<List<VendorDocument>>> documents() => _api.documents();
  Future<Result<VendorDashboard>> dashboard() => _api.dashboard();
  Future<Result<VendorMe>> setCategories(List<String> ids) => _api.setCategories(ids);
  Future<Result<VendorMe>> setRegions(List<String> ids) => _api.setRegions(ids);
  Future<Result<VendorMe>> resubmit() => _api.resubmit();

  /// intent → PUT bytes → complete. Returns the media key on success.
  Future<Result<String>> uploadKycDocument(File file, String contentType) async {
    final length = await file.length();
    final intent = await _api.uploadIntent(
      purpose: 'KYC_DOCUMENT',
      contentType: contentType,
      byteSize: length,
    );
    return intent.when(
      ok: (i) async {
        final bytes = await file.readAsBytes();
        final res = await _api.client.dio.put<dynamic>(
          i.uploadUrl,
          data: Stream.fromIterable([bytes]),
          options: Options(
            headers: {...i.requiredHeaders, 'content-length': length},
            contentType: contentType,
          ),
        );
        if ((res.statusCode ?? 0) >= 300) {
          return const Err<String>(ServerFailure(message: 'Upload failed. Try again.'));
        }
        final done = await _api.completeUpload(i.key);
        return done.when(
          ok: (_) => Ok<String>(i.key),
          err: Err<String>.new,
        );
      },
      err: Err<String>.new,
    );
  }

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
