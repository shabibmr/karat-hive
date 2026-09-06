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
  Future<Result<VendorMe>> setAvailability({required bool awayMode}) =>
      _api.setAvailability(awayMode: awayMode);
  Future<Result<VendorMe>> resubmit() => _api.resubmit();

  /// intent → PUT bytes → complete. Returns the media key on success.
  Future<Result<String>> uploadKycDocument(
    File file,
    String contentType, {
    void Function(double progress)? onProgress,
  }) async {
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
          for (var n = 0; n < 15; n++) {
            await Future<void>.delayed(const Duration(seconds: 1));
            final again = await _api.completeUpload(i.key);
            if (again.valueOrNull == 'READY') break;
          }
        }
        return Ok<String>(i.key);
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
