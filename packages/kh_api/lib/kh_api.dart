library kh_api;

import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import 'src/dtos.dart';

export 'src/dtos.dart';

/// Typed facade over [KhApiClient]. DTOs are mapped to `kh_domain` types here so
/// generated shapes never reach controllers/presentation (Architecture-Frontend §9.1).
class KhApi {
  KhApi(this._client);
  final KhApiClient _client;

  KhApiClient get client => _client;

  // --- auth ---
  Future<Result<OtpChallenge>> otpRequest({
    required String mobileNumber,
    required String purpose,
  }) async {
    final r = await _client.send('POST', '/v1/auth/otp/request', body: {
      'mobileNumber': mobileNumber,
      'purpose': purpose,
    });
    return r.when(
      ok: (d) => Ok(OtpChallenge.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<OtpVerifyResult>> otpVerify({
    required String challengeId,
    required String code,
  }) async {
    final r = await _client.send('POST', '/v1/auth/otp/verify', body: {
      'challengeId': challengeId,
      'code': code,
    });
    return r.when(
      ok: (d) => Ok(OtpVerifyResult.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<SessionBundle>> registerVendor(Map<String, dynamic> body) async {
    final r = await _client.send('POST', '/v1/auth/register/vendor', body: body);
    return r.when(
      ok: (d) => Ok(SessionBundle.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<SessionBundle>> loginPassword({
    required String email,
    required String password,
  }) async {
    final r = await _client.send('POST', '/v1/auth/login/password',
        body: {'email': email, 'password': password});
    return r.when(
      ok: (d) => Ok(SessionBundle.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  static Future<SessionTokens?> refresh(
    KhApiClient client,
    String refreshToken,
  ) async {
    final r = await client.send('POST', '/v1/auth/refresh',
        body: {'refreshToken': refreshToken});
    return r.when(
      ok: (d) => SessionBundle.fromJson(d as Map<String, dynamic>).tokens,
      err: (_) => null,
    );
  }

  Future<void> logout(String? refreshToken) =>
      _client.send('POST', '/v1/auth/logout', body: {'refreshToken': refreshToken});

  // --- me ---
  Future<Result<MeUser>> me() async {
    final r = await _client.send('GET', '/v1/me');
    return r.when(
      ok: (d) => Ok(MeUser.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  // --- taxonomy ---
  Future<Result<List<TaxonomyNode>>> categories() => _taxonomy('/v1/categories');
  Future<Result<List<TaxonomyNode>>> regions() => _taxonomy('/v1/regions');

  Future<Result<List<TaxonomyNode>>> _taxonomy(String path) async {
    final r = await _client.send('GET', path);
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => TaxonomyNode.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }

  // --- vendor onboarding ---
  Future<Result<VendorMe>> vendorMe() => _vendorMe('GET', '/v1/me/vendor');

  Future<Result<List<VendorDocument>>> documents() async {
    final r = await _client.send('GET', '/v1/me/vendor/documents');
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => VendorDocument.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }

  Future<Result<List<VendorDocument>>> attachDocument({
    required String documentType,
    required String mediaKey,
    String? expiryDate,
  }) async {
    final r = await _client.send('POST', '/v1/me/vendor/documents', body: {
      'documentType': documentType,
      'mediaKey': mediaKey,
      if (expiryDate != null) 'expiryDate': expiryDate,
    });
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => VendorDocument.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }

  Future<Result<VendorMe>> setCategories(List<String> ids) =>
      _vendorMe('PUT', '/v1/me/vendor/categories', body: {'categoryIds': ids});

  Future<Result<VendorMe>> setRegions(List<String> ids) =>
      _vendorMe('PUT', '/v1/me/vendor/regions', body: {'regionIds': ids});

  Future<Result<VendorMe>> setAvailability({bool? awayMode, Object? businessHours}) =>
      _vendorMe('PATCH', '/v1/me/vendor/availability', body: {
        if (awayMode != null) 'awayMode': awayMode,
        if (businessHours != null) 'businessHours': businessHours,
      });

  Future<Result<VendorMe>> resubmit() =>
      _vendorMe('POST', '/v1/me/vendor/resubmit');

  Future<Result<VendorMe>> _vendorMe(
    String method,
    String path, {
    Object? body,
  }) async {
    final r = await _client.send(method, path, body: body);
    return r.when(
      ok: (d) => Ok(VendorMe.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<VendorDashboard>> dashboard() async {
    final r = await _client.send('GET', '/v1/me/dashboard');
    return r.when(
      ok: (d) => Ok(VendorDashboard.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  // --- media ---
  Future<Result<UploadIntent>> uploadIntent({
    required String purpose,
    required String contentType,
    required int byteSize,
  }) async {
    final r = await _client.send('POST', '/v1/media/upload-intent', body: {
      'purpose': purpose,
      'contentType': contentType,
      'byteSize': byteSize,
    });
    return r.when(
      ok: (d) => Ok(UploadIntent.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<String>> completeUpload(String key) async {
    final r = await _client.send('POST', '/v1/media/$key/complete');
    return r.when(
      ok: (d) => Ok((d as Map<String, dynamic>)['state'] as String? ?? 'READY'),
      err: Err.new,
    );
  }
}
